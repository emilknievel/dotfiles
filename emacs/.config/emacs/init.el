(setq vc-follow-symlinks t) ; edit real file when opening symbolic link

(if (file-exists-p (expand-file-name "config.elc" user-emacs-directory))
  (load (expand-file-name "config.elc" user-emacs-directory))
  (if (file-exists-p (expand-file-name "config.elc" user-emacs-directory))
    (org-babel-load-file (expand-file-name "config.el" user-emacs-directory))
    (org-babel-load-file (expand-file-name "config.org" user-emacs-directory))))
