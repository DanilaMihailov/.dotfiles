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

;; No sound
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; Paren mode is part of the theme
(show-paren-mode t)

;; small fringe
(fringe-mode '(0 . 0))

(global-set-key (kbd "C-x g") 'magit-status)

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

(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)

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
    ("aded61687237d1dff6325edb492bde536f40b048eab7246c61d5c6643c696b7f" "e1d09f1b2afc2fed6feb1d672be5ec6ae61f84e058cb757689edb669be926896" default)))
 '(display-line-numbers (quote relative))
 '(git-gutter:added-sign "┃")
 '(git-gutter:deleted-sign "•")
 '(git-gutter:modified-sign "┃")
 '(git-gutter:window-width 1)
 '(global-git-gutter-mode t)
 '(package-selected-packages
   (quote
    (evil-collection git-gutter smooth-scrolling evil-tabs flycheck exec-path-from-shell company lsp-ui rust-mode lsp-mode magit ## evil gruvbox-theme gru which-key beacon)))
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
