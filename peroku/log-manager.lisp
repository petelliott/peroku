(defpackage :peroku.log-manager
  (:nicknames :logman :log-manager)
  (:use :cl)
  (:export
    #:*log-manager-mw*
    #:make-log-endpoint
    #:make-log-manager
    #:*log-manager*
    #:is-endpoint
    #:log-manager-attach))

(in-package :peroku.log-manager)

(defstruct log-manager
  (lock (bt:make-lock))
  (endpoints (make-hash-table :test 'equal)))


(defvar *log-manager*
  "a global log manager bound by lexical let with the *log-manager-mw*")


(defvar *log-manager-mw*
  (lambda (app)
    (let ((*log-manager* (make-log-manager)))
      (lambda (env)
        (funcall app env))))
  "a lack middleware that provides a global log-manager")


(defun is-endpoint (logid)
  "returns t if logid is an endpoint, otherwise nil"
  (bt:with-lock-held ((log-manager-lock *log-manager*))
    (if (gethash logid
                 (log-manager-endpoints *log-manager*))
      t
      nil)))


(defun log-manager-attach (logid ws)
  "attach a new websocket to an endpoint"
  (bt:with-lock-held ((log-manager-lock *log-manager*))
    (wsd:on :open ws
            (lambda ()
              (logger:logger-attach
                (gethash
                  logid
                  (log-manager-endpoints *log-manager*))
                ws)))))


(defun make-log-endpoint ()
  "create a new logging endpoint. returns the endpoint
  id and the endpoints logger"
  (let ((logid (random-string)))
    (if (gethash logid (log-manager-endpoints *log-manager*))
      (make-log-endpoint *log-manager*)
      (let ((logger (logger:make-logger)))
        (setf (gethash logid (log-manager-endpoints *log-manager*))
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
