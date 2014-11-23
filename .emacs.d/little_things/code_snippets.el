;;
;; CODE SNIPPETS
;;

;; Tabs
;;(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;;(setq indent-tabs-mode nil)
(setq tab-width 4)

;; Understroke-like cursor mode
(setq-default cursor-type 'hbar)

;; Remove idiotic yes-or-no dialogues 
(fset 'yes-or-no-p 'y-or-n-p)

;; Disabling toolbar
(tool-bar-mode -1)

;; Immidiate copypaste of a whole string
;(defun my-copy-line ()
;  (interactive)
;  (kill-ring-save (line-beginning-position) (line-end-position))
;  (end-of-line)
;  (newline)
;  (cua-paste nil))
;;(global-set-key [(alt d)] 'my-copy-line)

;; New line
;(defun my-new-line ()
;  (interactive)
; (end-of-line)
; (newline-and-indent))
;(global-set-key [(alt o)] 'my-new-line)

;; Comments selected line or region
(defun my-comment-or-uncomment-region (arg)
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not mark-active) (save-excursion (beginning-of-line) (not (looking-at "\\s-*$"))))
  (comment-or-uncomment-region (line-beginning-position) (line-end-position))
  (comment-dwim arg)))
(global-unset-key (kbd "C-/"))
(global-set-key (kbd "C-/") 'my-comment-or-uncomment-region)
;; Comment symbols respect indentation
(setq comment-style 'indent)

;; That should make easier typing HTML/XML/SGML tags
(defun html-surround-region-with-closing-tag (tag-name beg end)
  (interactive "sTag name: \nr")
  (insert "</" tag-name ">")
  (insert "")
  (goto-char (+ end 2 (length tag-name)))
  )
(global-set-key [(control >)] 'html-surround-region-with-closing-tag)
;; Press Control then put tag name w/o parenteses.

;; That should make easier typing HTML/XML/SGML tags
(defun html-surround-region-with-tag (tag-name1 beg end)
  (interactive "sTag name: \nr")
  (insert "<" tag-name1 ">")
  (insert "")
  (goto-char (+ end 2 (length tag-name1)))
  )
(global-set-key [(control <)] 'html-surround-region-with-tag)
;; Press C-< and put tag name w/o parenteses.

;; Seeking for a pair to partentesis (C-p).
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

;; This closes all windows which titles start with an asterisk.
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


;; This is for rotating windows while switching them.
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
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-use-filename-at-point nil)
;; Disable auto searching for files unless called explicitly
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

;; Move to Line:column 
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


(defun my-list-buffers-vertical-split ()
  "`list-buffers', but forcing a vertical split.
    See `split-window-sensibly'."
  (interactive)
  (let ((split-width-threshold nil)
        (split-height-threshold 0))
    (call-interactively 'list-buffers)))
;;
(global-set-key [remap list-buffers] 'my-list-buffers-vertical-split)

;; Make combinations from the other layout work (C-ч и → C-x b)
;; Execute it with
;; M-x reverse-input-method RET russian-computer RET
(require 'cl)
;;
(defun reverse-input-method (input-method)
    "Build the reverse mapping of single letters from INPUT-METHOD."
    (interactive
     (list (read-input-method-name "Use input method (default current): ")))
    (if (and input-method (symbolp input-method))
        (setq input-method (symbol-name input-method)))
    (let ((current current-input-method)
          (modifiers '(nil (control) (meta) (control meta))))
      (when input-method
        (activate-input-method input-method))
      (when (and current-input-method quail-keyboard-layout)
        (dolist (map (cdr (quail-map)))
          (let* ((to (car map))
                 (from (quail-get-translation
                        (cadr map) (char-to-string to) 1)))
            (when (and (characterp from) (characterp to))
              (dolist (mod modifiers)
                (define-key local-function-key-map
                  (vector (append mod (list from)))
                  (vector (append mod (list to)))))))))
      (when input-method
        (activate-input-method current))))
;;
(defun my/-is-interactive-frame-available ()
  (and (not noninteractive)
       (not (and (daemonp)
                 (null (cdr (frame-list)))
                 (eq (selected-frame) terminal-frame)))))
;;
(defmacro* my/-exec-after-interactive-frame-available ((&rest captures) &rest body)
  (declare (indent defun))
  `(if (my/-is-interactive-frame-available)
       (progn ,@body)
     (lexical-let (,@(mapcar #'(lambda (c) (list c c)) captures))
       (add-hook 'after-make-frame-functions
                 #'(lambda (frame)
                     (with-selected-frame frame
                       ,@body))))))
;;
;;
(my/-exec-after-interactive-frame-available ()
                 (reverse-input-method "russian-computer")
                 (setq read-passwd-map
                       (let ((map read-passwd-map))
                         (set-keymap-parent map minibuffer-local-map)
                         (define-key map [return] #'exit-minibuffer)
                         (define-key map [backspace] #'delete-backward-char)
                         map)))
