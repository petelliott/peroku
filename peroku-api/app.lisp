(defpackage :peroku.api.app
  (:use :cl)
  (:export
    #:*app*))

(in-package :peroku.api.app)

(defparameter *app* (make-instance 'ningle:<app>))
