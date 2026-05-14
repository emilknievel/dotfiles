;;; init.el --- Bootstrap Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Set up early startup behavior, bootstrap Elpaca, install packages needed
;; before the main configuration, then load the literate config.

;;; Code:

(setq vc-follow-symlinks t) ; edit real file when opening symbolic link


;;; Bootstrap Elpaca

;; `elpaca-core-date' may be needed when using a source-built Emacs.
;; (when (eq system-type 'gnu/linux)
;;   (setq elpaca-core-date '(20250224)))

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
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
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))


;;; Load early packages

(when (< emacs-major-version 31)
  (use-package compat :ensure (:wait t)))

(use-package project :ensure (:wait t))

;; Remove org-mode's C-, binding to avoid conflict with general.
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-,") nil))

(use-package general
  :ensure (:wait t)
  :demand t)
(general-create-definer my-leader-keys :prefix "C-,")

;; Make sure that we use the latest version of `transient'.
(use-package transient :ensure (:wait t))

;; Use latest version of Org rather than the older one built into Emacs.
;; Configuration resides in the main `config.org' file.
(use-package org
  :ensure (:wait t))

(let ((compiled-config (expand-file-name "config.elc" user-emacs-directory))
      (tangled-config (expand-file-name "config.el" user-emacs-directory))
      (literate-config (expand-file-name "config.org" user-emacs-directory)))
  (cond
   ((and (file-exists-p compiled-config)
         (or (not (file-exists-p tangled-config))
             (file-newer-than-file-p compiled-config tangled-config))
         (or (not (file-exists-p literate-config))
             (file-newer-than-file-p compiled-config literate-config)))
    (load compiled-config))
   ((and (file-exists-p tangled-config)
         (or (not (file-exists-p literate-config))
             (file-newer-than-file-p tangled-config literate-config)))
    (load-file tangled-config))
   ((file-exists-p literate-config)
    (org-babel-load-file literate-config t))
   (t
    (user-error "No Emacs config found"))))

(put 'upcase-region 'disabled nil)
(load-file (expand-file-name "lisp/journelly.el" user-emacs-directory))
