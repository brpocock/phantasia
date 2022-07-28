(in-package :skyline-tool)

(defvar *bank*)
(defvar *last-bank*)

(defun parse-assets-line (line)
  (destructuring-bind (asset &optional builds-string) (split-sequence #\space line :remove-empty-subseqs t)
    (list asset 
          (if (null builds-string)
              (list "AA" "Public" "Demo")
              (remove-if #'null
                         (list
                          (when (member #\A builds-string :test #'char-equal) "AA")
                          (when (member #\P builds-string :test #'char-equal) "Public")
                          (when (member #\D builds-string :test #'char-equal) "Demo")))))))

(defun read-assets-list (index-file)
  (let ((index-hash (make-hash-table :test 'equal)))
    (with-input-from-file (index index-file)
      (loop for line = (read-line index nil nil)
            while line
            do (destructuring-bind (asset builds) (parse-assets-line line)
                 (setf (gethash asset index-hash) builds))))
    index-hash))

(defun filter-assets-for-build (index-hash build)
  (loop for asset being the hash-keys of index-hash
        when (member build (gethash asset index-hash) :test #'equal)
          collect asset))

(defun existing-object-file (file-name)
  (assert (probe-file file-name) (file-name)
          "Object file not found: “~a”" file-name)
  file-name)

(defun asset-file (asset &key sound video)
  (existing-object-file (asset->object-name asset :sound sound :video video)))

(defun song-asset-p (asset)
  (eql 0 (search "Songs/" asset)))

(defun script-asset-p (asset)
  (eql 0 (search "Scripts/" asset)))

(defun map-asset-p (asset)
  (eql 0 (search "Maps/" asset)))

(defun song-asset-loader-size ()
  (ecase *machine* 
    (7800 256)))  ; FIXME

(defun script-asset-loader-size ()
  (ecase *machine*
    (7800 256)))  ; FIXME

(defun map-asset-loader-size ()
  (ecase *machine*
    (7800 1024)))  ; FIXME

(defun general-overhead-size ()
  (ecase *machine*
    (7800 1024)))  ; FIXME

(defun bank-size (asset-size-hash)
  (let ((assets (hash-table-keys asset-size-hash)))
    (reduce 
     #'+
     (remove-if #'null
                (flatten
                 (list 
                  (general-overhead-size)
                  (when (some #'song-asset-p assets) 
                    (song-asset-loader-size))
                  (when (some #'script-asset-p assets)
                    (script-asset-loader-size))
                  (when (some #'map-asset-p assets)
                    (map-asset-loader-size))
                  (mapcar (lambda (asset) (gethash asset asset-size-hash)) 
                          assets)))))))

(defun best-permutation (permutations)
  (loop with optimal-count = most-positive-fixnum
        with optimal-assets = nil
        for sequence being the hash-keys of permutations
        for banks = (gethash sequence permutations)
        for bank-count = (length (hash-table-keys banks))
        when (< bank-count optimal-count)
          do (setf optimal-count bank-count
                   optimal-assets banks)
        finally (return optimal-assets)))

(defun size-of-banks ()
  (ecase *machine*
    (7800 #x4000)))

(defun try-allocation-sequence (sequence file-sizes permutations &key sound video)
  (loop with banks = (make-hash-table :test 'equal)
        with bank = 0
        with bank-assets = (make-hash-table :test 'equal)
        for asset in sequence
        for asset-file = (asset-file asset :sound sound :video video)
        for asset-size = (gethash asset-file file-sizes)
        for tentative-bank = (let ((tentative-bank (copy-hash-table bank-assets)))
                               (setf (gethash asset tentative-bank) asset-size)
                               tentative-bank)
        when (null asset-size)
          do (error "Did not get size of “~a” (for ~a)" asset-file asset)
        when (zerop asset-size)
          do (error "Asset file is empty: “~a” (for ~a)" asset-file asset)
        if (< (bank-size tentative-bank) (size-of-banks))
          do (setf bank-assets tentative-bank)
        else
          do (setf (gethash bank banks) bank-assets
                   bank (1+ bank))
        finally (setf (gethash bank banks) bank-assets
                      (gethash sequence permutations) banks)))

(defun find-best-allocation (assets &key build sound video)
  (let ((file-sizes (make-hash-table :test 'equal)))
    (dolist (asset assets)
      (let ((asset-file (asset-file asset :sound sound :video video)))
        (setf (gethash asset-file file-sizes) (ql-util:file-size asset-file))))
    (let ((permutations (make-hash-table :test 'equal)))
      (map-permutations (lambda (sequence) 
                          (try-allocation-sequence sequence file-sizes permutations
                                                   :sound sound :video video))
                        assets)
      (let ((best (best-permutation permutations)))
        (when (zerop (length (hash-table-keys best)))
          (error "Could not find any assets to allocate?"))
        (let ((available-banks (- (number-of-banks build sound video)
                                  (first-assets-bank)
                                  1)))
          (unless (< (length (hash-table-keys best)) available-banks)
            (error "Best-case arrangement takes ~:d memory bank~:p (out of ~:d available)"
                   (length (hash-table-keys best)) available-banks)))
        best))))

(define-constant +all-builds+ '("AA" "Public" "Demo")
  :test #'equalp)

(define-constant +all-sounds+ '("TIA" "POKEY" "YM")
  :test #'equalp)

(defun all-sound-chips-for-build (build)
  (cond ((equal "AA" build) '("YM"))
        (t +all-sounds+)))

(define-constant +all-video+ '("NTSC" "PAL")
  :test #'equalp)

(defun first-assets-bank ()
  (loop for bank from 0
        unless (probe-file (make-pathname :directory (list :relative "Source" "Banks" (format nil "Bank~(~2,'0x~)" bank))
                                          :name (format nil "Bank~(~2,'0x~)" bank)
                                          :type "s"))
          return bank))

(defun allocation-list-name (bank build sound video)
  (make-pathname :directory '(:relative "Source" "Generated")
                 :name (format nil "Bank~(~2,'0x~).~a.~a.~a"
                               bank
                               build sound video)
                 :type "list"))

(defun allocate-assets (build &optional (*machine* 7800))
  (assert (member build +all-builds+ :test 'equal) (build)
          "BUILD must be one of ~{~a~^ or ~} not “~a”" +all-builds+ build)
  (let ((assets-list (all-assets-for-build build)))
    (dolist (sound (all-sound-chips-for-build build))
      (dolist (video +all-video+)
        (format *trace-output* "~&Writing asset list files for ~a ~a ~a: Bank"
                build sound video)
        (loop with allocation =  (find-best-allocation assets-list
                                                       :build build :sound sound :video video)
              for bank-offset being the hash-keys of allocation
              for bank = (+ (first-assets-bank) bank-offset)
              for assets = (gethash bank-offset allocation)
              unless assets
                do (error "No assets assigned to bank ~(~2,'0x~)" bank)
              do (with-output-to-file (allocation-file (allocation-list-name 
                                                        bank build sound video)
                                                       :if-exists :supersede)
                   (format *trace-output* " ~(~2,'0x~) (~:d asset~:p) " 
                           bank (length (hash-table-keys assets)))
                   (format allocation-file "~{~a~%~}" (hash-table-keys assets)))
              finally (when (< (+ (length (hash-table-keys allocation)) (first-assets-bank))
                               (1- (number-of-banks build sound video)))
                        (format *trace-output* "~&… and blank asset lists for: Bank")
                        (loop for bank from (+ (first-assets-bank)
                                               (length (hash-table-keys allocation)))
                                below (1- (number-of-banks build sound video))
                              do (with-output-to-file (allocation-file
                                                       (allocation-list-name bank build sound video)
                                                       :if-exists :supersede)
                                   (format *trace-output* " ~(~2,'0x~)" bank)
                                   (fresh-line allocation-file)))))))))

(defun number-of-banks (build sound video)
  (declare (ignore sound video))
  (cond
    ((equal build "Demo") 8)
    (t 32)))

(defun included-file (line)
  (let ((match (nth-value 1 (cl-ppcre:scan-to-strings "\\.include \"(.*)\\.s\"" line))))
    (when (and match (plusp (array-dimension match 0)))
      (aref match 0))))

(defun included-binary-file (line)
  (let ((match (nth-value 1 (cl-ppcre:scan-to-strings "\\.binary \"(.*)\\.o\"" line))))
    (when (and match (plusp (array-dimension match 0)))
      (aref match 0))))

(defun include-paths-for-current-bank ()
  (let* ((bank (if (= *bank* *last-bank*)
                   "LastBank"
                   (format nil "Bank~(~2,'0x~)" *bank*)))
         (includes (list (list :relative "Source" "Common")
                         (list :relative "Source" "Routines")
                         (list :relative "Object" "Assets")
                         (list :relative "Source" "Generated" "Assets"))))
    (if (probe-file (make-pathname :directory (list :relative "Source" "Banks" bank)
                                   :name bank :type "s"))
        (append includes (list (list :relative "Source" "Banks" bank)))
        includes)))

(defun generated-path (path)
  (cond 
    ((equalp path '(:relative "Source" "Common"))
     (list :relative "Source" "Generated" "Common"))
    ((equalp (subseq path 0 3) '(:relative "Source" "Banks"))
     (append (list :relative "Source" "Generated") (subseq path 3)))
    (t (error "Don't know how to find a generated path from ~a" path))))

(defun write-art-generation (pathname)
  (format t "~%
Object/Assets/Art.~a.o: Source/Art/~a.art \\~{~%~10t~a \\~}~%~10tbin/skyline-tool
	mkdir -p Object/Assets
	bin/skyline-tool compile-art-7800 $@ $<"
          (pathname-name pathname)
          (pathname-name pathname)
          (mapcar #'second 
                  (read-7800-art-index pathname))))

(defun write-tsx-generation (pathname)
  (format t "~%
Object/Assets/Tileset.~a.o: Source/Maps/~:*~a.tsx \\~%~10tSource/Maps/~:*~a.png \\~%~10tbin/skyline-tool
	mkdir -p Object/Assets
	bin/skyline-tool compile-tileset $<"
          (pathname-name pathname)))

(defun find-included-file (name)
  (when (eql 0 (search "Song." name))
    (return-from find-included-file 
      (make-pathname :directory '(:relative "Source" "Generated" "Assets")
                     :name name :type "s")))
  (dolist (path (include-paths-for-current-bank))
    (let ((possible-file (make-pathname :directory path :name name :type "s")))
      (when (probe-file possible-file)
        (return-from find-included-file possible-file))))
  (error "Cannot find a possible source for included file ~a.s in bank ~(~2,'0x~)" name *bank*))

(defun find-included-binary-file (name)
  (when (eql 0 (search "Art." name))
    (let ((possible-file (make-pathname :directory '(:relative "Source" "Art") 
                                        :name (subseq name 4) :type "art")))
      (when (probe-file possible-file)
        (return-from find-included-binary-file
          (make-pathname :directory '(:relative "Object" "Assets") 
                         :name name :type "o")))))
  (when (eql 0 (search "Tileset." name))
    (let ((possible-file (make-pathname :directory '(:relative "Source" "Maps")
                                        :name (subseq name 8) :type "tsx")))
      (when (probe-file possible-file)
        (return-from find-included-binary-file
          (make-pathname :directory '(:relative "Object" "Assets")
                         :name name :type "o")))))
  (error "Cannot find a possible source for included binary file ~a.o in bank ~(~2,'0x~)" name *bank*))

(defun recursive-read-deps (source-file)
  (unless (equal (pathname-type source-file) "o")
    (with-input-from-file (source source-file)
      (let ((includes (loop for line = (read-line source nil nil)
                            while line
                            for included = (included-file line)
                            for binary = (included-binary-file line)
                            for file = (cond 
                                         (included (find-included-file included))
                                         (binary (find-included-binary-file binary))
                                         (t nil))
                            when file collect file)))
        (remove-duplicates
         (flatten (append (list source-file) includes
                          (mapcar #'recursive-read-deps includes)))
         :test #'equal)))))

(defun all-assets ()
  (loop for (dir . type) in '(("Maps" . "tmx") ("Songs" . "midi") ("Scripts" . "scup"))
        appending (mapcar
                   (lambda (pathname)
                     (format nil "~a/~a" 
                             dir (pathname-name pathname)))
                   (directory (make-pathname :directory (list :relative "Source" dir)
                                             :name :wild
                                             :type type)))))

(defun asset->object-name (asset-indicator &key sound video)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (if (equal kind "Songs")
        (format nil "Object/Assets/Song.~a.~a.~a.o" name sound video)
        (format nil "Object/Assets/~a.~a.o" (subseq kind 0 (1- (length kind))) name))))

(defun asset->deps-list (asset-indicator build)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (if (equal kind "Songs")
        (format nil "Source/Generated/Assets/Song.~a.s \\~%~{~25tObject/Assets/Song.~{~a.~a.~a~}.o~^ \\~%~}"
                name
                (loop for sound in (all-sound-chips-for-build build)
                      append (loop for video in +all-video+
                                   collecting (list name sound video))))
        (asset->object-name asset-indicator))))

(defun asset->symbol-name (asset-indicator)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (format nil "~a_~a" (subseq kind 0 (1- (length kind))) name)))

(defun asset->source-name (asset-indicator)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (format nil "Source/~a/~a.~a" kind name
            (cond
              ((equal kind "Maps") "tmx")
              ((equal kind "Songs") "midi")
              ((equal kind "Scripts") "scup")
              (t (error "Asset kind ~a not known" kind))))))

(defun asset-compilation-line (asset-indicator &key sound video)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (declare (ignore name))
    (cond
      ((equal kind "Maps")
       (format nil "bin/skyline-tool compile-map $<"))
      ((equal kind "Songs")
       (format nil "bin/skyline-tool compile-music $@ $< 7800 ~a ~a" sound video))
      ((equal kind "Scripts")
       (format nil "bin/skyline-tool compile-scripts $<"))
      (t (error "Asset kind ~a not known" kind)))))

(defun write-asset-compilation/music (asset-indicator)
  (let* ((basename (last-segment asset-indicator #\/))
         (source-pathname (make-pathname :directory '(:relative "Source" "Generated" "Assets")
                                         :name (format nil "Song.~a" basename)
                                         :type "s")))
    (ensure-directories-exist source-pathname)
    (with-output-to-file (source source-pathname :if-exists :supersede)
      (format source ";; This is a generated file~2%")
      (dolist (video +all-video+)
        (dolist (sound +all-sounds+)
          (format source "~%          .if MUSIC == ~a && TV == ~a
            .binary \"Song.~a.~a.~a.o\"
          .fi~%"
                  sound video basename sound video)
          )))
    (dolist (video +all-video+)
      (dolist (sound +all-sounds+)
        (format t "~%
~a: ~a \\
          Source/Assets.index bin/skyline-tool
	mkdir -p Object/Assets
	~a"
                (asset->object-name asset-indicator 
                                    :sound sound :video video)
                (asset->source-name asset-indicator)
                (asset-compilation-line asset-indicator 
                                        :sound sound :video video))))))

(defun write-asset-compilation (asset-indicator)
  (if (song-asset-p asset-indicator)
      (write-asset-compilation/music asset-indicator)
      (format t "~%
~a: ~a \\
          Source/Assets.index bin/skyline-tool
	mkdir -p Object/Assets
	~a"
              (asset->object-name asset-indicator)
              (asset->source-name asset-indicator)
              (asset-compilation-line asset-indicator))))

(defun write-asset-bank-makefile (bank &key build sound video)
  (let* ((all-assets (all-assets-for-build build))
         (asset-objects (mapcar (rcurry #'asset->deps-list build) all-assets)))
    (format t "~%
Source/Generated/Bank~(~2,'0x~).~a.~a.~a.list: Source/Assets.index \\
~10tbin/skyline-tool \\~{~%~10t~a~^ \\~}
	bin/skyline-tool allocate-assets ~a

Source/Generated/Bank~(~2,'0x~).~a.~a.~a.s: Source/Assets.index Source/Generated/Bank~(~2,'0x~).~a.~a.~a.list \\
~10tbin/skyline-tool \\~{~%~10t~a~^ \\~}
	bin/skyline-tool write-asset-bank ~x ~a ~a ~a

Object/Bank~(~2,'0x~).~a.~a.~a.o: Source/Generated/Bank~(~2,'0x~).~a.~a.~a.s \\
          Source/Assets.index bin/skyline-tool \\~{~%~10t~a~^ \\~}
	mkdir -p Object
	${AS7800} -DTV=~a -DMUSIC=~a ~a \\~{~%-I ~a \\~}
		-l $@.labels.txt -L $@.list.txt $< -o $@"
            bank build sound video
            asset-objects
            build
            bank build sound video
            bank build sound video
            asset-objects
            bank build sound video
            bank build sound video
            bank build sound video
            asset-objects
            video sound (cond ((equal build "AA") "-DATARIAGE")
                              ((equal build "Demo") "-DDEMO")
                              (t ""))
            (mapcar (lambda (path) (format nil "~{~a~^/~}" (rest path))) 
                    (include-paths-for-current-bank)))))

(defun write-bank-makefile (bank-source &key build sound video bank)
  (format t "~%
Object/Bank~(~2,'0x~).~a.~a.~a.o:~{ \\~&~20t~a~}
	mkdir -p Object
	${AS7800} -DTV=~a -DMUSIC=~a ~a ~a \\~{~%	-I ~a \\~}
		-l $@.labels.txt -L $@.list.txt $< -o $@"
          *bank* build sound video (recursive-read-deps bank-source)
          video sound (cond ((equal build "AA") "-DATARIAGE")
                            ((equal build "Demo") "-DDEMO")
                            (t ""))
          (if bank (format nil "-DBANK=~d" bank) "")
          (mapcar (lambda (path) (format nil "~{~a~^/~}" (rest path))) 
                  (include-paths-for-current-bank))))

(defun write-makefile-top-line (&key sound video build)
  (format t "~%
Dist/~a.~a.~a.~a.a78: \\~
~{~%~10tObject/Bank~(~2,'0x~).~a.~a.~a.o~^ \\~}
	mkdir -p Dist
	cat $^ > $@
	bin/7800sign -w $@
	bin/7800header -f Source/Generated/header.~a.~a.~a.script $@
"
          "Phantasia" ; TODO game title
          build sound video
          (loop for bank below (number-of-banks build sound video)
                appending (list bank build sound video))
          build sound video))

(defun all-assets-for-build (build)
  (filter-assets-for-build (read-assets-list "Source/Assets.index") build))

(defun write-assets-makefile (&key build sound video)
  (assert build) (assert sound) (assert video)
  (format t "
Source/Generated/Bank~(~2,'0x~).~a.~a.~a.s: \\~{~%~10t~a~^ \\~}
	bin/skyline-tool allocate-assets ~a"
          *bank*
          build sound video
          (all-assets-for-build build) 
          build))

(defun write-header-script (&key build sound video)
  (with-output-to-file (script (make-pathname :directory '(:relative "Source" "Generated")
                                              :name (format nil "header.~a.~a.~a"
                                                            build sound video)
                                              :type "script")
                               :if-exists :supersede)
    (format script "name ~a (BRPocock, ~d)
set tv~(~a~)
set supergameram
set 7800joy1
unset 7800joy2
set savekey
set composite~@[
set pokey@440
~]~@[
set ym2151@460
~]save
exit
"
            "Phantasia" ; TODO
            (nth-value 6 (decode-universal-time (get-universal-time)))
            video
            (equal sound "POKEY")
            (equal sound "YM"))))

(defun write-master-makefile ()
  (with-output-to-file (*standard-output* "Source/Generated/Makefile" :if-exists :supersede)
    (format t "# Makefile (generated)
# -*- makefile -*-

YEAR=$(shell date +%Y)
YEAR2=$(shell date +%y)
MONTH=$(shell date +%m)
DATE=$(shell date +%d)
JULIAN=$(shell date +%j)
BUILD=$(shell date +%y.%j)
ASFLAGS=--nostart --long-branch --case-sensitive --ascii  \\
	-D YEARNOW=${YEAR} -D MONTHNOW=${MONTH} \\
	-D DATENOW=${DATE} -D JULIANDATENOW=${JULIAN} \\
	-D BUILD=${BUILD} \\
	-Wall -Wno-shadow -Wno-leading-zeros
AS7800=64tass ${ASFLAGS} --m6502 -m --tab-size=1 --verbose-list

")
    (dolist (asset (all-assets))
      (write-asset-compilation asset))
    (dolist (tileset (directory (make-pathname :directory (list :relative "Source" "Maps")
                                               :name :wild
                                               :type "tsx")))
      (write-tsx-generation tileset))
    (dolist (art (directory (make-pathname :directory (list :relative "Source" "Art")
                                           :name :wild
                                           :type "art")))
      (write-art-generation art))
    (dolist (build +all-builds+)
      (dolist (sound (all-sound-chips-for-build build))
        (dolist (video +all-video+)
          (let ((*last-bank* (1- (number-of-banks build sound video))))
            (write-makefile-top-line :build build :sound sound :video video)
            (write-header-script :build build :sound sound :video video)
            (dotimes (*bank* (number-of-banks build sound video))
              (let ((bank-source (make-pathname
                                  :directory (list :relative "Source" "Banks"
                                                   (format nil "Bank~(~2,'0x~)" *bank*))
                                  :name (format nil "Bank~(~2,'0x~)" *bank*)
                                  :type "s")))
                (cond
                  ((probe-file bank-source)
                   (write-bank-makefile bank-source
                                        :build build :sound sound :video video))
                  ((= *bank* *last-bank*)
                   (write-bank-makefile (make-pathname
                                         :directory (list :relative "Source" "Banks" "LastBank")
                                         :name "LastBank" :type "s")
                                        :build build :sound sound :video video :bank *bank*))
                  (t (write-asset-bank-makefile *bank*
                                                :build build :sound sound :video video)))))))))))

(defmethod get-asset-id ((kind (eql :map)) asset)
  (find-locale-id-from-xml 
   (xmls:parse-to-list 
    (alexandria:read-file-into-string 
     (make-pathname :directory '(:relative "Source" "Maps")
                    :name asset :type "tmx")))))

(defmethod get-asset-id ((kind (eql :script)) asset)
  (with-input-from-file (script (make-pathname :directory'(:relative "Source" "Scripts")
                                               :name asset :type "scup"))
    (loop for line = (read-line script nil nil)
          while line
          do (when-let (scene-text (search "Scene " line))
               (return-from get-asset-id (parse-integer (subseq line (+ 6 scene-text))
                                                        :junk-allowed t))))
    (error "Script file ~a has no Scene # declaration" asset)))

(defmethod get-asset-id ((kind (eql :song)) asset)
  (warn "TODO: Get asset ID from song file somehow (needed for ~a)" asset)
  0)

(defun write-asset-source (kind predicate assets source)
  (if (some predicate assets)
      (progn
        (when (equal "Map" kind)
          (format source "~&~10t.include \"RLE.s\""))
        (format source "~&~10t.include \"Load~a.s\"~2%~as:" kind kind)
        (dolist (asset (remove-if-not predicate assets))
          (format source "~&~10t.byte ~d" (get-asset-id (make-keyword (string-upcase kind)) 
                                                        (subseq asset (position #\/ asset))))
          (format source "~&~10t.word ~a" (asset->symbol-name asset)))
        (format source "~&~10t.byte $ff~2%"))
      (format source "Load~a:~&~10tsec~&~10trts~2%" kind)))

(defun last-segment (string char)
  (if-let (position (position char string :from-end t))
    (subseq string (1+ position))
    string))

(defun write-asset-bank (bank-hex build sound video)
  (let* ((*bank* (parse-integer bank-hex :radix 16))
         (basename (format nil "Bank~(~2,'0x~).~a.~a.~a" *bank* build sound video))
         (outfile (make-pathname :directory (list :relative "Source" "Generated")
                                 :name basename
                                 :type "s"))
         (assets (with-input-from-file (list (allocation-list-name *bank* build sound video))
                   (loop for asset = (read-line list nil nil)
                         while asset
                         collect asset))))
    (format *trace-output* "~& Bank ~(~2,'0x~) assets: ~s" *bank* assets)
    (ensure-directories-exist outfile)
    
    (with-output-to-file (source outfile :if-exists :supersede)
      (format source ";;; Bank ~(~2,'0x~) file (generated by Skyline Tool)

~10tBANK = $~(~2,'0x~)

~10t.include \"StartBank.s\"

VLoadMap: jmp LoadMap
VLoadSong: jmp LoadSong
VLoadScript: jmp LoadScript
~2%"
              *bank* *bank*)
      (write-asset-source "Map" #'map-asset-p assets source)
      (write-asset-source "Song" #'song-asset-p assets source)
      (write-asset-source "Script" #'script-asset-p assets source)
      (dolist (asset assets)
        (if (song-asset-p asset)
            (format source "~&~a:~%~10t.include \"Song.~a.s\"" 
                    (asset->symbol-name asset)
                    (subseq asset (1+ (position #\/ asset))))
            (format source "~&~a:~%~10t.binary \"~a.o\"" 
                    (asset->symbol-name asset)
                    (pathname-name (parse-namestring (asset->object-name asset))))))
      (format source "~3&~10t.include \"EndBank.s\"~%"))))
