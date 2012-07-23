
(in-package :cl-user)
(defpackage lircog-asd
  (:use :cl :asdf))
(in-package :lircog-asd)

(defsystem lircog
  :version "0.1"
  :author ""
  :license ""
  :depends-on (:ningle
               :clack
               :cl-syntax
               :cl-syntax-annot
               :cl-who
               :cl-ppcre
               :url-rewrite
               :alexandria)
  :components ((:module "src"
                :components
                ((:file "parse")
                 (:file "log" :depends-on ("util"))
                 (:file "util")
                 (:file "render" :depends-on ("log" "util" "parse"))
                 (:file "controller" :depends-on ("log" "render")))))
  :description "")
