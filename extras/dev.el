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
;;;   Common file types
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :ensure t
  :hook ((markdown-mode . visual-line-mode)))

(use-package yaml-mode
  :ensure t)

(use-package json-mode
  :ensure t)

(use-package rustic
  :ensure t
  :config
  (setq rustic-format-on-save t)
  (setq rustic-lsp-client 'eglot)
  :custom
  (rustic-cargo-use-last-stored-arguments t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Eglot, the built-in LSP client for Emacs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Helpful resources:
;;
;;  - https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
(setq eglot-ignored-server-capabilities '(:inlayHintProvider))

(use-package eglot
  ;; no :ensure t here because it's built-in

  ;; Configure hooks to automatically turn-on eglot for selected modes
  :hook
  (((rustic-mode python-mode ruby-mode elixir-mode) . eglot-ensure))

  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; activate Eglot in referenced non-project files

  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  ;; Sometimes you need to tell Eglot where to find the language server
  ; (add-to-list 'eglot-server-programs
  ;              '(haskell-mode . ("haskell-language-server-wrapper" "--lsp")))
  )

;; 3. Eglot and Eldoc optimizations for Rust
(with-eval-after-load 'eglot
  ;; CRITICAL: Turn off Eglot logging. 
  ;; By default, Eglot logs every single JSON message between Emacs and rust-analyzer.
  ;; In Rust, this will consume gigabytes of memory and slow Emacs to a crawl over time.
  (setq eglot-events-buffer-size 0)
  
  ;; Optional but recommended: disable Eglot formatting if you use rustfmt on save
  ;; to prevent conflicting save hooks.
  ;; (setq-default eglot-workspace-configuration
  ;;               '(:rust-analyzer (:checkOnSave (:command "clippy"))))
  )

(with-eval-after-load 'eldoc
  ;; CRITICAL: Delay Eldoc. 
  ;; If set to 0 (or too low), Eldoc tries to fetch Rust documentation for 
  ;; every single thing your cursor passes over while you are moving it.
  ;; This blocks the UI. Set it to wait until you pause for half a second.
  (setq eldoc-idle-delay 0.5)
  
  ;; Keep the echo area from resizing aggressively and causing visual jumping
  (setq eldoc-echo-area-use-multiline-p nil))

;; Force *eldoc* (and other help buffers if you want) to open on the right
(add-to-list 'display-buffer-alist
             '("^\\*eldoc\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.4))) ;; Takes up 40% of the frame width

; (use-package eldoc
;   :ensure nil
;   :custom
;   ;; Don't block the editor while fetching documentation
;   (eldoc-echo-area-prefer-doc-buffer t)
;   ;; Truncate very long Rust errors so they don't resize your whole window
;   (eldoc-echo-area-use-multiline-p nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Other useful stuffs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Fast diagnostic navigation
(with-eval-after-load 'flymake
  (evil-define-key 'normal flymake-mode-map
    (kbd "]d") #'flymake-goto-next-error
    (kbd "[d") #'flymake-goto-prev-error))

;; Indent guideline for tree-sitter scope
(use-package indent-bars
  :ensure t
  :custom
  (indent-bars-prefer-character t)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-treesit-support t)
  (indent-bars-treesit-scope '((rust function_item impl_item trait_item struct_item enum_item block)))
  :hook 
  ((rustic-mode . indent-bars-mode)
   (rustic-mode . (lambda ()
                    (when (treesit-available-p)
                      (treesit-parser-create 'rust))))))


