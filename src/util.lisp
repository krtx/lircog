(clack.util:namespace lircog.util
  (:use :cl
        :local-time)
  (:import-from :local-time))

(cl-syntax:use-syntax :annot)

@export
(defun format-422 (date &key sep)
  (let ((sep (or sep "-")))
    (format-timestring nil date
                       :format `((:year 4) ,sep (:month 2) ,sep (:day 2)))))

@export
(defun remove-first-sharp (str)
  (if (char= #\# (elt str 0)) (subseq str 1) str))

@export
(defun date+ (date amount)
  (format-422 (timestamp+ (parse-timestring date) amount :day)))
