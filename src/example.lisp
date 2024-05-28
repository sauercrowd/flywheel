(in-package :flywheel)


(deftemplate 'application (body)
    (:html
     (:body (:k 1) body)))


(defrouter
  (:get "/posts" 'posts :index)
  (:get "/posts/:id" 'posts :get)
  (:get "/posts/2" 'posts :get))

(defcontroller 'posts)

(defaction 'posts :get (req)
  (let ((params (car req)))
    (@= :params params)
    (list 200 nil (list
	(render-view 'posts :get)))))
				

(defview 'posts :get ()
  (format nil "hello world ~a" (@< :params)))
