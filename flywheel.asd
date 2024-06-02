(asdf:defsystem "flywheel"
  :version "0.1"
  :author "Jonas Otten"
  :license "MIT"
  :components ((:module "src"
		:components ((:file "package")
			     (:file "html")
			     (:file "template")
			     (:file "router")
                             (:file "server")
                             (:file "static-files")
                             (:file "controller")
			     (:file "view"))))
  :depends-on ("clack"
               "lack-request"
               "alexandria"
               "lack-response"
               "dbi"
               "myway"
               "quri"))
