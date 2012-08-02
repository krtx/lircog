(clack.util:namespace lircog.controller
  (:use :cl
        :ningle
        :lircog.render
        :clack
        :clack.middleware.static
        :clack.middleware.auth.basic
        :clack.builder)
  (:import-from :lircog.render
                :render))

(defvar *app* (make-instance 'ningle:<app>))

;;; routing
(setf (ningle:route *app* "/")
      (lambda (params) (render)))

(setf (ningle:route *app* "/log/:channel")
      (lambda (params)
        (render (format nil "#~A" (getf params :channel)))))

(setf (ningle:route *app* "/log/:channel/:date")
      (lambda (params)
        (render (format nil "#~A" (getf params :channel))
                (getf params :date))))

(defclass <light-log> (<middleware>) ())

(defmethod call ((this <light-log>) env)
  (format t "~A ~A~%"
          (getf env :request-method)
          (getf env :request-uri))
  (call-next this env))

(defvar *handler*
    (clack:clackup
     (clack.builder:builder
      (clack.middleware.auth.basic:<clack-middleware-auth-basic>
       :authenticator #'(lambda (user pass)
                          (and (string= user "irclog")
                               (string= pass "golori"))))
      (clack.middleware.static:<clack-middleware-static>
       :path (lambda (path)
               (when (ppcre:scan "^(?:/static/|/images/|/css/|/js/|/robot\\.txt$|/favicon.ico$)" path)
                 (ppcre:regex-replace "^/static" path "")))
       :root #P"/home/minoru/quicklisp/local-projects/lircog/static/")
      <light-log>
      *app*)))
