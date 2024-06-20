(in-package :flywheel)

(defclass controller ()
  ((name  :initarg :name :accessor name)
   (actions :initform (make-hash-table :test 'equal) :accessor actions)
   (before :initform (make-hash-table :test 'equal) :accessor before)
   (after :initform (make-hash-table :test 'equal) :accessor before)))

(defclass request-context ()
  ((state :initform (make-hash-table :test 'equal) :accessor state)
   (template :initform :application :accessor template)
   (headers :initform '(:content-type "text/html") :accessor headers)
   (lack-session :initarg :lack-session :accessor lack-session)
   (request-env :initarg :request-env :accessor request-env)))


(defparameter *controllers* (make-hash-table :test 'equal))

;;(defvar *request-context* nil "hold state within a request context")

(defun @get (key)
  (gethash key (slot-value *request-context* 'state)))

(defun @set (key value)
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
  (let ((is-empty-content (= (length html-response) 0)))
    (when is-empty-content
      (remf (slot-value *request-context* 'headers) :content-type))
    (list (if is-empty-content 204 200)
	  (slot-value *request-context* 'headers)
	  (if is-empty-content
	    nil
	    (list html-response)))))

(defun call-action (controller-symbol action-symbol req)
  (let* ((controller (gethash controller-symbol *controllers*)))
    (if controller
	(let ((action
		(gethash action-symbol
			 (slot-value controller 'actions))))
	  (if action
	      (let ((action-response (apply action (list req))))
		(if (is-flywheel-response action-response)
		    (convert-flywheel-response action-response nil) ; TODO: pass actual headers
		    (make-html-controller-response action-response)))
	      nil))
	nil)))

(defclass flywheel-response ()
  ((status :initarg :status :accessor :status)
   (body :initarg :body :accessor :body)
   (extra-headers :initarg :extra-headers :accessor :extra-headers)))

(defun redirect (url)
  (make-instance 'flywheel-response
		 :status 302
		 :extra-headers (list :location url)
		 :body nil))


(defun send-text (status text)
  (make-instance 'flywheel-response
		 :status status
		 :extra-headers nil
		 :body text))

(defmethod is-flywheel-response ((resp flywheel-response)) t)
(defmethod is-flywheel-response ((resp t)) nil)
  
(defun convert-flywheel-response (fw-resp existing-headers)
  (list (slot-value fw-resp 'status)
	(slot-value fw-resp 'extra-headers) ;todo: merge headers
	(list (slot-value fw-resp 'body))))
