(defvar xdebug-mode-hook nil)

(defvar xdebug-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-h" 'xdebug-hide-call-level-at-cursor)
    (define-key map "\C-s" 'xdebug-show-overlay-again)
    map)
  "Keymap for xdebug major mode")
                                           
(add-to-list 'auto-mode-alist '("\\.xt\\'" . xdebug-mode))


(defun string-is-pure-integer (string)
  (if (string-match "\\`[0-9]+\\'" string)
      t
    nil))


(defun extract-call-level ()
  (let ((line-start (point-at-bol))
        (number-end (point-at-bol)))
    (while (or (char-equal (char-after number-end) ?0)
               (char-equal (char-after number-end) ?1)
               (char-equal (char-after number-end) ?2)
               (char-equal (char-after number-end) ?3)
               (char-equal (char-after number-end) ?4)
               (char-equal (char-after number-end) ?5)
               (char-equal (char-after number-end) ?6)
               (char-equal (char-after number-end) ?7)
               (char-equal (char-after number-end) ?8)
               (char-equal (char-after number-end) ?9))
      (setq number-end (+ number-end 1)))
    (buffer-substring line-start number-end)))


(defun get-xdebug-call-level-at-cursor ()
  (let ((stack-number (extract-call-level)))
    (if (string-is-pure-integer stack-number)
        (string-to-number stack-number)
      -1)))


(defun identify-xdebug-current-call-level-start ()
  (let ((current-call-level (get-xdebug-call-level-at-cursor)))
    (while (<= current-call-level (get-xdebug-call-level-at-cursor))
      (previous-line))
    (next-line)
    (point-at-bol)))


(defun identify-xdebug-current-call-level-end ()
  (let ((current-call-level (get-xdebug-call-level-at-cursor)))
    (while (<= current-call-level (get-xdebug-call-level-at-cursor))
      (next-line))
    (previous-line)
    (point-at-eol)))


(defun hide-lines-add-overlay (start end)
  "Add an overlay from start to end and store
  the overlay in the current overlay list"
  (let ((overlay (make-overlay start end)))
    (overlay-put overlay 'display "[...]")))


(defun xdebug-hide-call-level-at-cursor ()
  "hides all lines that belong to this call
stack level or below"
  (interactive)
  (hide-lines-add-overlay
   (identify-xdebug-current-call-level-start)
   (identify-xdebug-current-call-level-end)))


(defun xdebug-show-overlay-again ()
  "unfolds the hidden call stack level at point including the lower ones"
  (interactive)
  (let ((overlays (overlays-in (point-at-bol)
                               (point-at-eol))))
    (mapcar #'delete-overlay overlays)))


(defun xdebug-mode ()
  "Major mode to view and interpret Xdebug machine readable files"
  (interactive)
  (kill-all-local-variables)
  (use-local-map xdebug-mode-map)
  (setq major-mode 'xdebug-mode)
  (setq mode-name "xdebug")
  (setq buffer-read-only t)
  (run-hooks 'xdebug-mode-hook))


(provide 'xdebug-mode)
