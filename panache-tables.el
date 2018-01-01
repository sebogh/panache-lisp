(require 'pcsv)
(require 'org-table)

(defun panache-tables-csv-to-org-table(beg end &optional delim)
  "Parse region as .csv and replace it by .org-table"
  (interactive "r")
  (if (region-active-p)
      (save-excursion
	(save-restriction
	  (let ((beg (progn
		       (goto-char (region-beginning))
		       (line-beginning-position)))
		(end (progn
		       (goto-char end)
		       (line-end-position)))
		(delim (or delim (when (called-interactively-p 'any)
				   (read-string "delimiter : " (format "%s" ","))))))
	    (narrow-to-region beg end)
	    (let ((table (concat
			  "|-\n"
			  (mapconcat 
			   (lambda (x) 
			     (concat "|"
				     (mapconcat 'identity x "|")
				     "|"))
			   (pcsv-parse-region (point-min) (point-max) delim)
			   "\n|-\n")
			  "\n|-")))
	      (kill-region (point-min) (point-max))
	      (insert table)
	      (goto-char (point-min))
	      (org-table-align)))))))

(defun panache-tables-org-to-grid-table()
  "Convert .org to .grid-table."
  (interactive)
  (save-excursion
    (save-restriction
      (let ((beg (org-table-begin))
	    (end (org-table-end)))
	(narrow-to-region beg end)
	(goto-char (point-min))
	(while (re-search-forward "|\\(-[+-]*\\)|" nil t)
	  (replace-match "+\\1+" nil nil))
	))))

(defun panache-tables-grid-to-org-table()
  "Convert .grid to .org-table."
  (interactive)
  (save-excursion
    (save-restriction
      (let ((beg (org-table-begin t))
	    (end (org-table-end t)))
	(narrow-to-region beg end)
	(goto-char (point-min))
	(while (re-search-forward "\\+\\(-[+-]*\\)\\+" nil t)
	  (replace-match "|\\1|" nil nil))
	))))

(defun panache-tables-is-org-table-p()
  "True, if this is an .org-table."
  (interactive)
  (save-excursion
    (save-restriction
      (let ((beg (org-table-begin t))
	    (end (org-table-end t)))
	(narrow-to-region beg end)
	(goto-char (point-min))
	(re-search-forward "|\\(-[+-]*\\)|" nil t)))))

(defun panache-tables-toggle-table()
  "Toggle between .grid and .org-table."
  (interactive)
  (if (panache-tables-is-org-table-p)
      (panache-tables-org-to-grid-table)
    (panache-tables-grid-to-org-table)))



(provide 'panache-tables)
