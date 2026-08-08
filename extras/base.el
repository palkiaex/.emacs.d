;;; ...  -*- lexical-binding: t -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Motion aids
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package avy
  :ensure t
  :demand t
  :bind (("C-c j" . avy-goto-line)
         ("s-j"   . avy-goto-char-timer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Power-ups: Embark and Consult
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Consult: Misc. enhanced commands
(use-package consult
  :ensure t
  :bind (
         ;; Drop-in replacements
         ("C-x b" . consult-buffer)     ; orig. switch-to-buffer
         ("M-y"   . consult-yank-pop)   ; orig. yank-pop
         ;; Searching
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)       ; Alternative: rebind C-s to use
         ("M-s s" . consult-line)       ; consult-line instead of isearch, bind
         ("M-s L" . consult-line-multi) ; isearch to M-s s
         ("M-s o" . consult-outline)
         ;; Isearch integration
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)   ; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
         ("M-s l" . consult-line)            ; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)      ; needed by consult-line to detect isearch
         )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

(use-package embark-consult
  :ensure t)

;; Embark: supercharged context-dependent menu; kinda like a
;; super-charged right-click.
(use-package embark
  :ensure t
  :demand t
  :after (avy embark-consult)
  :bind (("C-c a" . embark-act))        ; bind this to an easy key to hit
  :init
  ;; Add the option to run embark when using avy
  (defun bedrock/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer and completion
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :ensure t
  :init
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  (vertico-mode))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; ;; Company: The main autocompletion framework
;; (use-package company
;;   :ensure t
;;   :custom
;;   ;; ANTI-LAG: Wait 0.2 seconds before popping up to let you type fast
;;   (company-idle-delay 0.2)
;;   ;; How many characters to type before triggering
;;   (company-minimum-prefix-length 2)
;;   ;; Wrap around completions when reaching the end
;;   (company-selection-wrap-around t)
;;   ;; Align annotations (like variable types) to the right
;;   (company-tooltip-align-annotations t)
;;   :hook (after-init . global-company-mode)
;;   :bind
;;   (:map company-active-map
;;         ("C-n" . company-select-next)
;;         ("C-p" . company-select-previous)
;;         ("TAB" . company-complete-selection)
;;         ("<tab>" . company-complete-selection)
;;         ("SPC" . nil))) ; Don't autocomplete on space!

;; ;; Documentation popups for Company
;; (use-package company-quickhelp
;;   :ensure t
;;   :after company
;;   :custom
;;   ;; ANTI-LAG: Wait 1 full second before asking LSP for documentation
;;   (company-quickhelp-delay 1.0)
;;   :config
;;   (company-quickhelp-mode 1))
(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  ;; Enable optional extension modes:
  ;; (corfu-history-mode)
  ;; (corfu-mouse-mode)
  ;; (corfu-popupinfo-mode)
  )

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package eshell
  :init
  (defun bedrock/setup-eshell ()
    ;; Something funny is going on with how Eshell sets up its keymaps; this is
    ;; a work-around to make C-r bound in the keymap
    (keymap-set eshell-mode-map "C-r" 'consult-history))
  :hook ((eshell-mode . bedrock/setup-eshell)))

;; Eat: Emulate A Terminal
(use-package eat
  :ensure t
  :custom
  (eat-term-name "xterm")
  :config
  (eat-eshell-mode)                     ; use Eat to handle term codes in program output
  (eat-eshell-visual-command-mode))     ; commands like less will be handled by Eat

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Misc. editing enhancements
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modify search results en masse
(use-package wgrep
  :ensure t
  :config
  (setq wgrep-auto-save-buffer t))
