(defpackage :peroku.core
  (:nicknames core)
  (:use :cl)
  (:export
    #:+label+
    #:build
    #:create-container
    #:replace-container
    #:list-projects
    #:delete-project))

(in-package :peroku.core)

(defvar +label+ "ca.pelliott.peroku.managed")

(defun build (tarstring)
  "builds a project image from a name and base64 tarfile string"
  (docker:build-image
    (base64:base64-string-to-usb8-array tarstring)))

(defun create-container (project host image)
  "creates the containers for a project"
  (docker:create-container
    image
    :name project
    :json `(("Labels"
             (,+label+ . "")
             ("traefik.frontend.rule" . ,(format nil "Host:~a" host))))))

(defun replace-container (project host image)
  "creates a new container but deletes the old one first (if it exists)"
  (ignore-errors
    (delete-project project))
  (create-container project host image))

(defun list-projects ()
  "lists all containers manged by peroku"
  (let ((dockerinfo (docker:list-containers
                      :all t
                      :filters
                      `(("label" . #(,+label+))))))
    (mapcar
      (lambda (cont)
        `(("project" . ,(subseq (car (cdr (assoc :*NAMES cont))) 1))
          ("rule" . ,(cdr (assoc :traefik.frontend.rule
                                 (cdr (assoc :*LABELS cont)))))))
      dockerinfo)))

(defun delete-project (project)
  "delete a project"
  ;TODO: prune after project deletion
  (docker:remove-container project :force t))
