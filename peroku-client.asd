(defpackage :peroku-client-asd
  (:use :cl :asdf))

(in-package :peroku-client-asd)

(defsystem peroku-client
  :version "0.0.0"
  :author  "Peter Elliott"
  :license "AGPL"
  :depends-on (:cl-json
               :cl-base64
               :uiop
               :websocket-driver-client
               :dexador)
  :components ((:module "peroku-client"
                :components
                ((:file "api")
                 (:file "main"))))
  :description "the peroku client"
  :build-operation program-op
  :build-pathname "perok"
  :entry-point "peroku-client.main:start-peroku")
