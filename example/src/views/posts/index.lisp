(defview posts :index
    (let [posts (get-posts)]
      (render-html
        (:div
          (:h1 "Posts")
          (:ul
            (for (post posts)
              (:li
                (:a (:href (str "/posts/" (:id post))) (:title post)))))))))
