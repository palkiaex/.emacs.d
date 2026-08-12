;;; my-utils.el -*- lexical-binding: t; -*-

;; Shows a popup of available keybindings when typing a long sequence
(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

;; Custom Config Search Function
(defun my-search-emacs-config ()
  "Search for a file in the Emacs configuration directory using project.el."
  (interactive)
  (let ((default-directory user-emacs-directory))
    (call-interactively #'project-find-file)))

(keymap-global-set "C-c s n" #'my-search-emacs-config)

(provide 'my-utils)
