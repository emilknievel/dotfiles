;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Emil Vågstedt"
      user-mail-address "emil.vagstedt@icloud.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; Bigger font size on Windows to make it look nice with high DPI on WSL.
(if (eq system-type 'darwin)
    (progn
      (setq doom-font (font-spec :family "Iosevka Nerd Font" :size 14 :weight 'regular)
            doom-variable-pitch-font (font-spec :family "SF Pro" :size 13)
            doom-serif-font (font-spec :family "CMU Serif" :size 16)))
  (progn
    (setq doom-font (font-spec :family "MesloLGS NF" :size 20 :weight 'regular)
          doom-variable-pitch-font (font-spec :family "Nimbus Sans L"  :size 20))))

(setq doom-unicode-font doom-font)

;; Make terminal font slightly smaller
(add-hook 'term-mode-hook (lambda () (text-scale-decrease 1)))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
(defun my/apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'doom-one t))
    ('dark (load-theme 'doom-one t))))

(if (display-graphic-p)
    (if (eq system-type 'darwin)
        (add-hook 'ns-system-appearance-change-functions #'my/apply-theme)
      (setq doom-theme 'doom-one))
  (setq doom-theme 'doom-one))

;; Default to relative line numbers.
(setq display-line-numbers-type 'relative)

;; Relative line numbers in VISUAL and NORMAL mode.
(defun my/display-set-relative ()
  (setq display-line-numbers 'relative))

;; Absolute line numbers in INSERT mode.
(defun my/display-set-absolute ()
  (setq display-line-numbers t))

(add-hook 'evil-insert-state-entry-hook #'my/display-set-absolute)
(add-hook 'evil-insert-state-exit-hook #'my/display-set-relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-agenda-files '("~/org"))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Set initial window size
(setq initial-frame-alist '((width . 120) (height . 40)))
(setq doom-themes-treemacs-theme "doom-colors")

(defun my/org-mode-visual()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t
        display-fill-column-indicator nil
        display-line-numbers nil)
  (visual-fill-column-mode 1))

(after! org
  (setq org-startup-folded 'overview
        org-ellipsis " ▾ "
        org-list-demote-modify-bullet '(("+" . "-") ("-" . "+"))))

(add-hook! 'org-mode-hook
           #'+org-pretty-mode #'mixed-pitch-mode #'my/org-mode-visual)

(after! org
  (custom-set-faces!
    '(org-document-title :height 1.3)
    '(org-level-1 :inherit outline-1 :weight extra-bold :height 1.4)
    '(org-level-2 :inherit outline-2 :weight bold :height 1.15)
    '(org-level-3 :inherit outline-3 :weight bold :height 1.12)
    '(org-level-4 :inherit outline-4 :weight bold :height 1.09)
    '(org-level-5 :inherit outline-5 :weight semi-bold :height 1.06)
    '(org-level-6 :inherit outline-6 :weight semi-bold :height 1.03)
    '(org-level-7 :inherit outline-7 :weight semi-bold)
    '(org-level-8 :inherit outline-8 :weight semi-bold)
    ;; Ensure that anything that should be fixed-pitch in org buffers appears that
    ;; way
    '(org-block nil :foreground nil :inherit 'fixed-pitch)
    '(org-code nil   :inherit '(shadow fixed-pitch))
    '(org-table nil   :inherit '(shadow fixed-pitch))
    '(org-verbatim nil :inherit '(shadow fixed-pitch))
    '(org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    '(org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
    '(org-checkbox nil :inherit 'fixed-pitch))
  (setq org-log-done 'note) ; Add timestamp and note if todo item marked as done.
  (setq org-roam-directory (file-truename "~/org-roam"))
  (org-roam-db-autosync-mode))

(setq projectile-project-search-path '("~/projects/" "~/stuff/"))

;; Add vertical ruler at column 80
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(setq-default show-trailing-whitespace t)
