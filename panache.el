;;; panache.el

;; Setup
;;
;; The following is an example for a setup:
;;
;;      ;; Panache
;;      (defvar panache-lisp-dir (expand-file-name "~/Panache-lisp"))
;;      (setq load-path (cons panache-lisp-dir load-path))
;;      (require 'panache)
;;      
;;      (setq panache (expand-file-name "panache" "~/Panache/bin"))
;;      ;(setq panache-style-dir (expand-file-name (expand-file-name "~/.panache")))
;;      ;(setq panache-html-medium "html")
;;      ;(setq panache-draft-html-medium "drafthtml")
;;      ;(setq panache-pdf-medium "pdf")
;;      (setq panache-html-fallback-style "tsihtmlde")
;;      (setq panache-draft-html-fallback-style "tsihtmldraftde")
;;      (setq panache-pdf-fallback-style "tsipdfde")
;;      ;(setq panache-html-view-command "start \"\"") ; uses the default html viewer
;;      ;(setq panache-pdf-view-command "start \"\"") ; uses the default pdf viewer
;;      ;(setq panache-pdf-view-command "start \"\" \"C:/Program Files/MiKTeX 2.9/miktex/bin/x64/miktex-texworks.exe\"") ; uses texworks
;;      ;(setq panache-dir-view-command "start \"\"") ; uses explorer
;;      ;(setq panache-html-view-command "setsid -w /usr/bin/xdg-open") ; uses the default html viewer
;;      ;(setq panache-pdf-view-command "setsid -w /usr/bin/xdg-open") ; uses the default pdf viewer
;;      ;(setq panache-dir-view-command "setsid -w /usr/bin/xdg-open") ; uses explorer


(require 'easymenu)
(require 'markdown-mode)
(require 'panache-tables)

(defvar panache "panache" "Panache executable.")
(defvar panache-style-dir nil "Where to find the style definitions.")
(defvar panache-html-medium "html" "The medium to use for html.")
(defvar panache-draft-html-medium "drafthtml" "The medium to use for draft-html.")
(defvar panache-pdf-medium "pdf" "The medium to use for pdf.")
(defvar panache-docx-medium "docx" "The medium to use for docx.")
(defvar panache-html-fallback-style nil "Fallback style to use for html.")
(defvar panache-draft-html-fallback-style nil "Fallback style to use for draft-html.")
(defvar panache-pdf-fallback-style nil "Fallback style to use for pdf.")
(defvar panache-docx-fallback-style nil  "Fallback style to use for pdf.")
(defvar panache-html-view-command nil "Command to view html files.")
(defvar panache-pdf-view-command nil "Command to view pdf files.")
(defvar panache-docx-view-command nil "Command to view docx files.")
(defvar panache-dir-view-command nil "Command to view dir.")

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
    (define-key map (kbd "C-c c c") 'panache-cleanup)
    (define-key map (kbd "C-c c h") 'panache-compile-html)
    (define-key map (kbd "C-c c d") 'panache-compile-docx)
    (define-key map (kbd "C-c c p") 'panache-compile-pdf)
    (define-key map (kbd "C-c c t") 'panache-compile-tex)
    (define-key map (kbd "C-c C-c c") 'panache-cleanup)
    (define-key map (kbd "C-c C-c h") 'panache-compile-html)
    (define-key map (kbd "C-c C-c d") 'panache-compile-docx)
    (define-key map (kbd "C-c C-c p") 'panache-compile-pdf)
    (define-key map (kbd "C-c C-c t") 'panache-compile-tex)
    (define-key map (kbd "C-c v h") 'panache-view-html)
    (define-key map (kbd "C-c v p") 'panache-view-pdf)
    (define-key map (kbd "C-c v d") 'panache-view-docx)
    (define-key map (kbd "C-c v t") 'panache-view-tex)        
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
    ["Compile TEX"             panache-compile-tex]
    ["Compile DOCX"            panache-compile-docx]
    "---"
    ["View HTML"               panache-view-html]
    ["View PDF"                panache-view-pdf]
    ["View TEX"                panache-view-tex]
    ["View DOCX"               panache-view-docx]
    "---"
    ["View directory"          panache-view-dir]    
    ))

(defun panache-compile-html()
  "Compile a .html"
  (interactive)
  (panache-compile panache-html-medium panache-html-fallback-style ".html")
  )
(defun panache-compile-draft-html()
  "Compile a draft .html"
  (interactive)
  (panache-compile panache-draft-html-medium panache-draft-html-fallback-style ".html")  
  )
(defun panache-compile-pdf()
  "Compile a .pdf"
  (interactive)
  (panache-compile panache-pdf-medium panache-pdf-fallback-style ".pdf")  
  )
(defun panache-compile-tex()
  "Compile a .tex"
  (interactive)
  (panache-compile panache-pdf-medium panache-pdf-fallback-style ".tex")  
  )
(defun panache-compile-docx()
  "Compile a .docx"
  (interactive)
  (panache-compile panache-docx-medium panache-docx-fallback-style ".docx")  
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
     "pandoc --reference-links --standalone --atx-headers --reference-location=document --wrap=auto --columns=80 --to=markdown_strict+pipe_tables+yaml_metadata_block+blank_before_header+header_attributes+blank_before_blockquote+fenced_code_blocks+fenced_code_attributes+definition_lists+table_captions+intraword_underscores+tex_math_dollars+raw_tex+shortcut_reference_links+bracketed_spans+auto_identifiers+link_attributes+escaped_line_breaks+bracketed_spans+link_attributes+strikeout"
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

(defun panache-compile (medium fallback-style extension)
"compile."
(interactive)
(let ((command
       (format "\"%s\" %s %s %s --input=\"%s\" --output=\"%s%s\" --verbose"
               panache
	        (if panache-style-dir
                    (format "--style-dir=\"%s\"" panache-style-dir)
                  "")
                (if medium
                    (format "--medium=\"%s\"" medium)
                  "")
	        (if fallback-style
                    (format "--style=\"%s\"" fallback-style)
                  "")
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
  (let ((command
         (format "%s \"%s.html\""
                 panache-html-view-command
                 (file-name-sans-extension (buffer-file-name))
                 )))
    (start-process-shell-command command (get-buffer-create "*Panache-Viewer*") command)
    ))


(defun panache-view-pdf ()
  "View PDF-output."
  (interactive)
  (let ((command
         (format "%s \"%s.pdf\""
                 panache-docx-view-command
                 (file-name-sans-extension (buffer-file-name))
                 )))
    (start-process-shell-command command (get-buffer-create "*Panache-Viewer*") command)
    ))

(defun panache-view-docx ()
  "View PDF-output."
  (interactive)
  (let ((command
         (format "%s \"%s.docx\""
                 panache-pdf-view-command
                 (file-name-sans-extension (buffer-file-name))
                 )))
    (start-process-shell-command command (get-buffer-create "*Panache-Viewer*") command)
    ))


(defun panache-view-tex ()
  "View TEX-output."
  (interactive)
  (find-file (format "%s.tex" (file-name-sans-extension (buffer-file-name)))))

(defun panache-view-dir()
  "View dir."
  (interactive)
  (let ((command
         (format "%s \"%s\""
                 panache-dir-view-command
                 (file-name-directory (buffer-file-name))
                 )))
    (start-process-shell-command command (get-buffer-create "*Panache-Viewer*") command)
    ))


(provide 'panache)
