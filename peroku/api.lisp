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

(setf (ningle:route *app* "/:project/build" :method :POST)
      (lambda (params)
        (declare (ignore params))
        "build not yet implemented"))

(setf (ningle:route *app* "/:project/run" :method :POST)
      (lambda (params)
        (declare (ignore params))
        "run not yet implemented"))

(setf (ningle:route *app* "/:project/start" :method :POST)
      (lambda (params)
        (declare (ignore params))
        "start not yet implemented"))

(setf (ningle:route *app* "/:project/stop" :method :POST)
      (lambda (params)
        (declare (ignore params))
        "stop not yet implemented"))
