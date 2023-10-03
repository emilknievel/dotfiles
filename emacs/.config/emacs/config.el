;; DO NOT EDIT THIS FILE DIRECTLY
;; This is a file generated from a literate programming source file located at
;; https://github.com/emilknievel/dotfiles/blob/main/emacs/.config/emacs/config.org
;; You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

(setq straight-repository-branch "develop")

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
(setq straight-use-package-by-default t)

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

(defvar my/work-projects-path "~/projects/"
  "Work related projects")

(defvar my/learning-path "~/stuff/learning-stuff/"
  "Learning resources/projects")

(defun my/toggle-theme ()
  "Toggle between two themes"
  (interactive)
  (if (eq my/current-theme my/dark-theme)
      (progn (load-theme my/light-theme t)
             (setq my/current-theme my/light-theme))
    (progn (load-theme my/dark-theme t)
           (setq my/current-theme my/dark-theme))))

(use-package gnutls
  :defer t
  :custom
  (gnutls-verify-error t))

(use-package which-key
  :diminish which-key-mode
  :init
  (which-key-mode)
  (which-key-setup-minibuffer)
  :config
  (setq which-key-idle-delay 0.3))

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
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :custom (evil-collection-setup-minibuffer t) ; enable evil in the minibuffer
  :config
  (evil-collection-init)
  :hook (vterm-mode . evil-collection-vterm-escape-stay))

(use-package evil-commentary
  :hook (prog-mode . evil-commentary-mode))

(use-package evil-surround
  :after evil
  :hook ((org-mode . (lambda () (push '(?~ . ("~" . "~")) evil-surround-pairs-alist)))
          (org-mode . (lambda () (push '(?$ . ("\\(" . "\\)")) evil-surround-pairs-alist))))
  :config
  (global-evil-surround-mode 1))

(use-package general
  :after evil
  :config
  (general-evil-setup t)
  (general-define-key
    :keymaps '(normal insert emacs)
    :prefix "SPC"
    :non-normal-prefix "M-SPC"
    :prefix-map 'my/leader-key-map

    ;; Top level functions

    "SPC" '(execute-extended-command :which-key "M-x")
    ;; files
    "f s" 'save-buffer
    "f f" 'find-file
    "f l" 'load-file
    "f g" '(consult-ripgrep :which-key "consult-ripgrep")

    ;; dirs
    "d d" 'dired

;; buffers
"b" '(nil :which-key "buffers")
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

;; help
"h f" 'describe-function
"h v" 'describe-variable
"h k" 'describe-key
"h i" 'info
"h b" 'describe-bindings

;; toggles
"t" '(nil :which-key "toggles")
"t v" '(visual-line-mode :which-key "visual line mode")
"t n" '(display-line-numbers-mode :which-key "display line numbers")
"t c" '(visual-fill-column-mode :which-key "visual fill column mode")
"t t" 'my/toggle-theme))

;; git
"g" '(nil :wk "git")

(use-package iedit
  :general
  (my/leader-key-map "e" 'iedit-mode))

(use-package evil-iedit-state)

(require 'whitespace)

(setq inhibit-startup-screen t)

(setopt confirm-kill-emacs 'y-or-n-p)

(setq ns-use-proxy-icon nil
  ns-use-mwheel-momentum t
  ns-use-mwheel-acceleration t
  frame-resize-pixelwise t
  mac-command-modifier 'meta
  mac-right-command-modifier 'none
  mac-option-modifier nil
  mac-control-modifier 'control)

(when (and (eq system-type 'gnu/linux) (not (string-match "-[Mm]icrosoft" operating-system-release)))
  (setq default-frame-alist '((undecorated . t))))

(defvar my/dark-theme 'doom-rose-pine)
(defvar my/light-theme 'doom-rose-pine-dawn)
(defvar my/current-theme my/light-theme)

(setq custom-theme-directory "~/.config/emacs/themes/")

(use-package kaolin-themes
  :config
  (setq kaolin-themes-distinct-fringe t)
  (setq kaolin-themes-hl-line-colored t))

(use-package catppuccin-theme
  :init (setq catppuccin-flavor 'frappe))

(use-package modus-themes)

(use-package doom-themes
  :ensure t
  :init
  (setq doom-themes-enable-bold nil
        doom-themes-enable-italic nil)
  :config
  (doom-themes-org-config)
  (doom-themes-visual-bell-config))

(load-theme my/current-theme t)

(use-package circadian
  :config
  (setq calendar-latitude 58.4)
  (setq calendar-longitude 13.8)
  ;; todo: use my/dark-theme and my/light-theme instead
  (setq circadian-themes '((:sunrise . doom-rose-pine-dawn)
                           (:sunset  . doom-rose-pine)))
  (circadian-setup))

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))

(use-package ns-auto-titlebar
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

(cond ((eq system-type 'darwin)
       (add-to-list 'default-frame-alist '(font . "Iosevka 15"))
       ;; Render fonts like in iTerm
       ;; Still need to set `defaults write org.gnu.Emacs AppleFontSmoothing -int`
       ;; in the terminal for it to work like intended.
       ;; (setq ns-use-thin-smoothing t)
       )
      ((eq system-type 'gnu/linux)
       (add-to-list 'default-frame-alist '(font . "Iosevka 11"))
       ))

(when (string-match "-[Mm]icrosoft" operating-system-release)
  (add-to-list 'default-frame-alist '(font . "Iosevka 18")))

(cond ((eq system-type 'gnu/linux)
       (setq variable-pitch-size 110)
       (setq fixed-pitch-size 110))
      ((eq system-type 'darwin)
       (setq variable-pitch-size 150)
       (setq fixed-pitch-size 150)))

(when (string-match "-[Mm]icrosoft" operating-system-release)
  (setq variable-pitch-size 180)
  (setq fixed-pitch-size 180))

(custom-theme-set-faces
 'user
 `(variable-pitch ((t (:family "Inter" :height ,variable-pitch-size :weight normal))))
 `(fixed-pitch ((t (:family "Iosevka" :height ,fixed-pitch-size :weight normal))))

 '(org-block ((t (:inherit fixed-pitch))))
 ;; '(org-block-begin-line ((t (:inherit fixed-pitch))))
 ;; '(org-block-end-line ((t (:inherit fixed-pitch))))
 ;; '(org-code ((t (:inherit (shadow fixed-pitch)))))
 ;; '(org-document-info ((t (:foreground "dark orange"))))
 '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
 '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
 ;; '(org-link ((t (:foreground "royal blue" :underline t))))
 '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-property-value ((t (:inherit fixed-pitch))) t)
 '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 ;; '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
 '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
 '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))

(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'visual-line-mode)

(defun my/show-column-guide ()
  (setq display-fill-column-indicator-column 80)
  (display-fill-column-indicator-mode))

(add-hook 'prog-mode-hook #'my/show-column-guide)

(column-number-mode 1)

(defun my/display-set-relative ()
  (interactive)
  (if (not (or (eq major-mode 'org-mode) (eq major-mode 'vterm-mode)))
      (setq display-line-numbers 'visual)
    (setq display-line-numbers nil)))

(defun my/display-set-absolute ()
  (interactive)
  (if (not (or (eq major-mode 'org-mode) (eq major-mode 'vterm-mode)))
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
  (evil-insert-state-entry . my/display-set-absolute)
  (evil-insert-state-exit . my/display-set-relative)
  ;; :config
  ;; (add-hook 'evil-insert-state-entry-hook #'my/display-set-absolute)
  ;; (add-hook 'evil-insert-state-exit-hook #'my/display-set-relative)
  :general
  (my/leader-key-map
    "n h" 'my/display-set-hidden
    "n r" 'my/display-set-relative
    "n a" 'my/display-set-absolute))

(setq show-trailing-whitespace t)

(setq require-final-newline t)

;; (use-package treesit-auto
;;   :demand t
;;   :init
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
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")
        (ocaml "https://github.com/tree-sitter/tree-sitter-ocaml" "master" "ocaml/src")
        (c-sharp "https://github.com/tree-sitter/tree-sitter-c-sharp")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (c "https://github.com/tree-sitter/tree-sitter-c")))
  ;; :config
  ;; (setq treesit-auto-install 'prompt)
  ;; (global-treesit-auto-mode))

(defun my/install-treesit-grammars ()
  "Install tree-sitter grammars from treesit-language-source-alist"
  (interactive)
  (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist)))

(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook ((dired-mode . nerd-icons-dired-mode)
         ;; prevent icons from overlapping vertically
         (dired-mode . (lambda () (setq line-spacing 0.25)))))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

(use-package spacious-padding
  :config
  (spacious-padding-mode 1))

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
  (corfu-auto nil)                 ;; Enable auto completion
  (corfu-auto-delay 0)
  (corfu-auto-prefix 0)

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

;; Add extensions
(use-package cape
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :bind (("C-c p p" . completion-at-point) ;; capf
         ("C-c p t" . complete-tag)        ;; etags
         ("C-c p d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c p h" . cape-history)
         ("C-c p f" . cape-file)
         ("C-c p k" . cape-keyword)
         ("C-c p s" . cape-symbol)
         ("C-c p a" . cape-abbrev)
         ("C-c p l" . cape-line)
         ("C-c p w" . cape-dict)
         ("C-c p \\" . cape-tex)
         ("C-c p _" . cape-tex)
         ("C-c p ^" . cape-tex)
         ("C-c p &" . cape-sgml)
         ("C-c p r" . cape-rfc1345))
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  ;; NOTE: The order matters!
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  ;;(add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
)

(use-package lsp-mode
  :init
  (add-to-list 'load-path (expand-file-name "lib/lsp-mode" user-emacs-directory))
  (add-to-list 'load-path (expand-file-name "lib/lsp-mode/clients" user-emacs-directory))

  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(flex)))

  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ((web-mode . lsp-deferred)
   (lsp-mode . lsp-enable-which-key-integration)
   (lsp-mode . lsp-ui-mode)
   (lsp-completion-mode . my/lsp-mode-setup-completion)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred)
  :custom
  (lsp-completion-provider :none)) ;; Corfu instead of Company

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;; (use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
;; (use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package yasnippet
  :hook ((lsp-mode . yas-minor-mode)))

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

(add-to-list 'auto-mode-alist '("\\.tsx?\\'" . tsx-ts-mode))

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode)))

(use-package jq-mode
  :mode ("\\.jq\\'" . jq-mode))

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
    "o t" 'vterm
    "o T" 'vterm-other-window)
  :config
  (setq vterm-max-scrollback 5000)
  (setq vterm-kill-buffer-on-exit 't))

(use-package project
  :general
  (my/leader-key-map
    "p" '(:keymap project-prefix-map :wk "project")) ; leader prefix for built-in project.el
  :straight (:type built-in))

(use-package dired
  :straight (:type built-in)
  :general
  (my/leader-key-map
    "d j" '(dired-jump :which-key "dired jump"))
  :config
  (when (string= system-type "darwin")
    (setq dired-use-ls-dired t
          insert-directory-program "/opt/homebrew/bin/gls"))
  (evil-define-key 'normal dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file)
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  (dired-listing-switches "-aBhl --group-directories-first"))

(use-package dired-single)

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-define-key 'normal dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package editorconfig
  :diminish
  :config (editorconfig-mode 1))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
)

(use-package org
  :straight (:type built-in)
  :config
  (setq org-hide-emphasis-markers t))

(use-package org-superstar
  :hook
  (org-mode . (lambda ()
                (org-superstar-mode 1))))

;; OCaml configuration
;;  - better error and backtrace matching

(defun set-ocaml-error-regexp ()
 (set
  'compilation-error-regexp-alist
  (list '("[Ff]ile \\(\"\\(.*?\\)\", line \\(-?[0-9]+\\)\\(, characters \\(-?[0-9]+\\)-\\([0-9]+\\)\\)?\\)\\(:\n\\(\\(Warning .*?\\)\\|\\(Error\\)\\):\\)?"
          2 3 (5 . 6) (9 . 11) 1 (8 compilation-message-face)))))

(add-hook 'tuareg-mode-hook 'set-ocaml-error-regexp)
(add-hook 'caml-mode-hook 'set-ocaml-error-regexp)
