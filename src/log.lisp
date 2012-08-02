(clack.util:namespace lircog.log
  (:use :cl
        :cl-fad
        :lircog.util
        :local-time)
  (:import-from :local-time)
  (:import-from :lircog.util))

(cl-syntax:use-syntax :annot)

(defparameter *log-directory* #P"/path/to/irclog/")

@export
(defun get-channel-list ()
  (mapcar (lambda (path) (car (last (pathname-directory path))))
          (cl-fad:list-directory *log-directory*)))

@export
(defun get-row-log (channel &optional date)
  (format t "get-row-log: [~A] [~A]~%" channel date)
  (let* ((date (format-422 (or (parse-timestring date) (now))
                           :sep "."))
         (file-path (merge-pathnames (format nil "~A/~A.txt" channel date)
                                     *log-directory*)))
    (format t "file-path: ~A~%" file-path)
    (handler-case
        (with-open-file (in file-path :direction :input
                            :external-format :utf-8)
          (loop for l = (read-line in nil nil)
                while l collect l))
      (file-error () '("log-ga-nai-yo")))))
