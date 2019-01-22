(defpackage :peroku-api-asd
  (:use :cl :asdf))

(in-package :peroku-api-asd)

(defsystem peroku-api
  :version "0.2.0"
  :author  "Peter Elliott"
  :license "AGPL"
  :depends-on (:ningle
               :cl-json
               :uiop
               :websocket-driver-server
               :bordeaux-threads
               :lack
               :peroku)
  :components ((:module "peroku-api"
                :components
                ((:file "app")
                 (:file "auth")
                 (:file "api")
                 (:file "logs"))))
  :description "the peroku server")
