(defpackage :peroku.api.auth
  (:nicknames auth)
  (:use :cl)
  (:export
    #:*token*
    #:unauth
    #:ws-unauth))

(in-package :peroku.api.auth)

(defparameter *token* (uiop:getenv "PEROKU_TOK"))


(setf (ningle:requirement peroku.api.app:*app* :secured)
      (lambda (value)
        (declare (ignore value))
        (or
          (null *token*)
          (string=
            *token*
            (get-token
              (lack.request:request-headers
                ningle:*request*))))))


(defun get-token (headers)
  (let ((auth (gethash "authorization" headers)))
    (let* ((parts (cl-ppcre:split "\\s+" auth))
           (atype (first parts))
           (aval (second parts)))
      (cond
        ((string= atype "Bearer")
         aval)
        ((string= atype "Basic")
         (let* ((authparts (cl-ppcre:split
                             ":" (base64:base64-string-to-string aval)))
                (username (first authparts))
                (password (second authparts)))
           password))))))



(defun unauth (&rest args)
  "define an unautorised endpoint for correct error codes"
  (setf (apply #'ningle:route peroku.api.app:*app* args)
        (lambda (params)
          (declare (ignore params))
          '(403 (:content-type "text/plain") ("Invalid token.")))))

(defun ws-unauth (&rest args)
  "define an unautorised websocket endpoint for correct error codes"
  (setf (apply #'ningle:route peroku.api.app:*app* args)
        (lambda (params)
          (let ((ws (wsd:make-server
                      (lack.request:request-env ningle:*request*))))
            (wsd:on :open ws
              (lambda ()
                (wsd:close-connection ws "invalid token" 4001)))
            (lambda (responder)
              (declare (ignore responder))
              (wsd:start-connection ws))))))
