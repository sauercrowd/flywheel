(in-package :flywheel)

(defparameter *views* (make-hash-table :test 'equal))

(defun render-view (&rest key)
  (let ((target-view (gethash key *views*)))
    (if target-view
	(render-template
	 (slot-value *request-context* 'template)
	    (list (funcall target-view)))
	nil)))

(defun define-view (key body)
  (setf (gethash key *views*) body))

(defmacro defview (controller action args &body body)
  `(define-view (list ,controller ,action)
     (lambda ,args ,@body)))
		      

	       


