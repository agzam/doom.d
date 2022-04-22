;;; custom/dired/config.el -*- lexical-binding: t; -*-

(use-package! treemacs-icons-dired
  :defer t
  :hook (dired-mode . treemacs-icons-dired-mode))

(use-package! treemacs
  :defer t
  :init
  (setq treemacs-follow-after-init t
        ;; treemacs-is-never-other-window t
        treemacs-sorting 'alphabetic-case-insensitive-asc
        treemacs-persist-file (concat doom-cache-dir "treemacs-persist")
        treemacs-last-error-persist-file (concat doom-cache-dir "treemacs-last-error-persist"))
  :config
  (map! :leader "pt" #'treemacs-project-toggle+)
  (after! dired (treemacs-resize-icons 16))
  (treemacs-follow-mode 1)

  (after! winum
    (map! :map winum-keymap
     [remap winum-select-window-0] #'treemacs-select-window)

    (dolist (wn (seq-map 'number-to-string (number-sequence 0 9)))
      (let ((f (intern (concat "winum-select-window-" wn)))
            (k (concat "s-" wn)))
        (map! :map treemacs-mode-map k f)))))

(use-package! treemacs-evil
  :defer t
  :init
  (after! treemacs (require 'treemacs-evil))
  (add-to-list 'doom-evil-state-alist '(?T . treemacs))
  :config
  (define-key! evil-treemacs-state-map
    [return] #'treemacs-RET-action
    [tab]    #'treemacs-TAB-action
    "TAB"    #'treemacs-TAB-action
    ;; REVIEW Fix #1875 to be consistent with C-w {v,s}, but this should really
    ;;        be considered upstream.
    "o v"    #'treemacs-visit-node-horizontal-split
    "o s"    #'treemacs-visit-node-vertical-split
    "L"     (cmd! (treemacs-toggle-node :recursive))))

(use-package! treemacs-projectile
  :after treemacs)

(use-package! lsp-treemacs
  :after (treemacs lsp))

(use-package! direx
  :after dired
  :init
  (require 'direx-project)
  :config

  ;; Direx completely got broken in Emacs 29.
  ;; I don't think it's worth trying to fix it and needs to be rewritten
  ;;
  ;; (map! :leader "pt" #'direx/jump-to-project-root-or-current-dir)

  (map! :map direx:file-keymap
        "q" #'kill-this-buffer
        "R" #'direx:do-rename-file
        "C" #'direx:do-copy-files
        "D" #'direx:do-delete-files
        "+" #'direx:create-directory
        "T" #'direx:do-touch
        "j" #'direx:next-item
        "J" #'direx:next-sibling-item
        "k" #'direx:previous-item
        "K" #'direx:previous-sibling-item
        "h" #'direx:collapse-item
        "H" #'direx:collapse-item-recursively
        "l" #'direx:expand-item
        "L" #'direx:expand-item-recursively
        "RET" #'direx:maybe-find-item
        "a" #'direx:find-item
        "r" #'direx:refresh-whole-tree
        "O" #'direx:find-item-other-window
        "|" #'direx:fit-window
        "<C-return>" #'direx:set-root
        "^" #'direx:expand-root-to-parent))

(use-package! dired-imenu
  :after dired)

(use-package! dired-subtree
  :after dired
  :init
  (setq dired-subtree-cycle-depth 5)
  (map! :map dired-mode-map
        :n "M-l" #'dired-subtree-cycle
        :n "M-h" #'dired-subtree-remove*
        :n "M-k" #'dired-subtree-remove*
        :n "M-j" #'dired-subtree-down-n-open
        :n "M-n" #'dired-subtree-next-sibling
        :n "M-p" #'dired-subtree-previous-sibling))

(after! projectile
  (map! :leader
        (:prefix ("p" . "project")
         "d" #'projectile-find-dir
         "D" #'projectile-dired)))

(after! dired
  (map! :leader
        "fj" #'dired-jump
        "fO" #'+macos-open-with)

  (map! :map dired-mode-map
        :n "o" #'dired-find-file-other-window)

  (setq dired-use-ls-dired t
        dired-dwim-target t)

  (put 'dired-find-alternate-file 'disabled nil)

  (when (eq system-type 'darwin)
    (let ((gls (executable-find "gls")))
      (when gls
        (setq insert-directory-program gls
              dired-listing-switches "-aBhl --group-directories-first"))))

  (add-hook 'dired-mode-hook #'dired-hide-details-mode))

(after! embark
  (when (featurep! :custom general)
    (map!
     :map (dired-mode-map direx:direx-mode-map)
     :n "oj" (dired-split-action +evil/window-split-and-follow)
     :n "ol" (dired-split-action +evil/window-vsplit-and-follow)
     :n "oh" (dired-split-action split-window-horizontally)
     :n "ok" (dired-split-action split-window-vertically)
     :n "oa" #'dired-ace-action)))
