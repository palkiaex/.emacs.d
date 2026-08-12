;;; my-dired.el -*- lexical-binding: t; -*-

(use-package autorevert
  :ensure nil
  :custom
  (auto-revert-avoid-polling t)
  (auto-revert-interval 5)
  (auto-revert-check-vc-info t)
  (auto-revert-verbose nil)
  (global-auto-revert-non-file-buffers t)
  :config
  (global-auto-revert-mode 1))

(use-package dired
  :ensure nil
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  (dired-listing-switches "-Al")
  (dired-kill-when-opening-new-dired-buffers t)
  (delete-by-moving-to-trash t) 
  :config
  (set-face-attribute 'dired-header nil :background 'unspecified)
  (set-face-attribute 'dired-header nil :foreground 'unspecified :weight 'normal))

(provide 'my-dired)
