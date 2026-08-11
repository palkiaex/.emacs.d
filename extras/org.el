;;; -*- lexical-binding: t; -*-


;;; Emacs Bedrock
;;; Extra config: Org-mode starter config

;;; Usage: Append or require this file from init.el for some software
;;; development-focused packages.
;;;
;;; Org-mode is a fantastically powerful package. It does a lot of things, which
;;; makes it a little difficult to understand at first.
;;;
;;; YOU NEED TO CONFIGURE SOME VARIABLES! The most important variable is the
;;; `org-directory', which tells org-mode where to look to find your agenda files.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ORG-MODE BASE CONFIGURATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :hook
  ((org-mode . visual-line-mode) ; wrap lines at word breaks
   (org-mode . flyspell-mode))   ; spell checking!
  
  :bind
  (("C-c l s" . org-store-link)          ; Mnemonic: link → store
   ("C-c l i" . org-insert-link-global)  ; Mnemonic: link → insert
   ("C-c c"   . org-capture)             ; Capture templates
   ("C-c a"   . org-agenda))             ; Agenda views
  
  :custom
  ;; ---------------------------------------------------------
  ;; 1. Critical Variables & Paths
  ;; ---------------------------------------------------------
  (org-directory "~/Documents/org/")
  (org-agenda-files '("inbox.org" "trading.org"))
  
  ;; ---------------------------------------------------------
  ;; 2. UI & Editing Preferences
  ;; ---------------------------------------------------------
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-agenda-tags-column 0)
  (org-ellipsis "…")
  (org-export-with-smart-quotes t)
  
  ;; ---------------------------------------------------------
  ;; 3. Task Tracking & TODO states
  ;; ---------------------------------------------------------
  (org-todo-keywords
   '((sequence "TODO( t )" "WAITING(W@/!)" "STARTED(s!)" "|" "DONE(d!)" "OBSOLETE( o@ )")
     (sequence "OPEN(O)" "|" "WIN(w)" "LOSS(l)" "BE(b)")))

  ;; ---------------------------------------------------------
  ;; 4. Tags & Refiling
  ;; ---------------------------------------------------------
  (org-tag-alist
   '(;; locale
     (:startgroup) ("home" . ?h) ("work" . ?w) ("school" . ?s) (:endgroup)
     (:newline)
     ;; scale
     (:startgroup) ("one-shot" . ?o) ("project" . ?j) ("tiny" . ?t) (:endgroup)
     ;; misc
     ("meta") ("review") ("reading")))
  
  (org-outline-path-complete-in-steps nil)
  (org-refile-use-outline-path 'file)
  ;; (org-refile-targets '((org-agenda-files . (:maxlevel . 3)))) ; Example refile target

  ;; ---------------------------------------------------------
  ;; 5. Capture Templates
  ;; ---------------------------------------------------------
  (org-capture-templates
   '(("c"  "Default Capture" entry (file "inbox.org") "* TODO %?\n%U\n%i")
     ("r"  "Capture with Reference" entry (file "inbox.org") "* TODO %?\n%U\n%i\n%a")
     ("t" "Open Trade" entry (file+olp+datetree "trading.org")
      (file "~/Documents/org/templates/trade.txt")
      :empty-lines 1)))

  ;; ---------------------------------------------------------
  ;; 6. Custom Agenda Views
  ;; ---------------------------------------------------------
  (org-agenda-custom-commands
   '(("n" "Agenda and All Todos" ((agenda) (todo)))
     ;; Finds only "OPEN" trades inside trading.org
     ("T" "Active Trades" tags-todo "TODO=\"OPEN\""
      ((org-agenda-files '("trading.org"))))))
  
  ;; ---------------------------------------------------------
  ;; 7. Advanced: Custom Link Types
  ;; ---------------------------------------------------------
  (org-link-abbrev-alist
   '(("family_search" . "https://www.familysearch.org/tree/person/details/%s")))

  :config
  ;; ---------------------------------------------------------
  ;; Execution & Initialization
  ;; ---------------------------------------------------------
  (require 'oc-csl) ; Citation support
  (add-to-list 'org-export-backends 'md)
  
  ;; Make org-open-at-point follow file links in the same window
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PHASE 3: EXTENSIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Org-Roam Variables (Requires org-roam to be installed)
(setq org-roam-directory "~/Documents/org-roam/"
      org-roam-index-file "~/Documents/org-roam/index.org")

;;; Org-Download (Drag and drop images)
(use-package org-download
  :ensure t
  :hook (org-mode . org-download-enable)
  :bind
  (("C-c i y" . org-download-yank)      ; y for yank (paste URL)
   ("C-c i c" . org-download-clipboard)); c for clipboard
  :custom
  (org-download-image-dir "~/Documents/org/images")
  (org-download-timestamp "%Y%m%d_%H%M%S_")
  (org-download-heading-lvl nil)
  (org-download-display-inline t))

;;; Org-Modern (Beautify Org-mode)
(use-package org-modern
  :ensure t
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star '("●" "○" "◈" "◇" "✳"))
  (org-modern-hide-stars t))

(defun my/trade-exit-hook ()
  "Automates trade exits: adds 'Exit on', RR property, and Post-Trade Thoughts."
  (when (member org-state '("WIN" "LOSS" "BE"))
    (save-excursion
      (org-back-to-heading t)
      
      ;; 1. Calculate and prompt for RR
      (let* ((default-rr (pcase org-state
                           ("WIN" "2")
                           ("LOSS" "-1")
                           ("BE" "0")
                           (_ "")))
             (rr-input (read-string (format "RR (default %s): " default-rr)))
             (final-rr (if (string-empty-p rr-input) default-rr rr-input))
             
             ;; Temporarily override Org's default spacing behavior 
             ;; so it uses exactly 1 space instead of aligning to 10 chars.
             (org-property-format "%s %s"))
        
        (unless (string-empty-p final-rr)
          (org-set-property "RR" final-rr)))
      
      ;; 2. Find "Entered on:" and insert "Exit on:" directly below it
      (goto-char (org-entry-beginning-position))
      (when (re-search-forward "^\\s-*Entered on: .*" (save-excursion (org-end-of-subtree t) (point)) t)
        (insert "\nExit on: " (format-time-string "<%Y-%m-%d %a %H:%M>")))
      
      ;; 3. Prompt for post-trade thoughts in the minibuffer
      (let ((thoughts (read-string "Post-Trade Thoughts: ")))
        (unless (string-empty-p thoughts)
          (goto-char (org-entry-beginning-position))
          (when (re-search-forward "^\\s-*Post-Trade Thoughts:" (save-excursion (org-end-of-subtree t) (point)) t)
            (insert "\n" thoughts "\n")))))))

;; Attach the function to Org-mode's state change hook (Leave this as is)
(add-hook 'org-after-todo-state-change-hook #'my/trade-exit-hook)
