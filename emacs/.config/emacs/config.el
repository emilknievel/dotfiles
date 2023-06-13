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
      ; visible-bell t
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
  ;; :config
  ;; (evil-set-leader '(normal visual) (kbd "SPC"))
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :custom (evil-collection-setup-minibuffer t) ; enable evil in the minibuffer
  :config
  (evil-collection-init))

(use-package evil-commentary
  :hook (prog-mode . evil-commentary-mode))

(use-package general
  :after evil
  :config
  (general-evil-setup t)
  (general-define-key
    :keymaps '(normal insert emacs)
    :prefix "SPC"
    :non-normal-prefix "M-SPC"
    :prefix-map 'my/leader-key-map

    ;; files
    "f s" 'save-buffer
    "f f" 'find-file
    "f l" 'load-file

    ;; dirs
    "d d" 'dired

    ;; buffers
    "b b" 'switch-to-buffer
    "b B" 'ibuffer
    "b X" 'scratch-buffer
    "q q" 'save-buffers-kill-terminal

    ;; windows
    "w s" 'evil-window-split
    "w v" 'evil-window-vsplit
    "w w" 'other-window
    "w q" 'delete-window
    "w +" 'evil-window-increase-height
    "w -" 'evil-window-decrease-height
    "w >" 'evil-window-increase-width
    "w <" 'evil-window-decrease-width
    "w =" 'balance-windows
    "w H" 'evil-window-left
    "w J" 'evil-window-down
    "w K" 'evil-window-up
    "w L" 'evil-window-right
))

(setq inhibit-startup-screen t)

(setopt confirm-kill-emacs 'y-or-n-p)

(setq ns-use-proxy-icon nil
  ns-use-mwheel-momentum t
  ns-use-mwheel-acceleration t
  frame-resize-pixelwise t)

(setq custom-theme-directory "~/.config/emacs/themes/")

;; (require-theme 'modus-themes)
(use-package modus-themes)

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-org-config))

(use-package circadian
  :config
  (setq calendar-latitude 58.389590)
  (setq calendar-longitude 13.837250)
  ;; (setq circadian-themes '((:sunrise . modus-operandi)
  ;;                          (:sunset . modus-vivendi)))
  (setq circadian-themes '(("8:00" . doom-rose-pine-dawn)
                           ("20:00" . doom-rose-pine)))
  (circadian-setup))

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))

(use-package ns-auto-titlebar
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

(cond ((eq system-type 'darwin)
       (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font 13"))
       ;; Render fonts like in iTerm
       ;; Still need to set `defaults write org.gnu.Emacs AppleFontSmoothing -int`
       ;; in the terminal for it to work like intended.
       (setq ns-use-thin-smoothing t)
       )
      ((eq system-type 'gnu/linux)
       (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font 10"))
       ))

(defun my/show-column-guide ()
  (setq display-fill-column-indicator-column 80)
  (display-fill-column-indicator-mode))

(add-hook 'prog-mode-hook #'my/show-column-guide)

(column-number-mode 1)

(defun my/display-set-relative ()
  (interactive)
  (if (not (eq major-mode 'org-mode))
      (setq display-line-numbers 'visual)
    (setq display-line-numbers nil)))

(defun my/display-set-absolute ()
  (interactive)
  (if (not (eq major-mode 'org-mode))
      (setq display-line-numbers t)
    (setq display-line-numbers nil)))

(defun my/display-set-hidden ()
  (interactive)
  (setq display-line-numbers nil))

(use-package display-line-numbers
  :custom
  (display-line-numbers-widen t)
  (display-line-numbers-type 'visual)
  :hook
  ((prog-mode conf-mode) . display-line-numbers-mode)
  :config
  (add-hook 'evil-insert-state-entry-hook #'my/display-set-absolute)
  (add-hook 'evil-insert-state-exit-hook #'my/display-set-relative)
  :general
  (my/leader-key-map
    "n h" 'my/display-set-hidden
    "n r" 'my/display-set-relative
    "n a" 'my/display-set-absolute))

(setq show-trailing-whitespace t)

(setq require-final-newline t)

(use-package treesit-auto
  :demand t
  :init
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (cmake "https://github.com/uyha/tree-sitter-cmake")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (make "https://github.com/alemuller/tree-sitter-make")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook ((dired-mode . nerd-icons-dired-mode)
         ;; prevent icons from overlapping vertically
         (dired-mode . (lambda () (setq line-spacing 0.25)))))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

(use-package nerd-icons-completion
  :after (marginalia nerd-icons)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :init
  (nerd-icons-completion-mode))

(use-package marginalia
  :general
  (:keymaps 'minibuffer-local-map
    "M-A" 'marginalia-cycle)
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package vertico
:demand t                             ; Otherwise won't get loaded immediately
:straight (vertico :files (:defaults "extensions/*") ; Special recipe to load extensions conveniently
                   :includes (vertico-indexed
                              vertico-flat
                              vertico-grid
                              vertico-mouse
                              vertico-quick
                              vertico-buffer
                              vertico-repeat
                              vertico-reverse
                              vertico-directory
                              vertico-multiform
                              vertico-unobtrusive
                              ))
:general
(:keymaps '(normal insert visual motion)
 "M-." #'vertico-repeat
 )
(:keymaps 'vertico-map
 "<tab>" #'vertico-insert ; Set manually otherwise setting `vertico-quick-insert' overrides this
 "<escape>" #'minibuffer-keyboard-quit
 "?" #'minibuffer-completion-help
 "C-M-n" #'vertico-next-group
 "C-M-p" #'vertico-previous-group
 ;; Multiform toggles
 "<backspace>" #'vertico-directory-delete-char
 "C-w" #'vertico-directory-delete-word
 "C-<backspace>" #'vertico-directory-delete-word
 "RET" #'vertico-directory-enter
 "C-i" #'vertico-quick-insert
 "C-o" #'vertico-quick-exit
 "M-o" #'kb/vertico-quick-embark
 "M-G" #'vertico-multiform-grid
 "M-F" #'vertico-multiform-flat
 "M-R" #'vertico-multiform-reverse
 "M-U" #'vertico-multiform-unobtrusive
 "C-l" #'kb/vertico-multiform-flat-toggle
 )
:hook ((rfn-eshadow-update-overlay . vertico-directory-tidy) ; Clean up file path when typing
       (minibuffer-setup . vertico-repeat-save) ; Make sure vertico state is saved
       )
:custom
(vertico-count 13)
(vertico-resize t)
(vertico-cycle nil)
;; Extensions
(vertico-grid-separator "       ")
(vertico-grid-lookahead 50)
(vertico-buffer-display-action '(display-buffer-reuse-window))
(vertico-multiform-categories
 '((file reverse)
   (consult-grep buffer)
   (consult-location)
   (imenu buffer)
   (library reverse indexed)
   (org-roam-node reverse indexed)
   (t reverse)
   ))
(vertico-multiform-commands
 '(("flyspell-correct-*" grid reverse)
   (org-refile grid reverse indexed)
   (consult-yank-pop indexed)
   (consult-flycheck)
   (consult-lsp-diagnostics)
   ))
:init
(defun kb/vertico-multiform-flat-toggle ()
  "Toggle between flat and reverse."
  (interactive)
  (vertico-multiform--display-toggle 'vertico-flat-mode)
  (if vertico-flat-mode
      (vertico-multiform--temporary-mode 'vertico-reverse-mode -1)
    (vertico-multiform--temporary-mode 'vertico-reverse-mode 1)))
(defun kb/vertico-quick-embark (&optional arg)
  "Embark on candidate using quick keys."
  (interactive)
  (when (vertico-quick-jump)
    (embark-act arg)))

;; Workaround for problem with `tramp' hostname completions. This overrides
;; the completion style specifically for remote files! See
;; https://github.com/minad/vertico#tramp-hostname-completion
(defun kb/basic-remote-try-completion (string table pred point)
  (and (vertico--remote-p string)
       (completion-basic-try-completion string table pred point)))
(defun kb/basic-remote-all-completions (string table pred point)
  (and (vertico--remote-p string)
       (completion-basic-all-completions string table pred point)))
(add-to-list 'completion-styles-alist
             '(basic-remote           ; Name of `completion-style'
               kb/basic-remote-try-completion kb/basic-remote-all-completions nil))
:config
(vertico-mode)
;; Extensions
(vertico-multiform-mode)

;; Prefix the current candidate with “» ”. From
;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
(advice-add #'vertico--format-candidate :around
                                        (lambda (orig cand prefix suffix index _start)
                                          (setq cand (funcall orig cand prefix suffix index _start))
                                          (concat
                                           (if (= vertico--index index)
                                               (propertize "» " 'face 'vertico-current)
                                             "  ")
                                           cand)))
)

(use-package orderless
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)    ; I want to be in control!
  (completion-category-overrides
   '((file (styles basic-remote ; For `tramp' hostname completion with `vertico'
                   orderless
                   ))
     ))

  (orderless-component-separator 'orderless-escapable-split-on-space)
  (orderless-matching-styles
   '(orderless-literal
     orderless-prefixes
     orderless-initialism
     orderless-regexp
     ;; orderless-flex
     ;; orderless-strict-leading-initialism
     ;; orderless-strict-initialism
     ;; orderless-strict-full-initialism
     ;; orderless-without-literal          ; Recommended for dispatches instead
     ))
  (orderless-style-dispatchers
   '(prot-orderless-literal-dispatcher
     prot-orderless-strict-initialism-dispatcher
     prot-orderless-flex-dispatcher
     ))
  :init
  (defun orderless--strict-*-initialism (component &optional anchored)
    "Match a COMPONENT as a strict initialism, optionally ANCHORED.
The characters in COMPONENT must occur in the candidate in that
order at the beginning of subsequent words comprised of letters.
Only non-letters can be in between the words that start with the
initials.

If ANCHORED is `start' require that the first initial appear in
the first word of the candidate.  If ANCHORED is `both' require
that the first and last initials appear in the first and last
words of the candidate, respectively."
    (orderless--separated-by
     '(seq (zero-or-more alpha) word-end (zero-or-more (not alpha)))
     (cl-loop for char across component collect `(seq word-start ,char))
     (when anchored '(seq (group buffer-start) (zero-or-more (not alpha))))
     (when (eq anchored 'both)
       '(seq (zero-or-more alpha) word-end (zero-or-more (not alpha)) eol))))

  (defun orderless-strict-initialism (component)
    "Match a COMPONENT as a strict initialism.
This means the characters in COMPONENT must occur in the
candidate in that order at the beginning of subsequent words
comprised of letters.  Only non-letters can be in between the
words that start with the initials."
    (orderless--strict-*-initialism component))

  (defun prot-orderless-literal-dispatcher (pattern _index _total)
    "Literal style dispatcher using the equals sign as a suffix.
It matches PATTERN _INDEX and _TOTAL according to how Orderless
parses its input."
    (when (string-suffix-p "=" pattern)
      `(orderless-literal . ,(substring pattern 0 -1))))

  (defun prot-orderless-strict-initialism-dispatcher (pattern _index _total)
    "Leading initialism  dispatcher using the comma suffix.
It matches PATTERN _INDEX and _TOTAL according to how Orderless
parses its input."
    (when (string-suffix-p "," pattern)
      `(orderless-strict-initialism . ,(substring pattern 0 -1))))

  (defun prot-orderless-flex-dispatcher (pattern _index _total)
    "Flex  dispatcher using the tilde suffix.
It matches PATTERN _INDEX and _TOTAL according to how Orderless
parses its input."
    (when (string-suffix-p "." pattern)
      `(orderless-flex . ,(substring pattern 0 -1))))
  )

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  (corfu-quit-no-match 'separator)
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Keybindings
  (global-set-key (kbd "C-<tab>") #'corfu-next)
  (global-set-key (kbd "C-S-<tab>") #'corfu-previous)
  (global-set-key (kbd "C-M-i") #'corfu-complete)

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-exclude-modes'.
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

(use-package eglot)

(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :config
  (global-flycheck-eglot-mode 1))

(add-to-list 'auto-mode-alist '("\\.pl?\\'" . prolog-mode))

(use-package dockerfile-mode
  :config (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package yaml-mode
  :hook
  (yaml-mode . (lambda ()
                 (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc"))

(use-package clojure-mode)

(use-package aggressive-indent-mode
  :hook (clojure-mode))

(use-package smartparens
  :init (require 'smartparens-config)
  :hook (clojure-mode . smartparens-mode))

(use-package sly
  :init (setq inferior-lisp-program (executable-find "sbcl"))
  :mode ("\\.lisp?\\'" . common-lisp-mode)
  :hook
  (sly-mode . (lambda ()
                (unless (sly-connected-p)
                  (save-excursion (sly))))))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package magit
  :general
  (my/leader-key-map
    "g s" 'magit-status))

(use-package diff-hl
  :init
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  :hook
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh))

(use-package vterm
  :general
  (my/leader-key-map
    "o T" 'vterm
    "o t" 'vterm-other-window)
  :config
  (setq vterm-max-scrollback 5000))
