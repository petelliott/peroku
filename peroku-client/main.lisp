(defpackage :peroku-client.main
  (:nicknames :pcli.main)
  (:use :cl)
  (:export
    #:main
    #:start-peroku))

(in-package :peroku-client.main)

(defun main (args)
  (config:with-config (#P".peroku.json")
    (cond
      ((string= (car args) "list")
       (core:list-projects config:*peroku*))
      (t (format t "~&useage: perok [up|down|list]~%")))))

(defun start-peroku ()
  (main (uiop:command-line-arguments)))
