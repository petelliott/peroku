(defpackage :peroku-client.main
  (:nicknames pcli.main)
  (:use :cl)
  (:export
    #:main
    #:start-peroku))

(in-package :peroku-client.main)

(defun main (args)
  (format t "~a~%" args)
  (format t "peroku client~%"))

(defun start-peroku ()
  (main (uiop:command-line-arguments)))
