(clack.util:namespace lircog.parse
  (:use :cl
        :cl-ppcre
        :cl-who
        :alexandria)
  (:import-from :cl-ppcre)
  (:import-from :cl-who)
  (:import-from :alexandria
                :with-gensyms))

(cl-syntax:use-syntax :annot)

;; privmsg notice others の３つに分ける

(defmacro regcommand (name elems regex &rest html)
  (with-gensyms (stream line prev)
    `(defun ,name (,stream ,line &optional ,prev)
       (register-groups-bind ,elems
           (,regex ,line)
         (with-html-output (,stream)
           ,@html)))))

(defun privmsg (stream line &optional prev)
  (register-groups-bind (time channel _ nick message)
      ("^(\\d{2}:\\d{2}):\\d{2} [<>]([^:]+):(\\*\\.jp:)?([^<>]+)[<>] (.*)$" line)
    (with-html-output (stream)
      (:div :class "row-fluid"
            (:div :class "span1 time" (str time))
            (:div :class "span2 nick" (str nick))
            (:div :class "span6" (esc message))))))
      
(defun notice (stream line &optional prev)
  (register-groups-bind (time channel _ nick message)
      ("^(\\d{2}:\\d{2}):\\d{2} [()]([^:]+):(\\*\\.jp:)?([^()]+)[()] (.*)$" line)
    (with-html-output (stream)
      (:div :class "row-fluid"
            (:div :class "span1 time" (str time))
            (:div :class "span2 nick" (str nick))
            (:div :class "span6" (esc message))))))

(defun message (stream line &optional prev)
  (register-groups-bind (time message)
      ("^(\\d{2}:\\d{2}):\\d{2} (.*)$" line)
    (with-html-output (stream)
      (:div :class "row-fluid message"
            (:div :class "span1 time" (str time))
            (:div :class "span8" (esc message))))))

@export
(defun channel-log (stream log)
  (with-html-output (stream)
    (:div :class "channel-log"
          (loop for log in log
                do (or (privmsg stream log)
                       (notice stream log)
                       (message stream log))))))

