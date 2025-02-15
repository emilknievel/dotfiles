(setq vc-follow-symlinks t) ; edit real file when opening symbolic link


;; Bootstrap Elpaca
(defvar elpaca-installer-version 0.9)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;; Load below packages early
(use-package general
  :ensure (:wait t)
  :demand t)
(general-create-definer my-leader-keys :prefix "<f8>")

;; Makes sure that we use the latest transient version
(use-package transient :ensure (:wait t))

;; Needs to be loaded outside of org config file
;; TODO: I believe it's possible to only use the `:ensure' part here and
;; use `:ensure nil' inside the org config with all the configurations.
(use-package org
  :ensure (:wait t)
  :after general
  :init
  (setq org-directory (expand-file-name "~/Documents/org")
        org-agenda-files `(,org-directory)
        org-default-notes-file (concat org-directory "/inbox.org"))
  (require 'org-indent)
  :custom
  (org-return-follows-link t)
  (org-startup-with-inline-images t)
  (org-fontify-quote-and-verse-blocks t)
  (org-image-actual-width '(300))
  (org-pretty-entities t)
  ;; (org-auto-align-tags nil)
  ;; (org-tags-column 0)
  (org-fold-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-startup-indented t)

  ;; Add CLOSED: [timestamp] line after todo headline when marked as done
  ;; and prompt for closing note.
  (org-log-done 'note)

  ;; Ask how many minutes to keep if idle for at least 15 minutes.
  (org-clock-idle-time 15)

  (org-capture-templates
   '(("f" "Fleeting note" item
      (file+headline org-default-notes-file "Notes")
      "- %?")
     ("t" "New task" entry
      (file+headline org-default-notes-file "Tasks")
      "* TODO %i%?")))
  :config
  ;; Agenda
  (setq org-refile-targets
        '((org-agenda-files :maxlevel . 3)
          (nil :maxlevel . 3)))
  (setq org-refile-use-outline-path t)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-refile-use-cache t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :hook
  ((org-mode gfm-mode markdown-mode) . visual-line-mode)
  ;; ((org-mode gfm-mode markdown-mode) . (lambda () (setq-local line-spacing 0.2)))
  ;; (org-agenda-mode . hl-line-mode)
  ;; ((org-mode gfm-mode markdown-mode) . hl-line-mode)
  :general (my-leader-keys
             "o b t" 'org-babel-tangle
             "o l d" 'org-toggle-link-display))

(if (file-exists-p (expand-file-name "config.elc" user-emacs-directory))
    (load (expand-file-name "config.elc" user-emacs-directory))
  (if (file-exists-p (expand-file-name "config.elc" user-emacs-directory))
      (org-babel-load-file (expand-file-name "config.el" user-emacs-directory))
    (org-babel-load-file (expand-file-name "config.org" user-emacs-directory))))


(setq calendar-latitude  58.38959
      calendar-longitude 13.83725)
