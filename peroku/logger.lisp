(defpackage :peroku.logger
  (:nicknames :logger)
  (:use :cl)
  (:export
    #:make-logger
    #:logger-send
    #:logger-attach
    #:logger-close))

(in-package :peroku.logger)


(defstruct logger
  (lock (bt:make-lock))
  (closed nil)
  (history '())
  (websockets '()))


(defun logger-send (logger message)
  "sends a message to a websocket logger"
  (bt:with-lock-held ((logger-lock logger))
    (push message (logger-history logger))
    (setf (logger-websockets logger)
          (remove-if
            (lambda (sock)
              (wsd:send sock message)
              (eq (wsd:ready-state sock) :closed))
            (logger-websockets logger)))))


(defun logger-attach (logger ws)
  "attaches a websocket to the logger, catching
  it up with the previous messages"
  (bt:with-lock-held ((logger-lock logger))
    (loop
      for entry in (reverse (logger-history logger))
      do (wsd:send ws entry))
    (if (logger-closed logger)
      (wsd:close-connection ws)
      (push ws (logger-websockets logger)))))


(defun logger-close (logger)
  "close the connected websockets, and close new websockets
  after sending them the history"
  (bt:with-lock-held ((logger-lock logger))
    (loop
      for ws in (logger-websockets logger)
      do (wsd:close-connection ws))
    (setf (logger-closed logger) t)))
