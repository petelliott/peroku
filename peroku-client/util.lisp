(defpackage :peroku-client.util
  (:nicknames :pcli.util :util)
  (:use :cl)
  (:export
    #:auth-header
    #:write-websocket
    #:tar-and-b64
    #:prepare-tar-dir
    #:relative-dir))

(in-package :peroku-client.util)

(defun auth-header (token &optional headers)
  "return the auth header in an alist with other headers"
  (if token
    (cons
      `("Authorization" .
        ,(concatenate 'string
                      "Bearer " token))
      headers)
    headers))

(defun write-websocket (uri &key output-stream insecure additional-headers)
  "writes the contents of a websocket to output-stream.
  defaults to stdout. will block until the socket is closed"
  (let ((sem (bt-sem:make-semaphore))
        (ws (wsd:make-client uri)))
    (wsd:start-connection ws :verify (not insecure)
                          :additional-headers additional-headers)
    (wsd:on :message ws
      (lambda (message)
        (write-string message output-stream)))
    (wsd:on :close ws
      (lambda (&key code reason)
        (declare (ignore code) (ignore reason))
        (bt-sem:signal-semaphore sem)))
    (bt-sem:wait-on-semaphore sem)))


(defun tar-and-b64 (path)
  "creates a tarfile from path and outputs a base64 string"
  (base64:usb8-array-to-base64-string
    (flexi-streams:with-output-to-sequence (s :element-type '(unsigned-byte 8))
      (let ((archive (archive:open-archive
                       'archive:tar-archive
                       s :direction :output))
            (files (prepare-tar-dir path)))
        (dolist (file files (archive:finalize-archive archive))
          (archive:write-entry-to-archive
            archive
            (archive:create-entry-from-pathname archive file)))))))

(defun prepare-tar-dir (dir)
  "prepares a list of files for a direcotry to tar"
  (apply #'concatenate
         'list
         (mapcar
           (lambda (elem)
             (if (fad:directory-pathname-p elem)
                 (prepare-tar-dir elem)
               (list (relative-dir elem))))
           (fad:list-directory dir))))

(defun relative-dir (path &optional relto)
  "gets a directory relative to relto. if relto is not specified
  *default-pathname-defaults is used"
  (unless relto
    (setf relto *default-pathname-defaults*))
  (fad:canonical-pathname
    (subseq
      (namestring path)
      (length (namestring relto)))))
