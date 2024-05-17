(defun require-auth (req)
    (if (not (session-get :user))
        (redirect "/login")))

(defcontroller posts
  (before :index require-auth))

(defaction posts :index (req)
    (let (posts (query-db
                  (select :*
                          (from :posts)
                          (where (:= :published true))
                          (order-by :created_at :desc)
                          (limit 10))))
        (render-view :posts posts)))

(defaction posts :get (req)
    (let (posts (db/posts))
        (render-view :posts posts)))
