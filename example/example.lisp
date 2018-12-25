(defpackage :example
  (:use :cl)
  (:export
    #:*app*))

(in-package :example)

(defvar *app*
  (lambda (env)
    (declare (ignore env))
    '(200 (:content-type "text/plain") ("peroku example"))))
