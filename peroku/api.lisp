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
        (let* ((project (cdr (assoc "project" params :test #'string=)))
               (rule (cdr (assoc "rule" params :test #'string=)))
               (data (cdr (assoc "data" params :test #'string=)))
               (image (cdr (assoc :+ID+ (core:build data))))
               (cont (core:replace-container project rule image)))
          (docker:start-container project)
          (json:encode-json-to-string cont))))

(setf (ningle:route *app* "/:project" :method :GET)
      (lambda (params)
        (declare (ignore params))
        "getting project not yet implemented"))

(setf (ningle:route *app* "/:project" :method :DELETE)
      (lambda (params)
        (core:delete-project
          (cdr (assoc :project params)))))

(defun headers (&rest headers)
  (setf (lack.response:response-headers ningle:*response*)
        (append (lack.response:response-headers ningle:*response*)
                headers)))
