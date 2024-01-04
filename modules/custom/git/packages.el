;; -*- no-byte-compile: t; -*-
;;; custom/git/packages.el

(package! magit)
(package! compat)
;; (package! emacsql-sqlite-builtin)
(package! forge)
(package! gh-notify
  :recipe (:host github
           ;; until PR anticomputer/gh-notify#14 gets merged
	   :repo "benthamite/gh-notify"
           ;; :branch "fix/update-forge-functions"
           ))

(package! git-link)
;; (package! code-review :recipe (:host github :repo "wandersoncferreira/code-review")
;; 	  :pin "26f426e99221a1f9356aabf874513e9105b68140")

;; @tarsius broke Code-Review: https://github.com/wandersoncferreira/code-review/issues/245
(package! code-review :recipe (:host github :repo "phelrine/code-review" :branch "fix/closql-update"))

(package! gist)

(package! transient :recipe (:host github :repo "magit/transient" ))

(unpin! magit forge compat)

(package! closql)

(package! consult-gh :recipe (:host github :repo "armindarvish/consult-gh"))
