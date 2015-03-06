;; SHORTCUTS
;; Examples:
;; (global-set-key (kbd "key") 'function)
;; (global-unset-key (kbd "C-_"))


;; C-. will not work in terminal because C-. combination will produce
;; <ASCII code of . -64>. ASCII code for . is 46
;; and 46-64=-18 which is invalid.
;(global-set-key (kbd "TAB") 'self-insert-command)
(global-set-key (kbd "C-s")     'save-buffer)               ;; Save
;(global-set-key (kbd "C-S")     'write-file)               ;; Save as…
(global-set-key (kbd "C-a")     'save-some-buffers)         ;; Save all unsaved
(global-set-key (kbd "C-q")     'delete-frame)              ;; Close current frame
(global-unset-key (kbd "C-x C-q"))
(global-set-key (kbd "C-x C-q") 'save-buffers-kill-emacs)   ;; Save all unsaved buffers and quit emacs
(global-set-key (kbd "C-x C-z") 'suspend-emacs)             ;; Like C-z from the terminal
(global-set-key (kbd "C-b")     'list-buffers)
(global-set-key (kbd "M-w")     'kill-buffer)
(global-set-key (kbd "C-l")     'goto-line)
(global-set-key (kbd "C-`")     'close-annoying-windows)
(global-set-key (kbd "C-h m")   'describe-mode)

;; Navigation
(global-set-key (kbd "M-i") 'previous-line)
(global-set-key (kbd "M-k") 'next-line)
(global-set-key (kbd "M-l") 'forward-char)
(global-set-key (kbd "M-j") 'backward-char)
(global-set-key (kbd "M-u") 'scroll-down)
(global-set-key (kbd "M-m") 'scroll-up)
(global-set-key (kbd "M-U") 'beginning-of-buffer)
(global-set-key (kbd "M-M") 'end-of-buffer)
(global-set-key (kbd "M-h") 'beginning-of-line)
(global-set-key (kbd "M-'") 'end-of-line)
(global-set-key (kbd "M-H") 'backward-word)
(global-set-key (kbd "M-\"") 'forward-word)
;; navigation between windows is based on the same ↑←↓→
(global-set-key (kbd "M-I") 'windmove-up)
(global-set-key (kbd "M-K") 'windmove-down)	;
(global-set-key (kbd "M-L") 'windmove-right)
(global-set-key (kbd "M-J") 'windmove-left)
;;
(global-unset-key (kbd "C-,"))
(global-unset-key (kbd "C-o"))
(global-set-key (kbd "C-o") 'other-window)
(global-set-key (kbd "C-,") 'rotate-windows)

;; Editing
;; Disable annoying ‘set fill-column to’ while mistyping C-x C-f
(global-unset-key (kbd "C-SPC"))
(global-set-key (kbd "M-SPC") 'set-mark-command)
(global-unset-key (kbd "C-x f"))
(global-set-key (kbd "M-;") 'backward-delete-char)
(global-set-key (kbd "M-:") 'backward-kill-word)
(global-set-key (kbd "C-z" ) 'undo)
(global-set-key (kbd "C-S-z") 'repeat-complex-command)
(global-set-key (kbd "C-k") 'clipboard-kill-region)
(global-unset-key (kbd "C-j"))
(global-set-key (kbd "C-j") 'clipboard-kill-ring-save)
(global-set-key (kbd "C-y") 'clipboard-yank)
    ;;(global-set-key (kbd "") 'beginning-of-sentence)
    ;;(global-set-key (kbd "") 'end-of-sentence)
    ;;(global-set-key (kbd "M-[") 'beginning-of-paragraph)
    ;;(global-set-key (kbd "M-]") 'end-of-paragraph)

;; Search
(global-set-key (kbd "C-f") 'isearch-forward)
;(global-set-key (kbd "") 'isearch-backward)
    (global-set-key (kbd "C-F") 'isearch-forward-regexp)
    (global-set-key (kbd "C-R") 'isearch-backward-regexp)
(global-set-key (kbd "C-r") 'isearch-repeat-backward)
(global-set-key (kbd "C-v") 'isearch-repeat-forward)
;(global-set-key (kbd "C-g") 'query-replace)
(global-set-key (kbd "C-g") 'pcre-query-replace-regexp)

;;(global-set-key (kbd "") ')
;;(global-set-key (kbd "") ')
;;(global-set-key (kbd "") ')
