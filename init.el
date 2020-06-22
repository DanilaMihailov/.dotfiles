;; TODO
;; make modeline prettier
;; sessions
;; configure more lsps
;; try orgmode
;; fix slow auto complete

;; add packages repo
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; disable startup screen
;;(setq inhibit-startup-screen t)

;; disable toolbar
(tool-bar-mode 0)

;; change backup dir for autosave
(setq backup-directory-alist '(("." . "~/.emacs_saves")))

;; show the cursor when moving after big movements in the window
(require 'beacon)
(beacon-mode +1)

;; show available keybindings after you start typing
(require 'which-key)
(which-key-mode +1)

(setq evil-want-C-u-scroll t)
(setq evil-want-Y-yank-to-eol t)
(setq evil-split-window-below t)
(setq evil-vsplit-window-right t)

;; Line spacing, can be 0 for code and 1 or 2 for text
(setq-default line-spacing 0)

;; No ugly button for checkboxes
(setq widget-image-enable nil)

;; hide line numbers in mode line
(line-number-mode nil)

;; No sound
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; Paren mode is part of the theme
(show-paren-mode t)

;; small fringe
(fringe-mode '(0 . 0))

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x p") 'fzf-git-files)

(require 'smooth-scrolling)
(smooth-scrolling-mode 1)
(setq smooth-scroll-margin 5)

;; Enable Evil
(setq evil-want-keybinding nil)
(require 'evil)
(evil-mode 1)
(evil-collection-init)
(require 'rust-mode)
(require 'lsp-mode)
(setq lsp-rust-server 'rust-analyzer)
(add-hook 'rust-mode-hook #'lsp)

;;(global-evil-tabs-mode t)
(scroll-bar-mode -1)

(add-hook 'after-init-hook 'global-company-mode)

(global-git-gutter-mode +1)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; highlight the current line
(global-hl-line-mode +1)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; autocomplete everywhere
(require 'ido)
(require 'flx-ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)

(require 'icomplete)
(icomplete-mode 1)

(require 'ido-completing-read+)
(ido-ubiquitous-mode 1)

(load "~/.emacs.d/evil-unimpared")
(evil-unimpaired-mode)
;; does not work :(
(evil-unimpaired-define-pair "e" '(move-text-up . move-text-down) '(normal visual))
(evil-unimpaired-define-pair "q" '(flycheck-previous-error . flycheck-next-error))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#ebdbb2" "#cc241d" "#98971a" "#d79921" "#458588" "#b16286" "#689d6a" "#3c3836"])
 '(custom-enabled-themes (quote (gruvbox-dark-medium)))
 '(custom-safe-themes
   (quote
    ("3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "aded61687237d1dff6325edb492bde536f40b048eab7246c61d5c6643c696b7f" "e1d09f1b2afc2fed6feb1d672be5ec6ae61f84e058cb757689edb669be926896" default)))
 '(display-line-numbers (quote relative))
 '(git-gutter:added-sign "┃")
 '(git-gutter:deleted-sign "•")
 '(git-gutter:modified-sign "┃")
 '(git-gutter:window-width 1)
 '(global-git-gutter-mode t)
 '(line-number-mode nil)
 '(package-selected-packages
   (quote
    (fzf flx-ido rich-minority smart-mode-line ido-completing-read+ evil-collection git-gutter smooth-scrolling evil-tabs flycheck exec-path-from-shell company lsp-ui rust-mode lsp-mode magit ## evil gruvbox-theme gru which-key beacon)))
 '(pdf-view-midnight-colors (quote ("#282828" . "#fbf1c7"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(git-gutter:added ((t (:background "#282828" :foreground "#98971a"))))
 '(git-gutter:deleted ((t (:background "#282828" :foreground "#cc241d"))))
 '(git-gutter:modified ((t (:background "#282828" :foreground "#458588"))))
 '(line-number ((t (:background "#282828" :foreground "#7c6f64"))))
 '(line-number-current-line ((t (:background "#282828" :foreground "#fe8019")))))
