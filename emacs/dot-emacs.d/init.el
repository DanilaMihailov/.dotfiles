(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(icomplete-mode t)
 '(package-selected-packages
   '(wanderlust flycheck company lsp-treemacs lsp-pyright lsp-ui lsp-mode tree-sitter-langs tree-sitter markdown-mode evil-collection magit general which-key projectile evil doom-themes doom-modeline))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; No sound
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; highlight the current line
(global-hl-line-mode +1)

(use-package exec-path-from-shell :ensure t
  :init
    (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))
  )

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

(scroll-bar-mode -1)

(setq evil-want-keybinding nil)
(use-package evil
  :ensure t
  :config
    (setq evil-want-C-u-scroll t)
    (setq evil-want-Y-yank-to-eol t)
    (setq evil-split-window-below t)
    (setq evil-vsplit-window-right t)
  :init
  (evil-mode 1)
)

(use-package evil-collection :ensure t
  :init
  (evil-collection-init)
)

(use-package which-key
  :ensure t
  :config
    ;; Set the time delay (in seconds) for the which-key popup to appear. A value of
    ;; zero might cause issues so a non-zero value is recommended.
    (setq which-key-idle-delay 0.2)
    (setq which-key-popup-type 'minibuffer)
  :init
    (which-key-mode)
)

(use-package doom-modeline
  :ensure t
  :init
    (doom-modeline-mode 1)
)

(use-package doom-themes
  :ensure t
  :init
    (load-theme 'doom-one t)
)

(use-package general :ensure t)

(use-package magit :ensure t)

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package tree-sitter
  :ensure t
  :config
    (global-tree-sitter-mode)
    (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
  )
(use-package tree-sitter-langs
  :ensure t
  )

(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (prog-mode . lsp-deferred)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp lsp-deferred)

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred))))  ; or lsp-deferred


;; optionally
(use-package lsp-ui :ensure t :commands lsp-ui-mode)
(use-package lsp-treemacs :ensure t :commands lsp-treemacs-errors-list)
(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))
(use-package company :ensure t
  :init
    (add-hook 'after-init-hook 'global-company-mode)
  )


(use-package ivy :ensure t
  :config
    (setq ivy-use-virtual-buffers t)
    (setq enable-recursive-minibuffers t)
(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)
  :init
    (ivy-mode)
)

(use-package counsel :ensure t
  :init
  )
