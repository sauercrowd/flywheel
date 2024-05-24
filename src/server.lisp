(in-package :flywheel)

(defun handler (env)
  (let* ((path (getf env :path-info))
        (method (getf env :request-method))
        (target-route (find-route method path)))
  (list 200 nil (list
                  (format nil "hellob ~a" path)))))

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


(maybe-get-fd 1234)

(defparameter *server*
  (let ((fd (maybe-get-fd 8080)))
      (clack:clackup
        (lambda (env)
          (funcall 'handler env))
        :server :woo
        :fd fd)))

; (clack:stop *server*)
