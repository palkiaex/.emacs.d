;;; Emacs Bedrock
;;;
;;; Extra config: Development tools

;;; Usage: Append or require this file from init.el for some software
;;; development-focused packages.
;;;
;;; It is **STRONGLY** recommended that you use the base.el config if you want to
;;; use Eglot. Lots of completion things will work better.
;;;
;;; This will try to use tree-sitter modes for many languages. Please run
;;;
;;;   M-x treesit-install-language-grammar
;;;
;;; Before trying to use a treesit mode.

;;; Contents:
;;;
;;;  - Built-in config for developers
;;;  - Version Control
;;;  - Common file types
;;;  - Eglot, the built-in LSP client for Emacs
;;;  - Templating

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
  (when (>= emacs-major-version 30)
    (project-mode-line t)))         ; show project name in modeline

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Version Control
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Magit: best Git client to ever exist
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

;; Emacs ships with a lot of popular programming language modes. If it's not
;; built in, you're almost certain to find a mode for the language you're
;; looking for with a quick Internet search.

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
;;;   Templating
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package tempel
  :ensure t
  ;; By default, tempel looks at the file "templates" in
  ;; user-emacs-directory, but you can customize that with the
  ;; tempel-path variable:
  ;; :custom
  ;; (tempel-path (concat user-emacs-directory "custom_template_file"))
  :bind (("M-*" . tempel-insert)
         ("M-+" . tempel-complete)
         :map tempel-map
         ("C-c RET" . tempel-done)
         ("C-<down>" . tempel-next)
         ("C-<up>" . tempel-previous)
         ("M-<down>" . tempel-next)
         ("M-<up>" . tempel-previous))
  :init
  ;; Make a function that adds the tempel expansion function to the
  ;; list of completion-at-point-functions (capf).
  (defun tempel-setup-capf ()
    (add-hook 'completion-at-point-functions #'tempel-expand -1 'local))
  ;; Put tempel-expand on the list whenever you start programming or
  ;; writing prose.
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

(with-eval-after-load 'flymake
  ;; Bind ]d and [d only in Evil's Normal state when flymake is active
  (evil-define-key 'normal flymake-mode-map
    (kbd "]d") #'flymake-goto-next-error
    (kbd "[d") #'flymake-goto-prev-error))

(use-package prism
  :ensure t
  ;; Optional: If you also want prism to color your code text, uncomment this:
  ;; :hook (prog-mode . prism-mode)
  )

(use-package indent-bars
  :ensure t
  :after prism
  :custom
  ;; 1. Core & Tree-sitter settings
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-string t)
  (indent-bars-treesit-scope '((rust function_item impl_item trait_item struct_item enum_item block)))

  ;; 2. Visual Style (Matched to screenshot)
  (indent-bars-width-frac 0.1)           ; Found at the bottom left of the image
  (indent-bars-pattern nil)             ; Found in the "Indent Bars Pattern" field

  ;; 3. Depth Coloring (Matched to screenshot)
  ;; Note: This requires the 'prism' package/faces to be loaded in your Emacs.
  (indent-bars-color-by-depth
   '(:palette (prism-level-1
               prism-level-2
               prism-level-3
               prism-level-4
               prism-level-5
               prism-level-6
               prism-level-7
               prism-level-8)
     :blend 0.9))                        ; Blend fraction set to 0.9

  ;; 4. Highlight settings
  (indent-bars-highlight-selection-method 'context) ; Set to 'Context' in image
  (indent-bars-highlight-current-depth nil)

  :hook 
  ;; Enable it in rustic-mode (and yaml-mode, since your screenshot is Ansible/YAML!)
  ((rustic-mode . indent-bars-mode)
   (yaml-mode . indent-bars-mode) 
   
   ;; CRITICAL: rustic-mode does not automatically start the treesitter parser. 
   ;; We must initialize it manually so indent-bars can read the Rust AST for scope.
   (rustic-mode . (lambda ()
                    (when (treesit-available-p)
                      (treesit-parser-create 'rust))))))
