(in-package :skyline-tool)

(defvar *bank*)

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
  (let ((object-pathname (make-pathname :directory '(:relative "Object" "Assets")
                                        :type "o"
                                        :name file-name)))
    (assert (probe-file object-pathname) (file-name)
            "Object file not found: “~a”" object-pathname)
    object-pathname))

(defun asset-file (asset &key sound video)
  (destructuring-bind (kind name) (split-sequence #\/ asset)
    (assert (member kind '("Songs" "Maps" "Scripts") :test #'equal) (asset)
            "Asset indicator must be a song, map, or script, not “~a”" asset)
    (existing-object-file
     (if (equal kind "Songs")
         (format nil "Song.~a.~a.~a" name sound video)
         (format nil "~a.~a" (subseq kind 0 (length kind)) name)))))

(defun song-asset-p (asset)
  (zerop (position "Songs/" asset)))

(defun script-asset-p (asset)
  (zerop (position "Scripts/" asset)))

(defun map-asset-p (asset)
  (zerop (position "Maps/" asset)))

(defun bank-size (asset-size-hash)
  (let ((assets (hash-table-keys asset-size-hash)))
    (reduce 
     #'+
     (remove-if #'null
                (flatten
                 (list (when (some #'song-asset-p assets) 
                         (ecase *machine* 
                           (7800 256)))
                       (when (some #'script-asset-p assets)
                         (ecase *machine*
                           (7800 256)))
                       (when (some #'map-asset-p assets)
                         (ecase *machine*
                           (7800 1024)))
                       (loop for asset in assets
                             collecting (gethash asset asset-size-hash))))))))

(defun best-permutation (permutations)
  (loop with optimal-count = nil
        with optimal-assets = nil
        for sequence being the hash-keys of permutations
        for banks = (gethash sequence permutations)
        for bank-count = (length (hash-table-keys banks))
        when (< bank-count optimal-count)
          do (setf optimal-count bank-count
                   optimal-assets banks)
        finally (if optimal-count
                    (return optimal-assets)
                    (error "No permutation can be allocated"))))

(defun try-allocation-sequence (sequence file-sizes permutations)
  (loop with banks = (make-hash-table :test 'equal)
        with bank = 0
        with bank-assets = (make-hash-table :test 'equal)
        for asset in sequence
        for asset-size = (gethash asset file-sizes)
        for tentative-bank = (let ((tentative-bank (copy-hash-table bank-assets)))
                               (setf (gethash asset tentative-bank) asset-size))
        if (< (bank-size tentative-bank) (ecase *machine*
                                           (7800 #x4000)))
          do (setf bank-assets tentative-bank)
        else do (progn 
                  (setf (gethash bank banks) bank-assets
                        bank (1+ bank)))
        finally (setf (gethash sequence permutations) banks)))

(defun find-best-allocation (assets &key build sound video)
  (let ((file-sizes (make-hash-table :test 'equal)))
    (dolist (asset assets)
      (setf (gethash asset file-sizes) 
            (ql-util:file-size (asset-file asset :sound sound :video video))))
    (let ((permutations (make-hash-table :test 'equal)))
      (map-permutations (rcurry #'try-allocation-sequence file-sizes permutations)
                        (hash-table-keys file-sizes))
      (let ((best (best-permutation permutations)))
        (unless (< (length (hash-table-keys best))
                   (ecase *machine*
                     (7800 (cond
                             ((equal build "Demo") 8)
                             (t 12)))))
          (error "Best-case arrangement takes ~:d memory banks" (length (hash-table-keys best))))
        best))))

(define-constant +all-builds+ '("AA" "Public" "Demo")
  :test #'equalp)

(define-constant +all-sounds+ '("TIA" "POKEY")
  :test #'equalp)

(define-constant +all-video+ '("NTSC" "PAL")
  :test #'equalp)

(defun first-assets-bank ()
  (loop for bank from 0
        unless (probe-file (make-pathname :directory (list :relative "Source" "Banks" (format nil "Bank~(~2,'0x~)" bank))
                                          :name (format nil "Bank~(~2,'0x~)" bank)
                                          :type "s"))
          return bank))

(defun allocate-assets (build)
  (assert (member build +all-builds+ :test 'equal) (build)
          "BUILD must be one of ~{~a~^ or ~} not “~a”" +all-builds+ build)
  (let ((assets-list (all-assets-for-build build)))
    (dolist (sound +all-sounds+)
      (dolist (video +all-video+)
        (loop with allocation =  (find-best-allocation assets-list :build build :sound sound :video video)
              for bank being the hash-keys of allocation
              for assets = (gethash bank allocation)
              do (with-output-to-file (allocation-file (make-pathname :directory '(:relative "Source" "Generated")
                                                                      :name (format nil "Bank~(~2,'0x~).~a.~a.~a"
                                                                                    (+ (first-assets-bank) bank)
                                                                                    build sound video)
                                                                      :type "list")
                                                       :if-exists :supersede)
                   (format allocation-file "~{~a~%~}" assets)))))))

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
  (let ((bank (format nil "Bank~(~2,'0x~)" *bank*)))
    (list (list :relative "Source" "Banks" bank)
          (list :relative "Source" "Common")
          (list :relative "Source" "Routines"))))

(defun generated-path (path)
  (cond 
    ((equalp path '(:relative "Source" "Common"))
     (list :relative "Source" "Generated" "Common"))
    ((equalp (subseq path 0 3) '(:relative "Source" "Banks"))
     (append (list :relative "Source" "Generated") (subseq path 3)))
    (t (error "Don't know how to find a generated path from ~a" path))))

(defun write-art-generation (path name)
  (format t "~%
Object/Assets/~a.o: ~{~a/~}~a.art \\~{~%~10t~{~a/~}~a.png \\~}~%~10tbin/skyline-tool
	mkdir -p Object/Assets
	bin/skyline-tool compile-art-7800 $@ $<"
          name (rest path) name 
          (read-7800-art-index (make-pathname :directory path :name name :type "art"))))

(defun write-tsx-generation (pathname)
  (format t "~%
Object/Assets/~a.o: Source/Maps/~:*~a.tsx \\~%~10tSource/Maps/~:*~a.png \\~%~10tbin/skyline-tool
	mkdir -p Object/Assets
	bin/skyline-tool compile-tileset $<"
          (pathname-name pathname)))

(defun find-included-file (name)
  (dolist (path (include-paths-for-current-bank))
    (let ((possible-file (make-pathname :directory path :name name :type "s")))
      (when (probe-file possible-file)
        (return-from find-included-file possible-file))))
  (error "Cannot find a possible source for included file ~a.s in bank ~(~2,'0x~)" name *bank*))

(defun find-included-binary-file (name)
  (dolist (path (include-paths-for-current-bank))
    (let ((possible-file (make-pathname :directory path :name name :type "art")))
      (when (probe-file possible-file)
        (write-art-generation path name)
        (return-from find-included-binary-file
          (make-pathname :directory '(:relative "Object" "Assets") :name name :type "o")))))
  (let ((possible-file (make-pathname :directory '(:relative "Source" "Maps") :name name :type "tsx")))
    (when (probe-file possible-file)
      (return-from find-included-binary-file
        (make-pathname :directory '(:relative "Object" "Assets") :name name :type "o"))))
  (error "Cannot find a possible source for included binary file ~a.o in bank ~(~2,'0x~)" name *bank*))

(defun recursive-read-deps (source-file)
  (unless (equal (pathname-type source-file) "o")
    (with-input-from-file (source source-file)
      (let ((includes (remove-if 
                       #'null
                       (loop for line = (read-line source nil nil)
                             while line
                             for included = (included-file line)
                             for binary = (included-binary-file line)
                             append (list 
                                     (when included (find-included-file included))
                                     (when binary (find-included-binary-file binary)))))))
        (flatten (append includes (mapcar #'recursive-read-deps includes)))))))

(defun all-assets ()
  (loop for (dir . type) in '(("Maps" . "tmx") ("Songs" . "midi") ("Scripts" . "scup"))
        appending (mapcar
                   (lambda (pathname)
                     (format nil "~a/~a" 
                             dir (pathname-name pathname)))
                   (directory (make-pathname :directory (list :relative "Source" dir)
                                             :name :wild
                                             :type type)))))

(defun asset->object-name (asset-indicator)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (format nil "Object/~a/~a.o" kind name)))

(defun asset->symbol-name (asset-indicator)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (format nil "~a_~a" kind name)))

(defun asset->source-name (asset-indicator)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (format nil "Source/~a/~a.~a" kind name
            (cond
              ((equal kind "Maps") "tmx")
              ((equal kind "Songs") "midi")
              ((equal kind "Scripts") "scup")
              (t (error "Asset kind ~a not known" kind))))))

(defun asset-compilation-line (asset-indicator)
  (destructuring-bind (kind name) (split-sequence #\/ asset-indicator)
    (declare (ignore name))
    (cond
      ((equal kind "Maps")
       (format nil "bin/skyline-tool compile-map $<"))
      ((equal kind "Songs")
       (format nil "bin/skyline-tool compile-music $<"))
      ((equal kind "Scripts")
       (format nil "bin/skyline-tool compile-scripts $<"))
      (t (error "Asset kind ~a not known" kind)))))

(defun write-asset-compilation (asset-indicator)
  (format t "~%
~a: ~a \\
          Source/Assets.index bin/skyline-tool
	mkdir -p Object/Assets
	~a"
          (asset->object-name asset-indicator)
          (asset->source-name asset-indicator)
          (asset-compilation-line asset-indicator)))

(defun write-asset-bank-makefile (bank &key build sound video)
  (let ((all-assets (all-assets-for-build build)))
    (format t "~%
Source/Generated/Bank~(~2,'0x~).~a.~a.~a.s: Source/Assets.index bin/skyline-tool \\~{~%~10t~a~^ \\~}
	bin/skyline-tool write-asset-bank ~x ~a ~a ~a

Object/Bank~(~2,'0x~).~a.~a.~a.o: Source/Generated/Bank~(~2,'0x~).~a.~a.~a.s \\
          Source/Assets.index bin/skyline-tool \\~{~%~10t~a~^ \\~}
	mkdir -p Object
	${AS7800} -DTV=~a -DMUSIC=~a ~a \\~{~%-I ~a \\~}
		-l $@.labels.txt -L $@.list.txt $< -o $@"
            bank build sound video
            (mapcar #'asset->object-name all-assets)
            bank build sound video
            bank build sound video
            bank build sound video
            (mapcar #'asset->object-name all-assets)
            video sound (cond ((equal build "AA") "-DATARIAGE")
                              ((equal build "Demo") "-DDEMO")
                              (t ""))
            (mapcar (lambda (path) (format nil "~{~a~^/~}" (rest path))) 
                    (include-paths-for-current-bank)))))

(defun write-bank-makefile (bank-source &key build sound video)
  (format t "~%
Object/Bank~(~2,'0x~).~a.~a.~a.o:~{ \\~&~20t~a~}
	mkdir -p Object
	${AS7800} -DTV=~a -DMUSIC=~a ~a \\~{~%	-I ~a \\~}
		-l $@.labels.txt -L $@.list.txt $< -o $@"
          *bank* build sound video (recursive-read-deps bank-source)
          video sound (cond ((equal build "AA") "-DATARIAGE")
                            ((equal build "Demo") "-DDEMO")
                            (t ""))
          (mapcar (lambda (path) (format nil "~{~a~^/~}" (rest path))) 
                  (include-paths-for-current-bank))))

(defun write-makefile-top-line (&key sound video build)
  (format t "~%
Dist/Phantasia.~a.~a.~a.a78: \\~
~{~%~10tObject/Bank~(~2,'0x~).~a.~a.~a.o~^ \\~}
	mkdir -p Dist
	cat $^ > $@
	bin/7800sign -w $@
	bin/7800header -f Source/header.~a.~a.~a.script $@
"
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
    (dolist (build +all-builds+)
      (dolist (sound +all-sounds+)
        (dolist (video +all-video+)
          (write-makefile-top-line :build build :sound sound :video video)
          (dotimes (*bank* (number-of-banks build sound video))
            (let ((bank-source (make-pathname :directory (list :relative "Source" "Banks" (format nil "Bank~(~2,'0x~)" *bank*))
                                              :name (format nil "Bank~(~2,'0x~)" *bank*)
                                              :type "s")))
              (cond
                ((= *bank* (1- (number-of-banks build sound video)))
                 (write-bank-makefile (make-pathname :directory (list :relative "Source" "Banks" "LastBank")
                                                     :name "LastBank" :type "s")
                                      :build build :sound sound :video video))
                ((probe-file bank-source)
                 (write-bank-makefile bank-source
                                      :build build :sound sound :video video))
                (t (write-asset-bank-makefile *bank*
                                              :build build :sound sound :video video))))))))))

(defun write-asset-source (kind predicate assets)
  (if (some predicate assets)
      (progn
        (format source ".include \"Load~a.s\"~2%~as:" kind kind)
        (dolist (asset (remove-if-not predicate assets))
          (format source "~&~10t.word ~a" (asset->symbol-name asset)))
        (format source "~2%"))
      (format source "Load~a: rts~2%" kind)))

(defun write-asset-bank (bank-hex build sound video)
  (let* ((bank (parse-integer bank-hex :radix 16))
         (basename (format nil "Bank~(~2,'0x~).~a.~a.~a" bank build sound video))
         (outfile (make-pathname :directory (list :relative "Source" "Generated")
                                 :name basename
                                 :type "s"))
         (assets (with-input-from-file (list (make-pathname :directory (list :relative "Source" "Generated")
                                                            :name basename
                                                            :type "list"))
                   (loop for asset = (read-line list nil nil)
                         collect asset))))
    (ensure-directories-exist outfile)
    
    (with-output-to-file (source outfile :if-exists :supersede)
      (format source ";;; Bank ~2,'0x file (generated by Skyline Tool)

~10tBANK = $~2,'0x

~10t.include \"StartBank.s\"

VLoadMap: jmp LoadMap
VLoadSong: jmp LoadSong
VLoadScript: jmp LoadScript
~2%")
      (write-asset-source "Map" #'map-asset-p assets)
      (write-asset-source "Song" #'song-asset-p assets)
      (write-asset-source "Script" #'script-asset-p assets)
      (dolist (asset assets)
        (format source "~a:~%~10t.binary\"~a\"" 
                (asset->symbol-name asset)
                (asset->object-name asset)))
      (format source "~10t.include \"EndBank.s\"~%"))))
