(defpackage :peroku-asd
  (:use :cl :asdf))

(in-package :peroku-asd)

(defsystem peroku
  :version "0.0.0"
  :author  "Peter Elliott"
  :license "AGPL"
  :depends-on (:ningle
               :docker
               :cl-json
               :cl-base64)
  :components ((:module "peroku"
                :components
                ((:file "core")
                 (:file "api"))))
  :description "the peroku server")
