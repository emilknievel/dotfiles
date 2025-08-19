;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;;; Commentary:

;; Loaded before initialization.

;;; Code:

;; Garbage collection

(defun my-minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
  (setq gc-cons-threshold 800000000))

(setq gc-cons-threshold most-positive-fixnum)

(run-with-idle-timer 1.2 t 'garbage-collect)

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)


(setq native-comp-jit-compilation nil)
(setq load-prefer-newer noninteractive)

(setq-default inhibit-redisplay t
              inhibit-message t)
(add-hook 'window-setup-hook
          (lambda ()
            (setq-default inhibit-redisplay nil
                          inhibit-message nil)
            (redisplay)))

(set-language-environment "UTF-8")
(setq default-input-method nil)

;; Prevent package.el loading packages prior to their init-file loading
(setq package-enable-at-startup nil)

;; Customize titlebar
(setq default-frame-alist '((width . 100) (height . 40)))
(cond ((eq system-type 'darwin)
       (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
      ((and (eq system-type 'gnu/linux)
            (not (getenv "WSL_DISTRO_NAME")))
       (add-to-list 'default-frame-alist '(fullscreen . maximized))))

;; Load dark theme early to avoid getting flashed when launching Emacs.
(load-theme 'wombat t)

(if (file-exists-p "~/.private.el")
    (load-file "~/.private.el")
  (message "WARNING: Unable to find file ~/.private.el."))

;;; early-init.el ends here
