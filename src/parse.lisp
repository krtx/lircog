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
          (loop for line in log
                and prev = line
                do (loop for f in '(privmsg notice message)
                         for it = (funcall f stream line prev)
                         when it return it)))))
