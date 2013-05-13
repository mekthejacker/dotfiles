;;
;; CODE SNIPPETS
;;

;; tabs
;;(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;;(setq indent-tabs-mode nil)
(setq tab-width 4)

;; understroke-like cursor mode
(setq-default cursor-type 'hbar)

;; remove idiotic yes-or-no dialogues 
(fset 'yes-or-no-p 'y-or-n-p)

;; disabling toolbar
(tool-bar-mode -1)

;;Дублирование строки одной командой.
;(defun my-copy-line ()
;  (interactive)
;  (kill-ring-save (line-beginning-position) (line-end-position))
;  (end-of-line)
;  (newline)
;  (cua-paste nil))
;;(global-set-key [(alt d)] 'my-copy-line)

;;Новая строка.
;;(defun my-new-line ()
;;  (interactive)
;; (end-of-line)
;; (newline-and-indent))
;;(global-set-key [(alt o)] 'my-new-line)

;;Комментарии.
;;Удобное комментирование и разкомментирование либо одной строки, либо замакированного блока, используя одну и ту же команду.
(defun my-comment-or-uncomment-region (arg)
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not mark-active) (save-excursion (beginning-of-line) (not (looking-at "\\s-*$"))))
  (comment-or-uncomment-region (line-beginning-position) (line-end-position))
  (comment-dwim arg)))
(global-unset-key (kbd "C-/"))
(global-set-key (kbd "C-/") 'my-comment-or-uncomment-region)
;; При этом мне очень важно, чтобы знаки комментариев учитывали актуальный отступ строки. Для этого делаем:
(setq comment-style 'indent)

;;Этот прибамбас облегчает на порядок написание SGML/HTML/XML тегов.
(defun html-surround-region-with-closing-tag (tag-name beg end)
  (interactive "sTag name: \nr")
  (insert "</" tag-name ">")
  (insert "")
  (goto-char (+ end 2 (length tag-name)))
  )
(global-set-key [(control >)] 'html-surround-region-with-closing-tag)
;;Жмём control-> и даём название тега без знаков '<' и '>'. Всё осталное Emacs сделает сам. 

;;Этот прибамбас облегчает на порядок написание SGML/HTML/XML тегов.
(defun html-surround-region-with-tag (tag-name1 beg end)
  (interactive "sTag name: \nr")
  (insert "<" tag-name1 ">")
  (insert "")
  (goto-char (+ end 2 (length tag-name1)))
  )
(global-set-key [(control <)] 'html-surround-region-with-tag)
;;Жмём control-< и даём название тега без знаков '<' и '>'. Всё осталное Emacs сделает сам. 


;;Поиск парной скобки.
;;Мне дико нравился в своё время поиск парной скобки в Vim по нажатию %. Поэтому решил сделать подобное и в Emacs. Вот что получилось:
(defun my-match-paren (arg)
  (interactive "p")
  (cond ((looking-at "\\s\(")
  (forward-list 1) (backward-char 1))
  ((looking-at "\\s\)")
  (forward-char 1) (backward-list 1))
  (t (self-insert-command (or arg1)))))
(global-unset-key (kbd "C-p"))
(global-set-key (kbd "C-p") 'my-match-paren)
 

;;Захват всей строки.
;;Этот прибамбас я подсмотрел в Textmate. Заключается он в том, чтобы замаркировать всю строку и переместить курсор в начало следуюшей строки. При этом совершенно неважно, в каком месте строки находился курсор до этого.
;;(defun my-mark-line ()
;;  (interactive)
;;  (beginning-of-line)
;;  (cua-set-mark)
;;  (end-of-line)
;;  (next-line)
;;  (beginning-of-line))
;;(global-set-key [(alt k)] 'my-mark-line)

;;Перекодировка при открытии 
;;(setq unify-8859-on-decoding-mode 't)

;;Суть такая: биндишь это на шорткат, и оно скрывает все окна, которые начинаются на звездочку. Если ты начинаешь с аргумента, то тебя будет спрашивать про закрытие каждого из буфферов, ответы y/n.
(defun close-annoying-windows(&optional verbose)
   (interactive "P")
   (let ((blist (buffer-list)))

(while blist
  (and
    (= ?* (aref (buffer-name (car blist)) 0))
    (get-buffer-window (buffer-name (car blist)))
    (or (not verbose) (y-or-n-p (concat "Kill the window of " (buffer-name (car blist)) " buffer?")))
    (or verbose (not (equal (car blist) (current-buffer))))
    (delete-window (get-buffer-window (car blist))))
  (setq blist (cdr blist)))))


;; This is for rotating switching windows while switching them. 
;;
(defun rotate-windows ()
   (interactive)
   (let ((this-buffer (buffer-name)))

(other-window -1)
(let ((that-buffer (buffer-name)))
  (switch-to-buffer this-buffer)
  (other-window 1)
  (switch-to-buffer that-buffer)
  (other-window -1))))


;; ido buffers or something
;; Конфигурации(там реквайры на пакеты, которые есть на емаксовики):
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-use-filename-at-point nil)
;; disable auto searching for files unless called explicitly
(setq ido-auto-merge-delay-time 99999)
(ido-mode 1)
;; (require 'ido-preview)
;; (require 'kill-ring-ido)
;; (global-set-key (kbd "M-y") 'kill-ring-ido)
;; (add-hook 'ido-setup-hook
;;    (lambda()

;; (define-key ido-completion-map (kbd "M-a") (lookup-key ido-completion-map (kbd "C-a")))
;; (define-key ido-completion-map (kbd "M-e") (lookup-key ido-completion-map (kbd "C-e")))
;; (define-key ido-completion-map (kbd "C-a") 'move-beginning-of-line)
;; (define-key ido-completion-map (kbd "C-e") 'move-end-of-line)

;; (define-key ido-completion-map (kbd "C-M-p") (lookup-key ido-completion-map (kbd "C-p")))
;; (define-key ido-completion-map (kbd "C-M-n") (lookup-key ido-completion-map (kbd "C-n"))) ;; currently, this makes nothing. Maybe they'll make C-n key lately.
;; (define-key ido-completion-map (kbd "C-p") 'ido-preview-backward)
;; (define-key ido-completion-map (kbd "C-n") 'ido-preview-forward)))

;; C-c C-e to eval scratch buffer in lisp interaction mode
(define-key emacs-lisp-mode-map (kbd "C-c C-e") 
  (lambda () 
    (interactive)
    (let ((result (eval (read (buffer-substring 
                               (point-at-bol) (point-at-eol)))))) 
      (goto-char (point-at-eol)) 
      (insert (format " ; ⇒ %s" result)))))

(setq initial-major-mode 'emacs-lisp-mode) ;elisp mode for scratch

;; move to Line:column 
(defadvice goto-line (around goto-column activate)
  "Allow a specification of LINE:COLUMN instead /home/www/site12/htof just COLUMN.
Just :COLUMN moves to the specified column on the current line.
Just LINE: moves to the current column on the specified line.
LINE alone still moves to the beginning of the specified line (like LINE:0)."
  (if (symbolp line) (setq line (symbol-name line)))
  (let ((column (save-match-data
                  (if (and (stringp line)
                           (string-match "\\`\\([0-9]*\\):\\([0-9]*\\)\\'" line))
                      (prog1
                        (match-string 2 line)
                        (setq line (match-string 1 line)))
                    nil))))
    (if (stringp column)
        (setq column (if (= (length column) 0)
                         (current-column)
                       (string-to-int column))))
    (if (stringp line)
        (setq line (if (= (length line) 0)
                       (if buffer
                         (save-excursion
                           (set-buffer buffer)
                           (line-number-at-pos))
                         nil)
                     (string-to-int line))))
    (if line
        ad-do-it)
    (if column
        (let ((limit (- (save-excursion (forward-line 1) (point))
                        (point))))
          (when (< column limit)
            (beginning-of-line)
            (forward-char column))))))