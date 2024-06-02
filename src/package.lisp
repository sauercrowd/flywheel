(defpackage :flywheel
  (:use :cl :alexandria)
  (:export
   :start-server
   :stop-server
           ; controller
	:defaction
   :defview
   :defrouter
   :render-view
   :set-project-root
   :deftemplate
   :render-html
           :defcontroller))

(in-package :flywheel)
(defparameter *project-root* nil)


(defun set-project-root (root)
  (setf *project-root* root))
