;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Built-in config for developers
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :config
  ;; Treesitter config
  ;; Tell Emacs to prefer the treesitter mode
  ;; You'll want to run the command `M-x treesit-install-language-grammar' before editing.
  (setq major-mode-remap-alist
        '((yaml-mode . yaml-ts-mode)
          (bash-mode . bash-ts-mode)
          (js2-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode)
          (python-mode . python-ts-mode)))
  :hook
  ;; Auto parenthesis matching
  ((prog-mode . electric-pair-mode)))

(use-package project
  :custom
  (project-mode-line (if (>= emacs-major-version 30) t nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Version Control
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Magit: slowest Git client to ever exist
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Common file types & Languages
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :ensure t
  :hook ((markdown-mode . visual-line-mode)))

(use-package yaml-mode
  :ensure t)

(use-package json-mode
  :ensure t)

;; Add the official rust-mode
(use-package rust-mode
  :ensure t
  :init
  ;; Tell rust-mode to use the new treesitter mode
  (setq rust-mode-treesitter-derive t)
  :custom
  ;; Format on save
  (rust-format-on-save t)
  ;; Force rustfmt to use the 2024 edition
  (rust-rustfmt-switches '("--edition" "2024"))
  :hook
  ;; Automatically start Eglot LSP when entering rust-mode
  (rust-mode . eglot-ensure))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Eglot, the built-in LSP client for Emacs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-package eglot
  :hook
  (((rust-mode python-mode ruby-mode elixir-mode) . eglot-ensure))
  :custom
  (eglot-ignored-server-capabilities '(:inlayHintProvider))
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)
  (eglot-events-buffer-size 0)
  (eglot-workspace-configuration
                '(:rust-analyzer (:checkOnSave (:enable t :command "clippy")
                                  :procMacro (:enable t)
                                  :cargo (:buildScripts (:enable t)))))
  :config
  (fset #'jsonrpc--log-event #'ignore))

(with-eval-after-load 'eldoc
  (setq eldoc-idle-delay 0.5)
  (setq eldoc-echo-area-use-multiline-p nil))

;; Force *eldoc* to open on the right
(add-to-list 'display-buffer-alist
             '("^\\*eldoc\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.4)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Other useful stuffs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indent guideline for tree-sitter scope
(use-package indent-bars
  :ensure t
  :custom
  (indent-bars-prefer-character t)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-treesit-support t)
  (indent-bars-treesit-scope '((rust function_item impl_item trait_item struct_item enum_item block)))
  :hook 
  ;; Swapped rustic-mode for rust-mode here
  ((rust-mode . indent-bars-mode)
   (rust-mode . (lambda ()
                  (when (treesit-available-p)
                    (treesit-parser-create 'rust))))))
