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

;; Customize frame size and titlebar
(setq default-frame-alist '((width . 130) (height . 35)))
(cond ((eq system-type 'darwin)
       ;; (add-to-list 'default-frame-alist '(fullscreen . maximized))
       (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
      ((and (eq system-type 'gnu/linux)
            (not (getenv "WSL_DISTRO_NAME")))
       (add-to-list 'default-frame-alist '(width . 160))
       (add-to-list 'default-frame-alist '(height . 50))))
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))
;; (add-to-list 'default-frame-alist '(undecorated . t))))

;; Load dark theme early to avoid getting flashed when launching Emacs.
(load-theme 'wombat t)

(let ((private-file (expand-file-name "~/.private.el")))
  (if (file-exists-p private-file)
      (load-file private-file)
    (warn "Unable to find file %s" private-file)))

;;; early-init.el ends here
