(in-package :flywheel)

(defparameter *templates* (make-hash-table :test 'equal))


(defmacro deftemplate (key args html-value)
  `(setf (gethash ,key *templates*)
	 (lambda ,args ',html-value)))


(defun render-template (key)
  (let ((template (gethash *templates* key)))
    (if template
	(render-html template)
	nil)))
