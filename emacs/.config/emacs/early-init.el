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
                                '(width . 100)
                                ;; override above and make it fullscreen
                                '(fullscreen . maximized)))

;; Customize titlebar
(cond ((eq system-type 'darwin)
       (add-to-list 'default-frame-alist '(ns-transparent-titlebar . nil)))
      ((and (eq system-type 'gnu/linux)
            ;; TODO: replace obsolete operating-system-release variable
            (not (string-match "-[Mm]icrosoft" operating-system-release)))
       (add-to-list 'default-frame-alist '(undecorated . t))))

;;; early-init.el ends here
