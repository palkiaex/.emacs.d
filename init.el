;;; -*- lexical-binding: t; -*-

(when (< emacs-major-version 29)
  (error "Emacs Bedrock only works with Emacs 29 and newer; you have version %s" emacs-major-version))

;; 1. Increase read size for rust-analyzer's massive JSON responses
(setq read-process-output-max (* 3 1024 1024)) ;; 3 MB

;; 2. Smart Garbage Collection
(use-package gcmh
  :ensure t
  :demand t
  :custom
  (gcmh-idle-delay 1.0)
  (gcmh-high-cons-threshold (* 100 1024 1024))
  :config
  (gcmh-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Basic settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package package
  :ensure nil
  :custom
  (package-native-compile t)
  :config
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(menu-bar-mode -1)
(setopt inhibit-splash-screen t)
(setopt initial-major-mode 'fundamental-mode)  ; default mode for the *scratch* buffer
(setopt display-time-default-load-average nil) ; this information is useless for mostly
(setq mode-line-collapse-minor-modes t)
;; Automatically reread from disk if the unerlying file changes
(setopt auto-revert-avoid-polling t)

;; Some systems don't do file notifications well; see
;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode)

;; Save history of minibuffer
(savehist-mode)

;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control) ; You can use other modifiers here

;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Make right-click do something sensible
(when (display-graphic-p)
  (context-menu-mode))

;; Stop Dired from opening too many buffers
(setq dired-kill-when-opening-new-dired-buffers t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Discovery aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setopt enable-recursive-minibuffers t)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold 1)                  ; TAB cycles candidates
(setopt completions-detailed t)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is arbitrary
(setopt completions-format 'one-column)
(setopt completions-group t)
(setopt completion-auto-select 'second-tab)            ; Much more eager
;(setopt completion-auto-select t)                     ; See `C-h v completion-auto-select' for more possible values

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete) ; TAB acts more like how it does in the shell

;; For a fancier built-in completion option, try ido-mode,
;; icomplete-vertical, or fido-mode. See also the file extras/base.el

;(icomplete-vertical-mode)
;(fido-vertical-mode)
;(setopt icomplete-delay-completions-threshold 4000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setopt line-number-mode t)                        ; Show current line in modeline
(setopt column-number-mode t)                      ; Show column as well
(global-visual-line-mode 1)
(setopt x-underline-at-descent-line nil)           ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

(scroll-bar-mode -1)

;; Disable the horizontal scroll bar (if applicable)
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))

;; We won't set these, but they're good to know about
;;
;; (setopt indent-tabs-mode nil)
;; (setopt tab-width 4)

(blink-cursor-mode -1)                                ; Steady cursor
(pixel-scroll-precision-mode)                         ; Smooth scrolling

;; Use common keystrokes by default
(cua-mode)

;; For terminal users, make the mouse more useful

(xterm-mouse-mode 1)

;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3)           ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Tab-bar configuration
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the tab-bar as soon as tab-bar functions are invoked
(setopt tab-bar-show 1)

;; Add the time to the tab-bar, if visible
(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
(setopt display-time-format "%a %F %T")
(setopt display-time-interval 1)
(display-time-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Built-in customization framework
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package compile
  :ensure nil
  :custom
  ;; Optional but highly recommended: auto-scroll the compilation buffer
  (compilation-scroll-output t)
  :config
  ;; Load the built-in ansi-color package
  (require 'ansi-color)
  ;; Apply the color filter to the compilation buffer
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Appearance
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(setq my-font-size 
      (cond ((eq system-type 'darwin) 144) 
            ((eq system-type 'windows-nt) 105) 
            (t 140))) 
(let ((my-font "FiraCode Nerd Font")) 
  (when (find-font (font-spec :family my-font)) 
    ;; 1. Set the default font
    (set-face-attribute 'default nil 
                        :family my-font
                        :height my-font-size 
                        :weight 'normal)
    ;; 2. Force the fixed-pitch font (used in eldoc code blocks) to match
    (set-face-attribute 'fixed-pitch nil 
                        :family my-font
                        :height my-font-size 
                        :weight 'normal)))
(setq-default line-spacing 0.3)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Unicode & Emoji Support
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Force Emacs to use UTF-8 everywhere
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Setup fallback fonts for Emojis and Symbols
(when (fboundp 'set-fontset-font)
  ;; Emacs will go down this list and use the first one available on your OS
  (let ((emoji-fonts '("Apple Color Emoji"
                       "Noto Color Emoji"
                       "Segoe UI Emoji"
                       "Symbola")))
    (dolist (font emoji-fonts)
      ;; Apply to the 'emoji and 'symbol character sets
      (set-fontset-font t 'emoji (font-spec :family font) nil 'append)
      (set-fontset-font t 'symbol (font-spec :family font) nil 'append))))

(use-package solarized-theme
  :ensure t
  :init
  ;; Set solarized variables BEFORE the theme loads
  (setq solarized-use-less-bold t))

(use-package emacs
  :config
  (load-theme 'solarized-wombat-dark))

(defun my-toggle-theme ()
  (interactive)
  (if (memq 'solarized-light custom-enabled-themes)
      (progn
        (mapc #'disable-theme custom-enabled-themes)
        (load-theme 'modus-vivendi t)
        (message "Switched to Modus Vivendi (Dark)"))
    (progn
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme 'solarized-light t)
      (message "Switched to Solarized (Light)"))))
(global-set-key (kbd "C-c t") 'my-toggle-theme)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Optional extras
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI/UX enhancements mostly focused on minibuffer and autocompletion interfaces
;; These ones are *strongly* recommended!
(load-file (expand-file-name "extras/base.el" user-emacs-directory))

;; Packages for software development
(load-file (expand-file-name "extras/dev.el" user-emacs-directory))

;; Vim-bindings in Emacs (evil-mode configuration)
(load-file (expand-file-name "extras/vim-like.el" user-emacs-directory))

;; Org-mode configuration
;; WARNING: need to customize things inside the elisp file before use! See
;; the file extras/org-intro.txt for help.
;; (load-file (expand-file-name "extras/org.el" user-emacs-directory))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Custom Keybindings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-search-emacs-config ()
  "Search for a file in the Emacs configuration directory using project.el."
  (interactive)
  ;; Temporarily pretend we are inside the Emacs config directory
  (let ((default-directory user-emacs-directory))
    ;; Call the exact same function that C-x p f uses
    (call-interactively #'project-find-file)))

;; Bind it to C-c s n
(keymap-global-set "C-c s n" #'my-search-emacs-config)

(use-package no-littering
  :ensure t
  :demand t)
