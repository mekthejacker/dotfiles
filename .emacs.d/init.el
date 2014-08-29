;; Default xemacs configuration directory
(defconst toc:emacs-config-dir "~/.emacs.d/" "")

;; Utility finction to auto-load my package configurations
(defun toc:load-config-file (filelist)
  (dolist (file filelist)
    (load (expand-file-name 
           (concat toc:emacs-config-dir file)))
     (message "Loaded config file:%s" file)
     ))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Buffer-menu-use-header-line nil)
 '(column-number-mode t)
 '(desktop-base-file-name ".desktop")
 '(desktop-base-lock-name ".desktop.lock")
 '(desktop-load-locked-desktop t)
 '(desktop-path (quote ("~/.emacs.d/")))
 '(desktop-save t)
 '(desktop-save-mode t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(eshell-highlight-prompt nil)
 '(fringe-mode (quote (0)) nil (fringe))
 '(global-hl-line-mode t)
 '(ibuffer-modified-char 43)
 '(ibuffer-read-only-char 215)
 '(indent-tabs-mode t)
 '(inhibit-default-init nil)
 '(inhibit-startup-screen nil)
 '(initial-buffer-choice nil)
 '(line-number-display-limit-width 6820)
 '(menu-bar-mode nil)
 '(n-back-active-match-types (quote (position)))
 '(n-back-allowed-match-types (quote (word color position)))
 '(n-back-level 2)
 '(ourcomments-ido-ctrl-tab t)
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("marmalade" . "http://marmalade-repo.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(popcmp-completion-style (quote emacs-default))
 '(scalable-fonts-allowed t)
 '(scroll-bar-mode (quote left))
 '(show-paren-mode t)
 '(tab-always-indent (quote complete))
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 58)))
 '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
 '(text-scale-mode-step 1.0)
 '(tool-bar-mode nil)
 '(word-wrap t))

;; good old colors:
;; bg: #2e3436
;; fg: #d3d7cf
;; variable name:  #729fcf
;; string: #edd400
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#303030" :foreground "#d0d0d0" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 118 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(bold ((t (:weight bold))))
 '(comint-highlight-prompt ((t (:foreground "blue blue"))))
 '(custom-button ((((type x w32 ns) (class color)) (:background "lightgrey" :foreground "black" :box (:line-width 1 :style released-button)))))
 '(custom-button-mouse ((((type x w32 ns) (class color)) (:background "grey90" :foreground "black" :box (:line-width 1 :style released-button)))))
 '(custom-button-pressed ((((type x w32 ns) (class color)) (:background "lightgrey" :foreground "black" :box (:line-width 1 :style pressed-button)))))
 '(custom-face-tag ((t (:inherit custom-variable-tag))))
 '(custom-group-tag ((((class color) (background dark)) (:inherit variable-pitch :weight bold :height 1.2))))
 '(custom-group-tag-1 ((((class color) (background dark)) (:inherit variable-pitch :weight bold :height 1.2))))
 '(custom-link ((t (:foreground "cyan"))))
 '(custom-variable-tag ((((min-colors 88) (class color) (background light)) (:foreground "cyan" :weight bold))))
 '(ecb-default-highlight-face ((((class color) (background dark)) (:inherit highlight :weight bold))))
 '(eshell-prompt ((((class color) (background dark)) (:foreground "#8AE234" :weight normal))))
 '(fci-shading ((((class color) (min-colors 88) (background dark)) (:background "#555754"))))
 '(font-lock-builtin-face ((((class color) (min-colors 88) (background dark)) (:foreground "white" :weight bold))))
 '(font-lock-comment-face ((((class color) (min-colors 88) (background dark)) (:foreground "#888a85"))))
 '(font-lock-constant-face ((((class color) (min-colors 88) (background dark)) (:foreground "#d0d0d0" :weight bold))))
 '(font-lock-function-name-face ((((class color) (min-colors 88) (background dark)) (:foreground "#d0d0d0"))))
 '(font-lock-keyword-face ((((class color) (min-colors 88) (background dark)) (:foreground "#d0d0d0" :family "DejaVu Sans Mono Bold"))))
 '(font-lock-negation-char-face ((t (:foreground "#9df43c"))))
 '(font-lock-preprocessor-face ((t (:inherit font-lock-builtin-face :foreground "#d0d0d0"))))
 '(font-lock-string-face ((((class color) (min-colors 88) (background dark)) (:foreground "#edd400"))))
 '(font-lock-variable-name-face ((t (:foreground "#729fcf"))))
 '(font-lock-warning-face ((((class color) (min-colors 88) (background dark)) (:foreground "#fcaf3e" :weight normal))))
 '(fringe ((((class color) (background dark)) nil)))
 '(highlight ((((class color) (min-colors 88) (background dark)) (:background "#888a85" :foreground "#222"))))
 '(hl-line ((t (:background "#444444"))))
 '(isearch ((((class color) (min-colors 88) (background light)) (:background "#254667" :foreground "#e2e2e2"))))
 '(italic ((t (:underline nil :slant italic))))
 '(lazy-highlight ((((class color) (min-colors 88) (background dark)) (:background "#75507b" :foreground "white"))))
 '(linum ((t (:inherit (shadow default) :background "#303030" :foreground "#6e6e6e" :box nil :height 120 :width normal))))
 '(nil ((t (:foreground "white" :weight normal))) t)
 '(nobreak-space ((((class color) (min-colors 88)) (:foreground "#d3d7cf" :box (:line-width 1 :color "cyan")))))
 '(nxml-attribute-local-name-face ((t (:foreground "#729fcf"))))
 '(nxml-attribute-value-delimiter-face ((t (:foreground "#edd400"))))
 '(nxml-attribute-value-face ((t (:foreground "#edd400"))))
 '(nxml-comment-content-face ((t (:foreground "#888a85" :slant italic))))
 '(nxml-comment-delimiter-face ((t (:foreground "#888a85"))))
 '(nxml-element-local-name-face ((t (:foreground "#729fcf"))))
 '(nxml-tag-delimiter-face ((t (:foreground "#e8e8e8"))))
 '(nxml-text-face ((t nil)) t)
 '(region ((((class color) (min-colors 88) (background dark)) (:inherit highlight :foreground "white"))))
 '(sh-heredoc ((((min-colors 88) (class color) (background dark)) (:foreground "gray70" :weight normal))))
 '(sh-quoted-exec ((((class color) (background dark)) (:foreground "#AD7FA8"))))
 '(show-paren-match ((((class color) (background dark)) (:background "#75507b" :foreground "white"))))
 '(show-paren-mismatch ((((class color)) (:background "#ce5c00" :foreground "white"))))
 '(textile-acronym-face ((t nil)))
 '(textile-alignments-face ((t nil)))
 '(textile-class-face ((t (:foreground "#edd400"))))
 '(textile-h1-face ((t (:height 1.5))))
 '(textile-h2-face ((t (:height 1.25))))
 '(textile-h3-face ((t (:height 1.1))))
 '(textile-image-face ((t (:foreground "palegreen"))))
 '(textile-link-face ((t (:foreground "#729fcf"))))
 '(trailing-whitespace ((((class color) (background dark)) (:background "#eeeeee" :foreground "#eeeeee")))))

;; settings for smooth-scrolling.el
(setq scroll-conservatively 10000
	  scroll-preserve-screen-position 1
	  ;; redisplay-dont-pause t
	  ;; scroll-margin 1
	  ;; scroll-step 1
)

;;(turn-off-auto-fill)
(auto-fill-mode -1)
(remove-hook 'text-mode-hook 'turn-on-auto-fill)

;; After copy Ctrl+c in X11 apps, you can paste by `yank' in emacs
(setq x-select-enable-clipboard t)
;; After mouse selection in X11, you can paste by `yank' in emacs
(setq x-select-enable-primary t)

;; Disable VCS-stuff
(setq vc-handled-backends ())

;; Load my configuration files
(toc:load-config-file '("php-mode.el"))
(require 'site-gentoo)

;; M-j hook to rebound keybinding from C-mode back
(add-hook 'php-mode-hook (lambda () (define-key php-mode-map (kbd "M-j") 'backward-char)))
(add-hook 'php-mode-hook (lambda () (define-key php-mode-map (kbd "C-.") 'rotate-windows)))
(add-hook 'nxml-mode-hook (lambda () (define-key nxml-mode-map (kbd "M-h") 'beginning-of-line)))
(add-hook 'nroff-mode-hook (lambda () (define-key php-mode-map (kbd "C-j") 'clipboard-kill-ring-save)))
(toc:load-config-file '("textile-mode.el"))  

;; Load code snippets, shortcuts etc.
(load "~/.emacs.d/little_things/code_snippets.el")
(load "~/.emacs.d/little_things/fill-column-indicator.el")
(load "~/.emacs.d/little_things/linum.el")
;; must be after code_snippets, because there may be redefined functions
(load "~/.emacs.d/little_things/shortcuts.el")
;;(load "~/.emacs.d/geben-0.26/dbgp.el")
;;(load "~/.emacs.d/geben-0.26/geben.el")

;; Prevent default init load
(setq inhibit-default-init 1)

;; Disable auto breaking lines
(setq auto-fill-mode -1)

;; Load GEBEN
;;(autoload 'geben "geben" "PHP Debugger on Emacs" t)

;; Enabling line numbers
(global-linum-mode 1)

;; Enabling 80-column margin 'rule or 'shading
(setq fci-style 'shading)
(require 'fill-column-indicator)
(fci-mode 1)

;; (add-hook 'php-mode-hook 'font-lock-add-keywords) ;;(font-lock-add-keywords nil '(("^[^\n]\\{80\\}\\(.*\\)$" 1 font-lock-warning-face t)))


;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
;; (when
  ;; 	(load
  ;; 	 (expand-file-name "~/.emacs.d/elpa/package.el"))
  ;; (package-initialize)) 

;; C-j to force ido-mode accept what was entered
