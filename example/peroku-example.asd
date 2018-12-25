(defpackage :peroku-example-asd
  (:use :cl :asdf))

(in-package :peroku-example-asd)

(defsystem peroku-example
  :components ((:file "example")))
