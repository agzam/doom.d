;; -*- no-byte-compile: t; -*-
;;; custom/webdev/packages.el

(package! emmet-mode)
(package! rjsx-mode)
(package! prettier-js)

(when (modulep! :tools lookup)
  (package! xref-js2))
