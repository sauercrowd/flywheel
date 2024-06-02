(in-package :flywheel)

(defparameter *templates* (make-hash-table :test 'equal))


(defmacro deftemplate (key args html-value)
  `(setf (gethash ,key *templates*)
	 (lambda ,args
	   ,html-value)))


(defun render-template (key args)
  (let ((template (gethash key *templates*)))
    (if template
	(apply template args)
	nil)))
