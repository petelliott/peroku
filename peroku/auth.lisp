(defpackage :peroku.auth
  (:nicknames auth)
  (:use :cl)
  (:export
    #:*token*
    #:unauth))

(in-package :peroku.auth)

(defparameter *token* (uiop:getenv "PEROKU_TOK"))


(setf (ningle:requirement peroku:*app* :secured)
      (lambda (value)
        (declare (ignore value))
        (or
          (null *token*)
          (string=
            *token*
            (gethash
              "authorization"
              (lack.request:request-headers
                ningle:*request*))))))

(defun unauth (&rest args)
  "define an unautorised endpoint for correct error codes"
  (setf (apply #'ningle:route peroku:*app* args)
        (lambda (params)
          (declare (ignore params))
          '(403 (:content-type "text/plain") ("Invalid token.")))))
