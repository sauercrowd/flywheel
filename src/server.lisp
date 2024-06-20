(in-package :flywheel)

(defun make-response (status-code content)
  (list status-code nil
	(list content)))

(defun handle-route-match (target-route env)
    (destructuring-bind (params route) target-route
	    (let ((controller (slot-value route 'controller))
		  (action (slot-value route 'action)))
	      (handler-case (call-action controller action
			     (list params env))
		(error (e)
		       (make-response 500 (format nil "Error: ~a" e)))))))

(defvar *request-context* nil)

(defun handler (env)
  (let* ((path (getf env :path-info))
         (method (getf env :request-method))
	 (target-route (find-route method path))
	 (*request-context* (make-instance 'request-context
					   :request-env env
					   :lack-session (getf env :lack.session))))
    (if (uiop:string-prefix-p  "/static/" path)
	(handle-static-file path)
	(if target-route
	    (let ((response
		    (handle-route-match target-route env)))
	    (if response
		response
		(make-response 404 "not found")))
	    (make-response 404  "not found")))))

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

(defparameter *server* nil)

(defparameter *server-address* "127.0.0.1")
(defparameter *use-thread* t)

(defun start-server ()
  (let ((builder 
    (lack:builder
     :session
     :csrf
	 (:mito '(:sqlite3 :database-name #P"./myapp.db"))
	    (lambda (env)
	      (funcall 'handler env)))))
    (setf *server*
	(let ((fd (maybe-get-fd 8080)))
	    (clack:clackup
	    builder
	    :server :woo
	    :use-thread *use-thread*
	    :port 8080
	    :address *server-address*
	    :debug t
	    :fd fd)))))

(defun stop-server ()
  (clack:stop *server*))
