(in-package :flywheel)

(defparameter *views* (make-hash-table :test 'equal))

(defun render-view (&rest key)
  (let ((target-view (gethash key *views*)))
    (if target-view
	(funcall target-view)
	nil)))

(defun define-view (key body)
  (setf (gethash key *views*) body))

(defmacro defview (&rest args)
  (let ((reversed (reverse args)))
    (let ((body (first reversed))
	  (args (second reversed))
	  (key (reverse (cddr reversed))))
  `(define-view ,key (lambda ,args ,body)))))

(defview posts :get ()
  (format nil "~a" 123))
	       


