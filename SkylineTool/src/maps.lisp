(in-package :skyline-tool)

(defclass level ()
  ((sprites :accessor level-sprites :initarg :sprites)
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

(defun assocdr (key alist)
  (or (second (assoc key alist :test #'equalp))
      (error "Could not find ~a in ~s" key alist)))

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
  (assert (equal "properties" (car (third layer))))
  (assert (equal "data" (car (fourth layer))))
  (assert (equal "base64" (assocdr "encoding" (second (fourth layer)))))
  (assert (stringp (third (fourth layer))))
  (let* ((width (parse-integer (assocdr "width" (second layer))))
         (height (parse-integer (assocdr "height" (second layer)))))
    (split-grid-to-rows width height
                        (bytes-to-32-bits
                         (cl-base64:base64-string-to-usb8-array (third (fourth layer)))))))

(defun find-tile-by-number (number tileset)
  (let ((id (- number (tileset-gid tileset))))
    (if (< id 128)
        (values id 
                (apply #'vector (loop for b below 6
                                      collect (aref (tile-attributes tileset) id b))))
        (values 0 #(0 0 0 0 0 0)))))

(defun assign-attributes (attr alt-tile-id attr-table)
  (setf (aref attr 5) (or alt-tile-id 0))
  (or (position-if (lambda (attribute) (equalp attr attribute)) attr-table)
      (progn (setf (cdr (last attr-table)) (cons attr nil))
             (1- (length attr-table)))))

(defun object-covers-tile-p (x y object)
  (or (and (find-if (lambda (el) (equal "point" (car el)))
                    (subseq object 2))
           (<= (* x 8) (parse-number (assocdr "x" (second object))) (1- (* (1+ x) 8)))
           (<= (* y 16) (parse-number (assocdr "y" (second object))) (1- (* (1+ y) 16))))))

(defun find-effective-attributes (x y objects attributes)
  (let ((effective-objects (remove-if-not (lambda (el)
                                            (and (equal "object" (car el))
                                                 (object-covers-tile-p x y el)))
                                          (subseq objects 2))))
    (dolist (object effective-objects)
      (add-attribute-values object attributes)))
  attributes)

(defun parse-tile-grid (layers objects tileset)
  (let* ((ground (parse-layer (first layers)))
         (detail (and (= 2 (length layers))
                      (parse-layer (second layers))))
         (output (make-array (list (array-dimension ground 0)
                                   (array-dimension ground 1)
                                   2)
                             :element-type 'integer))
         (attributes-table (list #(0 0 0 0 0 0))))
    (dotimes (y (array-dimension ground 1))
      (dotimes (x (array-dimension ground 0))
        (let* ((detailp (and detail (> (aref detail x y) 0)))
               (tile-number (if detailp
                                (aref detail x y)
                                (aref ground x y))))
          (multiple-value-bind (tile-id tile-attributes) (find-tile-by-number tile-number tileset)
            (let* ((alt-tile-number (when detailp (aref ground x y)))
                   (alt-tile-id (when detailp (find-tile-by-number tile-number tileset)))
                   (effective-attributes (find-effective-attributes x y objects tile-attributes))
                   (attribute-id (assign-attributes effective-attributes alt-tile-id attributes-table)))
              (setf (aref output x y 0) tile-id
                    (aref output x y 1) attribute-id))))))
    ;;TODO third & fourth returned values are the sprites and exits tables
    (values output attributes-table #() #())))

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
   (tile-attributes :accessor tile-attributes
                    :initform (make-array (list 128 6) :element-type '(unsigned-byte 8)))))

(defun load-tileset-image (pathname)
  (format *trace-output* "~&Loading tileset image from ~a" pathname)
  (let* ((png (png-read:read-png-file (make-pathname 
                                       :name (subseq pathname 0
                                                     (position #\. pathname :from-end t))
                                       :type (subseq pathname (1+ (position #\. pathname :from-end t)))
                                       :defaults #p"./Source/Maps/")))
         (height (png-read:height png))
         (width (png-read:width png))
         (α (png-read:transparency png))
         (*machine* 7800))
    (png->palette height width
                  (png-read:image-data png)
                  α)))

(defun extract-8×16-tiles (image)
  (let ((output (list)))
    (dotimes (row (/ (1- (array-dimension image 1)) 16))
      (dotimes (column (/ (array-dimension image 0) 8))
        (let ((tile (extract-region image (* column 8) (* row 16) (+ (* column 8) 7) (+ (* row 16) 15))))
          (assert (= 8 (array-dimension tile 0)))
          (assert (= 16 (array-dimension tile 1)))
          (push tile output))))
    (format *trace-output* "… found ~d tile~:p in ~d×~d image" 
            (length output) (array-dimension image 0) (array-dimension image 1))
    output))

(defun extract-palettes (image)
  (let* ((last-row (1- (array-dimension image 1)))
         (palette-strip (extract-region image 0 last-row 25 last-row))
         (palettes (make-array (list 8 4) :element-type '(unsigned-byte 8))))
    (dotimes (p 8)
      (setf (aref palettes p 0) (aref palette-strip 0 0))
      (dotimes (c 3)
        (setf (aref palettes p (1+ c)) (aref palette-strip (+ 1 c (* p 3)) 0))))
    palettes))

(defun tile-fits-palette-p (tile palette)
  (every (lambda (c) (member c palette))
         (remove-duplicates (loop for y below 16 
                                  append
                                  (loop for x below 8
                                        collect (aref tile x y)))
                            :test #'=)))

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
  (let ((tiles (extract-8×16-tiles image))
        (palettes (extract-palettes image))
        (output (make-array '(128) :element-type '(unsigned-byte 3))))
    (dotimes (i (length tiles))
      (setf (aref output i) (or (best-palette (elt tiles i) palettes)
                                (error "Tile ~d does not match any palette~%~s~2%~s"
                                       i (elt tiles i) palettes))))
    output))

(defun tile-property-value (key tile.xml)
  (let ((prop (third tile.xml)))
    (when (and (equal "property" (car prop))
               (equalp key (assocdr "name" (second prop))))
      (let ((value (assocdr "value" (second prop))))
        (if (or (equalp "true" value)
                (equalp "t" value))
            t
            value)))))

(defun tile-collision-p (xml)
  ;; TODO
  nil)

(defun add-attribute-values (xml bytes)
  ;; TODO
  (when (tile-property-value "Wade" xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  (when (tile-property-value "Swim" xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  (when (tile-property-value "Exit" xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  (when (tile-property-value "Door" xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  (when (tile-property-value "Break" xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  (when (tile-property-value "Fire" xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  
  (when (tile-collision-p xml) (setf (elt bytes 0) (logior (elt bytes 0) #x00)))
  
  )

(defun parse-tile-attributes (xml i)
  (let ((bytes (make-array '(6) :element-type '(unsigned-byte 8)))
        (tile.xml (find-if (lambda (el)
                             (and (equal "tile" (car el))
                                  (= i (parse-integer (assocdr "id" (second el))))))
                           (subseq xml 2))))
    (add-attribute-values tile.xml bytes)
    bytes))

(defun load-tileset (xml-reference)
  (let* ((pathname (assocdr "source" (second xml-reference)))
         (gid (parse-integer (assocdr "firstgid" (second xml-reference))))
         (xml (xmls:parse-to-list (alexandria:read-file-into-string 
                                   (make-pathname :name pathname
                                                  :defaults #p"./Source/Maps/"))))
         (tileset (make-instance 'tileset :gid gid :pathname pathname)))
    (format *trace-output* "~&Loading tileset data from ~a" pathname)
    (assert (equal "tileset" (first xml)))
    (assert (equal "128" (assocdr "tilecount" (second xml))))
    (assert (<= 1.5 (parse-number (assocdr "version" (second xml))) 1.8))
    (let* ((properties (find-if (lambda (el) (equal "properties" (car el))) (subseq xml 2)))
           (image (find-if (lambda (el) (equal "image" (car el))) (subseq xml 2)))
           (image-data (load-tileset-image (assocdr "source" (second image))))
           (palette-data (split-images-to-palettes image-data)))
      (dotimes (i 128)
        (let ((bytes (parse-tile-attributes xml i)))
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
                                    collecting (subseq non-repeated start (min (+ 127 start)
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
    (unwind-protect
         (let ((rle (rle-compress-fully source nil)))
           (format *trace-output* "~& Compressed ~:d byte~:p into ~:d byte~:p using RLE (~d%), ~
after considering ~:d option~:p."
                   (length source) (length rle)
                   (round (* 100 (/ (length rle) (length source))))
                   *rle-options*)
           (if (> (length rle) (1+ (length source)))
               (prog1 
                   (concatenate 'vector #(#xff) source)
                 (format *trace-output* "~&(Compression failed, saving uncompressed)"))
               rle))
      (lparallel:end-kernel))))

(defun compile-map (pathname)
  (with-open-file (*standard-output* 
                   (make-pathname :defaults pathname
                                  :directory '(:relative "Source/Generated/Maps/")
                                  :type "s")
                   :direction :output
                   :if-exists :supersede)
    (let ((xml (xmls:parse-to-list (alexandria:read-file-into-string pathname)))
          (*map-exits* (list)))
      (assert (equal "map" (car xml)))
      (assert (equal "orthogonal" (assocdr "orientation" (second xml))))
      (assert (equal "right-down" (assocdr "renderorder" (second xml))))
      (assert (equal "8" (assocdr "tilewidth" (second xml))))
      (assert (equal "16" (assocdr "tileheight" (second xml))))
      (let ((tilesets (mapcar #'load-tileset
                              (remove-if-not (lambda (el)
                                               (equal "tileset" (car el)))
                                             (subseq xml 2))))
            (layers (remove-if-not (lambda (el)
                                     (equal "layer" (car el)))
                                   (subseq xml 2)))
            (object-groups (remove-if-not (lambda (el)
                                            (equal "objectgroup" (car el)))
                                          (subseq xml 2))))
        (assert (<= 1 (length layers) 2))
        (when (= 2 (length layers))
          (when (or (and (null (map-layer-depth (first layers)))
                         (eql 0 (map-layer-depth (second layers))))
                    (and (null (map-layer-depth (second layers)))
                         (eql 1 (map-layer-depth (first layers))))
                    (and (map-layer-depth (first layers)) (map-layer-depth (second layers))
                         (> (map-layer-depth (first layers)) (map-layer-depth (second layers)))))
            (setf layers (reversef layers))))
        (assert (<= 0 (length object-groups) 1))
        (format t ";;; This is a generated file.~%;;; Source file: ~a~2%" pathname)
        (format t "Map_~a:     .block" (pathname-base-name pathname))
        (let ((base-tileset (first tilesets))
              (objects (first object-groups)))
          (multiple-value-bind (tile-grid attributes-table sprites-table exits-table)
              (parse-tile-grid layers objects base-tileset)
            (let ((width (array-dimension tile-grid 0))
                  (height (array-dimension tile-grid 1)))
              (assert (<= (* width height) 1024))
              (format t "~2%;;; Tile grid — ~d × ~d tiles
GridSize:     
Width:    .byte ~d
Height:    .byte ~d" 
                      width height width height)
              (format t "~2%;;; Pointers into grid data:
Pointers:
     .word Art
     .word TileAttributes
     .word Attributes
     .word Sprites
     .word Exits")
              (format t "~2%Art:     ;; Tile art")
              (let ((string (make-array (list (* width height)) :element-type '(unsigned-byte 8))))
                (dotimes (y height)
                  (dotimes (x width)
                    (setf (aref string (+ (* width y) x)) (aref tile-grid x y 0))))
                (format t "~{~&     ;; ~
~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~}" 
                        (coerce string 'list))
                (let ((compressed (rle-compress string)))
                  (format t "~&     .word $~4,'0x" (length compressed))
                  (format t "~{~&     .byte $~2,'0x~^, $~2,'0x~^, $~2,'0x~^, $~2,'0x~
~^,   $~2,'0x~^, $~2,'0x~^, $~2,'0x~^, $~2,'0x~}" 
                          (coerce compressed 'list))))
              (format t "~2%TileAttributes:     ;; Tile attributes indices")
              (let ((string (make-array (list (* width height)) :element-type '(unsigned-byte 8))))
                (dotimes (y height)
                  (dotimes (x width)
                    (setf (aref string (+ (* width y) x)) (aref tile-grid x y 1))))
                (format t "~{~&     ;; ~
~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~
~^  ~2,'0x~^ ~2,'0x~^ ~2,'0x~^ ~2,'0x~}" 
                        (coerce string 'list))
                (let ((compressed (rle-compress string)))
                  (format t "~&     .word $~4,'0x" (length compressed))
                  (format t "~{~&     .byte $~2,'0x~^, $~2,'0x~^, $~2,'0x~^, $~2,'0x~
~^,   $~2,'0x~^, $~2,'0x~^, $~2,'0x~^, $~2,'0x~}" 
                          (coerce compressed 'list))))
              (format t "~2%Attributes:     ;; Tile attributes table")
              (dolist (attr attributes-table)
                (format t "~&     .byte ~{ $~2,'0x, $~2,'0x,  $~2,'0x,  $~2,'0x,  $~2,'0x,  $~2,'0x~}" 
                        (coerce attr 'list)))
              
              (format t "~2%Exits:     ;; Exit destination pointers")
              (format t "~2%Sprites:     ;; Sprites table")
              
              (format t "~%;;; TODO")
              
              ))))
      (format t "~2&      .bend")
      (fresh-line))))

