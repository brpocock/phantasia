(defun decode-header (&rest bytes)
  (check-type bytes cons)
  (assert (member (length bytes) '(4 5)))
  (cond 
    ((zerop (elt bytes 1))
     (progn (format t "~&  end of drawing list.")
            nil))
    ((= #x60 (logand #xe0 (elt bytes 1)))
     (progn (format t "~&  indirect stamp header, write mode ~d, string @ $~4,'0x, x = ~d, palette ~d, width ~d" 
                    (ash (logand #x80 (elt bytes 1)) -7)
                    (+ (* #x100 (elt bytes 2)) (elt bytes 0))
                    (if (< (elt bytes 4) 168) 
                        (elt bytes 4)
                        (- (elt bytes 4) #x100))
                    (ash (logand (elt bytes 3) #xe0) -5)
                    (1+ (logxor #x1f (logand #x1f (elt bytes 3))))) 
            5))
    (t (progn (format t "~&  direct stamp header, ")
              (if (= 0 (logand #x1f (elt bytes 1)))
                  (format t "extended, write mode ~d, stamp @ $~4,'0x, x = ~d, palette ~d, width ~d"
                          (ash (logand #x80 (elt bytes 1)) -7)
                          (+ (* #x100 (elt bytes 2)) (elt bytes 0))
                          (if (< (elt bytes 4) 168) 
                              (elt bytes 4)
                              (- (elt bytes 4) #x100))
                          (ash (logand (elt bytes 3) #xe0) -5)
                          (1+ (logxor #x1f (logand #x1f (elt bytes 3)))))
                  (format t "stamp @ $~4,'0x, x = ~d, palette ~d, width ~d"
                          (+ (* #x100 (elt bytes 2)) (elt bytes 0))
                          (if (< (elt bytes 3) 168)
                              (elt bytes 3) 
                              (- (elt bytes 3) #x100))
                          (ash (logand (elt bytes 1) #xe0) -5)
                          (1+ (logxor #x1f (logand #x1f (elt bytes 1))))))
              4))))

(defun string->hex (string)
  (loop for i from 0 by (if (find #\space string) 3 2)
        while (< i (length string))
        collecting (parse-integer (subseq string i (+ i 2)) :radix 16)))

(defun decode-hex-header (string)
  (apply #'decode-header (string->hex string)))

(defun decode-dll-entry (&rest bytes)
  (assert (= 3 (length bytes)))
  (if (and (zerop (elt bytes 2)) (zerop (elt bytes 1)))
      (progn
        (format t "~&End of Drawing-list List")
        nil)
      (progn
        (format t "~&Drawing list @ $~4,'0x~@[~*, with DLI~]~
~@[,~* 16 high holey DMA~]~@[~*, 8 high holey DMA~], offset ~d~@[~*, INVALID~]"
                (logior (ash (elt bytes 1) 8) (elt bytes 2))
                (plusp (logand #x80 (elt bytes 0)))
                (plusp (logand #x40 (elt bytes 0)))
                (plusp (logand #x20 (elt bytes 0)))
                (1+ (logand #x0f (elt bytes 0)))
                (plusp (logand #x10 (elt bytes 0))))
        (logior (ash (elt bytes 1) 8) (elt bytes 2)))))

(defun decode-dll-hex (string)
  (let ((bytes (string->hex string)))
    (loop for i from 0 below (length bytes) by 3
          do (apply #'decode-dll-entry (subseq bytes i (+ 3 i))))))

(defun decode-drawing-list (mem)
  (loop with dl-entry = 0
        for dl-increment = (apply #'decode-header (coerce (subseq mem dl-entry (+ 5 dl-entry)) 'list))
        while dl-increment
        do (incf dl-entry dl-increment)))

(defun decode-dll-deeply (mem &optional (start-address 0))
  (loop for dll-address from start-address by 3
        for dll-pointer = (apply #'decode-dll-entry (coerce (subseq mem dll-address (+ 3 dll-address)) 'list))
        while dll-pointer
        do (decode-drawing-list (subseq mem dll-pointer))))

(defun load-dump-into-mem (dump-file)
  (let ((mem (make-array (expt 2 16) :element-type '(unsigned-byte 8))))
    (with-input-from-file (dump dump-file :element-type '(unsigned-byte 8))
      (loop for byte = (read-byte dump nil nil)
            for i from 0
            while byte
            do (setf (aref mem i) byte)))
    mem))

(defun decode-dll-from-dump (dump-file start-address)
  (decode-dll-deeply (load-dump-into-mem dump-file) start-address))

