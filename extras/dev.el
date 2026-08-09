;;; -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CORE DEV SETTINGS & TREE-SITTER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :ensure nil
  :custom
  ;; Tell Emacs to prefer the treesitter mode for these languages.
  ;; Note: Run `M-x treesit-install-language-grammar' before editing.
  (major-mode-remap-alist
   '((yaml-mode       . yaml-ts-mode)
     (bash-mode       . bash-ts-mode)
     (js2-mode        . js-ts-mode)
     (typescript-mode . typescript-ts-mode)
     (json-mode       . json-ts-mode)
     (css-mode        . css-ts-mode)
     (python-mode     . python-ts-mode)
     (lua-mode        . lua-ts-mode)))
  :hook
  ;; Auto parenthesis matching
  (prog-mode . electric-pair-mode))

;; Built-in project management
(use-package project
  :ensure nil
  :custom
  (project-mode-line (if (>= emacs-major-version 30) t nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VERSION CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Magit: slowest Git client to ever exist (but we love it anyway)
(use-package magit
  :ensure t
  :bind 
  (("C-x g" . magit-status)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PROGRAMMING LANGUAGES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :ensure t
  :hook (markdown-mode . visual-line-mode))

(use-package yaml-mode :ensure t)
(use-package json-mode :ensure t)
(use-package lua-mode  :ensure t)

(use-package rust-mode
  :ensure t
  :init
  (setq rust-mode-treesitter-derive t)
  :custom
  (rust-format-on-save t)
  (rust-rustfmt-switches '("--edition" "2024")))

;; IMPORTANT: Even on Windows, use forward slashes (/) for the path!
;; (add-to-list 'load-path "/Users/huypk/Developer/flutter-tools")
;; (require 'flutter-tools)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LSP (EGLOT) & ELDOC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eglot
  :ensure nil
  :hook
  ((rust-mode python-ts-mode lua-ts-mode) . eglot-ensure)
  :custom
  (eglot-ignored-server-capabilities '(:inlayHintProvider))
  (eglot-send-changes-idle-time 0.5)
  (eglot-extend-to-xref t)
  (eglot-events-buffer-size 0)
  :config
  ;; Completely ignore JSONRPC logging for a massive performance boost
  (fset #'jsonrpc--log-event #'ignore))

;; Set this globally so Eglot catches it immediately when rust-analyzer starts.
(setq-default eglot-workspace-configuration
              '((:rust-analyzer .
				(:check (:command "clippy" :extraArgs ["--no-deps"])
					:procMacro (:enable t)
					:cargo (:buildScripts (:enable t))))))

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-idle-delay 0.5)
  :config
  (defun my-eldoc-dynamic-multiline (orig-fn &rest args)
    "Expand Eldoc to multiple lines only if there is a Flymake diagnostic at point."
    (let ((eldoc-echo-area-use-multiline-p
	   (if (and (bound-and-true-p flymake-mode)
		    (flymake-diagnostics (point)))
	       t    ;; IF ERROR AT CURSOR: Allow multi-line expansion
	     nil))) ;; IF NO ERROR: Force 1 line for clean method signatures
      (apply orig-fn args)))
  (advice-add 'eldoc-display-in-echo-area :around #'my-eldoc-dynamic-multiline))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; COMPILATION & WINDOW MANAGEMENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package compile
  :ensure nil
  :custom
  ;; 'first-error stops at the first error, t scrolls to the bottom always
  (compilation-scroll-output t) 
  ;; Automatically kill old compilation processes before starting a new one
  (compilation-always-kill t)
  ;; Skip warning and info messages when jumping to errors (M-g n / M-g p)
  (compilation-skip-threshold 2))

;; Force dev-related buffers to open in a side window on the right
(add-to-list 'display-buffer-alist
             '("^\\*\\(compilation\\|cargo.*\\|rust.*\\|eldoc.*\\)\\*$"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (window-width . 0.4)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; OPTIONAL EXTRAS (Commented out)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indent guideline for tree-sitter scope
;; (use-package indent-bars
;;   :ensure t
;;   :custom
;;   (indent-bars-highlight-current-depth nil)
;;   (indent-bars-treesit-support t)
;;   (indent-bars-treesit-scope '((rust function_item impl_item trait_item struct_item enum_item block)))
;;   (indent-bars-prefer-character (eq system-type 'darwin))
;;   :hook 
;;   ((rust-mode . indent-bars-mode)
;;    (rust-mode . (lambda ()
;;                   (when (treesit-available-p)
;;                     (treesit-parser-create 'rust))))
;;    (lua-ts-mode . (lambda ()
;;                     (when (treesit-available-p)
;;                       (treesit-parser-create 'lua))))))
