;;
;; SHORTCUTS
;; (global-set-key (kbd "key") 'function)
;; (global-unset-key (kbd "C-_"))
;;

;; common
(global-set-key (kbd "C-s")     'save-buffer)               ;; Сохранить.
;(global-set-key (kbd "C-S")     'write-file)               ;; Сохранить как…
(global-set-key (kbd "C-a")     'save-some-buffers)         ;; Сохранение всех несохранённых буферов на диск.
;(global-set-key (kbd "C-q")     'save-buffers-kill-emacs)  ;; Сохранение всех несохранённых буферов на диск и выход из среды Emacs.
(global-set-key (kbd "C-q")     'delete-frame)              ;; закрывает текущий фрейм Emacs
(global-unset-key (kbd "C-x C-q"))
(global-set-key (kbd "C-x C-q") 'save-buffers-kill-emacs);; вырубает весь Emacs
(global-set-key (kbd "C-x C-z") 'suspend-emacs)             ;; Это как C-z из шелла
(global-set-key (kbd "C-b")     'list-buffers)              ;; Отображение списка всех буферов.
(global-set-key (kbd "M-w")     'kill-buffer)               ;; Уничтожение буфера (по умолчанию текущего).
(global-set-key (kbd "C-l")     'goto-line)
(global-set-key (kbd "C-`")     'close-annoying-windows)
(global-unset-key (kbd "C-."))
(global-unset-key (kbd "C-,"))
(global-set-key (kbd "C-,")     'other-window)
(global-set-key (kbd "C-.")     'rotate-windows)

;; navigation
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

;; editing
;; disable annoying ‘set fill-column to’ misspelling C-x C-f
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

;; search    
(global-set-key (kbd "C-f") 'isearch-forward)
;(global-set-key (kbd "") 'isearch-backward)
    (global-set-key (kbd "C-F") 'isearch-forward-regexp)
    (global-set-key (kbd "C-R") 'isearch-backward-regexp)
(global-set-key (kbd "C-r") 'isearch-repeat-backward)
(global-set-key (kbd "C-v") 'isearch-repeat-forward)
(global-set-key (kbd "C-g") 'query-replace)

;;(global-set-key (kbd "") ')
;;(global-set-key (kbd "") ')
;;(global-set-key (kbd "") ')


