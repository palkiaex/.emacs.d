;;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CORE & PERFORMANCE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (< emacs-major-version 29)
  (error "Emacs Bedrock only works with Emacs 29 and newer; you have version %s" emacs-major-version))

;; Setup package archives
(use-package package
  :ensure nil
  :custom
  (package-native-compile t)
  :config
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

;; Keep `.emacs.d` clean from auto-generated files
(use-package no-littering
  :ensure t
  :demand t
  :config
  (setq auto-save-file-name-transforms
	`((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (setq backup-directory-alist
	`((".*" . ,(no-littering-expand-var-file-name "backup/")))))

;; Increase read size for rust-analyzer's massive JSON responses
(setq read-process-output-max (* 3 1024 1024)) ;; 3 MB

;; Smart Garbage Collection (speeds up Emacs significantly)
(use-package gcmh
  :ensure t
  :demand t
  :custom
  (gcmh-idle-delay 1.0)
  (gcmh-high-cons-threshold (* 100 1024 1024))
  :config
  (gcmh-mode 1))

;; Separate custom variables file so it doesn't pollute init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMACS DEFAULTS & UI SETTINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :ensure nil
  :custom
  ;; 1. Basic Interface Defaults
  (use-short-answers t)
  (inhibit-splash-screen t)
  (ring-bell-function 'ignore)
  (initial-major-mode 'fundamental-mode)
  (display-time-default-load-average nil)
  (mode-line-collapse-minor-modes t)
  (sentence-end-double-space nil)
  (dired-kill-when-opening-new-dired-buffers t)

  ;; 2. File & Buffer Behavior
  (create-lockfiles nil)
  (switch-to-buffer-obey-display-actions t)
  (process-adaptive-read-buffering t)

  ;; 3. Minibuffer & Completion
  (enable-recursive-minibuffers t)
  (completion-cycle-threshold 1)
  (completions-detailed t)
  (tab-always-indent 'complete)
  (completion-styles '(basic initials substring))
  (completion-auto-help 'always)
  (completions-max-height 20)
  (completions-format 'one-column)
  (completions-group t)
  (completion-auto-select 'second-tab)

  ;; 4. Visual Layout & Scrolling
  (line-number-mode t)
  (column-number-mode t)
  (display-line-numbers-width 3)
  (x-underline-at-descent-line nil)
  (show-trailing-whitespace nil)
  (indicate-buffer-boundaries 'left)
  (mouse-wheel-tilt-scroll t)
  (mouse-wheel-flip-direction t)

  :hook
  ;; Auto-enable modes for specific situations
  (prog-mode . display-line-numbers-mode)
  (text-mode . visual-line-mode)
  (prog-mode . hl-line-mode)
  (text-mode . hl-line-mode)

  :config
  ;; Disable UI clutter
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (blink-cursor-mode -1)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))

  ;; Enable Core global modes
  (savehist-mode 1)
  (global-auto-revert-mode 1)
  (global-visual-line-mode 1)
  (pixel-scroll-precision-mode 1)
  (xterm-mouse-mode 1)
  (cua-mode 1)
  (when (display-graphic-p)
    (context-menu-mode 1))

  ;; Bindings and Keymaps
  (windmove-default-keybindings 'control)
  (keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete))

(use-package autorevert
  :ensure nil
  :custom
  (auto-revert-avoid-polling t)
  (auto-revert-interval 5)
  (auto-revert-check-vc-info t)
  :config
  (global-auto-revert-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FONTS, UNICODE, & APPEARANCE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Force Emacs to use UTF-8 everywhere
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Font Configuration
(setq-default line-spacing 0.3)
(setq my-font-size 
      (cond ((eq system-type 'darwin) 144) 
            ((eq system-type 'windows-nt) 105) 
            (t 140))) 

(let ((my-font "FiraCode Nerd Font")) 
  (when (find-font (font-spec :family my-font)) 
    (set-face-attribute 'default nil :family my-font :height my-font-size :weight 'normal)
    (set-face-attribute 'fixed-pitch nil :family my-font :height my-font-size :weight 'normal)))

;; Emojis and Symbols
(when (fboundp 'set-fontset-font)
  (let ((emoji-fonts '("Apple Color Emoji" "Noto Color Emoji" "Segoe UI Emoji" "Symbola")))
    (dolist (font emoji-fonts)
      (set-fontset-font t 'emoji (font-spec :family font) nil 'append)
      (set-fontset-font t 'symbol (font-spec :family font) nil 'append))))

;; Tab-bar configuration
(use-package tab-bar
  :ensure nil
  :custom
  (tab-bar-show 1)
  (display-time-format "%a %F %T")
  (display-time-interval 1)
  :config
  (add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
  (add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
  (display-time-mode 1))

;; Theme Configuration
(use-package solarized-theme
  :ensure t
  :init
  (setq solarized-use-less-bold t)
  :config
  (load-theme 'solarized-wombat-dark t))
(defun my-switch-theme (theme)
  "Disable all active themes and load THEME."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  ;; Ensure tab-bar updates properly when theme changes
  (when (fboundp 'tab-bar-mode) (tab-bar-mode 1))
  (message "Switched to %s" theme))

;; Interactive wrappers for each theme
(defun my-theme-modus-vivendi () 
  "Switch to Modus Vivendi (Dark)." 
  (interactive) (my-switch-theme 'modus-vivendi))

(defun my-theme-wombat () 
  "Switch to Solarized Wombat Dark." 
  (interactive) (my-switch-theme 'solarized-wombat-dark))

(defun my-theme-solarized-light () 
  "Switch to Solarized Light." 
  (interactive) (my-switch-theme 'solarized-light))

(defvar-keymap my-theme-prefix-map
  :doc "Prefix keymap for switching Emacs themes."
  "v" #'my-theme-modus-vivendi
  "w" #'my-theme-wombat
  "s" #'my-theme-solarized-light)

(keymap-global-set "C-c t" my-theme-prefix-map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BUILT-IN TOOLS & PACKAGES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Shows a popup of available keybindings when typing a long sequence
(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

;; Compilation Buffer Styling
(use-package compile
  :ensure nil
  :custom
  (compilation-scroll-output t)
  :config
  (require 'ansi-color)
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter))

;; Custom Config Search Function
(defun my-search-emacs-config ()
  "Search for a file in the Emacs configuration directory using project.el."
  (interactive)
  (let ((default-directory user-emacs-directory))
    (call-interactively #'project-find-file)))

(keymap-global-set "C-c s n" #'my-search-emacs-config)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MODULAR CONFIG (EXTRAS)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let ((extras (list "extras/base.el"
                    "extras/dev.el"
                    "extras/vim-like.el"
                    "extras/org.el")))
  (dolist (file extras)
    (let ((full-path (expand-file-name file user-emacs-directory)))
      (when (file-exists-p full-path)
        (load-file full-path)))))
