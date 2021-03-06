(in-package :skyline-tool)

(defun labels-to-mame (labels-file mame-file)
  "Converts LABELS-FILE into a format MAME can read as “comments” in MAME-FILE."
  (with-output-to-file (mame mame-file :if-exists :supersede)
    (with-input-from-file (labels labels-file)
      (let ((comments (make-hash-table)))
        (loop for line = (read-line labels nil nil)
              while line
              do (destructuring-bind (label address) (mapcar (lambda (el)
                                                               (string-trim " " el))
                                                             (split-sequence #\= line))
                   (when-let (addr (cond ((find #\$ address)
                                          (parse-integer (string-trim "$" address) :radix 16))
                                         ((every #'digit-char-p address)
                                          (parse-integer address))
                                         (t nil)))
                     (when (>= addr #x1000)
                       (setf (gethash addr comments)
                             (cond
                               ((string= (string-upcase label) label)
                                (string-downcase label))
                               (t (string-downcase (cffi:translate-camelcase-name label)))))))))
        (loop for addr being the hash-keys of comments
              for label = (gethash addr comments)
              do (format mame "comadd ~8,'0x, ~a~%" addr (string-trim " " label)))))
    (format mame "printf \"\\n\\n\\n\\n\\nLabels loaded.\\nReady.\"")))

