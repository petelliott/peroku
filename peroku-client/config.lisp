(defpackage :peroku-client.config
  (:nicknames :pcli.config :config)
  (:use :cl)
  (:export
    *token*
    *peroku*
    *project*
    *rule*
    #:load-config
    #:with-config))

(in-package :peroku-client.config)

(defvar *token*)
(defvar *peroku*)
(defvar *project*)
(defvar *rule*)

(defgeneric load-config (config))

(defmacro with-config (config &rest body)
  "provides an environment with the peroku config bound"
  `(multiple-value-bind (*token* *peroku* *project* *rule*)
      (load-config ,(car config))
      (progn ,@body)))

(defmethod load-config :around (config)
  "load a configuration"
  (let ((params (call-next-method)))
    (values
      (cdr (assoc :token params))
      (cdr (assoc :peroku params))
      (cdr (assoc :project params))
      (cdr (assoc :rule params)))))


(defmethod load-config ((config string))
  "load a configuration from a json string"
  (json:decode-json-from-string config))

(defmethod load-config ((config stream))
  "load a configuration from a stream"
  (json:decode-json config))

(defmethod load-config ((config pathname))
  "load a configuration from a filename"
  (with-open-file (strm config :direction :input)
    (json:decode-json strm)))
