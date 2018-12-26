(defpackage :peroku-client.core
  (:nicknames :pcli.core :core)
  (:use :cl)
  (:export
    #:list-projects
    #:up
    #:down))

(in-package :peroku-client.core)


(defun list-projects (token peroku &key insecure)
  "list all projects managed by peroku"
  (let ((projects (json:decode-json-from-string
                    (dex:get
                      (concatenate 'string
                                   "https://"
                                   peroku
                                   "/list")
                      :headers (and token
                                    `(("Authorization" . ,token)))
                      :insecure insecure))))
    (mapc
      (lambda (alist)
        (format t "~&~20a~a~%"
                (cdr (assoc :project alist))
                (cdr (assoc :rule alist))))
      projects)))


(defun up (token peroku project rule &key insecure)
  "bring up the project"
  (let ((logid (cdr (assoc :logid
                      (json:decode-json-from-string
                        (dex:post
                          (concatenate 'string
                                       "https://"
                                       peroku
                                       "/run")
                          :headers (cons
                                     '("Content-Type" . "application/json")
                                     (and token
                                          `(("Authorization" . ,token))))
                          :content (json:encode-json-to-string
                                     `(("project" . ,project)
                                       ("rule" . ,rule)
                                       ("data" . ,(util:tar-and-b64 #P"."))))
                          :insecure insecure))))))
    (util:write-websocket
      (concatenate 'string
                   "wss://"
                   peroku
                   "/logs/"
                   logid)
      :insecure insecure)))


(defun down (token peroku project &key insecure)
  "take down a project"
  (handler-case
    (progn
      (dex:delete
        (concatenate 'string
                     "https://"
                     peroku
                     "/projects/"
                     project)
        :headers (and token
                      `(("Authorization" . ,token)))
        :insecure insecure)
      (format t "~&deleted ~a~%" project))
    (DEXADOR.ERROR:HTTP-REQUEST-NOT-FOUND ()
      (format t "~&project ~a not found~%" project))))
