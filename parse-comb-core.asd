(in-package #:asdf)

(defsystem "parse-comb"
    :description "Haskell inspired parser combinator library."
    :version "0"
    :author "Martin Carlson <spearalot@gmail.com>"
    :licence "Public Domain"
    :components ((:file "packages")
                 (:file "core" :depends-on ("packages"))))
