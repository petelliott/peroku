(defpackage :peroku-client.core
  (:nicknames :pcli.core :core)
  (:use :cl)
  (:export
    #:list-projects
    #:up
    #:down))

(in-package :peroku-client.core)


(defun list-projects (token peroku)
  "list all projects managed by peroku"
  (let ((projects (json:decode-json-from-string
                    (dex:get
                      (concatenate 'string
                                   "http://"
                                   peroku
                                   "/list")
                      :headers (and token
                                    `(("Authorization" . ,token)))))))
    (mapc
      (lambda (alist)
        (format t "~&~20a~a~%"
                (cdr (assoc :project alist))
                (cdr (assoc :rule alist))))
      projects)))


(defun up (token peroku project rule)
  "bring up the project"
  (let ((logid (cdr (assoc :logid
                      (json:decode-json-from-string
                        (dex:post
                          (concatenate 'string
                                       "http://"
                                       peroku
                                       "/run")
                          :headers (cons
                                     '("Content-Type" . "application/json")
                                     (and token
                                          `(("Authorization" . ,token))))
                          :content (json:encode-json-to-string
                                     `(("project" . ,project)
                                       ("rule" . ,rule)
                                       ("data" . ,(util:tar-and-b64 #P"."))))))))))
    (util:write-websocket
      (concatenate 'string
                   "ws://"
                   peroku
                   "/logs/"
                   logid))))


(defun down (token peroku project)
  "take down a project"
  (handler-case
    (progn
      (dex:delete
        (concatenate 'string
                     "ws://"
                     peroku
                     "/projects/"
                     project)
        :headers (and token
                      `(("Authorization" . ,token))))
      (format t "~&deleted ~a~%" project))
    (DEXADOR.ERROR:HTTP-REQUEST-NOT-FOUND ()
      (format t "~&project ~a not found~%" project))))
