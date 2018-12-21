(defpackage :peroku.log-manager
  (:nicknames :log-manager)
  (:use :cl)
  (:export
    #:make-log-endpoint))

(in-package :peroku.log-manager)

(defstruct log-manager
  (lock (bt:make-lock))
  (endpoints (make-hash-table :test 'equal)))


(setf (ningle:route peroku.api:*app* "/logs/logtest" :method :GET)
      (lambda (params)
        (declare (ignore params))
        (multiple-value-bind (logid logger)
            (make-log-endpoint)
          (logger:logger-send logger "hello")
          (logger:logger-send logger "world")
          logid)))


(setf (ningle:route peroku.api:*app* "/logs/:logid" :method :GET)
      (lambda (params)
        (when (ningle:context :log-manager)
          (let ((ws (wsd:make-server
                      (lack.request:request-env ningle:*request*))))
            (bt:with-lock-held ((log-manager-lock
                                  (ningle:context :log-manager)))
              (wsd:on :open ws
                      (lambda ()
                        (logger-attach
                          (gethash
                            (cdr (assoc :logid params))
                            (log-manager-endpoints (ningle:context :log-manager)))
                          ws))))
            (lambda (responder)
              (declare (ignore responder))
              (wsd:start-connection ws))))))


(defun make-log-endpoint (&optional log-manager)
  "create a new logging endpoint. returns the endpoint
  id and the endpoints logger"
  (unless log-manager
    (unless (ningle:context :log-manager)
      (setf (ningle:context :log-manager)
            (make-log-manager)))
    (setf log-manager (ningle:context :log-manager)))

  (let ((logid (random-string)))
    (if (gethash logid (log-manager-endpoints log-manager))
      (make-log-endpoint log-manager)
      (let ((logger (logger:make-logger)))
        (setf (gethash logid (log-manager-endpoints log-manager))
              logger)
      (values logid logger)))))


(defvar +ascii-alphabet+ "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNIPQRSTUVWXYZ0123456789")


(defun random-string (&optional (length 16) (alphabet +ascii-alphabet+))
  "Returns a random alphabetic string.

The returned string will contain LENGTH characters chosen from
the vector ALPHABET.
"
  (loop with id = (make-string length)
        with alphabet-length = (length alphabet)
        for i below length
        do (setf (cl:aref id i)
                 (cl:aref alphabet (random alphabet-length)))
        finally (return id)))


