(defpackage :peroku.logs
  (:nicknames :logs)
  (:use :cl))

(in-package :peroku.logs)


(setf (ningle:route peroku:*app* "/logs/:logid" :method :GET)
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
