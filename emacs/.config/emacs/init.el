(setq vc-follow-symlinks t) ; edit real file when opening symbolic link

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
(straight-use-package '(org :type built-in))

(if (file-exists-p (expand-file-name "config.elc" user-emacs-directory))
    (load (expand-file-name "config.elc" user-emacs-directory))
  (if (file-exists-p (expand-file-name "config.elc" user-emacs-directory))
      (org-babel-load-file (expand-file-name "config.el" user-emacs-directory))
    (org-babel-load-file (expand-file-name "config.org" user-emacs-directory))))

(setq calendar-latitude  58.38959
      calendar-longitude 13.83725)
