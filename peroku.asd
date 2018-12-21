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
               :cl-base64
               :websocket-driver-server
               :bordeaux-threads
               :lack)
  :components ((:module "peroku"
                :components
                ((:file "core")
                 (:file "logger")
                 (:file "api")
                 (:file "log-manager"))))
  :description "the peroku server")
