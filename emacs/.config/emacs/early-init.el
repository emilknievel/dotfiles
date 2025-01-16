;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;;; Commentary:

;; Loaded before initialization.

;;; Code:

(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (expt 2 23))))

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

;; Sensible default height/width
(setq default-frame-alist (list '(min-height . 1)
                                '(height . 40)
                                '(min-width . 1)
                                '(width . 110)))
;; '(fullscreen . maximized)))

;; Customize titlebar
(cond ((eq system-type 'darwin)
       (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))))
;; ((and (eq system-type 'gnu/linux)
;;       (not (getenv "WSL_DISTRO_NAME")))
;;  (add-to-list 'default-frame-alist '(internal-border-width . 8))))

;; Load dark theme early to avoid getting flashed when launching Emacs.
(load-theme 'modus-vivendi t nil)

(if (file-exists-p "~/.private.el")
    (load-file "~/.private.el")
  (message "WARNING: Unable to find file ~/.private.el."))

;;; early-init.el ends here
