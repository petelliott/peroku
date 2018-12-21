(defpackage :peroku.api
  (:nicknames api)
  (:use :cl)
  (:export
    #:*app*))

(in-package :peroku.api)

(defvar *app* (make-instance 'ningle:<app>))


(setf (ningle:route *app* "/" :method :GET)
      (lambda (params)
        (declare (ignore params))
        (format nil "peroku ~a"
                (asdf:component-version
                  (asdf:find-system :peroku)))))

(setf (ningle:route *app* "/list" :method :GET)
      (lambda (params)
        (declare (ignore params))
        (headers :content-type "application/json")
        (let ((projects (core:list-projects)))
          (if projects
            (json:encode-json-to-string projects)
            "[]"))))

(setf (ningle:route *app* "/run" :method :POST)
      (lambda (params)
        (headers :content-type "application/json")
        (let ((project (cdr (assoc "project" params :test #'string=)))
              (rule (cdr (assoc "rule" params :test #'string=)))
              (data (cdr (assoc "data" params :test #'string=))))
            (multiple-value-bind (logid logger)
                (logman:make-log-endpoint)
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

(setf (ningle:route *app* "/projects/:project" :method :GET)
      (lambda (params)
        (declare (ignore params))
        "getting project not yet implemented"))

(setf (ningle:route *app* "/projects/:project" :method :DELETE)
      (lambda (params)
        (core:delete-project
          (cdr (assoc :project params)))))

(defun headers (&rest headers)
  (setf (lack.response:response-headers ningle:*response*)
        (append (lack.response:response-headers ningle:*response*)
                headers)))
