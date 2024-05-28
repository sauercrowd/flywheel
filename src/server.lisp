(in-package :flywheel)

(defun make-response (status-code content)
  (list status-code nil
	(list content)))

(defun handle-route-match (target-route env)
    (destructuring-bind (params route) target-route
	    (let ((controller (slot-value route 'controller))
		    (action (slot-value route 'action)))
	      (call-action controller action
			   (list params env)))))

(defun handler (env)
  (let* ((path (getf env :path-info))
         (method (getf env :request-method))
	 (target-route (find-route method path))
	 (*request-context* (make-instance 'request-context)))
    (if target-route
	(let ((response
		(handle-route-match target-route env)))
	  (if response
	      response
	      (make-response 404 "not found")))
	(make-response 404  "not found"))))

(defun maybe-get-fd (port)
  (let ((fds (cl-ppcre:split ";" (uiop:getenv "SERVER_STARTER_PORT"))))
    (if fds
        (let* ((regex (format nil "~a=" port))
               (match (find-if
                        (lambda (fd)
                            (cl-ppcre:scan regex fd))
                        fds)))
          (if match
            (multiple-value-bind
                (int _)
                (parse-integer
                  (second
                    (cl-ppcre:split "=" match)))
              int)
              nil))
        nil)))

;;(apply (gethash :index (slot-value (gethash 'posts *controllers*) 'actions)) '(1))
;;(handle-route-match (gethash 'posts *routes*) ())

(defparameter *server*
  (let ((fd (maybe-get-fd 8080)))
      (clack:clackup
        (lambda (env)
          (funcall 'handler env))
        :server :woo
        :fd fd)))

(clack:stop *server*)
