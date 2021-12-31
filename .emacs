;;; Emfy 0.2.0-dev <https://github.com/susam/emfy>

;; Customize user interface.
(menu-bar-mode 0)
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))
(setq inhibit-startup-screen t)
(column-number-mode)

;; Theme.
(load-theme 'wombat)
(set-face-background 'default "#111")
(set-face-background 'cursor "#c96")
(set-face-background 'isearch "#c60")
(set-face-foreground 'isearch "#eee")
(set-face-background 'lazy-highlight "#960")
(set-face-foreground 'lazy-highlight "#ccc")
(set-face-foreground 'font-lock-comment-face "#fc0")

;; Show stray whitespace.
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)

;; Consider a period followed by a single space to be end of sentence.
(setq sentence-end-double-space nil)

;; Use spaces, not tabs, for indentation.
(setq-default indent-tabs-mode nil)

;; Display the distance between two tab stops as 4 characters wide.
(setq-default tab-width 4)

;; Indentation setting for various languages.
(setq c-basic-offset 4)
(setq js-indent-level 2)
(setq css-indent-offset 2)

;; Highlight matching pairs of parentheses.
(setq show-paren-delay 0)
(show-paren-mode)

;; Write auto-saves and backups to separate directory.
(make-directory "~/.tmp/emacs/auto-save/" t)
(setq auto-save-file-name-transforms '((".*" "~/.tmp/emacs/auto-save/" t)))
(setq backup-directory-alist '(("." . "~/.tmp/emacs/backup/")))

;; Do not move the current file while creating backup.
(setq backup-by-copying t)

;; Disable lockfiles.
(setq create-lockfiles nil)

;; Workaround for https://debbugs.gnu.org/34341 in GNU Emacs <= 26.3.
(when (and (version< emacs-version "26.3") (>= libgnutls-version 30603))
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; Write customizations to a separate file instead of this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

;; Enable installation of packages from MELPA.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install `use-package`, if necessary.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Load and set up `use-package`.
(require 'use-package)
(setq use-package-always-ensure t)

;;;; Packages ;;;;
;;;;;;; General utility ;;;;;;;
;; helm.el: Provides a much more pleasant `M-x` experience. Alternative to `ido`.
(use-package helm
             :diminish helm-mode  ;; removes the helm-mode from the mode-line
             :init (progn
                     (require 'helm-config)
                     (helm-mode))
             :bind (("M-x" . helm-M-x)))

(use-package helm-descbinds
  :bind (("C-h b" . helm-descbinds)))

;; which-key.el: Provides suggestions/completions for keybindings upon use.
(use-package which-key
  :pin melpa
  :config (which-key-mode))

;; company.el: Autocomplete backend. Other packages implement frontends for this,
;; e.g. auto-completer for Python.
(use-package company
  :config
  (progn
    (add-hook 'prog-mode-hook 'company-mode))
  )

;;;;;; Programming/markup related ;;;;;;
;; magit: Objectively the best interface for working with Git-related stuff ever.
(use-package magit)

;; Markdown
;; markdown-mode: Standard mode for markdown.
(use-package markdown-mode)

;; polymode: Allows you to use multiple modes within a single buffer, e.g.
;; use `julia-mode` for highlighting, etc. in a code-block within a markdown file.
(use-package polymode)

;; poly-markdown: Implementation of `polymode` for markdown, allowing other modes
;; to be used within buffers with `markdown-mode` enabled.
(use-package poly-markdown
  :mode ("\\.[jJ]md" . poly-markdown-mode) ;; Also enable for .jmd files.
  :bind (:map poly-markdown-mode-map
              ("C-c '" . markdown-edit-code-block)))

;; edit-indirect: Allows one to parts/subsections of buffers in a separate editable buffer,
;; whose changes are reflected in the main document. This is used by `poly-markdown` to allow
;; opening code-blocks in a separate editable buffer (see the `markdown-edit-code-block` from
;; the above `poly-markdown` block).
(use-package edit-indirect
  :config (progn
            (define-key edit-indirect-mode-map (kbd "C-c C-c") nil)))

;; Julia
(use-package julia-mode)

;; Python
(use-package python
  :config
  (progn
    ;; Make it so that `elpy-mode` is also enabled whenever `python-mode` is.
    (add-hook 'python-mode-hook 'elpy-mode)
    ))
(use-package elpy
  :defer t
  ;; `advice-add` effecftively allows you insert code before/after the execution of
  ;; some other functions. In this case we insert `(elpy-enable)` "before" `python-mode`,
  ;; i.e. whenever `python-mode` is called, `elpy-enable` will be called just before it.
  :init (advice-add 'python-mode :before 'elpy-enable))

;; ;; Jupyter
;; (use-package jupyter)

;; Enable Rainbow Delimiters.
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'ielm-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)

;; Customize Rainbow Delimiters.
(require 'rainbow-delimiters)
(set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")  ; red
(set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")  ; green
(set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")  ; blue
(set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")  ; yellow
(set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")  ; cyan
(set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")  ; magenta
(set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")  ; light gray
(set-face-foreground 'rainbow-delimiters-depth-8-face "#999")  ; medium gray
(set-face-foreground 'rainbow-delimiters-depth-9-face "#666")  ; dark gray

;; Custom command.
(defun show-current-time ()
  "Show current time."
  (interactive)
  (message (current-time-string)))

;; Custom key-binding.
(global-set-key (kbd "C-c t") 'show-current-time)

;; Start server.
(require 'server)
(unless (server-running-p)
  (server-start))
