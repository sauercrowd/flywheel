(defrouter
  ("/posts" posts :index)
  ("/posts/:id" posts :get))
