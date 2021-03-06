(in-package :skyline-tool)

(defvar *tileset*)

(define-constant +c64-names+
    '(black white red cyan
      purple blue green yellow
      orange brown pink gray1
      gray2 ltblue ltgreen gray3)
  :test 'equalp)

(define-constant +c64-palette+
    '(( 0 0 0 )
      ( 255 255 255 )
      ( 138 57 50 )
      ( 103 184 191 )
      ( 141 63 152 )
      ( 85 162 73 )
      ( 64 49 143 )
      ( 193 208 114 )
      ( 141 84 41 )
      ( 87 66 0 )
      ( 186 105 98 )
      ( 80 80 80 )
      ( 120 120 120 )
      ( 150 226 139 )
      ( 120 105 198 )
      ( 161 161 161 ))
  :test 'equalp)

(define-constant +apple-hires-palette+ '()) ;; TODO
(define-constant +nes-palette+ '()) ;; TODO
(define-constant +tg16-palette+ '()) ;; TODO
(define-constant +ted-palette+ '()) ;; TODO
(define-constant +vcs-ntsc-palette+
    '((0   0   0) (64  64  64) (108 108 108) (144 144 144) (176 176 176) (200 200 200) (220 220 220) (236 236 236)
      (68  68   0) (100 100  16) (132 132  36) (160 160  52) (184 184  64) (208 208  80) (232 232  92) (252 252 104)
      (112  40   0) (132  68  20) (152  92  40) (172 120  60) (188 140  76) (204 160  92) (220 180 104) (236 200 120)
      (132  24   0) (152  52  24) (172  80  48) (192 104  72) (208 128  92) (224 148 112) (236 168 128) (252 188 148)
      (136   0   0) (156  32  32) (176  60  60) (192  88  88) (208 112 112) (224 136 136) (236 160 160) (252 180 180)
      (120   0  92) (140  32 116) (160  60 136) (176  88 156) (192 112 176) (208 132 192) (220 156 208) (236 176 224)
      (72   0 120) (96  32 144) (120  60 164) (140  88 184) (160 112 204) (180 132 220) (196 156 236) (212 176 252)
      (20   0 132) (48  32 152) (76  60 172) (104  88 192) (124 112 208) (148 136 224) (168 160 236) (188 180 252)
      (0   0 136) (28  32 156) (56  64 176) (80  92 192) (104 116 208) (124 140 224) (144 164 236) (164 184 252)
      (0  24 124) (28  56 144) (56  84 168) (80 112 188) (104 136 204) (124 156 220) (144 180 236) (164 200 252)
      (0  44  92) (28  76 120) (56 104 144) (80 132 172) (104 156 192) (124 180 212) (144 204 232) (164 224 252)
      (0  60  44) (28  92  72) (56 124 100) (80 156 128) (104 180 148) (124 208 172) (144 228 192) (164 252 212)
      (0  60   0) (32  92  32) (64 124  64) (92 156  92) (116 180 116) (140 208 140) (164 228 164) (184 252 184)
      (20  56   0) (52  92  28) (80 124  56) (108 152  80) (132 180 104) (156 204 124) (180 228 144) (200 252 164)
      (44  48   0) (76  80  28) (104 112  52) (132 140  76) (156 168 100) (180 192 120) (204 212 136) (224 236 156)
      (68  40   0) (100  72  24) (132 104  48) (160 132  68) (184 156  88) (208 180 108) (232 204 124) (252 224 140))
  :test 'equalp)

(define-constant +prosystem-ntsc-palette+
    '((0 0 0) (18 18 18) (36 36 36) (54 54 54) (71 71 71) (89 89 89) (107 107 107) (125 125 125) (143 143 143) (161 161 161) (178 178 178) (196 196 196) (214 214 214) (232 232 232) (250 250 250) (255 255 255)
      (10 22 0) (36 40 0) (62 58 0) (88 76 0) (113 94 0) (139 111 0) (165 129 0) (186 147 11) (204 165 29) (222 183 47) (239 201 65) (255 218 82) (255 236 100) (255 254 118) (255 255 136) (255 255 154)
      (31 6 0) (57 24 0) (82 42 0) (108 59 0) (134 77 0) (160 95 0) (184 113 4) (202 131 22) (219 149 40) (237 166 58) (255 184 76) (255 202 94) (255 220 111) (255 238 129) (255 255 147) (255 255 165)
      (50 0 0) (71 6 0) (97 24 0) (122 42 0) (148 60 0) (166 78 18) (184 95 36) (201 113 54) (220 131 72) (238 149 89) (255 167 107) (255 185 125) (255 203 143) (255 220 161) (255 238 179) (255 255 197)
      (62 0 0) (80 0 0) (97 9 10) (116 27 28) (133 45 46) (151 62 64) (168 80 81) (187 98 99) (204 116 117) (223 134 135) (240 152 153) (255 170 171) (254 187 189) (255 205 206) (255 223 224) (255 241 242)
      (51 0 25) (61 0 43) (71 0 61) (88 17 79) (107 35 96) (125 53 114) (141 70 132) (159 88 150) (177 106 168) (195 124 186) (214 142 203) (227 160 221) (227 178 239) (228 195 255) (236 213 255) (244 231 255)
      (18 0 71) (28 0 89) (38 0 106) (54 14 124) (72 32 142) (89 50 160) (107 68 178) (125 86 196) (144 104 213) (161 121 231) (179 139 249) (203 157 255) (219 175 255) (227 193 255) (235 211 255) (243 228 255)
      (0 0 102) (0 0 120) (3 2 138) (20 19 156) (37 37 174) (55 55 192) (73 73 210) (92 91 227) (110 109 245) (131 126 255) (157 144 255) (182 162 255) (208 180 255) (229 198 255) (237 216 255) (246 234 255)
      (0 0 114) (0 0 132) (0 13 150) (0 31 168) (11 49 185) (29 67 203) (46 85 221) (64 103 239) (82 120 255) (108 138 255) (134 156 255) (160 174 255) (187 192 255) (212 210 255) (238 228 255) (250 245 255)
      (0 0 103) (0 12 121) (0 30 139) (0 47 157) (0 65 174) (13 83 192) (31 101 210) (49 119 228) (66 137 246) (88 155 255) (114 172 255) (140 190 255) (166 208 255) (192 226 255) (218 244 255) (240 255 255)
      (0 11 72) (0 29 90) (0 47 107) (0 65 125) (0 83 143) (13 101 161) (30 118 179) (48 136 197) (65 154 215) (84 172 232) (102 190 250) (126 208 255) (152 226 255) (177 243 255) (200 255 255) (218 255 255)
      (0 27 26) (0 44 44) (0 62 62) (0 80 80) (9 98 98) (27 116 116) (45 134 133) (63 152 151) (81 169 169) (98 187 187) (116 205 205) (134 223 223) (152 241 241) (170 255 255) (188 255 255) (206 255 255) 
      (17 37 0) (24 54 0) (27 72 11) (27 90 29) (36 108 47) (54 126 65) (72 144 83) (89 161 101) (107 179 118) (125 197 136) (143 215 154) (161 233 172) (179 251 190) (191 255 208) (200 255 226) (210 255 243) 
      (18 39 0) (26 57 0) (34 75 0) (45 93 0) (70 111 1) (88 129 19) (106 146 37) (124 164 55) (141 182 73) (159 200 90) (177 218 108) (195 236 126) (213 253 144) (224 255 162) (233 255 180) (243 255 198) 
      (15 34 0) (23 52 0) (38 70 0) (65 88 0) (91 106 0) (117 124 0) (140 141 5) (158 159 23) (175 177 41) (194 195 58) (212 213 76) (230 231 94) (247 248 112) (255 255 130) (255 255 148) (255 255 166) 
      (10 23 0) (35 40 0) (61 58 0) (87 76 0) (113 94 0) (138 112 0) (164 130 0) (185 147 11) (203 165 29) (221 183 47) (239 201 65) (255 219 82) (255 237 100) (255 255 118) (255 255 136) (255 255 154)) 
  :test 'equalp)

(define-constant +vcs-pal-palette+ '()) ;; TODO
(define-constant +vcs-secam-palette+ '()) ;; TODO

(define-constant +unicode->ascii-ish+ nil)

(defun double-up (list)
  (loop for item in list
        appending (list item item)))

(assert (equalp '(a a b b c c) (double-up '(a b c))))

(defun machine-palette ()
  (copy-list (ecase *machine*
               (20 (subseq +c64-palette+ 0 7))
               ((64 128) +c64-palette+)
               (2 +apple-hires-palette+)
               (8 +nes-palette+)
               (2600 (ecase *region*
                       (:ntsc +vcs-ntsc-palette+)
                       (:pal +vcs-pal-palette+)
                       (:secam +vcs-secam-palette+)))
               (7800 (ecase *region* ;;; Not techically accurate, there are 256 colors XXX
                       (:ntsc +prosystem-ntsc-palette+)
                       (:pal (double-up +vcs-pal-palette+))))
               (264 +ted-palette+)
               (16 +tg16-palette+))))

(defun machine-colors ()
  (ecase *machine*
    (20 (subseq +c64-names+ 0 7))
    ((64 128) +c64-names+)))

(defun color-distance (r0 g0 b0 rgb1)
  (destructuring-bind (r1 g1 b1) rgb1
    (+ (* .5 (abs (- r0 r1)))
       (* .6 (abs (- b0 b1)))
       (* .7 (abs (- g0 g1))))))

(defun find-nearest-in-palette (palette red green blue)
  (first (sort palette #'< :key (curry #'color-distance red green blue))))

(defun palette->rgb (index)
  (nth index (machine-palette)))

(defun rgb->palette (red green blue)
  (check-type red (integer 0 #xff))
  (check-type green (integer 0 #xff))
  (check-type blue (integer 0 #xff))
  (or (position (list red green blue) (machine-palette) :test 'equalp)
      (destructuring-bind (r g b) (find-nearest-in-palette
                                   (machine-palette) red green blue)
        (let ((use (position (list r g b) (machine-palette) :test 'equalp)))
          (unless (position (list red green blue) *palette-warnings* :test 'equalp)
            (warn-once "Colour not in ~a palette: #~2,'0X~2,'0X~2,'0X; used $~2,'0x (#~2,'0X~2,'0X~2,'0X)"
                       (machine-short-name) red green blue
                       use r g b)
            (push (list red green blue) *palette-warnings*))
          use))))

(defun png->palette (height width rgb &optional ??)
  (check-type height (integer 0 *))
  (check-type width (integer 0 *))
  (check-type rgb array)
  (check-type ?? (or null array))
  (destructuring-bind (w h bpp) (array-dimensions rgb)
    (unless (and (= h height) (= w width) (or (= bpp 3) (= bpp 4)))
      (error "~2%------------------------------------------------------------------------
PNG image in an unsuitable format:
  Make sure it's the right size and in RGB or RGBA mode.
------------------------------------------------------------------------"))
    (let ((image (make-array (list width height)
                             :element-type '(or null (unsigned-byte 8)))))
      (loop for x from 0 below width
         do (loop for y from 0 below height
               do (setf (aref image x y)
                        (if (and ?? (< 128 (aref ?? x y)))
                            nil
                            (rgb->palette (aref rgb x y 0)
                                          (aref rgb x y 1)
                                          (aref rgb x y 2))))))
      image)))

(defun extract-region (original left top right bottom)
  (let ((copy (make-array (list (1+ (- right left)) (1+ (- bottom top)))
                          :element-type '(unsigned-byte 8))))
    (loop for x from left to right
       do (loop for y from top to bottom
             do (setf (aref copy (- x left) (- y top)) (aref original x y))))
    copy))

(defun mob->mono-bits (mob)
  (mapcar #'code-char
          (loop for y from 0 to 20
             appending
               (loop for col from 0 to 2
                  for col-offset = (* 8 col)
                  collecting
                    (reduce #'logior
                            (loop for x from 0 to 7
                               for pixel = (aref mob (+ col-offset x) y)
                               collecting (case pixel
                                            (#xff 0)
                                            (otherwise (expt 2 (- 7 x))))))))))

(defun mob->multi-bits (mob)
  (mapcar #'code-char
          (loop for y from 0 to 20
             appending
               (loop for col from 0 to 2
                  for col-offset = (* 8 col)
                  collecting
                    (reduce #'logior
                            (loop for x from 0 to 3
                               for pixel = (aref mob (+ col-offset (* 2 x)) y)
                               collecting (* (expt 2 (* 2 (- 3 x)))
                                             (case pixel
                                               (8 1) (9 2) (#xff 0)
                                               (otherwise 3)))))))))

(defun tile->bits (tile)
  (do-collect (y to 7)
    (reduce #'logior
            (loop for x from 0 to 7
               collecting (if (zerop (aref tile x y))
                              0
                              (expt 2 (- 7 x)))))))

(defun tile->colour (tile)
  (remove-duplicates
   (remove-if (curry #'= #xff)
              (loop for y from 0 to 7
                 appending
                   (do-collect (x to 7)
                     (aref tile x y))))))

(defun fat-bits (array)
  (destructuring-bind (width height) (array-dimensions array)
    (do-collect (row upto (1- height))
      (do-collect (col upto (1- width))
        (let ((px (aref array col row)))
          (if (= #xff px)
              #\Space
              #\@))))))

(defun image-colours (palette-image
                      &optional
                        (height (array-dimension palette-image 1))
                        (width (array-dimension palette-image 0)))
  "Return the set of distinct colors in use in the paletted image"
  (remove-duplicates
   (remove-if #'null
              (loop for y from 0 to (1- height)
                 appending (loop for x from 0 to (1- width)
                              collecting (aref palette-image x y))))))

(defun mob-colours (mob)
  (image-colours mob 21 24))

(defun ensure-monochrome (mob)
  (let ((all-colours (mob-colours mob)))
    (unless (= 1 (length all-colours))
      (warn "MOB data is hi-res and not monochrome (using ~D; saw ~{~D~^, ~})"
            (car all-colours) all-colours))
    (code-char (car all-colours))))

(defun ensure-1+chrome (mob)
  (let ((all-colours (remove-if (rcurry #'member '(9 10))
                                (mob-colours mob))))
    (unless (or (null all-colours)
                (= 1 (length all-colours)))
      (warn "MOB data has more than 1 distinct colour after brown & orange ~
\(using ~D; saw ~{~D~^, ~})"
            (car all-colours) all-colours))
    (code-char (logior #x80 (or (car all-colours) 0)))))

(defun mob-empty (mob)
  (every (curry #'= #xff)
         (loop for col from 0 upto 23
            append (loop
                      for row from 0 upto 20
                      collect (aref mob col row)))))

(defun mob-hires (mob)
  "Returns T if any two adjacent pixels don't match"
  (not (every #'identity
              (loop for col from 0 upto 11
                 append (loop
                           for row from 0 upto 20
                           collect (= (aref mob (* col 2) row)
                                      (aref mob (1+ (* col 2)) row)))))))

(defun gather-mobs (image-nybbles height width)
  (let (mobs index)
    (loop
       for y-mob from 0 below (/ height 21)
       for y??? = (* y-mob 21)
       do (loop for x-mob from 0 below (/ width 24)
             for x??? = (* x-mob 24)
             for mob-data = (extract-region image-nybbles x??? y??? (+ x??? 23) (+ y??? 20))
             do
               (cond
                 ((mob-empty mob-data)
                  (format *trace-output*
                          "~% ??? Found empty MOB (relative ~D,~D)"
                          x-mob y-mob))
                 ((mob-hires mob-data)
                  (appendf mobs (append (mob->mono-bits mob-data)
                                        (cons (ensure-monochrome mob-data) nil)))
                  (appendf index (cons (cons x??? y???) nil))
                  (format *trace-output*
                          "~% ??? Found a hi-res MOB (relative ~D,~D)"
                          x-mob y-mob))
                 (t (appendf mobs (append (mob->multi-bits mob-data)
                                          (cons (ensure-1+chrome mob-data) nil)))
                    (appendf index (cons (cons x??? y???) nil))
                    (format *trace-output*
                            "~% ??? Found a multicolor MOB (relative ~D,~D)"
                            x-mob y-mob)))))
    (values mobs index)))

(defun tia-player-interpret/strip (pixels)
  (let ((shape nil)
        (colors nil))
    (loop for row from 0 below (second (array-dimensions pixels))
          do (push (reduce #'logior
                           (loop for bit from 0 to 7
                                 collect (if (plusp (aref pixels bit row))
                                             (expt 2 (- 7 bit))
                                             0)))
                   shape)
          do (push (or
                    (first
                     (remove-if #'null (loop for bit from 0 to 7
                                             for color = (aref pixels bit row)
                                             collect (when (plusp color)
                                                       color))))
                    0)
                   colors))
    (values (reverse shape) (reverse colors))))

(defun tia-player-interpret (pixels)
  (loop 
     with shapes
     with colors
     for x from 0 below (/ (array-dimension pixels 0) 8)
     do (multiple-value-bind (shape color)
            (tia-player-interpret/strip 
             (copy-rect pixels
                        (* 8 x) 0
                        8 (array-dimension pixels 1))) 
          (appendf shapes shape)
          (appendf colors color))
     finally (return (values shapes colors))))

(defun 48px-array-to-bytes (pixels)
  (do-collect (column below 6)
    (do-collect (row downfrom (1- (array-dimension pixels 1)) to 0)
      (reduce #'logior
              (do-collect (bit below 8)
                (if (plusp (aref pixels (+ bit (* column 8)) row))
                    (expt 2 (- 7 bit))
                    0))))))

(defun tia-48px-interpret (pixels)
  (let ((shape (48px-array-to-bytes pixels))
        (colors nil))
    (loop for row from 0 below (second (array-dimensions pixels))
       do (push (or (first
                     (remove-if #'null
                                (loop for bit from 0 to 7
                                   for color = (aref pixels bit row)
                                   collect (when (plusp color)
                                             color))))
                    0)
                colors))
    (values shape (reverse colors))))

(defun bits-to-art (byte)
  (check-type byte string)
  (assert (= 8 (length byte)))
  (assert (every (lambda (char) (member char '(#\0 #\1))) byte))
  (substitute #\??? #\0
              (substitute #\??? #\1
                          (make-array 8
                                      :element-type 'character
                                      :initial-contents byte))))

(defun bytes-and-art (bytes)
  (let* ((binary (mapcar (curry #'format nil "~2,8,'0r") bytes))
         (blocks (mapcar #'bits-to-art binary)))
    (format nil "~%	.byte ~{%~a~^, ~}	 ; ~{~a~^??~}" binary blocks)))

(defun byte-and-art (byte)
  (let* ((binary (format nil "~8,'0b" byte))
         (blocks (bits-to-art binary)))
    (format nil "~%	.byte %~a	; ~a" binary blocks)))

(defun assembler-label-name (string)
  (let ((result (cl-ppcre:regex-replace-all
                 "_(\\w)"
                 (substitute #\_ #\- string)
                 (lambda (s start end match-start match-end reg-start reg-end)
                   (declare (ignore match-start match-end reg-end))
                   (concatenate 'string
                                (subseq s 0 start)
                                (string (char-upcase (char s (elt reg-start 0))))
                                (subseq s end))))))
    (unless (upper-case-p (char result 0))
      (setf (char result 0) (char-upcase (char result 0))))
    (when (search "Brfp" result)
      (setf result (cl-ppcre:regex-replace-all "Brfp" result "BRFP")))
    result))

(defun tia-48px-preview (image-pixels)
  (let ((shape (48px-array-to-bytes image-pixels))
        (height (second (array-dimensions image-pixels))))
    (loop for row from (1- height) downto 0
       for row-bytes = (do-collect (column below 6)
                         (elt (elt shape column) row))
       collecting (reduce (curry #'concatenate 'string)
                          (mapcar #'bits-to-art (mapcar
						 (curry #'format nil "~8,'0b")
						 row-bytes))))))

(defun pathname-base-name (pathname)
  (subseq (pathname-name pathname)
          0 (position #\. (pathname-name pathname))))

(define-constant +atari-color-names+
    '(COLGRAY COLYELLOW COLBROWN COLORANGE COLRED COLMAGENTA
      COLPURPLE COLINDIGO COLBLUE COLTURQUOISE COLCYAN COLTEAL
      COLSEAFOAM COLGREEN COLSPRINGGREEN COLGOLD)
  :test 'equalp)

(defun atari-color-name (index)
  (elt +atari-color-names+ index))

(defun atari-colu (byte)
  (let ((co (ash (logand byte #x78) -3))
        (lu (ash (logand byte #x07) 1)))
    (list (atari-color-name co) lu)))

(defun compile-tia-48px (png-file out-dir height image-pixels)
  (let ((out-file-name (merge-pathnames
                        (make-pathname :name
                                       (pathname-name png-file)
                                       :type "s")
                        out-dir)))
    (format *trace-output* "~% Ripping TIA 48px graphics from 48??~D image"
            height)
    (with-output-to-file (source-file out-file-name
                                      :if-exists :supersede)
      (multiple-value-bind (shape colors) (tia-48px-interpret image-pixels)
        (format source-file ";;; -*- fundamental -*-
;;; Compiled sprite data from ~a
;;; Edit the original (probably Source/Art/~:*~a.png), editing this file is futile.

;;; Bitmap preview:
~{~%;;;   ~a~}
~a:	.block
	Height = ~d
	Width = 48
Shape:~{~{~a~}~2%~}
;CoLu:~{~%	;.colu ~{~a, $~1x~}~}
	.bend
"
                (pathname-name png-file)
                (tia-48px-preview image-pixels)
                (assembler-label-name (pathname-base-name png-file))
                height
                (mapcar (curry #'mapcar #'byte-and-art) shape)
                (mapcar #'atari-colu colors)))
      (format *trace-output* "~% Done writing to ~A" out-file-name))))

(defun reverse-7-or-8 (shape)
  (let* ((height (length shape))
         (group-height (if (zerop (mod height 7)) 7 8)))
    (loop for group from 0 below height by group-height
          append (loop for line from (1- group-height) downto 0
                       collecting (elt shape (+ group line))))))

(defun reverse-16 (shape)
  (let* ((height (length shape))
         (group-height 16))
    (loop for group from 0 below height by group-height
          append (loop for line from (1- group-height) downto 0
                       collecting (elt shape (+ group line))))))

(defun compile-tia-player (png-file out-dir 
                           height width image-pixels)
  (let ((out-file-name (merge-pathnames
                        (make-pathname :name
                                       (pathname-name png-file)
                                       :type "s")
                        out-dir)))
    (format *trace-output* "~% Ripping TIA Player graphics from ~D??~D image"
            width height)
    (finish-output *trace-output*)
    (with-output-to-file (source-file out-file-name
                                      :if-exists :supersede)
      (multiple-value-bind (shape colors) (tia-player-interpret image-pixels)
        (format source-file ";;; -*- fundamental -*-
;;; Compiled sprite data from ~a
;;; Edit the original (probably art/sprites/~:*~a.xcf),
;;; editing this file is futile.

~a:	.block
	Height = ~d
	Width = ~d
Shape:~{~a~}
;CoLu:~{~%	;.colu ~{~a, $~1x~}~}
	.bend
"
                (pathname-name png-file)
                (assembler-label-name (pathname-base-name png-file))
                height width
                (if (and (mod height 16) (> height 200))
                    (mapcar #'byte-and-art (reverse-16 shape))
                    (mapcar #'byte-and-art (reverse-7-or-8 shape)))
                
                (mapcar #'atari-colu colors)))
      (format *trace-output* "~% Done writing to ~A" out-file-name))))

(defun pretty-mob-data-listing-vic2 (mob)
  (mapcar #'bytes-and-art
          (group-into-3
           (map 'list #'char-code mob))))

(defun mob-index+bitmap+color-sets (more-mobs)
  (loop for mob = (subseq more-mobs 0 63)
        for more on more-mobs by (curry #'nthcdr 64)
        for i from 0
        collect (list i
                      (pretty-mob-data-listing-vic2 mob)
                      (char-code (last-elt mob)))))

(defun compile-mob (png-file out-dir height width image-nybbles)
  (let ((out-file (merge-pathnames
                   (make-pathname :name
                                  (pathname-name png-file)
                                  :type "s")
                   out-dir)))
    (format *trace-output* "~% Ripping MOBs from ~D??~D sprite" width height)
    (with-output-to-file (binary-file out-file
                                      :element-type '(unsigned-byte 8)
                                      :if-exists :supersede)
      (multiple-value-bind (mobs index) (gather-mobs image-nybbles height width)
        (assert (>= 6 (length index)) nil
                "There can be at most 6 (non-empty) MOBs in a sprite; ~
got ~:D MOB~:P"
                (length index))
        (format *trace-output* "~%Writing ~:D MOB~:P" (length index))
        (when (< 1 (length index))
          (warn "MOBs not stacked vertically won't work yet. ~
Proceed with caution."))
        (format binary-file ";;; -*- fundamental -*-
;;; Compiled sprite data from ~a
;;; Edit the original (probably art/sprites/~:*~a.xcf),
;;; editing this file is futile.

          .byte ~d	; length of index
          .byte ~{$~x~^, ~}	; MOBs in sprite
          .align 64
~{~{
          ;; MOB ~x data
~{~a~}
           .byte ~d	; Sprite distinct color
~}~}"
                (pathname-name png-file)
                (length index)
                (mapcar #'car index)  ; TODO: capture relative positioning
                (mob-index+bitmap+color-sets mobs)))
      (format *trace-output* "~% Done writing to ~A" out-file))))

(defgeneric compile-font-generic (machine-type format source-file-base-name font-input)
  (:method (machine-type format source-file-base-name font-input)
    (warn "No handler for converting art into ~a format to create ~a" format source-file-base-name)
    (with-output-to-file (source-file (make-source-file-name source-file-base-name)
                                      :if-exists :supersede)
      (format source-file ";;; -*- asm -*-
;;; TODO: write the function to generate this file's contents
 * = 0 ~% brk~%"))))

(defun tia-font-interpret (pixels x y)
  (loop for byte from 4 downto 0
     collecting
       (reduce #'logior
               (loop for bit from 0 to 3
                  collect
                    (if (plusp (aref pixels (+ bit (* x 4)) (+ byte (* y 5))))
                        (expt 2 (- 3 bit))
                        0)))))

(defun png->bits (png-file)
  (let ((height (png-read:height png-file))
        (width (png-read:width png-file))
        (rgb (png-read:image-data png-file))
        (?? (png-read:transparency png-file)))
    (check-type height (integer 0 *))
    (check-type width (integer 0 *))
    (check-type rgb array)
    (check-type ?? (or null array))
    (destructuring-bind (w h bpp) (array-dimensions rgb)
      (unless (and (= h height) (= w width) (= bpp 4))
        (error "WTF? File size mismatches contents"))
      (let ((image (make-array (list width height) :element-type '(unsigned-byte 1))))
        (loop for y from 0 below height
           do (loop for x from 0 below width
                 do (setf (aref image x y)
                          (cond ((and ?? (< 128 (aref ?? x y))) 0)
                                ((> (* 3 128)
                                    (+ (aref rgb x y 0) (aref rgb x y 1) (aref rgb x y 2)))
                                 1)
                                (t 0)))))
        image))))

(defun tia-font-guide (source-file pixels chars-width)
  (dotimes (line 8)
    (dotimes (row 5)
      (terpri source-file)
      (princ ";;; " source-file)
      (loop for i from (+ (* line 6) 0) to (min 47
                                                (+ (* line 6) 5))
         for column = (mod i 12)
         for x = (mod i chars-width)
         for y = (floor i chars-width)
         do (princ
             (subseq
              (elt (mapcar #'bits-to-art
                           (mapcar (lambda (byte)
                                     (format nil "~2,8,'0r" byte))
                                   (tia-font-interpret pixels x y)))
                   (- 4 row))
              4)
             source-file)
         do (princ #\space source-file)))
    (terpri source-file)))

(defun tia-font-write (source-file pixels chars-width bit-shift)
  (loop for i from 0 to 47
     for x = (mod i chars-width)
     for y = (floor i chars-width)
     do (format source-file "~%	;; char #~x ~:[(right)~;(left)~]~{~a~}"
                i (= 4 bit-shift)
                (mapcar #'byte-and-art
                        (mapcar (rcurry #'ash bit-shift)
                                (tia-font-interpret pixels x y))))))

(defmethod compile-font-generic ((machine-type (eql 2600))
                                 format source-file-base-name font-input)
  (let* ((png-image (png-read:read-png-file font-input))
         (chars-width (/ (png-read:width png-image) 4))
         (pixels (png->bits png-image)))
    (with-output-to-file (source-file (make-source-file-name source-file-base-name)
                                      :if-exists :supersede)
      (format source-file ";;; -*- asm -*-
;;; Font data compiled from ~a
;;; This is a generated file; editing it would be futile~2%"
              font-input)
      (assert (= 48 (* chars-width (/ (png-read:height png-image) 5))))
      (format source-file "~%;;;~|~%TIAFont:
;; Overview: (font follows, inverted, each char repeated for each nybble)")
      (tia-font-guide source-file pixels chars-width)
      (format source-file "~%;;;~|~%TIAFontLeft:")
      (tia-font-write source-file pixels chars-width 4)
      (format source-file "~%;;;~|~%TIAFontRight:~%")
      (tia-font-write source-file pixels chars-width 0)
      (format source-file "~2%;;; end of file.~%")
      (format *trace-output* "~&Wrote ~a (from ~a)" source-file-base-name font-input))))

(defun compile-font-command (source-file-name font-input)
  (destructuring-bind (obj genr source-file-base-name) (split-sequence #\/ source-file-name)
    (destructuring-bind (font format$ s) (split-sequence #\. source-file-base-name)
      (assert (equal font "Font"))
      (assert (equal s "s"))
      (assert (equal obj "Source"))
      (assert (equal genr "Generated"))
      (let ((*machine* (or *machine* 2600))
            (format (make-keyword format$)))
        (compile-font-generic *machine* format source-file-base-name font-input)))))

(defun compile-font-8??8 (png-file out-dir height width image-nybbles)
  (declare (ignore height))
  (let ((out-file (merge-pathnames
                   (make-pathname :name (pathname-name png-file)
                                  :type "s")
                   out-dir)))
    (with-output-to-file (src-file out-file :if-exists :supersede)
      (format src-file ";;; -*- asm -*-
;;; Generated file; editing is useless. Source is ~a (derived from the matching XCF)
;;;

VIC2Font:
"
              png-file)
      (let ((colour (loop for char from 0 to #xff
                       for x-cell = (mod (* char 8) width)
                       for y-cell = (* 8 (floor (* char 8) width))
                       for char-data = (extract-region image-nybbles
                                                       x-cell y-cell (+ 7 x-cell) (+ 7 y-cell))
                       do (format src-file
                                  "~%	;; 		 character ~d ($~:*~x)~{~a~}"
                                  char
                                  (map 'list #'byte-and-art
                                       (tile->bits char-data)))
                       collect (tile->colour char-data))))

        (unless (= 1 (length (remove-if #'null (remove-duplicates colour :test 'equalp))))
          (warn "Font with multicolor data detected?"))
        (format *error-output* "~% Wrote binary font (monochrome) data to ~A." out-file)))))

(defun tile-cell-vic2-x (cell width)
  "Each tile's data is arranged into four cells, like so:

 0 1
 2 3

This gives the X position of the top-left corner of a 16??16 pixel tile
cell (where the cell's number is (+ (* tile 4) cell)) within an image
of the given width."
  (mod (+ (* (floor cell 4) 16)
          (* (mod cell 2) 8)) width))

(defun tile-cell-vic2-y (cell width)
  (+ (* (floor (floor cell 4) (floor width 16)) 16)
     ;; even cells are on alternate rows
     (* (mod cell 2) 8)))

;;; Unit tests. This actually took me a while to get right!

(dotimes (i 62)
  (assert (= (tile-cell-vic2-y (* i 4) 16) (* 16 i)) nil
          "Tile ~D in 16px image should start at ~D, but TILE-CELL-VIC2-Y reports ~D"
          i (* 16 i) (tile-cell-vic2-y (* 4 i) 16)))

(loop for width in '(16 32 64 128)
      do (dotimes (i #xff)
           (assert (> (/ 16384 width) (tile-cell-vic2-y i width))
                   nil "The TILE-CELL-VIC2-Y function must return a valid value;
value ~D for tile-cell ~D is too far down for an image with width ~D" (tile-cell-vic2-y i width) i width)))

(defun compile-atari-8??8 (png-file target-dir height width)
  (let ((out-file (merge-pathnames
                   (make-pathname :name
                                  (pathname-name png-file)
                                  :type "s")
                   target-dir)))
    (with-output-to-file (src-file out-file :if-exists :supersede)
      (format src-file ";;; This is a generated file. Editing is futile.~2%")
      (loop for x1 from 0 below width by 8
            for y1 from 0 below height by 8
            for i from 0
            do (loop for y0 from 7 downto 0
                     do (format src-file "~t.byte %~0,8b" 0))))))

(defun compile-tileset-64 (png-file out-dir height width image-nybbles)
  (declare (ignore height))
  (let ((out-file (merge-pathnames
                   (make-pathname :name
                                  (concatenate 'string "tiles."
                                               (pathname-name png-file))
                                  :type "s")
                   out-dir)))
    (with-output-to-file (src-file out-file :if-exists :supersede)
      (let ((colour (loop for cell from 0 to #xff
                          for x-cell = (tile-cell-vic2-x cell width)
                          for y-cell = (tile-cell-vic2-y cell width)
                          for tile-data = (extract-region image-nybbles x-cell y-cell (+ 7 x-cell) (+ 7 y-cell))
                          do (format src-file "~{~a~}"
                                     (map 'list #'bytes-and-art (tile->bits tile-data)))
                          collect (tile->colour tile-data))))
        
        (format *error-output* "~% Tileset with multiple colours found")
        (loop for cell in colour
              for i from 0 upto #xff
              do (cond
                   ((null cell) (princ #\NUL src-file))
                   ((null (cdr cell)) (princ (code-char (car cell)) src-file))
                   (t (princ (code-char (car cell)) src-file)
                      (warn "Tile ~D (~:*$~2,'0X) cell at (~:D??~:D) uses colours: ~{~D, ~D~}; using ~D"
                            (floor i 4) (floor i 4)
                            (tile-cell-vic2-x i width) (tile-cell-vic2-y i width)
                            cell (car cell)))))
        (format *error-output* "~% Wrote binary tileset data to ~A." out-file)))))

#+ (or)
(defun compile-tileset (png-file out-dir height width image-nybbles)
  (case *machine*
    ((64 128) (compile-tileset-64 png-file out-dir height width image-nybbles))
    (otherwise (error "Tile set compiler not set up yet for ~a" (machine-long-name)))))

(defun monochrome-lines-p (palette-pixels height width)
  (every
   #'identity
   (loop for row from 0 below height
      for colors = (remove-duplicates
                    (remove-if
                     #'zerop
                     (loop for column from 0 below width
                        collect (aref palette-pixels column row)))
                    :test #'=)
      collect (or (null colors)
                  (= 1 (length colors))))))

(defgeneric dispatch-png% (machine png-file target-dir
                           png height width ?? palette-pixels))

#+mcclim
(defmethod dispatch-png% :before (machine png-file target-dir
                                  png height width ?? palette-pixels)
  (when (clim:extended-output-stream-p *trace-output*)
    (clim:formatting-table (*trace-output*)
                           (clim:formatting-row (*trace-output*)
                                                (clim:formatting-cell (*trace-output*)
                                                                      (clim:with-text-face (*trace-output* :bold)
                                                                        (princ "PNG file: " *trace-output*))
                                                                      (clim:present png-file 'pathname :stream *trace-output*)))
                           (clim:formatting-row (*trace-output*)
                                                (clim:formatting-cell (*trace-output*)
                                                                      (clim:draw-pattern*
                                                                       *trace-output*
                                                                       (clim:make-pattern-from-bitmap-file png-file
                                                                                                           :format :png)
                                                                       0 0))))))

(defun monochrome-image-p (palette-pixels)
  (let ((answer (> 3 (print (length (image-colours palette-pixels))))))
    (format *trace-output* "~&Monochrome-Image-P? ~a" answer)
    answer))

(defmethod dispatch-png% ((machine (eql 2600)) png-file target-dir
                          png height width ?? palette-pixels)
  (let ((monochrome-lines-p (monochrome-lines-p palette-pixels height width)))
    (cond
      ((and (zerop (mod height 5))
            (zerop (mod width 4))
            (= 48 (* (/ height 5) (/ width 4)))
            (monochrome-image-p palette-pixels))
       (format *trace-output* "~% Image ~A seems to be a font" png-file)
       (compile-font-8??8 png-file target-dir height width palette-pixels))
      
      ((and (= width 48))
       (format *trace-output* "~% Image ~a seems to be a 48px ~
 ???high-resolution??? bitmap"
               png-file)
       (compile-tia-48px png-file target-dir height palette-pixels))
      
      ((and (zerop (mod height 7))
            (zerop (mod width 4))
            (< 10 (* (/ height 7) (/ width 4)))
            monochrome-lines-p)
       (format *trace-output* "~% Image ~A seems to be a tileset" png-file)
       (compile-tileset png-file target-dir height width palette-pixels))
      
      ((and (zerop (mod width 8))
            (or (zerop (mod height 7))
                (zerop (mod height 8))))
       (format *trace-output* "~% Image ~A seems to be sprite (player) data"
               png-file)
       (compile-tia-player png-file target-dir height width palette-pixels))
      
      ((and (zerop (mod width 8))
            (zerop (mod height 8)))
       (format *trace-output* "~% Image ~A seems to be Atari 8??8 tiles" png-file)
       (compile-atari-8??8 png-file target-dir height width))
      
      (t (error "Don't know how to deal with image with dimensions ~
~:D??~:D pixels ~:[with~;without~] monochrome lines"
                width height monochrome-lines-p)))))

(defmethod dispatch-png% ((machine (eql 64)) png-file target-dir
                          png height width ?? palette-pixels)
  (cond
    ((and (zerop (mod height 8))
          (zerop (mod width 8))
          (= 256 (* (/ height 8) (/ width 8)))
          (monochrome-image-p palette-pixels))
     (format *trace-output* "~% Image ~A seems to be a font" png-file)
     (compile-font-8??8 png-file target-dir height width palette-pixels))
    
    ((and (zerop (mod height 16))
          (zerop (mod width 16))
          (>= 64 (* (/ height 16) (/ width 16))))
     (format *trace-output* "~% Image ~A seems to be a tileset" png-file)
     (compile-tileset png-file target-dir height width palette-pixels))
    
    ((and (zerop (mod height 21))
          (zerop (mod width 24)))
     (format *trace-output* "~% Image ~A seems to be sprite MOB data" png-file)
     (compile-mob png-file target-dir height width palette-pixels))
    
    (t (error "Don't know how to deal with image with dimensions ~:D??~:D pixels"
              width height))))

(defun dispatch-png (png-file target-dir)
  (with-simple-restart (retry-png "Retry processing PNG file ~a" png-file)
    (format *trace-output* "~%Reading PNG image ~a???" png-file)
    (force-output *trace-output*)
    (let* ((png (png-read:read-png-file png-file))
           (height (png-read:height png))
           (width (png-read:width png))
           (?? (png-read:transparency png))
           (palette-pixels (png->palette height width
                                         (png-read:image-data png)
                                         ??)))
      (dispatch-png% *machine* png-file target-dir
                     png height width ?? palette-pixels))))

(defun write-7800-binary (index-out bytes-lists)
  (with-output-to-file (binary index-out   
                               :element-type '(unsigned-byte 8)
                               :if-exists :supersede)
    (let ((page-length (length (first bytes-lists))))
      (format *trace-output* "~&~A: Writing ~:D pages, each of which is ~:D bytes (out of 256 possible) ???"
              index-out (length bytes-lists) page-length)
      (finish-output *trace-output*)
      (dolist (bytes-list bytes-lists)
        (dolist (byte bytes-list)
          (write-byte byte binary))
        (when (< page-length #x100)
          (dotimes (i (- #x100 page-length))
            (write-byte 0 binary))))
      (format *trace-output* " done.~%"))))

(defun interleave-7800-bytes (bytes-lists)
  ;; Interleave and reverse bytes
  (loop for j below (apply #'max (mapcar #'length bytes-lists))
        collect (loop for i from (1- (length bytes-lists)) downto 0
                      collect (if (< j (length (elt bytes-lists i)))
                                  (elt (elt bytes-lists i) j)
                                  0))))

(defgeneric parse-7800-object (mode png &key width height palette))

(defun extract-regions (pixels width height)
  (let ((images (list)))
    (dotimes (y (floor (/ (array-dimension pixels 1) height)))
      (dotimes (x (/ (array-dimension pixels 0) width))
        (push (extract-region pixels
                              (* x width) (* y height)
                              (1- (* (1+ x) width))
                              (1- (* (1+ y) height)))
              images)))
    (reverse images)))

(defun pixels-into-palette (pixels palette &optional x0 y0 i)
  ;; expects PIXELS to be a single row
  (let* ((width (array-dimension pixels 0))
         (output (make-array (list width) :element-type '(unsigned-byte 8))))
    (dotimes (x width)
      (let ((index (position (aref pixels x 0) palette)))
        (assert index (index) "Color value ~x at ~d, ~d ~anot found in palette, error" (aref pixels x 0)
                (if x0 (+ x0 x) x) (if y0 y0 "?") (if i (format nil "in image ~d " i) ""))
        (setf (aref output x) index)))
    output))

(defmethod parse-7800-obect ((mode (eql :160a)) pixels &key width height palette)
  (assert (>= 4 (length palette)))
  (let ((total-width (array-dimension pixels 0))
        (total-height (1- (array-dimension pixels 1))))
    (assert (zerop (mod total-height height)) (total-height)
            "Image height must be modulo ~:Dpx plus 1px for palette strip, but got ~:Dpx"
            height (1+ total-height))
    (assert (zerop (mod total-width width)) (total-width)
            "Image width must be module ~:Dpx, but get ~:Dpx" width total-width)
    (assert (zerop (mod width 4)) (width)
            "Width for mode 160A must be modulo 4px, not ~:Dpx" width))
  (let* ((byte-width (/ width 4))
         (images (extract-regions pixels width height))
         (bytes-lists (list)))
    (dolist (image images)
      (dotimes (b byte-width)
        (let ((bytes (list)))
          (dotimes (y height)
            (let* ((byte-pixels (extract-region image
                                                (* b 4) y
                                                (1- (* (1+ b) 4)) y))
                   (indices (pixels-into-palette byte-pixels palette (* b 4) y)))
              (push (logior
                     (ash (aref indices 0) 6)
                     (ash (aref indices 1) 4)
                     (ash (aref indices 2) 2)
                     (aref indices 3))
                    bytes)))
          (push bytes bytes-lists))))
    (reverse bytes-lists)))

(defun 160b-palette-monkey (values)
  (dotimes (i (length values))
    (setf (elt values i) (position (elt values i) '(0 1 2 3 0 4 5 6 0 7 8 9 0 10 11 12))))
  values)

(defmethod parse-7800-object ((mode (eql :160b)) pixels &key width height palette)
  (assert (= 13 (length palette)))
  (let ((total-width (array-dimension pixels 0))
        (total-height (1- (array-dimension pixels 1))))
    (assert (zerop (mod total-height height)) (total-height)
            "Image height must be modulo ~:Dpx plus 1px for palette strip, but got ~:Dpx"
            height (1+ total-height))
    (assert (zerop (mod total-width width)) (total-width)
            "Image width must be module ~:Dpx, but get ~:Dpx" width total-width)
    (assert (zerop (mod width 4)) (width)
            "Width for mode 160B must be modulo 2px, not ~:Dpx" width))
  (let* ((byte-width (/ width 2))
         (images (extract-regions pixels width height))
         (bytes-lists (list))
         (i 0)) 
    (dolist (image images)
      (dotimes (b byte-width)
        (let ((bytes (list)))
          (dotimes (y height)
            (let* ((byte-pixels (extract-region image
                                                (* b 2) y
                                                (1+ (* b 2)) y))
                   (indices (160b-palette-monkey
                             (pixels-into-palette byte-pixels palette (* b 2) y i))))
              ;; pixel:bit order = A: 3276, B: 1054
              ;;; which translates to bit:pixel order =
              ;; A1 A0 B1 B0 A3 A2 B3 B2
              (let ((a (aref indices 0))
                    (b (aref indices 1)))
                (flet ((truthy (n) (if (zerop n) 0 1)))
                  (push (logior (ash (truthy (logand a #x2)) 7)
                                (ash (truthy (logand a #x1)) 6)
                                (ash (truthy (logand b #x2)) 5)
                                (ash (truthy (logand b #x1)) 4)
                                (ash (truthy (logand a #x8)) 3)
                                (ash (truthy (logand a #x4)) 2)
                                (ash (truthy (logand b #x8)) 1)
                                (ash (truthy (logand b #x4)) 0))
                        bytes)))))
          (push bytes bytes-lists)))
      (incf i))
    (reverse bytes-lists)))

(defmethod parse-7800-object ((mode (eql :320a)) pixels &key width height palette)
  (declare (ignore palette))
  (let ((total-width (array-dimension pixels 0))
        (total-height (array-dimension pixels 1)))
    (unless (zerop (mod total-height height)) 
      (warn "Image height must be modulo ~:Dpx, but got ~:Dpx"
            height (1+ total-height)))
    (assert (zerop (mod total-width width)) (total-width)
            "Image width must be module ~:Dpx, but get ~:Dpx" width total-width)
    (assert (zerop (mod width 8)) (width)
            "Width for mode 320A must be modulo 8px, not ~:Dpx" width))
  (let* ((byte-width (/ width 8))
         (images (extract-regions pixels width height))
         (bytes-lists (list)))
    (dolist (image images)
      (dotimes (b byte-width)
        (let ((bytes (list)))
          (dotimes (y height)
            (let ((byte-pixels (extract-region image
                                               b y
                                               (+ b 7) y)))
              (push (reduce #'logior
                            (mapcar (lambda (bit)
                                      (ash (if (zerop (aref byte-pixels (- 7 bit) 0))
                                               0 1) 
                                           bit))
                                    '(7 6 5 4 3 2 1 0)))
                    bytes)))
          (push bytes bytes-lists))))
    (reverse bytes-lists)))

(defmethod parse-7800-object ((mode (eql :320b)) pixels &key width height palette)
  (assert (>= 4 (length palette)))
  (let ((total-width (array-dimension pixels 0))
        (total-height (1- (array-dimension pixels 1))))
    (assert (zerop (mod total-height height)) (total-height)
            "Image height must be modulo ~:Dpx plus 1px for palette strip, but got ~:Dpx"
            height (1+ total-height))
    (assert (zerop (mod total-width width)) (total-width)
            "Image width must be module ~:Dpx, but get ~:Dpx" width total-width)
    (assert (zerop (mod width 4)) (width)
            "Width for mode 320B must be modulo 4px, not ~:Dpx" width))
  (let* ((byte-width (/ width 4))
         (images (extract-regions pixels width height))
         (bytes-lists (list)))
    (dolist (image images)
      (dotimes (b byte-width)
        (let ((bytes (list)))
          (dotimes (y height)
            (let* ((byte-pixels (extract-region image
                                                (* b 4) y
                                                (1- (* (1+ b) 4)) y))
                   (indices (pixels-into-palette byte-pixels palette (* b 4) y)))
              (push (logior
                     (ash (aref indices 0) 6)
                     (ash (aref indices 1) 4)
                     (ash (aref indices 2) 2)
                     (aref indices 3))
                    bytes)))
          (push bytes bytes-lists))))
    (reverse bytes-lists)))

(defmethod parse-7800-object ((mode (eql :320c)) pixels &key width height palette)
  (assert (>= 8 (length palette)))
  (let ((total-width (array-dimension pixels 0))
        (total-height (1- (array-dimension pixels 1))))
    (assert (zerop (mod total-height height)) (total-height)
            "Image height must be modulo ~:Dpx plus 1px for palette strip, but got ~:Dpx"
            height (1+ total-height))
    (assert (zerop (mod total-width width)) (total-width)
            "Image width must be module ~:Dpx, but get ~:Dpx" width total-width)
    (assert (zerop (mod width 4)) (width)
            "Width for mode 320C must be modulo 4px, not ~:Dpx" width))
  (let* ((byte-width (/ width 4))
         (images (extract-regions pixels width height))
         (bytes-lists (list)))
    (dolist (image images)
      (dotimes (b byte-width)
        (let ((bytes (list)))
          (dotimes (y height)
            (let* ((byte-pixels (extract-region image
                                                (* b 4) y
                                                (1- (* (1+ b) 4)) y))
                   (indices (pixels-into-palette byte-pixels palette (* b 4) y))
                   (px-pair-palette (mapcar (lambda (pair)
                                              (cond
                                                ((and (zerop (car pair))
                                                      (zerop (cdr pair)))
                                                 0)
                                                ((zerop (car pair))
                                                 (ash (logand (cdr pair) #x06) -1))
                                                (t
                                                 (ash (logand (car pair) #x06) -1))))
                                            (list (cons (aref indices 0)
                                                        (aref indices 1))
                                                  (cons (aref indices 2)
                                                        (aref indices 3))))))
              (push (logior
                     (ash (logand (aref indices 0) #x01) 7)
                     (ash (logand (aref indices 1) #x01) 6)
                     (ash (logand (aref indices 2) #x01) 5)
                     (ash (logand (aref indices 3) #x01) 4)
                     (ash (first px-pair-palette) 2)
                     (second px-pair-palette))
                    bytes)))
          (push bytes bytes-lists))))
    (reverse bytes-lists)))

(defmethod parse-7800-object ((mode (eql :320d)) png &key width height palette)
  (error "unimplemented mode ~A" mode))

(defun grab-7800-palette (mode png)
  (when (member mode '(:320a :320d))
    (return-from grab-7800-palette nil))
  (let* ((palette-size (ecase mode
                         (:160a 4)
                         (:160b 13)
                         (:320b 4)
                         (:320c 8)))
         (last-row (1- (array-dimension png 1)))
         (palette-strip (extract-region png
                                        0 last-row
                                        palette-size last-row)))
    (let ((palette (loop for i below palette-size
                         collect (aref palette-strip i 0))))
      (if (eql mode :160b)
          (format *trace-output* "~&Palette detected: $~2,'0x; ~{$~2,'0x $~2,'0x $~2,'0x~^, ~}" (first palette) (rest palette))
          (format *trace-output* "~&Palette detected: ~{$~2,'0x $~2,'0x $~2,'0x $~2,'0x~^, ~}" palette))
      palette)))

(defun parse-into-7800-bytes (art-index)
  (let ((bytes (list)))
    (dolist (art-item art-index)
      (destructuring-bind (mode png-name width-px height-px) art-item
        (format *trace-output* "~&~A: parsing in mode ~A ???" png-name mode)
        (let* ((png (png-read:read-png-file png-name))
               (height (png-read:height png))
               (width (png-read:width png))
               (?? (png-read:transparency png))
               (palette-pixels (png->palette height width
                                             (png-read:image-data png)
                                             ??))
               (palette (grab-7800-palette mode palette-pixels)))
          (appendf bytes
                   (parse-7800-object mode palette-pixels :width width-px :height height-px
                                                          :palette palette)))
        (format *trace-output* " ??? Done.")))
    (reverse bytes)))

(defun read-7800-art-index (index-in)
  (let ((png-list (list)))
    (format *trace-output* "~&~A: reading art index ???" (enough-namestring index-in))
    (with-input-from-file (index index-in)
      (loop for line = (read-line index nil)
            while line
            do (let ((line (string-trim #(#\Space #\Tab #\Newline #\Return #\Page)
                                        line))) 
                 (cond
                   ((emptyp line) nil)
                   ((char= #\# (char line 0)) nil)
                   (t (destructuring-bind (png-name mode cell-size)
                          (split-sequence #\Space line :remove-empty-subseqs t :test #'char=)
                        (destructuring-bind (width-px height-px)
                            (split-sequence #\?? cell-size :test #'char=)
                          (push (list (make-keyword mode) 
                                      (make-pathname :defaults index-in
                                                     :name (subseq png-name 0 
                                                                   (position #\. png-name :from-end t))
                                                     :type "png")
                                      (parse-integer width-px) 
                                      (parse-integer height-px))
                                png-list))))))))
    (format *trace-output* " done. Got ~:D PNG files to read." (length png-list))
    (reverse png-list)))

(defun compile-art-7800 (index-out index-in)
  (let ((*machine* 7800))
    (write-7800-binary index-out
                       (interleave-7800-bytes
                        (parse-into-7800-bytes
                         (read-7800-art-index index-in))))))

(defun compile-art (index-out &rest png-files)
  (let ((*machine* (or (machine-from-filename index-out)
		   2600)))
    (dolist (file png-files)
      (dispatch-png file index-out))))

(defun def->tile-id (tile-definition x y)
  (destructuring-bind (tag x??? y??? x??? y???) tile-definition
    (declare (ignore tag x??? y???))
    (let ((set-width (reduce #'max (mapcar #'fourth *tileset*))))
      (+ x??? x (* set-width (+ y??? y))))))

(defun tile-art-value (tile-info)
  (let ((tile (or (getf tile-info :art)
                  (if (getf tile-info :wall) "WALL" "FLOOR"))))
    (let ((candidates (remove-if-not (lambda (def)
                                       (equalp (string (car def)) tile))
                                     *tileset*)))
      (unless candidates
        (error "Undefined tile art: ~A~%Wanted one of: ~S"
               tile
               (sort (mapcar #'string (remove-duplicates (mapcar #'car *tileset*)
                                                         :test #'equalp))
                     #'string<)))
      (let ((candidates (loop for each on
                                       (remove-if-not (lambda (def)
                                                        (destructuring-bind (tag x??? y??? x??? y???) def
                                                          (declare (ignore tag))
                                                          (and (= x??? x???) (= y??? y???))))
                                                      (reverse *tileset*))
                              by #'cdr appending each)))
        (let ((chosen (nth (random (length candidates)) candidates)))
          (def->tile-id chosen 0 0))))))

(defun tile-control-value (tile)
  (logand (if (getf tile :wall) #x80 0)
          (if (getf tile :swim) #x40 0)))

(defvar *tia-tiles*)
(defvar *tia-pf-colors*)

(defun bitmaps-for-tia-merged-tiles (merged-tiles)
  (check-type merged-tiles hash-table)
  (let* ((tiles (sort-hash-table-by-values merged-tiles))
         (raw-tile-count (array-dimension *tia-tiles* 0))
         (tile-bitmaps (make-array (list (length tiles) 7))))
    (loop
       for tile in tiles
       for i from 0
       do (dotimes (line 7)
            (destructuring-bind (left right big-endian-p) tile
              (assert (<= left raw-tile-count))
              (assert (<= right raw-tile-count))
              (let ((byte (logior (ash (aref *tia-tiles* left line) 4)
                                  (aref *tia-tiles* right line))))
                (setf (aref tile-bitmaps i line)
                      (if big-endian-p
                          byte
                          (reverse-byte byte)))))))
    tile-bitmaps))

(defun write-tia-bitmaps-scan-line (tile-bitmaps scan-line)
  (check-type tile-bitmaps (array t (* 7)))
  (check-type scan-line (integer 0 6))
  (format t "~%~|~%TilesScan~d:
	;; ~:(~:*~:r~) three scan-lines (of 7 triples) in each group of 21"
          (1+ scan-line))
  (format t "~{~%	.byte $~2,'0x~^, ~2,'0x~^, ~2,'0x~^, ~2,'0x~^,~
    ~2,'0x~^, ~2,'0x~^, ~2,'0x~^, ~2,'0x~}"
          (loop
             for i from 0 below (array-dimension tile-bitmaps 0)
             collect (let ((byte (aref tile-bitmaps i scan-line)))
                       (check-type byte (integer 0 255))
                       byte))))

(defun write-tia-tiles-trailer (tile-count)
  (check-type tile-count (integer 2 255))
  (format t "
          TilesEnd = *

          TileCount = ~d"
          tile-count))

(defun write-tia-tile-bitmaps-interleaved (merged-tiles)
  (check-type merged-tiles hash-table)
  (format t "~%~|~%Tiles:
          ;; Tile bitmap data is interleaved by scan-line within each
          ;; seven-triple-line grouping.~%")
  (let ((tile-bitmaps (bitmaps-for-tia-merged-tiles merged-tiles)))
    (check-type tile-bitmaps (array t (* 7)))
    (dotimes (scan-line 7)
      (write-tia-bitmaps-scan-line tile-bitmaps scan-line)))
  (write-tia-tiles-trailer (hash-table-count merged-tiles)))

(defconstant +tia-tile-limit+ 128
  "The maximum distinct tile-pairs allowed in one memory bank for the 2600.")

(defvar *merged-tiles*)
(defvar *tile-counter*)

(defun color-average (colors)
  (let ((colors (remove-if #'null colors)))
    (if colors
        (list (round (mean (mapcar #'first colors)))
              (round (mean (mapcar #'second colors)))
              (round (mean (mapcar #'third colors))))
        (list 0 0 0))))

(defun collect-foreground-color/tia (tiles)
  (assert (= 7 (array-dimension *tia-pf-colors* 1)))
  (assert (= (array-dimension *tia-pf-colors* 0)
             (array-dimension *tia-tiles* 0)))
  (assert (every (curry #'> (array-dimension *tia-pf-colors* 0))
                 tiles)
          (tiles) "Tiles referenced (~{~a~^, ~}) which are not known to the colors table"
          (remove-if (curry #'> (array-dimension *tia-pf-colors* 0))
                     tiles))
  (maptimes (line 7)
    (color-average
     (remove-if #'null
                (mapcar #'palette->rgb
                        (mapcar (lambda (tile)
                                  (aref *tia-pf-colors* tile line))
                                tiles))))))

(defun screen-to-grid/tia/tles (screen)
  (check-type screen (array integer (8 8)))
  (let ((tiles (make-array (list 4 8) :element-type 'fixnum)))
    (dotimes (y 8)
      (dotimes (2x 4)
        (let ((big-endian-p (evenp 2x)))
          (let* ((left (aref screen (* 2x 2) y))
                 (right (aref screen (1+ (* 2x 2)) y))
                 (tile-hash (tile-hash left right big-endian-p))
                 (merged-tile (or (gethash tile-hash *merged-tiles*)
                                  (setf (gethash tile-hash *merged-tiles*)
                                        (incf *tile-counter*)))))
            (assert (<= merged-tile *tile-counter*))
            (setf (aref tiles 2x y) merged-tile)))))
    tiles))

(defun screen-to-grid/tia (screen)
  (make-instance 'grid/tia
                 :tiles (screen-to-grid/tia/tles screen)
                 :colors (maptimes (y 8)
                           (collect-foreground-color/tia
                            (maptimes (x 8) (aref screen x y))))
                 ;; TODO
                 :background-color #x44))

(defun map-tiles/tia (world levels)
  (format *trace-output* "~&Sorting tile art into TIA format in world ~a???" world)
  (let* ((*merged-tiles* (make-hash-table :test #'equal))
         (*tile-counter* -1)
         (grids (mapcar #'screen-to-grid/tia (extract-8??8-screens levels))))
    (unless (> +tia-tile-limit+ *tile-counter*)
      (error "Too many merged tiles; TIA core can't handle more than ~:d tiles,
but world ???~a??? needs ~:d for the ~r level~:p
~{???~a???~^ and ~}"
             +tia-tile-limit+ world *tile-counter* (length levels) levels))
    (values grids *merged-tiles*)))
