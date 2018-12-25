(defpackage :peroku-client.core
  (:nicknames :pcli.core :core)
  (:use :cl)
  (:export
    #:list-projects))

(in-package :peroku-client.core)


(defun list-projects (peroku)
  "list all projects managed by peroku"
  (let ((projects (json:decode-json-from-string
                    (dex:get
                      (concatenate 'string
                                   peroku
                                   "/list")))))
    (mapc
      (lambda (alist)
        (format t "~&~20a~a~%"
                (cdr (assoc :project alist))
                (cdr (assoc :rule alist))))
      projects)))

(defun up (peroku project rule)
  "bring up the project"
  t)


