(in-package :flywheel)

(defclass controller ()
  ((name  :initarg :name :accessor name)
   (actions :initform (make-hash-table :test 'equal) :accessor actions)
   (before :initform (make-hash-table :test 'equal) :accessor before)
   (after :initform (make-hash-table :test 'equal) :accessor before)))

(defclass request-context ()
  ((state :initform (make-hash-table :test 'equal) :accessor state)
   (template :initform 'application :accessor template)
   (headers :initform '(:content-type "text/html") :accessor headers)
   (request-env :initarg :request-env :accessor request-env)))


(defparameter *controllers* (make-hash-table :test 'equal))

(defvar *request-context* nil "hold state within a request context")

(defun @< (key)
  (gethash key (slot-value *request-context* 'state)))

(defun @= (key value)
  (setf (gethash key (slot-value *request-context* 'state))
	value))


(defun hook-atom-to-symbol (hook)
  (case hook
    (:after 'after)
    (:before 'before)))

(defun get-hook-action-from-controller (controller hook action)
  (let ((hook-symbol (hook-atom-to-symbol hook)))
    (gethash action (slot-value controller hook-symbol))))

(defun get-hook-action-from-controller-name (controller-name hook action)
  (let ((controller (gethash controller-name *controllers*)))
    (get-hook-action-from-controller controller hook action)))

(defun create-controller (name hook-list)
  (let ((controller (make-instance 'controller :name name)))
    (setf (gethash name *controllers*) controller)
    (loop for (hook action fn) in hook-list
          collect (let ((hook-action (get-hook-action-from-controller controller hook action)))
                    (setf hook-action
                       (append hook-action fn))))))

(defmacro defcontroller (name &rest body)
  `(create-controller ,name (list ,@(loop for (hook action fn) in body
                                           collect `(list ,hook ,action ,fn)))))

(defun create-action (controller action handler)
  (let* ((controller (gethash controller *controllers*))
         (actions (slot-value controller 'actions)))
    (setf (gethash action actions) handler)))

(defmacro defaction (controller action args &rest body)
  `(create-action ,controller ,action (lambda ,args ,@body)))

(defun make-html-controller-response (html-response)
  (list 200
	 (slot-value *request-context* 'headers)
	 (list html-response)))

(defun call-action (controller-symbol action-symbol req)
  (let* ((controller (gethash controller-symbol *controllers*)))
    (if controller
	(let ((action
		(gethash action-symbol
			 (slot-value controller 'actions))))
	  (if action
	      (make-html-controller-response
	       (apply action (list req)))
	      nil))
	    nil)))

;(defun redirect (url)
;  (format nil "redirect: ~a" url))


