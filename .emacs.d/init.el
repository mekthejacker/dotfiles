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
 '(LaTeX-command "xetex -synctex=1")
 '(LaTeX-command-style (quote (("\\`fontspec\\'" "xelatex ") ("" "%(latex) %S%(PDFout)"))))
 '(TeX-auto-save t)
 '(TeX-command-list (quote (("TeX" "%(PDF)%(tex) %(extraopts) %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil (plain-tex-mode texinfo-mode ams-tex-mode) :help "Run plain TeX") ("LaTeX" "%`%l%(mode)%' %t" TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX") ("Makeinfo" "makeinfo %(extraopts) %t" TeX-run-compile nil (texinfo-mode) :help "Run Makeinfo with Info output") ("Makeinfo HTML" "makeinfo %(extraopts) --html %t" TeX-run-compile nil (texinfo-mode) :help "Run Makeinfo with HTML output") ("AmSTeX" "%(PDF)amstex %(extraopts) %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil (ams-tex-mode) :help "Run AMSTeX") ("ConTeXt" "texexec --once --texutil %(extraopts) %(execopts)%t" TeX-run-TeX nil (context-mode) :help "Run ConTeXt once") ("ConTeXt Full" "texexec %(extraopts) %(execopts)%t" TeX-run-TeX nil (context-mode) :help "Run ConTeXt until completion") ("BibTeX" "bibtex %s" TeX-run-BibTeX nil t :help "Run BibTeX") ("Biber" "biber %s" TeX-run-Biber nil t :help "Run Biber") ("View" "zathura %s.pdf" TeX-run-command t t :help "Run Text viewer") ("Print" "%p" TeX-run-command t t :help "Print the file") ("Queue" "%q" TeX-run-background nil t :help "View the printer queue" :visible TeX-queue-command) ("File" "%(o?)dvips %d -o %f " TeX-run-command t t :help "Generate PostScript file") ("Index" "makeindex %s" TeX-run-command nil t :help "Create index file") ("Xindy" "texindy %s" TeX-run-command nil t :help "Run xindy to create index file") ("Check" "lacheck %s" TeX-run-compile nil (latex-mode) :help "Check LaTeX file for correctness") ("ChkTeX" "chktex -v6 %s" TeX-run-compile nil (latex-mode) :help "Check LaTeX file for common mistakes") ("Spell" "(TeX-ispell-document \"\")" TeX-run-function nil t :help "Spell-check the document") ("Clean" "TeX-clean" TeX-run-function nil t :help "Delete generated intermediate files") ("Clean All" "(TeX-clean t)" TeX-run-function nil t :help "Delete generated intermediate and output files") ("Other" "" TeX-run-command t t :help "Run an arbitrary command"))))
 '(TeX-engine (quote xetex))
 '(TeX-master nil)
 '(TeX-output-view-style (quote (("^dvi$" ("^landscape$" "^pstricks$\\|^pst-\\|^psfrag$") "%(o?)dvips -t landscape %d -o && gv %f") ("^dvi$" "^pstricks$\\|^pst-\\|^psfrag$" "%(o?)dvips %d -o && gv %f") ("^dvi$" ("^\\(?:a4\\(?:dutch\\|paper\\|wide\\)\\|sem-a4\\)$" "^landscape$") "%(o?)xdvi %dS -paper a4r -s 0 %d") ("^dvi$" "^\\(?:a4\\(?:dutch\\|paper\\|wide\\)\\|sem-a4\\)$" "%(o?)xdvi %dS -paper a4 %d") ("^dvi$" ("^\\(?:a5\\(?:comb\\|paper\\)\\)$" "^landscape$") "%(o?)xdvi %dS -paper a5r -s 0 %d") ("^dvi$" "^\\(?:a5\\(?:comb\\|paper\\)\\)$" "%(o?)xdvi %dS -paper a5 %d") ("^dvi$" "^b5paper$" "%(o?)xdvi %dS -paper b5 %d") ("^dvi$" "^letterpaper$" "%(o?)xdvi %dS -paper us %d") ("^dvi$" "^legalpaper$" "%(o?)xdvi %dS -paper legal %d") ("^dvi$" "^executivepaper$" "%(o?)xdvi %dS -paper 7.25x10.5in %d") ("^dvi$" "." "%(o?)xdvi %dS %d") ("^pdf$" "." "zathura %o") ("^html?$" "." "netscape %o"))))
 '(TeX-save-query nil)
 '(TeX-show-compilation t)
 '(TeX-source-correlate-method (quote synctex))
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t)
 '(TeX-view-program-selection (quote (((output-dvi style-pstricks) "dvips and gv") (output-dvi "xdvi") (output-pdf "zathura") (output-html "xdg-open"))))
 '(autopair-global-mode t)
 '(case-fold-search nil)
 '(column-number-mode t)
 '(delete-selection-mode t)
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
 '(global-whitespace-mode t)
 '(ibuffer-modified-char 43)
 '(ibuffer-read-only-char 215)
 '(indent-tabs-mode t)
 '(inhibit-default-init nil)
 '(inhibit-startup-screen nil)
 '(initial-buffer-choice nil)
 '(latex-run-command "xelatex -synctex=1")
 '(line-number-display-limit-width 6820)
 '(menu-bar-mode nil)
 '(n-back-active-match-types (quote (position)))
 '(n-back-allowed-match-types (quote (word color position)))
 '(n-back-level 2)
 '(ourcomments-ido-ctrl-tab t)
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("marmalade" . "http://marmalade-repo.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(popcmp-completion-style (quote emacs-default))
 '(preview-fast-dvips-command "pdftops -origpagesizes %s.pdf %m/preview.ps")
 '(scalable-fonts-allowed t)
 '(scroll-bar-mode (quote left))
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(tab-always-indent (quote complete))
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 58)))
 '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
 '(text-scale-mode-step 1.0)
 '(tool-bar-mode nil)
 '(whitespace-display-mappings (quote ((space-mark 32 [32] [46]) (space-mark 160 [43] [95]) (newline-mark 10 [4347 10]) (tab-mark 9 [9002 8213 8213 8213] [9552 9]))))
 '(whitespace-global-modes t)
 '(whitespace-line-column 10000)
 '(whitespace-style (quote (face tabs spaces trailing newline indentation empty space-mark tab-mark newline-mark)))
 '(word-wrap t)
 '(x-select-enable-primary nil)
 '(x-stretch-cursor t))

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
 '(ediff-current-diff-A ((t (:background "pale green" :foreground "firebrick"))))
 '(ediff-current-diff-Ancestor ((t (:background "VioletRed" :foreground "Black"))))
 '(ediff-current-diff-B ((t (:background "Yellow" :foreground "DarkOrchid"))))
 '(ediff-current-diff-C ((t (:background "Pink" :foreground "Navy"))))
 '(ediff-even-diff-A ((t (:background "light grey" :foreground "Black"))))
 '(ediff-even-diff-Ancestor ((t (:background "Grey" :foreground "White"))))
 '(ediff-even-diff-B ((t (:background "Grey" :foreground "White"))))
 '(ediff-even-diff-C ((t (:background "light grey" :foreground "Black"))))
 '(ediff-fine-diff-A ((t (:background "sky blue" :foreground "Navy"))))
 '(ediff-fine-diff-Ancestor ((t (:background "Green" :foreground "Black"))))
 '(ediff-fine-diff-B ((t (:background "cyan" :foreground "Black"))))
 '(ediff-fine-diff-C ((t (:background "Turquoise" :foreground "Black"))))
 '(ediff-odd-diff-A ((t (:background "Grey" :foreground "White"))))
 '(ediff-odd-diff-Ancestor ((t (:background "gray40" :foreground "cyan3"))))
 '(ediff-odd-diff-B ((t (:background "light grey" :foreground "Black"))))
 '(ediff-odd-diff-C ((t (:background "Grey" :foreground "White"))))
 '(eshell-prompt ((((class color) (background dark)) (:foreground "#8AE234" :weight normal))))
 '(fci-shading ((((class color) (min-colors 88) (background dark)) (:background "#555754"))))
 '(flyspell-incorrect ((t (:underline (:color "OrangeRed2" :style wave)))))
 '(font-lock-builtin-face ((((class color) (min-colors 88) (background dark)) (:foreground "white" :weight bold))))
 '(font-lock-comment-face ((((class color) (min-colors 88) (background dark)) (:foreground "#888a85"))))
 '(font-lock-constant-face ((((class color) (min-colors 88) (background dark)) (:foreground "#d0d0d0" :weight bold))))
 '(font-lock-function-name-face ((((class color) (min-colors 88) (background dark)) (:foreground "#d0d0d0"))))
 '(font-lock-keyword-face ((t (:foreground "#d0d0d0" :weight bold))))
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
 '(trailing-whitespace ((t (:background "powder blue" :foreground "white smoke"))))
 '(whitespace-empty ((t (:background "slate gray"))))
 '(whitespace-hspace ((t (:foreground "grey10"))))
 '(whitespace-indentation ((t (:foreground "grey10"))))
 '(whitespace-newline ((t (:foreground "grey10" :weight bold))))
 '(whitespace-space ((t (:foreground "grey10"))))
 '(whitespace-space-after-tab ((t (:foreground "grey10"))))
 '(whitespace-space-before-tab ((t (:foreground "grey10"))))
 '(whitespace-tab ((t (:foreground "grey10"))))
 '(whitespace-trailing ((t (:background "powder blue" :foreground "white smoke")))))

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
(add-hook 'c-mode-hook (lambda () (define-key c-mode-map (kbd "M-j") 'backward-char)))
(toc:load-config-file '("textile-mode.el"))

;; Load code snippets, shortcuts etc.
(load "~/.emacs.d/little_things/code_snippets.el")
(load "~/.emacs.d/little_things/fill-column-indicator.el")
(load "~/.emacs.d/little_things/linum.el")
;; must be after code_snippets, because there may be redefined functions
(load "~/.emacs.d/little_things/shortcuts.el")
(load "~/.emacs.d/little_things/pcre2el.el")
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


;; This was installed by package-install.el.
;; This provides support for the package system and
;; interfacing with ELPA, the package archive.
;; Move this code earlier if you want to reference
;; packages in your .emacs.
; (when
  ; 	(load
  ; 	 (expand-file-name "~/.emacs.d/elpa/package.el"))
  ; (package-initialize))

; C-j to force ido-mode accept what was entered

;; ediff
;; Don’t use separate frame (aka window in normal, i.e. X interpretation).
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; Restore how it was before ediff
   (add-hook 'ediff-load-hook
             (lambda ()
               (add-hook 'ediff-before-setup-hook
                         (lambda ()
                           (setq ediff-saved-window-configuration (current-window-configuration))))
               (let ((restore-window-configuration
                      (lambda ()
                        (set-window-configuration ediff-saved-window-configuration))))
                 (add-hook 'ediff-quit-hook restore-window-configuration 'append)
                 (add-hook 'ediff-suspend-hook restore-window-configuration 'append))))

(add-hook 'text-mode-hook 'flyspell-mode)

;; doesn't work for Russian
;;(require 'auto-dictionary) ;; this actually makes emacs fail to load init.el
;;(add-hook 'flyspell-mode-hook (lambda () (auto-dictionary-mode 1)))

;;If you're unhappy with the results, call ‘adict-change-dictionary’ to change it and stop automatic checks.

(add-hook 'reftex-load-hook 'imenu-add-menubar-index)
(add-hook 'reftex-mode-hook 'imenu-add-menubar-index)
(global-set-key [down-mouse-3] 'imenu)
	

;;(add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
