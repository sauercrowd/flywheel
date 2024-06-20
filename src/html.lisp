(in-package :flywheel)

(defun render-single-tag (tag keys inner)
    (format nil "<~(~a~)~{ \~(~a~)\=\"~a\"~}>~a</~(~a~)>" tag keys (or inner "") tag))

(defun process-single-tag (html)
  (if (listp html)
	(let ((maybe-html-tag (first html)))
	    (if (typep maybe-html-tag 'keyword)
		(let ((attributes (second html))
		      (bodies (cddr html)))
		    `(render-single-tag ,maybe-html-tag ,attributes ,(render-html-recursively bodies)))
		html))
	 html))




(defun render-html-recursively (htmls)
    `(format nil "~{~a~}" (list ,@(loop for html in htmls collect (process-single-tag html)))))

(defmacro render-html (&body htmls)
  (render-html-recursively htmls))


(defun csrf-html-tag ()
  (let ((lack-session (slot-value *request-context* 'lack-session)))
    (lack/middleware/csrf:csrf-html-tag lack-session)))
	


;(render-html
;  (:html
;   '()
;     (:header () "hello")
;     (:body '(:k 1 :b 2) "inner body")))
