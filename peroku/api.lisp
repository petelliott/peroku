(defpackage :peroku.api
  (:nicknames api)
  (:use :cl)
  (:export
    #:*app*))

(in-package :peroku.api)

(defvar *app* (make-instance 'ningle:<app>))


(setf (ningle:route *app* "/" :method :GET)
      (lambda (params)
        (declare (ignore params))
        (format nil "peroku ~a"
                (asdf:component-version
                  (asdf:find-system :peroku)))))

(setf (ningle:route *app* "/list" :method :GET)
      (lambda (params)
        (declare (ignore params))
        "get not yet implemented"))

(setf (ningle:route *app* "/run" :method :POST)
      (lambda (params)
        (print params)
        (print "")
        "run not yet implemented"))

(setf (ningle:route *app* "/:project" :method :GET)
      (lambda (params)
        (declare (ignore params))
        "getting project not yet implemented"))

(setf (ningle:route *app* "/:project" :method :DELETE)
      (lambda (params)
        (declare (ignore params))
        "deletion not yet implemented"))
