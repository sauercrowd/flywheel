(defpackage :flywheel
  (:use :cl :alexandria)
  (:export
   :start-server
   :stop-server
   :defaction
   :defview
   :defrouter
   :csrf-html-tag
   :send-text
   :make-response
   :redirect
   :@get
   :@set
   :render-view
   :set-project-root
   :deftemplate
   :render-html
           :defcontroller))

(in-package :flywheel)
(defparameter *project-root* nil)


(defun set-project-root (root)
  (setf *project-root* root))
