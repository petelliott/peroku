(defpackage :peroku-client.core
  (:nicknames :pcli.core :core)
  (:use :cl)
  (:export
    #:list-projects
    #:logs
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
                      :headers (util:auth-header token)
                      :insecure insecure))))
    (mapc
      (lambda (alist)
        (format t "~&~20a~a~%"
                (cdr (assoc :project alist))
                (cdr (assoc :rule alist))))
      projects)))


(defun logs (token peroku project &key insecure)
  "display a projects logs"
  (util:write-ws-logs
    (concatenate 'string
                 "wss://" peroku
                 "/projects/" project "/logs")
    :insecure insecure
    :additional-headers (util:auth-header token)))


(defun up (token peroku project rule &key insecure)
  "bring up the project"
  (let ((logid (cdr (assoc :logid
                      (json:decode-json-from-string
                        (dex:post
                          (concatenate 'string
                                       "https://"
                                       peroku
                                       "/run")
                          :headers (util:auth-header
                                     token
                                     '(("Content-Type" . "application/json")))
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
      :insecure insecure
      :additional-headers (util:auth-header token))))


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
        :headers (util:auth-header token)
        :insecure insecure)
      (format t "~&deleted ~a~%" project))
    (DEXADOR.ERROR:HTTP-REQUEST-NOT-FOUND ()
      (format t "~&project ~a not found~%" project))))
