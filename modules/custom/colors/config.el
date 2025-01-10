;;; custom/colors/config.el -*- lexical-binding: t; -*-

(setq pulse-delay 0.05)

(use-package! ag-themes
  :after-call doom-init-ui-h
  :config)

(use-package! circadian
  :hook (window-setup . circadian-setup)
  :config
  ;; North of TX
  (setq calendar-latitude 33.16
        calendar-longitude -96.93)
  (setf circadian-themes
        `(("6:00" . ,(if (display-graphic-p)
                         'ag-themes-spacemacs-light
                       'base16-solarized-light))
          ("21:00" . ag-themes-base16-ocean)
          ;; ("" . ag-themes-base16-tokyo-night-light)
          )))

(use-package! rainbow-mode
  :defer t)

(use-package! beacon
  :after-call doom-first-file-hook
  :config
  (setq beacon-blink-delay 0.1
        beacon-blink-duration 0.7
        beacon-size 60
        beacon-color "DarkGoldenrod2"
        beacon-blink-when-window-scrolls nil)
  (when (and (display-graphic-p)
             (not (featurep :system 'macos)))
   (beacon-mode +1)))
