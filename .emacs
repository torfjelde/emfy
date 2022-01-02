;;; Emfy 0.2.0-dev <https://github.com/susam/emfy>

;; Customize user interface.
(menu-bar-mode 0)
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))
(setq inhibit-startup-screen t)
(column-number-mode)

;; ;; Theme.
;; (load-theme 'wombat)

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

;; Move the point to bottom/top when using `C-v' and `M-v', respectively,
;; rather than just trying to scroll.
(setq scroll-error-top-bottom t)

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

;; yasnippet.el: Snippet engine.
(use-package yasnippet
  ;; Enable globally.
  :init (yas-global-mode))
;; yasnippet-snippets.el: A huge collection of useful snippets.
(use-package yasnippet-snippets)

;; projectile.el: A _bunch_ of utility functionality for working with projects, e.g. rename everywhere
;; in a projet.
;; It'll automatically detect if something is a project using different heuristics, e.g.
;; if you have a `.git` file in a parent directory.
(use-package projectile
  :diminish projectile-mode ;; hide from mode-line since it'll be activated everywhere
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (progn
    (setq projectile-completion-system 'default)
    (setq projectile-enable-caching t)
    (setq projectile-indexing-method 'alien)
    (add-to-list 'projectile-globally-ignored-files "node-modules")
    (projectile-global-mode)))

;; helm-projectile.el: Improves interaction between `helm.el` and `projetile.el`.
(use-package helm-projectile)

;;;; Note-taking
(use-package org
  ;; Ignore org-mode from upstream and use a manually installed version.
  :pin manual
  :config
  (progn
    ;; Don't query us every time we trying to evaluate code in buffers.
    (setq org-confirm-babel-evaluate nil)
    ;; Don't indent text in a section to align with section-level.
    (setq org-adapt-indentation nil)
    ;; Don't indent body of code-blocks at all.
    (setq org-edit-src-content-indentation 0)
    ;; Allow setting variables in setup-files.
    (setq org-export-allow-bind-keywords t)
    ;; Where to store the generated images from `org-latex-preivew'. This '/' at the end is VERY important.
    (setq org-preview-latex-image-directory "~/.ltximg/")
    ;; Make it so that the src block is opened in the current window when we open to edit.
    (setq org-src-window-setup 'current-window)
    ;; Necessary for header-arguments in src-blocks to take effect during export.
    (setq org-export-use-babel t)
    ;; Disable execution of code-blocks on export by default.
    (add-to-list 'org-babel-default-header-args '(:eval . "never-export"))

    ;; If `flycheck` is installed, disable `flycheck` in src-blocks.
    ;; NOTE: This is maybe a bit "harsh". Could potentially just disable certain
    ;; features of `flycheck`.
    (when (package-installed-p 'flycheck)
      (require 'flycheck)
      (defun disable-flycheck-in-org-src-block ()
        (flycheck-mode -1))
      (add-hook 'org-src-mode-hook 'disable-flycheck-in-org-src-block))

    ;; Specify which programming languages to support in code-blocks.
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp t)
       (shell . t)
       (C . t)
       (latex . t)
       (python . t)
       (julia . t)))
    )
  )

;;;; Navigation
;; avy.el: Allows you to jump to words by specifying the first character.
(use-package avy
  ;; Feel free to change the binding.
  :bind ("M-j" . avy-goto-word-or-subword-1))

;; ace-window.el: Allows you to jump between windows. Super-useful when you're using more than 2 windows.
;; HACK: Only load if we're using a GUI. For some reason `ace-window' making it so that
;; switching between windows inserts 'I's and 'O's.
(when (display-graphic-p)
  (use-package ace-window
  ;; Feel free to change the binding.
  :bind ("M-[" . ace-window)))

;;;;;; Programming/markup related ;;;;;;
;; magit: Objectively the best interface for working with Git-related stuff ever.
(use-package magit)

;;;; LaTex
;; auctex.el: Everything related to LaTeX.
(use-package tex
  ;; It's weird. auctex.el provides a "module" called `tex` rather than `auctex`.
  ;; https://emacs.stackexchange.com/questions/41321/when-to-specify-a-package-name-in-use-packages-ensure-tag/41324#41324
  :ensure auctex)

;; company-auctex.el: `company.el` frontend for `auctex.el`.
(use-package company-auctex
  :init (progn
          (company-auctex-init)
          ;; Enable `company-mode` when we enable `LaTeX-mode`.
          (add-hook 'LaTeX-mode-hook 'company-mode)))

;;;; Markdown
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

;;;; Programming languages
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

;; Jupyter
;; This is awesome _but_ requires an Emacs version built with dynamic modules.
;; See https://github.com/nnicandro/emacs-zmq for more information on this.
;; But if this has been done, then you cna uncomment the line below.
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
