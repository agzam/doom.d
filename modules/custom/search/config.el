;;; custom/search/config.el -*- lexical-binding: t; -*-

(add-to-list
 'load-path
 (format "%sstraight/build-%s/consult-omni/sources/"
         (file-truename doom-local-dir) emacs-version))

(use-package! consult-omni
  :defer t
  :config
  (require 'consult-omni-embark)
  (setq consult-omni-multi-sources '(
                                     ;; "DuckDuckGo AP/"
                                     "Google"
                                     "Brave"
                                     "Wikipedia"
                                     "Browser History"
                                     "gptel"
                                     "GitHub"
                                     "elfeed"
                                     ;; "notmuch"
                                     "YouTube"))
  (setq consult-omni-default-count 30
        consult-omni-dynamic-input-debounce 0.7
        consult-omni-dynamic-refresh-delay 0.5
        consult-omni-default-browse-function #'browse-url)

  (defadvice! consult-omni-use-thing-at-point-a
    (fn &optional initial no-cb &rest args)
    :around #'consult-omni-multi
    :around #'consult-omni-google
    :around #'consult-omni-wikipedia
    :around #'consult-omni-youtube
    :around #'consult-omni-github
    :around #'consult-omni-gptel
    :around #'consult-omni-browser-history
    :around #'consult-omni-notmuch
    :around #'consult-omni-elfeed
    (let ((init (or initial
                    (if (use-region-p)
                        (buffer-substring (region-beginning) (region-end))
                      (thing-at-point 'symbol :no-props)))))
      (apply fn init no-cb args)))

  (defadvice! consult-omni--multi-dynamic-no-match-a (orig-fn &rest args)
    "Require no match for omni searches."
    :around #'consult-omni--multi-dynamic
    (apply orig-fn (plist-put args :require-match nil)))

  (defun consult-omni-embark-video-process (cand)
    (if-let* ((url (and (stringp cand) (get-text-property 0 :url cand))))
        (+process-external-url url)))

  (map! :map consult-omni-embark-video-actions-map
        "e" #'consult-omni-embark-video-process))
