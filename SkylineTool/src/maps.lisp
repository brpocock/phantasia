(in-package :skyline-tool)

(defclass level ()
  ((decals :accessor level-decals :initarg :decals)
   (grid :accessor level-grid :initarg :grid)
   (objects :accessor level-objects :initarg :objects)
   (name :reader level-name :initarg :name)))

(defvar *screen-ticker* 0)

(defclass grid/tia ()
  ((tiles :reader grid-tiles :initarg :tiles)
   (colors :reader grid-row-colors :initarg :colors)
   (background-color :reader grid-background-color :initarg :background-color)
   (id :reader grid-id :initform (incf *screen-ticker*))))

(defgeneric list-grid-row-colors (grid))
(defgeneric list-grid-tiles (grid))

(defmethod list-grid-row-colors ((grid grid/tia))
  (coerce (grid-row-colors grid) 'list))

(defun list-grid-row-palette-colors (grid)
  (mapcar (curry #'apply #'rgb->palette)
          (apply #'concatenate 'list (list-grid-row-colors grid))))

(defmethod list-grid-tiles ((grid grid/tia))
  (let (list
        (tiles (grid-tiles grid)))
    (dotimes (y 8)
      (dotimes (x 4)
        (push (aref tiles x y) list)))
    (nreverse list)))

(defun assocdr (key alist &optional (errorp t))
  (or (second (assoc key alist :test #'equalp))
      (when errorp 
        (error "Could not find ~a in ~s" key alist))))

(defun pin (n min max)
  (min max (max min n)))

(defun parse-tile-animation-sets (tileset)
  (let ((animations (list)))
    (dolist (tile-data (cddr tileset))
      (when (equal "tile" (car tile-data))
        (let ((tile-id (parse-integer (assocdr "id" (second tile-data)))))
          (dolist (animation (cddr tile-data))
            (when (equal "animation" (car animation))
              (let ((sequence (list)))
                (dolist (frame (cddr animation))
                  (assert (equal "frame" (car frame)))
                  (let ((frame-tile (parse-integer (assocdr "tileid" (second frame))))
                        (duration (/ (parse-integer (assocdr "duration" (second frame)))
                                     1000 1/60)))
                    (push frame-tile sequence)
                    (push duration sequence)))
                (push (list tile-id (reverse sequence)) animations)))))))
    animations))

(defun split-into-bytes (tile-collision-bitmap)
  (let ((width (array-dimension tile-collision-bitmap 0))
        (bytes (list)))
    (dotimes (y (array-dimension tile-collision-bitmap 1))
      (dotimes (byte (floor width 8))
        (let ((value 0))
          (dotimes (bit 8)
            (let ((x (+ bit (* 8 byte))))
              (when (< x width)
                (when (plusp (aref tile-collision-bitmap x y))
                  (setf value (logior value (ash 1 bit)))))))
          (push value bytes))))
    (reverse bytes)))

(defun 32-bit-word (bytes)
  (logior (elt bytes 0)
          (ash (elt bytes 1) 8)
          (ash (elt bytes 2) 16)
          (ash (elt bytes 3) 24)))

(defun bytes-to-32-bits (bytes)
  (loop for i from 0 by 4 below (length bytes)
        collecting (32-bit-word (subseq bytes i (+ i 4)))))

(defun split-grid-to-rows (width height words)
  (let ((output (make-array (list width height) :element-type 'integer))
        (i 0))
    (dotimes (y height)
      (dotimes (x width)
        (setf (aref output x y) (elt words i))
        (incf i)))
    output))

(defun parse-layer (layer)
  (let ((data (xml-match "data" layer)))
    (assert data)
    (assert (equal "base64" (assocdr "encoding" (second data))))
    (assert (stringp (third data)))
    (let* ((width (parse-integer (assocdr "width" (second layer))))
           (height (parse-integer (assocdr "height" (second layer)))))
      (split-grid-to-rows width height
                          (bytes-to-32-bits
                           (cl-base64:base64-string-to-usb8-array (third data)))))))

(defun find-tile-by-number (number tileset)
  (let ((id (- number (tileset-gid tileset))))
    (if (< id 128)
        (values id 
                (apply #'vector (loop for b below 6
                                      collect (aref (tile-attributes tileset) id b))))
        (values 0 #(0 0 0 0 0 0)))))

(defun assign-attributes (attr attr-table)
  (or (position-if (lambda (attribute) (equalp attr attribute)) attr-table)
      (progn (setf (cdr (last attr-table)) (cons attr nil))
             (1- (length attr-table)))))

(defun object-covers-tile-p (x y object)
  (or (and (find-if (lambda (el) (equal "point" (car el)))
                    (subseq object 2))
           (<= (* x 8) (parse-number (assocdr "x" (second object))) (1- (* (1+ x) 8)))
           (<= (* y 16) (parse-number (assocdr "y" (second object))) (1- (* (1+ y) 16))))))

(defun find-effective-attributes (tileset x y objects attributes exits)
  (declare (ignore tileset))
  (let ((effective-objects (remove-if-not (lambda (el)
                                            (and (equal "object" (car el))
                                                 (object-covers-tile-p x y el)))
                                          (subseq objects 2))))
    (dolist (object effective-objects)
      (add-attribute-values nil object attributes exits))))

(defun add-alt-tile-attributes (tile-attributes alt-tile-attributes)
  (let ((wall-bits (logand #x0f (aref alt-tile-attributes 0))))
    (setf (aref tile-attributes 0) (logior (ash wall-bits 4) (aref tile-attributes 0))
          (aref tile-attributes 1) (logior #x01 (aref tile-attributes 1)))))

(defun mark-palette-transitions (grid attributes-table)
  (dotimes (y (array-dimension grid 1))
    (dotimes (x (array-dimension grid 0))
      (if (zerop x)
          (setf (aref grid x y 0) (logior #x80 (aref grid x y 0)))
          (let ((palette-left (tile-effective-palette grid (1- x) y attributes-table))
                (palette-self (tile-effective-palette grid x y attributes-table)))
            (unless (= palette-left palette-self)
              (setf (aref grid x y 0) (logior #x80 (aref grid x y 0)))))))))

(defun properties->plist (properties.xml)
  (loop for (property alist) in (cddr properties.xml)
        for name = (cadr (assoc "name" alist :test #'equal))
        for value = (cadr (assoc "value" alist :test #'equal))
        appending (list (make-keyword (string-upcase name)) value)))

(defun get-text-reference (text texts)
  (let ((index (or (position text texts :test #'equal :key #'unicode->minifont)
                   (and (appendf texts (list text))
                        (1- (length texts))))))
    (check-type index (integer 0 (#x100)))
    index))

(defun collect-decal-object (object texts)
  (let ((x (floor (parse-integer (assocdr "x" (second object))) 8))
        (y (floor (parse-integer (assocdr "y" (second object))) 16))
        (name (or (assocdr "name" (second object) nil) "(Unnamed object)")))
    (when-let (gid$ (assocdr "gid" (second object) nil))
      (let ((gid (mod (parse-integer gid$) 128))
            (type (or (assocdr "type" (second object) nil) "rug"))
            (decal-props
              (reduce #'logior
                      (remove-if #'null
                                 (list
                                  (when-let (text (assocdr "text" (second object) nil))
                                    (logior (ash 1 30)
                                            (get-text-reference text texts)))
                                  (when-let (script (assocdr "script" (second object) nil))
                                    (logior (ash 1 31)
                                            (get-text-reference script texts))))))))
        (format *trace-output* "~& ???~a??? @(~d, ~d)" name x y) 
        (return-from collect-decal-object (list x y gid decal-props))))))

(defun parse-tile-grid (layers objects tileset)
  (let* ((ground (parse-layer (first layers)))
         (detail (and (= 2 (length layers))
                      (parse-layer (second layers))))
         (output (make-array (list (array-dimension ground 0)
                                   (array-dimension ground 1)
                                   2)
                             :element-type 'integer))
         (attributes-table (list #(0 0 0 0 0 0)))
         (exits-table (cons nil nil))
         (decals-table (cons nil nil))
         (texts (cons nil nil)))
    (dotimes (y (array-dimension ground 1))
      (dotimes (x (array-dimension ground 0))
        (let* ((detailp (and detail (> (aref detail x y) 0)))
               (tile-number (if detailp
                                (aref detail x y)
                                (aref ground x y))))
          (multiple-value-bind (tile-id tile-attributes) (find-tile-by-number tile-number tileset)
            (when detailp
              (multiple-value-bind (alt-tile-id alt-tile-attributes)
                  (find-tile-by-number (aref ground x y) tileset)
                (setf (aref tile-attributes 5) alt-tile-id)
                (add-alt-tile-attributes tile-attributes alt-tile-attributes)))
            (find-effective-attributes tileset x y objects tile-attributes exits-table)
            (setf (aref output x y 0) tile-id
                  (aref output x y 1) (assign-attributes tile-attributes
                                                         attributes-table))))))
    (loop for object in objects
          do (when-let (decal (collect-decal-object object texts))
               (appendf decals-table (list decal))))
    (mark-palette-transitions output attributes-table)
    (values output attributes-table (rest decals-table) (rest exits-table) (rest texts))))

(defun map-layer-depth (layer.xml)
  (when (and (<= 3 (length layer.xml))
             (equal "properties" (car (third layer.xml))))
    (loop for prop in (subseq (third layer.xml) 2)
          when (and (equal "property" (car prop))
                    (equalp "ground" (assocdr "name" (second prop)))
                    (or (equalp "true" (assocdr "value" (second prop)))
                        (equalp "t" (assocdr "value" (second prop)))))
            return 0
          when (and (equal "property" (car prop))
                    (equalp "detail" (assocdr "name" (second prop)))
                    (or (equalp "true" (assocdr "value" (second prop)))
                        (equalp "t" (assocdr "value" (second prop)))))
            return 1)))

(defclass tileset ()
  ((gid :initarg :gid :reader tileset-gid)
   (pathname :initarg :pathname :reader tileset-pathname)
   (image :initarg :image :accessor tileset-image)
   (tile-attributes :accessor tile-attributes
                    :initform (make-array (list 128 6) :element-type '(unsigned-byte 8)))))

(defun load-tileset-image (pathname$)
  (format *trace-output* "~&Loading tileset image from ~a" pathname$)
  (let* ((png (png-read:read-png-file 
               (let ((pathname (parse-namestring pathname$))) 
                 (make-pathname 
                  :name (pathname-name pathname)
                  :type (pathname-type pathname)
                  :defaults #p"./Source/Maps/"))))
         (height (png-read:height png))
         (width (png-read:width png))
         (?? (png-read:transparency png))
         (*machine* 7800))
    (png->palette height width
                  (png-read:image-data png)
                  ??)))

(defun extract-8??16-tiles (image)
  (let ((output (list)))
    (dotimes (row (/ (1- (array-dimension image 1)) 16))
      (dotimes (column (/ (array-dimension image 0) 8))
        (let ((tile (extract-region image (* column 8) (* row 16) (+ (* column 8) 7) (+ (* row 16) 15))))
          (assert (= 8 (array-dimension tile 0)))
          (assert (= 16 (array-dimension tile 1)))
          (push tile output))))
    (format *trace-output* "??? found ~d tile~:p in ~d??~d image"
            (length output) (array-dimension image 0) (array-dimension image 1))
    (reverse output)))

(defun extract-palettes (image)
  (let* ((last-row (1- (array-dimension image 1)))
         (palette-strip (extract-region image 0 last-row 25 last-row))
         (palettes (make-array (list 8 4) :element-type '(unsigned-byte 8))))
    (dotimes (p 8)
      (setf (aref palettes p 0) (aref palette-strip 0 0))
      (dotimes (c 3)
        (setf (aref palettes p (1+ c)) (aref palette-strip (+ 1 c (* p 3)) 0))))
    palettes))

(defun all-colors-in-tile (tile)
  (remove-duplicates (loop for y below 16 
                           append
                           (loop for x below 8
                                 collect (aref tile x y)))
                     :test #'=))

(defun tile-fits-palette-p (tile palette)
  (every (lambda (c) (member c palette))
         (all-colors-in-tile tile)))

(defun 2a-to-list (2a)
  (loop for row from 0 below (array-dimension 2a 0)
        collecting (loop 
                     with output = (make-array (list (array-dimension 2a 1)))
                     for column from 0 below (array-dimension 2a 1)
                     do (setf (aref output column) (aref 2a row column))
                     finally (return output))))

(defun best-palette (tile palettes)
  (position-if (lambda (palette)
                 (tile-fits-palette-p tile palette))
               (mapcar (lambda (p) (coerce p 'list)) (2a-to-list palettes))))

(defun split-images-to-palettes (image)
  (let ((tiles (extract-8??16-tiles image))
        (palettes (extract-palettes image))
        (output (make-array '(128) :element-type '(unsigned-byte 3))))
    (dotimes (i (length tiles))
      (setf (aref output i) (or (best-palette (elt tiles i) palettes)
                                (error "Tile ~d does not match any palette~%~s~2%~s"
                                       i (elt tiles i) palettes))))
    #+ (or) (format *trace-output* "~&Palettes for all tiles: ~s" output)
    output))

(defun tile-property-value (key tile.xml)
  (dolist (info (cddr tile.xml))
    (when (and (equal "properties" (car info)))
      (dolist (prop (cddr info))
        (when (and (equal "property" (car prop))
                   (equalp key (assocdr "name" (second prop))))
          (when-let (value (assocdr "value" (second prop)))
            (return-from tile-property-value
              (let ((value (string-trim #(#\Space) value)))
                (cond ((or (equalp "true" value)
                           (equalp "t" value)
                           (equalp "on" value))
                       t)
                      ((or (equalp "false" value)
                           (equalp "f" value)
                           (equalp "off" value))
                       :off)
                      (t value))))))))))

(defun tile-collision-p (tile.xml test-x test-y)
  (unless (and tile.xml (< 1 (length tile.xml)))
    (return-from tile-collision-p nil))
  (dolist (object-group (xml-matches "objectgroup" tile.xml))
    (let ((objects (when (and object-group (< 1 (length object-group)))
                     (remove-if (lambda (el)
                                  (or (not (equal "object" (car el)))
                                      (when-let (type-name (assocdr "type" (second el) nil))
                                        (not (equalp "Wall" type-name)))))
                                (subseq object-group 2)))))
      (dolist (object objects) 
        (let ((height (parse-number (assocdr "height" (second object))))
              (width (parse-number (assocdr "width" (second object))))
              (object-x (parse-number (assocdr "x" (second object))))
              (object-y (parse-number (assocdr "y" (second object)))))
          (when (and (<= object-x test-x (+ object-x width))
                     (<= object-y test-y (+ object-y height)))
            (return-from tile-collision-p t))))))
  nil)

(defun load-other-map (locale)
  (xmls:parse-to-list (alexandria:read-file-into-string 
                       (make-pathname :name locale
                                      :type "tmx"
                                      :defaults #p"./Source/Maps/"))))

(defun find-locale-id-from-xml (xml)
  (let ((id-prop (find-if (lambda (el) 
                            (some (lambda (kv)
                                    (destructuring-bind (key value) kv
                                      (and (equal key "name") (equalp value "id")))) 
                                  (second el)))
                          (xml-matches "property" (xml-match "properties" xml nil)))))
    (assert id-prop (id-prop) "Cannot find an ID property from map data")
    (parse-integer (second (find-if (lambda (kv)
                                      (destructuring-bind (key value) kv
                                        (declare (ignore value))
                                        (equal key "value")))
                                    (second id-prop))))))

(defun find-entrance-by-name (xml name locale-name)
  (let ((locale-id (find-locale-id-from-xml xml)))
    (dolist (group (xml-matches "objectgroup" xml))
      (dolist (object (xml-matches "object" group))
        (when-let (properties (xml-match "properties" object nil))
          (dolist (prop (xml-matches "property" properties))
            (when (and (find-if (lambda (kv) (destructuring-bind (key value) kv
                                               (and (equalp key "value")
                                                    (equalp value name))))
                                (second prop))
                       (find-if (lambda (kv) (destructuring-bind (key value) kv
                                               (and (equalp key "name")
                                                    (equalp value "Entrance"))))
                                (second prop)))
              (let ((x (parse-integer (second (find-if (lambda (kv)
                                                         (destructuring-bind (key value) kv
                                                           (declare (ignore value))
                                                           (equalp key "x"))) 
                                                       (second object)))))
                    (y (parse-integer (second (find-if (lambda (kv)
                                                         (destructuring-bind (key value) kv
                                                           (declare (ignore value))
                                                           (equalp key "y"))) 
                                                       (second object))))))
                (return-from find-entrance-by-name (list locale-id x y)))))))))
  (error "Can't link to non-existing ???~a??? point in locale ???~a???" name locale-name))

(defun assign-exit (locale point exits)
  (format *trace-output* "~&Searching locale ???~a??? for an entrance point ???~a??????" locale point)
  (let ((locale.xml (load-other-map locale)))
    (destructuring-bind (locale-id x y)
        (find-entrance-by-name locale.xml point locale)
      (format *trace-output* " Found at (~d, ~d)." x y)
      (or (position (list locale-id x y) exits :test #'equalp)
          (progn
            (setf (cdr (last exits)) (cons (list locale-id x y) nil))
            (1- (length exits)))))))

(defun add-attribute-values (tile-palettes xml bytes &optional (exits nil exits-provided-p))
  (labels ((set-bit (byte bit)
             (setf (elt bytes byte) (logior (elt bytes byte) bit)))
           (clear-bit (byte bit)
             (setf (elt bytes byte) (logand (elt bytes byte) bit)))
           (map-boolean (property byte bit)
             (when-let (value (tile-property-value property xml))
               (cond ((eql t value) (set-bit byte bit))
                     ((eql :off value) (clear-bit byte bit))
                     (t (warn "Unrecognized value ~s for property ~s" value property))))))
    
    (when (tile-collision-p xml 4 0) (set-bit 0 #x01))
    (when (tile-collision-p xml 4 15) (set-bit 0 #x02))
    (when (tile-collision-p xml 0 7) (set-bit 0 #x04))
    (when (tile-collision-p xml 7 7) (set-bit 0 #x08))
    (map-boolean "Wall" 0 #x0f)
    (map-boolean "WallNorth" 0 #x01)
    (map-boolean "WallSouth" 0 #x02)
    (map-boolean "WallWest" 0 #x04)
    (map-boolean "WallEast" 0 #x08)
    ;; Ceiling ??? #x01 set by details layer
    (map-boolean "Wade" 1 #x02)
    (map-boolean "Swim" 1 #x04)
    (map-boolean "Ladder" 1 #x08)
    (map-boolean "Climb" 1 #x08)
    (map-boolean "Pit" 1 #x10)
    (map-boolean "Door" 1 #x20)
    (map-boolean "Flammable" 1 #x40)
    (map-boolean "StairsDown" 1 #x80)
    (map-boolean "Ice" 2 #x01)
    (map-boolean "Fire" 2 #x02)
    (when-let (switch (tile-property-value "Trigger" xml))
      (cond
        ((equalp switch "Step") (set-bit 2 #x04))
        ((equalp switch "Pull") (set-bit 2 #x08))
        ((equalp switch "Push") (set-bit 2 #x0c))
        (t (warn "Unknown value for switch Trigger property: ~s" switch))))
    (map-boolean "Iron" 2 #x10)
    (when-let (push (tile-property-value "Push" xml))
      (cond
        ((equalp push "Heavy") (set-bit 2 #x40))
        ((equalp push "VeryHeavy") (set-bit 2 #x60))
        (t (set-bit 2 #x20))))
    (when-let (destination (tile-property-value "Exit" xml))
      (set-bit 2 #x80)
      (destructuring-bind (locale point) (split-sequence #\/ destination)
        (if exits-provided-p
            (set-bit 4 (logand #x1f (assign-exit locale point exits)))
            (warn "Exit in tileset data is not supported (to point ~s in locale ~s)" point locale))))
    (if-let (lock (tile-property-value "Lock" xml))
      (set-bit 3 (logand #x1f (parse-integer lock :radix 16)))
      (when (tile-property-value "Locked" xml)
        (warn "Locked tile without Lock code")))
    (if-let (switch (tile-property-value "Switch" xml))
      (set-bit 4 (ash (logand #x0c (parse-integer switch :radix 16)) 3)))
    (when-let (tile-id (assocdr "id" (second xml) nil))
      (when (and tile-palettes tile-id)
        (set-bit 4 (ash (aref tile-palettes (parse-integer tile-id)) 5))))
    (when-let (palette (tile-property-value "Palette" xml))
      (clear-bit 4 #x07)
      (set-bit 4 (ash (mod (parse-integer palette :radix 16) 8) 5)))))

(defun parse-tile-attributes (palettes xml i)
  (let ((bytes (make-array '(6) :element-type '(unsigned-byte 8)))
        (tile.xml (find-if (lambda (el)
                             (and (equal "tile" (car el))
                                  (= i (parse-integer (assocdr "id" (second el))))))
                           (subseq xml 2))))
    (add-attribute-values palettes tile.xml bytes)
    #+ (or) (format *trace-output* "~& Tile (~2,'0x) Palette ~x Attrs ~s"
                    i (logand #x07 (aref bytes 4)) bytes)
    bytes))

(defun tile-effective-palette (grid x y attributes-table)
  (let ((byte4 (ash (logand #xe0 (aref (elt attributes-table (aref grid x y 1)) 4)) -5)))
    (check-type byte4 (integer 0 7))
    byte4))

(defun load-tileset (xml-reference)
  (let* ((pathname (if (consp xml-reference)
                       (let ((pathname 
                               (parse-namestring (assocdr "source" (second xml-reference)))))
                         (make-pathname :name (pathname-name pathname)
                                        :type (pathname-type pathname)
                                        :defaults #p"./Source/Maps/"))
                       xml-reference))
         (gid (if (consp xml-reference)
                  (parse-integer (assocdr "firstgid" (second xml-reference)))
                  0))
         (xml (xmls:parse-to-list (alexandria:read-file-into-string pathname)))
         (tileset (make-instance 'tileset :gid gid :pathname pathname)))
    (format *trace-output* "~&Loading tileset data from ~a" pathname)
    (assert (equal "tileset" (first xml)))
    (assert (equal "128" (assocdr "tilecount" (second xml))))
    (assert (<= 1.7 (parse-number (assocdr "version" (second xml))) 1.8))
    (let* ((image (xml-match "image" xml))
           (image-data (load-tileset-image (assocdr "source" (second image))))
           (palette-data (split-images-to-palettes image-data)))
      (setf (tileset-image tileset) image-data)
      (dotimes (i 128)
        (let ((bytes (parse-tile-attributes palette-data xml i)))
          (dotimes (b 6)
            (setf (aref (tile-attributes tileset) i b) (elt bytes b))))))
    tileset))

(defun rle-encode (non-repeated repeated repeated-times)
  (when (> (length non-repeated) 127)
    (return-from rle-encode
      (reduce (lambda (a b) (concatenate 'vector a b))
              (append (mapcar (lambda (segment) (rle-encode segment #() 0))
                              (loop for start from 0 by 127
                                    while (< start (length non-repeated))
                                    collecting (subseq non-repeated
                                                       start
                                                       (min (+ 127 start)
                                                            (length non-repeated)))))
                      (list (rle-encode #() repeated repeated-times))))))
  (let ((output (make-array (list 0) :adjustable t :element-type '(unsigned-byte 8))))
    (when (plusp (length non-repeated))
      (vector-push-extend (1- (length non-repeated)) output)
      (dotimes (byte (length non-repeated))
        (vector-push-extend (aref non-repeated byte) output)))
    (when (plusp (length repeated))
      (vector-push-extend (logior #x80 (1- (length repeated))) output)
      (vector-push-extend (1- repeated-times) output)
      (dotimes (byte (length repeated))
        (vector-push-extend (aref repeated byte) output)))
    output))

(defun rle-expanded-string (rle)
  (let ((output (make-array (list 0) :adjustable t :element-type '(unsigned-byte 8)))
        (offset 0))
    (loop while (< offset (1- (length rle)))
          for string-length = (1+ (logand #x7f (aref rle offset)))
          do (if (zerop (logand #x80 (aref rle offset)))
                 (progn (loop for byte across (subseq rle (1+ offset) (+ 1 offset string-length))
                              do (vector-push-extend byte output))
                        (incf offset (1+ string-length)))
                 (progn (dotimes (i (1+ (aref rle (1+ offset))))
                          (loop for byte across (subseq rle (+ 2 offset) (+ 2 offset string-length))
                                do (vector-push-extend byte output)))
                        (incf offset (+ 2 string-length)))))
    output))

(defun rle-compress-segment (source)
  (when (< (length source) 4)
    (return-from rle-compress-segment (list (cons (rle-encode source #() 0) (length source)))))
  (let ((matches (list)))
    (lparallel:pdotimes (offset (min 127 (1- (length source))))
      (loop for length from (min 127 (- (length source) offset)) downto 1
            for first-part = (subseq source offset (+ offset length))
            do (loop for repeats
                     from (min 256 (floor (/ (- (length source) offset) length)))
                     downto (if (= 1 length) 3 2)
                     do (when (every (lambda (part) (equalp first-part part))
                                     (loop for i from 0 below repeats
                                           for n = (* i length)
                                           collect (subseq source (+ offset n)
                                                           (+ offset length n))))
                          (push (cons (rle-encode (subseq source 0 offset)
                                                  (subseq source offset (+ offset length))
                                                  repeats)
                                      (+ offset (* length repeats)))
                                matches)))))
    (incf *rle-options* (or (and matches (length matches))
                            1))
    (or matches
        (list (cons (rle-encode source #() 0) (length source))))))

(defun shorter (a b)
  (if (< (length a) (length b))
      a b))

(defun only-best-options (options)
  (let ((best-expanded-length (make-hash-table))
        (best-rle (make-hash-table)))
    (dolist (option options)
      (destructuring-bind (rle . expanded-length) option
        (let* ((length (length rle))
               (champion (gethash length best-expanded-length)))
          (if (or (null champion)
                  (> expanded-length length))
              (setf (gethash length best-expanded-length) expanded-length
                    (gethash length best-rle) rle)))))
    (let ((best-options
            (loop for length being each hash-key of best-expanded-length
                  collecting (cons (gethash length best-rle)
                                   (gethash length best-expanded-length)))))
      (if *rle-fast-mode*
          (if (> (length best-options) *rle-fast-mode*)
              (subseq (sort best-options
                            (lambda (a b)
                              (< (/ (length (car a)) (cdr a))
                                 (/ (length (car b)) (cdr b)))))
                      0 *rle-fast-mode*)
              best-options)
          best-options))))

(defun rle-compress-fully (source &optional recursive-p)
  (let ((total-length (length source))
        (options (only-best-options (rle-compress-segment source)))
        (fully (list)))
    (when (< 1 (length options))
      #+ (or)
      (format t "~& For source length ~:d, there are ~:d options with expanded-length from ~:d to ~:d bytes"
              (length source) 
              (length options)
              (reduce #'min (mapcar #'cdr options))
              (reduce #'max (mapcar #'cdr options))))
    (dolist (option options)
      (destructuring-bind (rle . expanded-length) option
        (when (zerop (random 10000))
          (format *trace-output* "~&(RLE compressor: ~:d segment options considered)" *rle-options*))
        (cond
          ((and (not recursive-p) (> (length rle) *rle-best-full*))
           ;; no op, drop that option
           )
          ((= expanded-length total-length)
           (push rle fully))
          (t
           (let ((rest (rle-compress-fully (subseq source expanded-length) t)))
             (when rest
               (push (concatenate 'vector rle rest) fully)))))))
    (when fully
      (reduce #'shorter fully))))

(defparameter *rle-fast-mode* 1)

(defvar *rle-options* 0)

(defvar *rle-best-full* most-positive-fixnum)

(defun rle-compress (source)
  (let ((lparallel:*kernel* (lparallel:make-kernel 8))
        (*rle-options* 0)
        (*rle-best-full* (1+ (length source))))
    (format *trace-output* "~& Compressing ~:d byte~:p ???" (length source))
    (finish-output *trace-output*)
    (unwind-protect
         (let ((rle (rle-compress-fully source nil)))
           (format *trace-output* " into ~:d byte~:p using RLE (-~d%), ~
after considering ~:d option~:p."
                   (length rle)
                   (round (- 100 (* 100 (/ (length rle) (length source)))))
                   *rle-options*)
           (if (> (length rle) (1+ (length source)))
               (prog1 
                   (concatenate 'vector #(#xff) source)
                 (format *trace-output* "~&(Compression failed, saving uncompressed)"))
               rle))
      (lparallel:end-kernel))))

(defun hex-dump-comment (string)
  (format t "~{~&     ;; ~
~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~}" 
          (coerce string 'list)))

(defun hex-dump-bytes (string)
  (format t "~{~&     .byte $~2,'0x~^, $~2,'0x~^, $~2,'0x~^, $~2,'0x~
~^,   $~2,'0x~^, $~2,'0x~^, $~2,'0x~^, $~2,'0x~}" 
          (coerce string 'list)))

(defun xml-match (element xml &optional (error-code nil error-code-p))
  (or (find-if (lambda (el) (equal element (car el)))
               (subseq xml 2))
      (unless error-code-p
        (error "Not found: expected element ???~a??? but ~:[there are no child elements of ???~a???~;~
only see elements: ~:*~{???~a???~^, ~} under ???~a???.~]"
               element (mapcar #'car (subseq xml 2)) (car xml)))
      error-code))

(defun xml-matches (element xml)
  (when (and xml (< 1 (length xml)))
    (remove-if-not (lambda (el) (equal element (car el)))
                   (subseq xml 2))))

(defun write-word (number stream)
  (assert (<= 0 number #xffff) (number)
          "Cannot write 16-bit word-sized data with number #x~x (~:d); range is 0 - #xffff (65,535)"
          number number)
  (write-byte (logand #x00ff number) stream)
  (write-byte (ash (logand #xff00 number) -8) stream))

(defun write-dword (number stream)
  (assert (<= 0 number #xffffffff) (number)
          "Cannot write 32-bit double-word-sized data with number #x~x (~:d); range is 0 - #xffffffff (4,294,967,295)"
          number number)
  (write-byte (logand #x000000ff number) stream)
  (write-byte (ash (logand #x0000ff00 number) -8) stream)
  (write-byte (ash (logand #x00ff0000 number) -16) stream)
  (write-byte (ash (logand #xff000000 number) -24) stream))

(defun write-bytes (vector stream)
  (loop for byte across vector
        do (write-byte byte stream)))

(defun char->minifont (char)
  (cond
    ((or (char<= #\0 char #\9)
         (char<= #\a char #\z)
         (char<= #\A char #\Z))
     (digit-char-p char 36))
    (t (or (let ((pos (position char " ,.?!/&+-????=??????':;???####?????????????????" :test #'char=)))
             (when pos (+ 36 pos)))
           (error "Cannot encode char ~:c in minifont" char)))))

(defun unicode->minifont (string)
  (let ((mini-string (make-array (length string) :element-type '(unsigned-byte 8))))
    (loop for i below (length string)
          do (setf (aref mini-string i) (char->minifont (aref string i))))
    mini-string))

(defun compile-map (pathname)
  (let ((outfile (make-pathname :name (format nil "Map.~a" (pathname-name pathname))
                                :directory '(:relative "Object" "Assets")
                                :type "o")))
    (ensure-directories-exist outfile)
    (with-output-to-file (object outfile
                                 :element-type '(unsigned-byte 8)
                                 :if-exists :supersede)
      (format *trace-output* "~&Loading tile map from ~a" pathname)
      (let ((xml (xmls:parse-to-list (alexandria:read-file-into-string pathname))))
        (assert (equal "map" (car xml)))
        (assert (equal "orthogonal" (assocdr "orientation" (second xml))))
        (assert (equal "right-down" (assocdr "renderorder" (second xml))))
        (assert (equal "8" (assocdr "tilewidth" (second xml))))
        (assert (equal "16" (assocdr "tileheight" (second xml))))
        (let ((tilesets (mapcar #'load-tileset
                                (xml-matches "tileset" xml)))
              (layers (xml-matches "layer" xml))
              (object-groups (xml-matches "objectgroup" xml)))
          (assert (<= 1 (length layers) 2) ()
                  "This tool requires 1-2 layers, found ~:d tile map layer~:p in ~a"
                  (length layers) pathname)
          (when (= 2 (length layers))
            (when (or (and (null (map-layer-depth (first layers)))
                           (eql 0 (map-layer-depth (second layers))))
                      (and (null (map-layer-depth (second layers)))
                           (eql 1 (map-layer-depth (first layers))))
                      (and (map-layer-depth (first layers)) (map-layer-depth (second layers))
                           (> (map-layer-depth (first layers)) (map-layer-depth (second layers)))))
              (setf layers (reversef layers))))
          (assert (<= 0 (length object-groups) 1))
          (let ((base-tileset (first tilesets))
                (objects (cddr (first object-groups))))
            (format *trace-output* "~&Parsing map layers???")
            (multiple-value-bind (tile-grid attributes-table decals-table exits-table texts-list)
                (parse-tile-grid layers objects base-tileset)
              (format *trace-output* "~&Ready to write binary output???")
              (let* ((width (array-dimension tile-grid 0))
                     (height (array-dimension tile-grid 1))
                     (name-full (concatenate 'string (string-downcase 
                                                      (cl-change-case:sentence-case (pathname-base-name pathname)))))
                     (name (subseq name-full 0 (min 20 (length name-full))))
                     (compressed-art (rle-compress 
                                      (let ((string (make-array (list (* width height)) :element-type '(unsigned-byte 8))))
                                        (dotimes (y height)
                                          (dotimes (x width)
                                            (let ((cell (aref tile-grid x y 0)))
                                              (setf (aref string (+ (* width y) x)) cell))))
                                        string)))
                     (compressed-attributes (rle-compress
                                             (let ((string (make-array (list (* width height)) :element-type '(unsigned-byte 8))))
                                               (dotimes (y height)
                                                 (dotimes (x width)
                                                   (setf (aref string (+ (* width y) x)) (aref tile-grid x y 1))))
                                               string)))
                     (texts (mapcar #'unicode->minifont texts-list)))
                (assert (<= (* width height) 1024))
                (format *trace-output* "~&Found grid ~d??~d tiles, ~
~d unique attribute~:p, ~d decal~:p, ~d unique exit~:p"
                        width height
                        (length attributes-table) (length decals-table)
                        (length exits-table))
                ;; offset 0, width
                (write-byte width object)
                ;; offset 1, height
                (write-byte height object)
                ;; offset 2-3, offset of art map
                (write-word (+ 16 1 (length name))
                            object)
                ;; offset 4-5, offset of attributes map
                (write-word (+ 16 1 (length name)
                               2 (length compressed-art))
                            object)
                ;; offset 6-7, offset of attributes list
                (write-word (+ 16 1 (length name)
                               2 (length compressed-art) 
                               2 (length compressed-attributes))
                            object)
                ;; offset 8-9, offset of decals list
                (write-word (+ 16 1 (length name)
                               2 (length compressed-art) 
                               2 (length compressed-attributes)
                               1 (* 6 (length attributes-table)))
                            object)
                ;; offset 10-11, offset of exits list
                (write-word (+ 16 1 (length name)
                               2 (length compressed-art) 
                               2 (length compressed-attributes)
                               1 (* 6 (length attributes-table))
                               1 (* 7 (length decals-table))) 
                            object)
                ;; offset 12-13, offset of texts list
                (write-word (+ 16 1 (length name)
                               2 (length compressed-art) 
                               2 (length compressed-attributes)
                               1 (* 6 (length attributes-table))
                               1 (* 7 (length decals-table))
                               1 (* 3 (length exits-table)))
                            object)
                ;; offset 14-15, currently end-of-data pointer but could be a further addition?
                (write-word (+ 16 1 (length name)
                               2 (length compressed-art) 
                               2 (length compressed-attributes)
                               1 (* 6 (length attributes-table))
                               1 (* 7 (length decals-table))
                               1 (* 3 (length exits-table))
                               1 (reduce #'+ (mapcar #'length texts)))
                            object)
                ;; offset 16, name (Pascal string)
                (write-byte (length name) object)
                (write-bytes (unicode->minifont name) object)
                ;; compressed art map
                (write-word (length compressed-art) object)
                (write-bytes compressed-art object)
                ;; compressed attributes map
                (write-word (length compressed-attributes) object)
                (write-bytes compressed-attributes object)
                ;; attributes list
                (write-byte (length attributes-table) object)
                (assert (every (lambda (attr) (= 6 (length attr))) attributes-table)
                        (attributes-table)
                        "All attributes table entries must be precisely 6 bytes: ~%~s" attributes-table)
                (dolist (attr attributes-table)
                  (write-bytes attr object))
                ;; decals list
                (write-byte (length decals-table) object)
                (assert (every (lambda (decal) (= 4 (length decal))) decals-table)
                        (decals-table)
                        "All decals table entries must be precisely 4 values: ~%~s" decals-table)
                (dolist (decal decals-table)
                  (write-byte (first decal) object) ; x
                  (write-byte (second decal) object) ; y
                  (write-byte (third decal) object) ; gid of first art
                  (write-dword (fourth decal) object) ; attributes
                  )
                ;; exits list
                (write-byte (length exits-table) object)
                (dolist (exit exits-table)
                  (destructuring-bind (locale x y) exit
                    (write-byte locale object)
                    (write-word x object)
                    (write-word y object)))
                ;; texts list
                (write-byte (length texts-list) object)
                (dolist (text texts-list)
                  (write-byte (length text) object)
                  (write-bytes text object))))))))))

(defun rip-tiles-from-tileset (tileset images)
  (let ((i 0))
    (dotimes (y (floor (array-dimension (tileset-image tileset) 1) 16))
      (dotimes (x (floor (array-dimension (tileset-image tileset) 0) 8))
        (setf (aref images i) (extract-region (tileset-image tileset)
                                              (* x 8) (* y 16) 
                                              (1- (* (1+ x) 8)) (1- (* (1+ y) 16))))
        (incf i)))))

(defun palette-index (pixel palette)
  (position pixel (coerce palette 'list)))

(defun rip-bytes-from-image (image palettes bytes index)
  (let ((palette (elt (2a-to-list palettes) (best-palette image palettes))))
    (dotimes (y 16)
      (dotimes (half 2)
        (let ((byte-index (+ (+ half (* 2 index)) (* y #x100))))
          (check-type byte-index (integer 0 (4096)))
          (dotimes (x 4)
            (setf (ldb (byte 2 (* 2 x)) (aref bytes byte-index))
                  (palette-index (aref image (+ (- 3 x) (* 4 half)) (- 15 y)) palette))))))))

(defun compile-tileset (pathname)
  (let ((outfile (make-pathname :directory '(:relative "Object" "Assets")
                                :name (format nil "Tileset.~a" (pathname-name pathname))
                                :type "o")))
    (ensure-directories-exist outfile)
    (with-output-to-file (object outfile
                                 :element-type '(unsigned-byte 8)
                                 :if-exists :supersede)
      (let* ((tileset (load-tileset pathname))
             (palettes (extract-palettes (tileset-image tileset)))
             (images (make-array (list 128)))
             (bytes (make-array (list (* 256 16)) :element-type '(unsigned-byte))))
        (rip-tiles-from-tileset tileset images)
        (dotimes (i 128)
          (rip-bytes-from-image (aref images i) palettes bytes i))
        (write-bytes bytes object)
        (write-byte (aref palettes 0 0) object)
        (dotimes (palette-index 7)
          (write-byte (aref palettes palette-index 1) object)
          (write-byte (aref palettes palette-index 2) object)
          (write-byte (aref palettes palette-index 3) object))))))

