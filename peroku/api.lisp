(defpackage :peroku.api
  (:nicknames api)
  (:use :cl :peroku)
  (:export))

(in-package :peroku.api)


(setf (ningle:route *app* "/" :method :GET)
      (lambda (params)
        (declare (ignore params))
        (format nil "peroku ~a"
                (asdf:component-version
                  (asdf:find-system :peroku)))))


(setf (ningle:route *app* "/list" :method :GET :secured t)
      (lambda (params)
        (declare (ignore params))
        (headers :content-type "application/json")
        (let ((projects (core:list-projects)))
          (if projects
            (json:encode-json-to-string projects)
            "[]"))))

(auth:unauth "/list" :method :GET)

(setf (ningle:route *app* "/run" :method :POST :secured t)
      (lambda (params)
        (headers :content-type "application/json")
        (let ((project (cdr (assoc "project" params :test #'string=)))
              (rule (cdr (assoc "rule" params :test #'string=)))
              (data (cdr (assoc "data" params :test #'string=))))
          (multiple-value-bind (logid logger)
            (logman:make-log-endpoint :single-use t)
            (bt:make-thread
              (lambda ()
                (let* ((image (cdr (assoc :+ID+
                                          (core:build
                                            data
                                            :strmfun
                                            (lambda (message)
                                              (logger:logger-send logger message))))))
                       (cont (core:replace-container project rule image)))
                  (logger:logger-close logger)
                  (docker:start-container project))))
            (json:encode-json-to-string
              `(("logid" . ,logid)))))))

(auth:unauth "/run" :method :POST)

(setf (ningle:route *app* "/projects/:project" :method :GET :secured t)
      (lambda (params)
        (declare (ignore params))
        "getting project not yet implemented"))

(auth:unauth "/project/:project" :method :GET)

(setf (ningle:route *app* "/projects/:project" :method :DELETE :secured t)
      (lambda (params)
        (handler-case
          (core:delete-project
            (cdr (assoc :project params)))
        (error ()
          `(404 (:content-type "text/plain")
            (,(format nil "project '~a' not found."
                      (cdr (assoc :project params)))))))))

(auth:unauth "/project/:project" :method :DELETE)

(defun headers (&rest headers)
  (setf (lack.response:response-headers ningle:*response*)
        (append (lack.response:response-headers ningle:*response*)
                headers)))
