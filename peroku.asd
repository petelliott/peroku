(defpackage :peroku-asd
  (:use :cl :asdf))

(in-package :peroku-asd)

(defsystem peroku
  :version "0.3.1"
  :author  "Peter Elliott"
  :license "AGPL"
  :depends-on (:docker
               :cl-json
               :uiop
               :websocket-driver-server
               :cl-base64
               :bordeaux-threads)
  :components ((:module "peroku"
                :components
                ((:file "core")
                 (:file "logger")
                 (:file "log-manager"))))
  :description "the core of a peroku server")
