;; DO NOT EDIT THIS FILE DIRECTLY
;; This is a file generated from a literate programming source file located at
;; https://github.com/emilknievel/dotfiles/blob/main/emacs/.config/emacs/config.org
;; You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

(setq straight-repository-branch "develop")

(setq straight-use-package-by-default t)

(defvar bootstrap-version)
  (let ((bootstrap-file
         (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
        (bootstrap-version 6))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously
           "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
           'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(unless (or (fboundp 'helm-mode) (fboundp 'ivy-mode))
  (ido-mode t)
  (setq ido-enable-flex-matching t))

(unless (memq window-system '(mac ns))
  (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))

(autoload 'zap-up-to-char "misc"
  "Kill up to, but not including ARGth occurrence of CHAR." t)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; https://www.emacswiki.org/emacs/SavePlace
(save-place-mode 1)

(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-z") 'zap-up-to-char)

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(show-paren-mode 1)
(setq-default indent-tabs-mode nil)
(savehist-mode 1)
(setq save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t
      require-final-newline t
      visible-bell t
      load-prefer-newer t
      backup-by-copying t
      frame-inhibit-implied-resize t
      ediff-window-setup-function 'ediff-setup-windows-plain
      custom-file (expand-file-name "custom.el" user-emacs-directory))

(unless backup-directory-alist
  (setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                                 "backups")))))

(use-package gnutls
  :defer t
  :custom
  (gnutls-verify-error t))

(use-package which-key
  :config
  (setq which-key-popup-type 'minibuffer)
  (which-key-mode))

(use-package undo-fu)

(use-package evil
  :demand t
  :bind (("<escape>" . keyboard-escape-quit))
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-set-leader '(normal visual) (kbd "SPC"))
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :custom (evil-collection-setup-minibuffer t) ; enable evil in the minibuffer
  :config
  (evil-collection-init))



(setq inhibit-startup-screen t)

(setopt confirm-kill-emacs 'yes-or-no-p)

(use-package kaolin-themes
  :config
  (setq kaolin-themes-distinct-fringe t)
  (setq kaolin-themes-hl-line-colored t))

;; Change dark/light theme on OS appearance change.
(defun my/apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'kaolin-light t))
    ('dark (load-theme 'kaolin-dark t))))
(add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))

(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font 14"))

;; Render fonts like in iTerm
;; Still need to set
;; `defaults write org.gnu.Emacs AppleFontSmoothing -int`
;; in the terminal for it to work like intended
(setq ns-use-thin-smoothing t)

(setq fill-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(column-number-mode 1)

(defun my/display-set-relative ()
  (setq display-line-numbers 'visual))

(defun my/display-set-absolute ()
  (setq display-line-numbers t))

(use-package display-line-numbers
  :custom
  (display-line-numbers-widen t)
  ; (display-line-numbers-type 'visual)
  :hook
  ((prog-mode conf-mode) . display-line-numbers-mode)
  :config
  (add-hook 'evil-insert-state-entry-hook #'my/display-set-absolute)
  (add-hook 'evil-insert-state-exit-hook #'my/display-set-relative))

(setq show-trailing-whitespace t)

(setq require-final-newline t)

(use-package treesit-auto
  :demand t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

;;(use-package corfu
;;  :general
;;  (:keymaps 'corfu-map
;;   :states 'insert
;;   "C-n" #'corfu-next
;;   "C-p" #'corfu-previous
;;   "<escape>" #'corfu-quit
;;   "<return>" #'corfu-insert
;;   "M-d" #'corfu-show-documentation ; rebind to <leader>-d
;;   "M-l" #'corfu-show-location)     ; rebind to <leader>-l
;;  :config
;;  (corfu-global-mode))

(add-to-list 'auto-mode-alist '("\\.pl?\\'" . prolog-mode))
