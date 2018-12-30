(defpackage :peroku.logs
  (:nicknames :logs)
  (:use :cl))

(in-package :peroku.logs)


(setf (ningle:route peroku:*app* "/logs/:logid" :method :GET :secured t)
      (lambda (params)
        (let ((ws (wsd:make-server
                    (lack.request:request-env ningle:*request*)))
              (logid (cdr (assoc :logid params))))
          (if (logman:is-endpoint logid)
            (progn
              (logman:log-manager-attach logid ws)
              (lambda (responder)
                (declare (ignore responder))
                (wsd:start-connection ws)))
            '(404 (:content-type "text/plain")
              ("logging endpoint not found"))))))

(auth:ws-unauth "/logs/:logid" :method :GET)


(defun forward-docker-stream (strm ws)
  "copies a docker stream to json messages to a websocket"
  (let* ((sem bt:make-semaphore)
         (thread
          (bt:make-thread
            (lambda ()
              (bt:wait-on-semaphore sem)
              (loop
                for line = (docker:read-docker-line strm)
                until (null line)
                do (wsd:send
                     ws
                     (json:encode-json-to-string
                       `(("stream" . ,(first line))
                         ("data" ., (third line))))))
              (wsd:close-connection ws)))))
    (wsd:on :open ws
      (lambda ()
        (bt:signal-semaphore sem)))
    (wsd:on :close ws
      (lambda ()
        (bt:destroy-thread thread)))))


(setf (ningle:route peroku:*app* "/projects/:project/logs" :method :GET :secured t)
      (lambda (params)
        (let* ((ws (wsd:make-server
                    (lack.request:request-env ningle:*request*)))
              (project (cdr (assoc :project params)))
              (thread nil)
              (strm (docker:container-logs project :follow 1)))
          (forward-docker-stream strm ws)
          (lambda (responder)
            (declare (ignore responder))
            (wsd:start-connection ws)))))

(auth:ws-unauth "/projects/:project/logs" :method :GET)


(setf logman:*log-manager* (logman:make-log-manager))

; TODO: fix this
#|
(print peroku.api:*app*)
(setf peroku.api:*app*
      (lack:builder
        logman:*log-manager-mw*
        peroku.api:*app*))

(print peroku.api:*app*)
(print "") |#
