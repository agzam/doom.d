;;; custom/writing/autoload/markdown.el -*- lexical-binding: t; -*-

;;;###autoload
(defun maybe-yank-as-org (orig-fun beg end &optional type register yank-handler)
  "Advice function to convert marked region to org before yanking."
  (let ((modes '(markdown-mode chatgpt-shell-mode)))
    (if (and (not current-prefix-arg)
             (apply 'derived-mode-p modes))
        (let* ((_ (unless (executable-find "pandoc")
                    (user-error "pandoc not found")))
               (region-content
                (buffer-substring-no-properties
                 beg end))
               (converted-content
                (with-temp-buffer
                  (insert region-content)
                  (shell-command-on-region
                   (point-min)
                   (point-max)
                   "pandoc -f markdown -t org" nil t)
                  (buffer-string))))
          (kill-new converted-content)
          (message "yanked Markdown as Org"))
      (funcall
       orig-fun
       beg end type register
       yank-handler))))

;;;###autoload
(defun markdown-wrap-collapsible ()
  "Wrap region in a collapsible section."
  (interactive)
  (when (region-active-p)
    (let* ((beg (region-beginning))
           (end (region-end))
           (content (buffer-substring beg end)))
      (delete-region beg end)
      (deactivate-mark)
      (insert
       (format "<details>\n  <summary></summary>\n%s\n</details>" content))
      (search-backward "<summary>")
      (forward-char 9)
      (when evil-mode
        (evil-insert-state)))))
