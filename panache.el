;;; panache.el

;; Setup
;;
;; The following is an example for a setup:
;;
;;      ;; Panache
;;      (defvar panache-dir (expand-file-name "~/.panache"))
;;      (defvar panache-lisp-dir (expand-file-name "lisp" panache-dir))
;;      (defvar panache-bin-dir (expand-file-name "bin" panache-dir))
;;      
;;      (setq load-path (cons panache-lisp-dir load-path))
;;      (require 'panache)
;;      
;;      (setq panache (expand-file-name "panache.exe" panache-bin-dir))
;;

(require 'easymenu)
(require 'markdown-mode)
(require 'panache-tables)

(defvar panache "panache" "Panache executable.")

(defvar panache-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c m") nil)
    (define-key map (kbd "C-c C-c p") nil)
    (define-key map (kbd "C-c C-c e") nil)
    (define-key map (kbd "C-c C-c v") nil)
    (define-key map (kbd "C-c C-c o") nil)
    (define-key map (kbd "C-c C-c l") nil)
    (define-key map (kbd "C-c C-c w") nil)
    (define-key map (kbd "C-c C-c c") nil)
    (define-key map (kbd "C-c C-c c") 'panache-cleanup)
    (define-key map (kbd "C-c C-c h") 'panache-compile-html)
    (define-key map (kbd "C-c C-c d") 'panache-compile-draft-html)
    (define-key map (kbd "C-c C-c p") 'panache-compile-pdf)
    (define-key map (kbd "C-c C-c v") 'panache-view-html)
    map)
  "Keymap for Panache minor mode.")

(easy-menu-define panache-mode-menu panache-mode-map
  "Menu for Panache minor mode."
  '("Panache"
    ["Cleanup" panache-cleanup]
    "---"
    [".csv -> table" panache-tables-csv-to-org-table]
    ["Toggle table" panache-tables-toggle-table]
    "---"
    ["Compile HTML"            panache-compile-html]
    ["Compile Draft HTML"      panache-compile-draft-html]
    ["Compile PDF"             panache-compile-pdf]
    "---"
    ["View HTML"               panache-view-html]
    ))

(defun panache-compile-html()
  "Compile a .html"
  (interactive)
  (panache-compile "tsihtml" ".html")
  )
(defun panache-compile-draft-html()
  "Compile a draft .html"
  (interactive)
  (panache-compile "tsihtmldraft" ".html")  
  )
(defun panache-compile-pdf()
  "Compile a .pdf"
  (interactive)
  (panache-compile "tsipdf" ".pdf")  
  )

(define-minor-mode panache-mode
  "Panache minor mode."
  :lighter " Panache"
  :keymap panache-mode-map
  )
(add-hook 'markdown-mode-hook 'panache-mode)

(defun panache-cleanup-command(start end)
  "The panache command we pass markers to."
  (let ((coding-system-for-read 'utf-8)
        (coding-system-for-write 'utf-8))
    (shell-command-on-region
     start
     end
     ;(format "%s --style mdcleanup" panache)
     ; For performance reasons, we use the command which would be generated by `panache --style mdcleanup` directly
     "panache --reference-links --standalone --atx-headers --wrap=auto --columns=80 --to=markdown_strict+pipe_tables+yaml_metadata_block+blank_before_header+header_attributes+blank_before_blockquote+fenced_code_blocks+fenced_code_attributes+definition_lists+table_captions+intraword_underscores+tex_math_dollars+raw_tex+shortcut_reference_links+bracketed_spans+auto_identifiers+link_attributes+escaped_line_breaks+bracketed_spans+link_attributes+strikeout"
     (current-buffer)
     t
     (get-buffer-create "*Panache*")
     t)))

(defun panache-cleanup (arg)
  "Panache a region or the entire buffer"
  (interactive "P")
  (let ((point (point)) (start) (end))
    (if (and mark-active transient-mark-mode)
	(setq start (region-beginning)
	      end (region-end))
      (setq start (point-min)
	    end (point-max)))
    (panache-cleanup-command start end)
    (goto-char point)))

(defun panache-compile (style extension)
"compile."
(interactive)
(let ((command
       (format "%s --style %s --input %s --output %s%s --debug"
               panache
               style
               (buffer-file-name)
               (file-name-sans-extension (buffer-file-name))
               extension
               )))
  (save-some-buffers)
  (set (make-local-variable 'compile-command) command)
  (compilation-start command nil #'(lambda (mode-name) (get-buffer-create "*Panache*")))
  ))

(defun panache-view-html ()
"View HTML-output."
(interactive)
(browse-url (format "%s.html" (file-name-sans-extension buffer-file-name))))

(provide 'panache)
