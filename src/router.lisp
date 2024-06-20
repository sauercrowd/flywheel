(in-package :flywheel)

(defparameter *routes* (make-hash-table :test 'equal))

(defclass route-param ()
  ((name :initarg :name :accessor route-param-name)))

(defmethod route-param-p ((param route-param))
  t)

(defmethod route-param-p ((param t))
  nil)

(defclass route ()
  ((method :initarg :method :accessor route-method)
   (path :initarg :path :accessor route-path)
   (controller :initarg :controller :accessor route-controller)
   (action :initarg :action :accessor route-action)))

(defun strip-leading-nil (list)
  (if (not (car list))
      (cdr list)
      list))

(defun strip-leading-and-trailing-nil (list)
  (reverse
    (strip-leading-nil
      (reverse
        (strip-leading-nil list)))))


(defun zip-and-extend (list1 list2)
  (let ((reverse-ret (if
                    (<= (length list1)
                       (length list2))
                    t
                    nil))
        (left (if
                 (> (length list1)
                    (length list2))
                 list1
                 list2))
        (right (if
                  (> (length list1)
                     (length list2))
                  list2
                  list1)))
    (loop for x in left
          for y-list = right then (cdr y-list)
          for y = (car y-list)
          collect (if reverse-ret
                      (list y x)
                      (list x y)))))


(defun create-route-key (method path)
  (format nil "~a ~a" method path))

(defun parse-route-path (path)
  (let ((parts (cl-ppcre:split "/" path)))
    (mapcar (lambda (part)
              (cond
                ((string= part "") nil)
                ((string= (subseq part 0 1) ":")
                 (make-instance 'route-param :name (subseq part 1)))
                (t part)))
            parts)))


(defun compare-route-parts (actual-path candidate-path)
  (let ((params (make-hash-table :test 'equal))
        (merged-parts (zip-and-extend actual-path candidate-path)))
    (loop named loop-1
          for
          (actual-part candidate-part) in merged-parts
          do
            (cond
              ((or (not actual-part) (not candidate-part)) (return-from loop-1))
              ((route-param-p candidate-part) (setf (gethash (route-param-name candidate-part) params) actual-part))
              ((string= actual-part candidate-part) nil)
              (t (return-from loop-1)))
            finally (return-from loop-1
                                 (list params
                                         (length actual-path)
                                         (- 0 (hash-table-count params)))))))

(defun find-route-candidates (method path)
  (let ((path-parts (strip-leading-and-trailing-nil (parse-route-path path))))
    (remove-if-not (lambda (value)
                     (and
                       (first value)
                       (equal method
                              (route-method
                                (second value)))))
                   (mapcar (lambda (route-candidate)
                                              (list (compare-route-parts path-parts (route-path route-candidate)) route-candidate))
                                            (alexandria:hash-table-values *routes*)))))

(defun find-target-route-element (method path)
  (let ((candidates (find-route-candidates method path)))
    (first
      (sort candidates (lambda ( a b)
                              (destructuring-bind (_ a-score-1 a-score-2) (car a)
                                (destructuring-bind (_ b-score-1 b-score-2) (car b)
                                  (or
                                    (< a-score-1 b-score-1)
                                    (and
                                      (= a-score-1 b-score-1)
                                      (< a-score-2 b-score-2))))))))))

(defun find-route (method path)
  (let ((target-route-element (find-target-route-element method path)))
    (if target-route-element
	(list  (first (first target-route-element)) (second target-route-element))
	nil)))


(defun create-route (method path controller action)
  (let* ((key (create-route-key method path)))
    (setf (gethash key *routes*)
	  (make-instance 'route
			 :method method
			 :path (strip-leading-and-trailing-nil
                                (parse-route-path path))
			 :controller controller
			 :action action))))

(defmacro defroute (route)
  (destructuring-bind (method path controller action) route
    `(create-route ,method ,path ,controller ,action)))


(defmacro defrouter (&rest routes)
  `(progn
     (setf *routes* (make-hash-table :test 'equal))
     ,@(mapcar (lambda (route)
                 `(defroute ,route))
	       routes)))
