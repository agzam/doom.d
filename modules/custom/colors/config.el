;;; custom/colors/config.el -*- lexical-binding: t; -*-

(map! :leader
      "Tn" #'colors/cycle-themes-down
      "Tp" #'colors/cycle-themes-up)

(use-package! ag-themes
  :after-call doom-init-ui-h
  :config)

(use-package! circadian
  :defer t
  :hook (doom-init-ui . circadian-setup)
  :config
  (setq
   ;; North of TX
   calendar-latitude 33.16
   calendar-longitude -96.93
   circadian-themes '((:sunrise . ag-themes-spacemacs-light)
                      (:sunset  . ag-themes-base16-ocean))))

(use-package! rainbow-mode
  :defer t)
