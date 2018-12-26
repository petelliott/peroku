(defpackage :peroku
  (:use :cl)
  (:export
    #:*app*))

(in-package :peroku)

(defparameter *app* (make-instance 'ningle:<app>))
