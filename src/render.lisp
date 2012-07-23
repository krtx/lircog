(clack.util:namespace lircog.render
  (:use :cl
        :cl-who
        :cl-ppcre
        :lircog.log
        :lircog.parse
        :lircog.util
        :local-time
        :url-rewrite)
  (:import-from :lircog.parse
                :parse-one-line)
  (:import-from :local-time)
  (:import-from :lircog.util)
  (:import-from :cl-who
                :with-html-output
                :with-html-output-to-string)
  (:import-from :lircog.log
                :get-channel-list
                :get-row-log)
  (:import-from :url-rewrite
                :url-encode))

(cl-syntax:use-syntax :annot)

(setf cl-who:*prologue* "<!DOCTYPE html>")

(defun channel-list (stream selected date)
  (with-html-output (stream)
    (:div :class "sidebar-nav"
          (:ul :class "well nav nav-list"
               (:li :class "nav-header" (str "channels"))
               (loop for channel in (get-channel-list)
                     do (htm (:li :class (if (string= selected channel) "active")
                                         (:a :href (format nil "/log/~A~A"
                                                           (url-encode (remove-first-sharp channel))
                                                           (if date (concatenate 'string "/" date) ""))
                                             (str channel)))))))))


(defun channel-log (stream channel date)
  (with-html-output (stream)
    (:table :class "table-condensed"
     (:tbody 
      (loop for log in (get-row-log channel date)
            do (parse-one-line stream log))))))

(defun pager (stream channel date)
  (with-html-output (stream)
    (:ul :class "pager"
         (:li :class "previous"
          (:a :href
              (format nil "/log/~A/~A"
                      (url-encode (remove-first-sharp channel))
                      (date+ date -1))
              "&larr; Older"))
         (:li :class "next"
          (:a :href
              (format nil "/log/~A/~A"
                      (url-encode (remove-first-sharp channel))
                      (date+ date 1))
              "Newer &rarr;")))))

(defun header (stream)
  (with-html-output (stream)
    (:head (:link :href "/css/bootstrap.css"
                  :rel "stylesheet")
           (:script :type "/text/javascript"
                    :src "/jquery.min.js")
           (:script :src "/js/bootstrap.js")
           (:link :href "/css/stylesheet.css"
                  :rel "stylesheet")
           (:title "Lircog"))))

(defun log-header (stream channel date)
  (with-html-output (stream)
    (:div :class "page-header"
          (:h1
           (or
            (ppcre:register-groups-bind (ch)
                ("^#([^=]+)=3a=2a.jp$" channel)
              (str (concatenate 'string "%" ch)))
            (str channel))
           (:small
            (str date))))))

@export
(defun render (&optional channel date)
  (let ((date (or date (format-422 (now)))))
    (with-html-output-to-string (ret nil :prologue t)
      (:html :lang "ja"
        (header ret)
        (:body
         (:div :class "container-fluid"
               (:div :class "span4 sidebar-nav-fixed" (channel-list ret channel date))
               (if channel
                   (htm
                    (:div :class "span10 offset4"
                          (:h1 :class "page-header" (str date))
                          (:div
                           (channel-log ret channel date)
                           (pager ret channel date)))))))))))

