(defpackage :peroku-client.main
  (:nicknames :pcli.main)
  (:use :cl)
  (:export
    #:main
    #:start-peroku))

(in-package :peroku-client.main)

(defun main (args)
  (let ((insecure (when (string= (car args) "noverify")
                    (setf args (cdr args)) t)))
    (config:with-config (#P".peroku.json")
      (handler-case
        (cond
          ((string= (car args) "list")
           (core:list-projects config:*token* config:*peroku* :insecure insecure))
          ((string= (car args) "logs")
           (core:logs config:*token* config:*peroku* config:*project* :insecure insecure))
          ((string= (car args) "up")
           (core:up config:*token* config:*peroku* config:*project* config:*rule* :insecure insecure))
          ((string= (car args) "down")
           (core:down config:*token* config:*peroku* config:*project* :insecure insecure))
          (t (format t "~&useage: perok [noverify] [up|down|list|logs]~%")))
        (CL+SSL:SSL-ERROR-VERIFY ()
          (format *error-output* "~&Unable to varify ssl certificate.~%")
          (format *error-output* "~&Use 'perok noverify *' to not check certificate validity.~%")
          (uiop:quit 1))
        (DEXADOR.ERROR:HTTP-REQUEST-FORBIDDEN ()
          (format *error-output* "~&Missing or Invalid token~%")
          (uiop:quit 1))))))

(defun start-peroku ()
  (main (uiop:command-line-arguments)))
