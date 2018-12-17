(defpackage :peroku.api
  (:nicknames api)
  (:use :cl)
  (:export
    #:*app*
    #:system-version))

(in-package :peroku.api)

(defvar *app* (make-instance 'ningle:<app>))


(setf (ningle:route *app* "/" :method :GET)
      (lambda (params)
        (declare (ignore params))
        (format nil "peroku ~a"
                (asdf:component-version
                  (asdf:find-system :peroku)))))

(setf (ningle:route *app* "/build" :method :POST)
      (lambda (params)
        (declare (ignore params))
        "hello world"))
