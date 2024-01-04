;;; custom/git/autoload/bug-reference.el -*- lexical-binding: t; -*-

(defvar bug-reference-default-org "zerocmd")

;;;###autoload
(defun init-bug-reference-mode-settings ()
  (setq bug-reference-bug-regexp
        (concat "\\(\\b\\(PR \\|[Bb]ug \\|[Ii]ssue \\|\\)" ; type
                "\\(\\([A-z]+\\/\\)\\|\\/\\)" ; org
                "\\([A-z -]+\\)" ; project
                "#\\([0-9]+\\)\\)" ; ticket No
                ))
  (setq bug-reference-url-format #'bug-reference-url-format-fn))

;;;###autoload
(defun bug-reference-url-format-fn ()
  (let* ((type (pcase (match-string-no-properties 2)
                 ("PR " "pull")
                 ((or "Bug " "bug " "Issue " "issue ") "issues")
                 ("" "issues")))
         (org (match-string-no-properties 4))
         (project (match-string-no-properties 5))
         (ticket (match-string-no-properties 6))
         (org (if (not (or (null org)
                           (string-blank-p org)))
                  (substring org 0 -1)
                bug-reference-default-org)))
    (if type (format "https://github.com/%s/%s/%s/%s" org project type ticket)
      (format "https://github.com/%s/%s/search?q=%s" org project ticket))))
