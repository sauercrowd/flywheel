(deftemplate application
  (render-html
    (html
      (head
        (title "Application"))
      (body
        (h1 "Application")
        (p "This is the application.")
        (slot)))))
