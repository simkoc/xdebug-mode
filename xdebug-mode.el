The MIT License (MIT)

Copyright (c) 2017,2018 Simon Koch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
