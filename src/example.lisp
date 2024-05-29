(in-package :flywheel)


(deftemplate 'application (body)
    (:html
     (:body '(:k 1) body)))


(defrouter
  (:get "/posts" 'posts :index)
  (:get "/posts/:id" 'posts :get)
  (:get "/posts/2" 'posts :get))

(defcontroller 'posts)

(defaction 'posts :get (req)
  (let ((params (car req)))
    (@= :params "hey what's going on")
    (render-view 'posts :get)))
				

(defview 'posts :get ()
  (format nil "hello world ~a!!" (@< :params)))
  


(render-template 'application '("hello"))

;; todo
;; setup default template and use it for view
;; serve static assets
;; partials
;; database
;; eval refresh
