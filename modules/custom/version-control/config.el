;;; custom/version-control/config.el -*- lexical-binding: t; -*-

(use-package! magit
  :commands magit-file-delete
  :defer-incrementally (dash f s with-editor git-commit package eieio transient)
  :init
  ;; Must be set early to prevent ~/.emacs.d/transient from being created
  (setq transient-levels-file  (concat doom-etc-dir "transient/levels")
        transient-values-file  (concat doom-etc-dir "transient/values")
        transient-history-file (concat doom-etc-dir "transient/history"))
  :config
  (add-to-list 'doom-debug-variables 'magit-refresh-verbose)


  ;; The default location for git-credential-cache is in
  ;; ~/.cache/git/credential. However, if ~/.git-credential-cache/ exists, then
  ;; it is used instead. Magit seems to be hardcoded to use the latter, so here
  ;; we override it to have more correct behavior.
  (unless (file-exists-p "~/.git-credential-cache/")
    (setq magit-credential-cache-daemon-socket
          (doom-glob (or (getenv "XDG_CACHE_HOME")
                         "~/.cache/")
                     "git/credential/socket")))
  (setq
   magit-save-repository-buffers 'dontask
   magit-clone-set-remote.pushDefault nil
   magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1
   ;; magit-repository-directories '(("~/work" . 2)
   ;;                                ("~/Sandbox" . 2)
   ;;                                ("~/.hammerspoon" . 1)
   ;;                                ("~/.spacemacs.d" . 1)
   ;;                                ("~/.emacs-profiles/.emacs-spacemacs.d" . 1))
   ;; magit-show-refs-arguments '("--sort=-committerdate")
   magit-delete-by-moving-to-trash nil
   magit-branch-rename-push-target nil ; do not push renamed/deleted branch to remote automatically
   magit-diff-refine-hunk 'all
   ;; transient-values-file "~/.spacemacs.d/magit_transient_values.el"

   ;; https://github.com/magit/ghub/issues/81
   ;; gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"
   )

  ;; Don't display parent/related refs in commit buffers; they are rarely
  ;; helpful and only add to runtime costs.
  (setq magit-revision-insert-related-refs nil)

  ;; Add `git log ORIG_HEAD..HEAD` to magit
  ;; that lets you log only changes since the last pull
  (transient-append-suffix 'magit-log "l"
    '("p" "orig_head..head" +magit-log-orig_head--head))

  (transient-append-suffix 'magit-log "l"
    '("R" "other..current" +magit-log-other--current))

  (transient-append-suffix 'magit-log "l"
    '("m" "origin/master..current" +magit-log--origin-master))

  (transient-append-suffix 'magit-diff "d"
    '("R" "Diff range (reversed)" +magit-diff-range-reversed))

  (transient-append-suffix 'magit-diff "d"
    '("m" "origin/master..current" +magit-diff--origin-master))

  ;; Center the target file, because it's poor UX to have it at the bottom of
  ;; the window after invoking `magit-status-here'.
  (advice-add #'magit-status-here :after #'doom-recenter-a)

  ;; who cares if tags not displayed in magit-refs buffer?
  (remove-hook 'magit-refs-sections-hook 'magit-insert-tags)
  (add-hook 'magit-process-mode-hook #'goto-address-mode)

  (map! :leader "gs" #'magit-status))

(use-package! evil-collection-magit
  :defer t
  :init (defvar evil-collection-magit-use-z-for-folds t)
  :config
  ;; These numbered keys mask the numerical prefix keys. Since they've already
  ;; been replaced with z1, z2, z3, etc (and 0 with g=), there's no need to keep
  ;; them around:
  ;; (undefine-key! magit-mode-map "M-1" "M-2" "M-3" "M-4" "1" "2" "3" "4" "0")

  ;; q is enough; ESC is way too easy for a vimmer to accidentally press,
  ;; especially when traversing modes in magit buffers.
  (evil-define-key* 'normal magit-status-mode-map [escape] nil)

  ;; Some extra vim-isms I thought were missing from upstream
  (map! :map magit-mode-map
    "%"  #'magit-gitflow-popup
    "zt" #'evil-scroll-line-to-top
    "zz" #'evil-scroll-line-to-center
    "zb" #'evil-scroll-line-to-bottom
    "g=" #'magit-diff-default-context
    "gi" #'forge-jump-to-issues
    "gm" #'forge-jump-to-pullreqs
    "l" #'evil-forward-char
    "M-l" #'magit-log
    "h" #'evil-backward-char
    "M-h" #'magit-dispatch
    "q" #'+magit/quit)

  (map! :map transient-map "q" #'transient-quit-one
        :map transient-edit-map "q" #'transient-quit-one
        :map transient-sticky-map "q" #'transient-quit-seq)

  (evil-define-key* 'normal magit-revision-mode-map
    "q" #'magit-log-bury-buffer)

  ;; Fix these keybinds because they are blacklisted
  ;; REVIEW There must be a better way to exclude particular evil-collection
  ;;        modules from the blacklist.
  (map! (:map magit-mode-map
         :nv "q" #'+magit/quit
         :nv "Q" #'+magit/quit-all
         :nv "]" #'magit-section-forward-sibling
         :nv "[" #'magit-section-backward-sibling
         :nv "gr" #'magit-refresh
         :nv "gR" #'magit-refresh-all)
        (:map magit-status-mode-map
         :nv "gz" #'magit-refresh)
        (:map magit-diff-mode-map
         :nv "gd" #'magit-jump-to-diffstat-or-diff))

  ;; A more intuitive behavior for TAB in magit buffers:
  (define-key! 'normal
    (magit-status-mode-map
     magit-stash-mode-map
     magit-revision-mode-map
     magit-process-mode-map
     magit-diff-mode-map)
    [tab] #'magit-section-toggle)

  (after! git-rebase
    (dolist (key '(("M-k" . "gk") ("M-j" . "gj")))
      (when-let (desc (assoc (car key) evil-collection-magit-rebase-commands-w-descriptions))
        (setcar desc (cdr key))))
    (evil-define-key* evil-collection-magit-state git-rebase-mode-map
      "gj" #'git-rebase-move-line-down
      "gk" #'git-rebase-move-line-up))

  (after! magit-gitflow
    (transient-replace-suffix 'magit-dispatch 'magit-worktree
      '("%" "Gitflow" magit-gitflow-popup)))

  (transient-append-suffix 'magit-dispatch '(0 -1 -1)
    '("*" "Worktree" magit-worktree)))

(use-package! forge
  ;; We defer loading even further because forge's dependencies will try to
  ;; compile emacsql, which is a slow and blocking operation.
  :after-call magit-status
  :commands forge-create-pullreq forge-create-issue
  :preface
  (setq forge-database-file (concat doom-etc-dir "forge/forge-database.sqlite"))
  :config
  ;; All forge list modes are derived from `forge-topic-list-mode'
  (map! :map forge-topic-list-mode-map :n "q" #'kill-current-buffer)
  (map! :map forge-topic-mode-map
        "0" #'evil-digit-argument-or-evil-beginning-of-line
        "$" #'evil-end-of-line
        "v" #'evil-visual-char
        "l" #'evil-forward-char
        "h" #'evil-backward-char
        "w" #'evil-forward-word-begin
        "b" #'evil-backward-word-begin)

  (set-popup-rule! "^\\*?[0-9]+:\\(?:new-\\|[0-9]+$\\)" :size 0.45 :modeline t :ttl 0 :quit nil)
  (set-popup-rule! "^\\*\\(?:[^/]+/[^ ]+ #[0-9]+\\*$\\|Issues\\|Pull-Requests\\|forge\\)" :ignore t)

  (defadvice! +magit--forge-get-repository-lazily-a (&rest _)
    "Make `forge-get-repository' return nil if the binary isn't built yet.
This prevents emacsql getting compiled, which appears to come out of the blue
and blocks Emacs for a short while."
    :before-while #'forge-get-repository
    (file-executable-p emacsql-sqlite-executable))

  (defadvice! +magit--forge-build-binary-lazily-a (&rest _)
    "Make `forge-dispatch' only build emacsql if necessary.
Annoyingly, the binary gets built as soon as Forge is loaded. Since we've
disabled that in `+magit--forge-get-repository-lazily-a', we must manually
ensure it is built when we actually use Forge."
    :before #'forge-dispatch
    (unless (file-executable-p emacsql-sqlite-executable)
      (emacsql-sqlite-compile 2)
      (if (not (file-executable-p emacsql-sqlite-executable))
          (message (concat "Failed to build emacsql; forge may not work correctly.\n"
                           "See *Compile-Log* buffer for details"))
        ;; HACK Due to changes upstream, forge doesn't initialize completely if
        ;;      it doesn't find `emacsql-sqlite-executable', so we have to do it
        ;;      manually after installing it.
        (setq forge--sqlite-available-p t)
        (magit-add-section-hook 'magit-status-sections-hook 'forge-insert-pullreqs nil t)
        (magit-add-section-hook 'magit-status-sections-hook 'forge-insert-issues   nil t)
        (after! forge-topic
          (dolist (hook forge-bug-reference-hooks)
            (add-hook hook #'forge-bug-reference-setup)))))))

(use-package! gist
  :config
  (setq
   gist-view-gist t ; view your Gist using `browse-url` after it is created
   ))

(use-package! github-review
  :after forge
  :config

  (after! (magit forge gh-notify)
    (map! :map (magit-status-mode-map
                forge-topic-mode-map
                gh-notify-mode-map)
          "M-r" #'github-review-forge-pr-at-point))

  (defun github-review--copy-suggestion ()
    "kill a region of diff+ as a review suggestion template."
    (interactive)
    (setq deactivate-mark t)
    (let ((s-region
           (buffer-substring-no-properties
            (region-beginning)
            (region-end))))
      (kill-new
       (format "# ```suggestion\n%s\n# ```\n"
               (replace-regexp-in-string "^\\+" "# " s-region)))))

  (map! :map github-review-mode-map :v "M-y" #'github-review--copy-suggestion)

  (defun github-review--after-save-diff (pr-alist diff)
    (let-alist pr-alist
      (with-current-buffer
          (format "%s___%s___%s___%s.diff" .owner .repo .num .sha)
        (goto-line 1))))

  (advice-add 'github-review-save-diff :after 'github-review--after-save-diff)

  ;; otherwise it messes up with backwards-kill-word when commenting
  (bind-key (kbd "M-DEL") nil diff-mode-map)

  (setq github-review-fetch-top-level-and-review-comments t
        github-review-view-comments-in-code-lines t
        github-review-view-comments-in-code-lines-outdated t))

(use-package! git-link
  :config
  (map! :leader "glm" #'git-link-master-branch))

(use-package! gh-notify
  :defer t
  :after magit
  :init (require 'gh-notify)
  :config
  (setq gh-notify-redraw-on-visit t)

  (map! :leader "agh" #'gh-notify)

  (map! :map gh-notify-mode-map
        :n "RET" #'gh-notify-visit-notification
        :n "q" #'kill-buffer-and-window)
  (map! :localleader :map gh-notify-mode-map
        "C-l" nil
        "l" #'gh-notify-retrieve-notifications
        "r" #'gh-notify-reset-filter
        "t" #'gh-notify-toggle-timing
        "y" #'gh-notify-copy-url
        "s" #'gh-notify-display-state
        "i" #'gh-notify-ls-issues-at-point
        "P" #'gh-notify-ls-pullreqs-at-point
        "p" #'gh-notify-forge-refresh
        "g" #'gh-notify-forge-visit-repo-at-point
        "m" #'gh-notify-mark-notification
        "M" #'gh-notify-mark-all-notifications
        "u" #'gh-notify-unmark-notification
        "U" #'gh-notify-unmark-all-notifications
        "\\" #'gh-notify-toggle-url-view
        "/d" #'gh-notify-toggle-global-ts-sort
        "/u" #'gh-notify-limit-unread
        "/'" #'gh-notify-limit-repo
        "/\"" #'gh-notify-limit-repo-none
        "/p" #'gh-notify-limit-pr
        "/i" #'gh-notify-limit-issue
        "/*" #'gh-notify-limit-marked
        "/a" #'gh-notify-limit-assign
        "/y" #'gh-notify-limit-author
        "/m" #'gh-notify-limit-mention
        "/t" #'gh-notify-limit-team-mention
        "/s" #'gh-notify-limit-subscribed
        "/c" #'gh-notify-limit-comment
        "/r" #'gh-notify-limit-review-requested
        "//" #'gh-notify-limit-none)

  ;; always recenter when getting back to gh-notify buffer from forge-buffers
  (advice-add 'gh-notify--filter-notifications :after 'recenter))

(use-package! code-review
  :after (magit gh-notify)
  :init
  (setq code-review-db-database-file
        (concat doom-etc-dir "code-review-db-file.sqlite"))
  :config
  (after! (magit forge gh-notify)
    (map! :map (magit-status-mode-map
                forge-topic-mode-map
                gh-notify-mode-map)
          :n "s-r" #'code-review-forge-pr-at-point))

  (after! 'evil-escape
    (add-to-list 'evil-escape-excluded-major-modes 'code-review-mode))

  (after! 'evil-collection
    (dolist (binding evil-collection-magit-mode-map-bindings)
      (pcase-let* ((`(,states _ ,evil-binding ,fn) binding))
        (dolist (state states)
          (evil-collection-define-key state 'code-review-mode-map evil-binding fn))))
    (evil-set-initial-state 'code-review-mode evil-default-state))

  (map! :map code-review-mode-map
        :nv (kbd "<escape>") nil
        :nv "," nil
        :n "q" #'kill-buffer-and-window)

  (map! :localleader
        :map code-review-mode-map
        "," #'code-review-transient-api))
