(defpackage :peroku-asd
  (:use :cl :asdf))

(in-package :peroku-asd)

(defsystem peroku
  :version "0.1.0"
  :author  "Peter Elliott"
  :license "AGPL"
  :depends-on (:ningle
               :docker
               :cl-json
               :uiop
               :cl-base64
               :websocket-driver-server
               :bordeaux-threads
               :lack)
  :components ((:module "peroku"
                :components
                ((:file "app")
                 (:file "core")
                 (:file "logger")
                 (:file "log-manager")
                 (:file "auth")
                 (:file "api")
                 (:file "logs"))))
  :description "the peroku server")
