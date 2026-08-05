;;; Emacs Bedrock
;;;
;;; Extra config: Vim emulation

;;; Core package
(use-package evil
  :ensure t

  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)

  :config
  (evil-mode)

  ;; If you use Magit, start editing in insert state
  (add-hook 'git-commit-setup-hook 'evil-insert-state)

  ;; Configuring initial major mode for some modes
  (evil-set-initial-state 'eat-mode 'emacs)
  (evil-set-initial-state 'vterm-mode 'emacs))

;;; Better key binding for evil
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;;; Highlight yanked text
(require 'pulse)
(defun my-pulse-on-yank (beg end &rest _)
  (pulse-momentary-highlight-region beg end 'highlight))

(advice-add 'evil-yank :after #'my-pulse-on-yank)

;;; Useful bindings
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "g R") 'xref-find-references))
;;; Emacs Bedrock
;;;
;;; Extra config: Vim emulation

;;; Core package
(use-package evil
  :ensure t

  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)

  :config
  (evil-mode)

  ;; If you use Magit, start editing in insert state
  (add-hook 'git-commit-setup-hook 'evil-insert-state)

  ;; Configuring initial major mode for some modes
  (evil-set-initial-state 'eat-mode 'emacs)
  (evil-set-initial-state 'vterm-mode 'emacs))

;;; Better key binding for evil
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;;; Highlight yanked text
(require 'pulse)
(defun my-pulse-on-yank (beg end &rest _)
  (pulse-momentary-highlight-region beg end 'highlight))

(advice-add 'evil-yank :after #'my-pulse-on-yank)

;; Fast diagnostic navigation
(with-eval-after-load 'flymake
  (evil-define-key 'normal flymake-mode-map
    (kbd "]d") #'flymake-goto-next-error
    (kbd "[d") #'flymake-goto-prev-error))
