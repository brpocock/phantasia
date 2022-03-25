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
    (values id 
            (apply #'vector (loop for b below 6
                                  collect (aref (tile-attributes tileset) id b))))))

(defun assign-attributes (attr alt-tile-id attr-table)
  (setf (aref attr 5) alt-tile-id)
  (or (position-if (lambda (attribute) (equalp attr attribute)) attr-table)
      (progn (appendf attr-table (cons attr nil))
             (1- (length attr-table)))))

(defun parse-tile-grid (layers tileset)
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
                   (attribute-id (assign-attributes tile-attributes alt-tile-id attributes-table)))
              (setf (aref output x y 0) tile-id
                    (aref output x y 1) attribute-id))))))
    (values output attributes)))

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
  
  )

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
  (dotimes (y 16)
    (dotimes (x 8)
      (unless (member (aref tile x y) palette :test #'rgb=)
        (return-from tile-fits-palette-p nil))))
  t)

(defun best-palette (tile palettes)
  (position-if (lambda (palette)
                 (tile-fits-palette-p tile palette))
               palettes))

(defun split-images-to-palettes (image)
  (let ((tiles (extract-8×16-tiles image))
        (palettes (extract-palettes image))
        (output (make-array '(128) :element-type '(unsigned-byte 3))))
    (dotimes (i (length tiles))
      (setf (aref output i) (best-palette (elt tiles i) palettes)))
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

(defun parse-tile-attributes (xml i)
  (let ((bytes (make-array '(6) :element-type '(unsigned-byte 8)))
        (tile.xml (find-if (lambda (el)
                             (and (equal "tile" (car el))
                                  (= i (parse-integer (assocdr "id" (second el))))))
                           (subseq xml 2))))
    (when (eql t (tile-property-value "Wade" tile.xml)))
    bytes))

(defun load-tileset (xml-reference)
  (let* ((pathname (assocdr "source" (second xml-reference)))
         (gid (parse-integer (assocdr "firstgid" (second xml-reference))))
         (xml (xmls:parse-to-list (alexandria:read-file-into-string 
                                   (make-pathname :name pathname
                                                  :defaults #p"./Source/Maps/"))))
         (tileset (make-instance 'tileset :gid gid :pathname pathname)))
    (assert (equal "tileset" (first xml)))
    (assert (equal "128" (assocdr "tilecount" (second xml))))
    (assert (equal "1.8" (assocdr "version" (second xml))))
    (assert (equal "properties" (car (third xml))))
    (assert (equal "image" (car (fourth xml))))
    (let* ((image-data (load-tileset-image (assocdr "source" (second (fourth xml)))))
           (palette-data (split-images-to-palettes image-data)))
      (dotimes (i 128)
        (let ((bytes (parse-tile-attributes xml i)))
          (dotimes (b 6)
            (setf (aref (tile-attributes tileset) i b) (elt bytes b))))))
    tileset))

(defun compile-map (pathname)
  (let ((xml (xmls:parse-to-list (alexandria:read-file-into-string pathname))))
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
      (let ((base-tileset (first tilesets)))
        (multiple-value-bind (tile-grid attributes-table) (parse-tile-grid layers base-tileset)
          (let ((width (array-dimension tile-grid 0))
                (height (array-dimension tile-grid 1)))
            (assert (<= (* width height) 1024))
            (format t "~2%;;; Tile grid — ~d × ~d tiles~%	.byte ~d, ~d" width height width height)
            (format t "~2%     ;; Tile art")
            (dotimes (y height) 
              (dotimes (x width)
                (format t "~&     .byte ~x" (aref tile-grid x y 0))))
            (format t "~2%     ;; Tile attributes pointer")
            (dotimes (y height) 
              (dotimes (x width)
                (format t "~&     .byte ~x" (aref tile-grid x y 1))))
            (format t "~2%     ;; Tile attributes table")
            (dolist (attr attributes-table)
              (format t "~&     .byte ~{~x, ~x, ~x, ~x, ~x, ~x~}" 
                      (loop for i below 6 collecting (aref attr i))))
            
            
            (format t "~2%;;; Tile animation sets — ~d animation set~:p" (length tile-animation-sets))
            (format t "~%	.byte ~d~%" (length tile-animation-sets))
            (format t "~{~{~%	.byte $~2,'0x,  ~{$~2,'0x, ~3d~^, ~}, 0~}~}" tile-animation-sets)))))
    (fresh-line)))

