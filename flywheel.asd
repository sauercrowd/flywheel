(asdf:defsystem "flywheel"
  :version "0.1"
  :author "Jonas Otten"
  :license "MIT"
  :components ((:module "src"
                        :components ((:file "package")
                                     (:file "server")
                                     (:file "controller"))))
  :depends-on ("clack"
               "lack-request"
               "alexandria"
               "lack-response"
               "dbi"
               "myway"
               "quri"))
