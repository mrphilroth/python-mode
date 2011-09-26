;;; python-mode-shell-install.el --- Installing python, python3, ipython and other python shells


;; Copyright (C) 2011  Andreas Roehler

;; Author: Andreas Roehler <andreas.roehler@online.de>
;; Keywords: languages, processes, python, oop

;; Python-components-mode started from python-mode.el
;; and python.el, where Tim Peters, Barry A. Warsaw,
;; Skip Montanaro, Ken Manheimer, Dave Love and many
;; others wrote major parts. Author of ipython.el's
;; stuff merged is Alexander Schmolck.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides utilities creating python-mode commands

;;; Code:


(defcustom py-installed-shells
  '("ipython" "python2" "python3" "python2.7" "python" "jython")
  "Python-mode will generate commands opening shells mentioned here. Edit this list \w resp. to your machine. "
  :type '(repeat string)
  :group 'python)

(defun py-provide-installed-shells-commands (&optional force)
  "Reads py-installed-shells, provides commands opening these shell. "
  (interactive "P")
  (let ((force (eq 4 (prefix-numeric-value force)))
        (temp-buffer "*Python Shell Install Buffer*")
        done)
    (unless force
      (dolist (ele py-installed-shells)
        (unless (commandp (car (read-from-string ele)))
          (setq done t))))
    (when (or force done)
      (set-buffer (get-buffer-create temp-buffer))
      (erase-buffer)
      (insert ";; Commands calling installed python shells generated by python-mode's python-mode-shell-install.el.
;; Install these commands, to get it loaded next time python-mode starts.
;; Copying it onto the end of python-mode-shell-install.el should do it.
")
      (newline)
      (dolist (ele py-installed-shells)
        (if force
            (progn
              (insert (concat "(defun " ele " (&optional argprompt)
  \"Start an interactive "))
              (if (string= "ipython" ele)
                  (insert "IPython")
                (insert (capitalize ele)))
              (insert (concat " interpreter in another window.
   With optional \\\\[universal-argument] user is prompted
    for options to pass to the "))
              (if (string= "ipython" ele)
                  (insert "IPython")
                (insert (capitalize ele)))
              (insert (concat " interpreter. \"
  (interactive)
  (let ((py-shell-name \"" ele "\"))
    (py-shell argprompt)))\n\n")))
          (unless (commandp (car (read-from-string ele)))
            (insert (concat "(defun " ele " (&optional argprompt)
  \"Start an interactive "))
            (if (string= "ipython" ele)
                (insert "IPython")
              (insert (capitalize ele)))
            (insert (concat " interpreter in another window.
   With optional \\\\[universal-argument] user is prompted
    for options to pass to the "))
            (if (string= "ipython" ele)
                (insert "IPython")
              (insert (capitalize ele)))
            (insert (concat " interpreter. \"
  (interactive)
  (let ((py-shell-name \"" ele "\"))
    (py-shell argprompt)))\n\n")))))))
  (emacs-lisp-mode)
  (switch-to-buffer (current-buffer)))


(defun py-write-beginning-position-forms ()
  (interactive)
  (set-buffer (get-buffer-create "py-write-beginning-position-forms"))
  (erase-buffer)
      (dolist (ele py-shift-forms)
        (insert "
(defun py-beginning-of-" ele "-position ()
  \"Returns beginning of " ele " position. \"
  (interactive)
  (save-excursion
    (let ((erg (py-beginning-of-" ele ")))
      (when (interactive-p) (message \"%s\" erg))
      erg)))
")))

(defun py-write-end-position-forms ()
  (interactive)
  (set-buffer (get-buffer-create "py-write-end-position-forms"))
  (erase-buffer)
      (dolist (ele py-shift-forms)
        (insert "
(defun py-end-of-" ele "-position ()
  \"Returns end of " ele " position. \"
  (interactive)
  (save-excursion
    (let ((erg (py-end-of-" ele ")))
      (when (interactive-p) (message \"%s\" erg))
      erg)))
")))

(setq py-shift-forms (list "paragraph" "block" "clause" "def" "class" "line" "statement"))

(defun py-write-shift-forms ()
  " "
  (interactive)
  (set-buffer (get-buffer-create "py-shift-forms"))
  (erase-buffer)
      (dolist (ele py-shift-forms)
        (insert (concat "
\(defun py-shift-" ele "-right (&optional arg)
  \"Indent " ele " by COUNT spaces.

COUNT defaults to `py-indent-offset',
use \\[universal-argument] to specify a different value.

Returns outmost indentation reached. \"
  (interactive \"\*P\")
  (let ((erg (py-shift-forms-base \"" ele "\" (or arg py-indent-offset))))
        (when (interactive-p) (message \"%s\" erg))
    erg))

\(defun py-shift-" ele "-left (&optional arg)
  \"Dedent " ele " by COUNT spaces.

COUNT defaults to `py-indent-offset',
use \\[universal-argument] to specify a different value.

Returns outmost indentation reached. \"
  (interactive \"\*P\")
  (let ((erg (py-shift-forms-base \"" ele "\" (- (or arg py-indent-offset)))))
    (when (interactive-p) (message \"%s\" erg))
    erg))
"))
  (emacs-lisp-mode)
  (switch-to-buffer (current-buffer))))

(setq py-down-forms (list "block" "clause" "def" "class" "statement"))

(defun py-write-down-forms ()
  " "
  (interactive)
  (set-buffer (get-buffer-create "py-down-forms"))
  (erase-buffer)
      (dolist (ele py-down-forms)
        (insert (concat "
\(defun py-down-" ele " ()
  \"Goto beginning of line following end of " ele ".
  Returns position reached, if successful, nil otherwise.

A complementary command travelling left, whilst `py-end-of-" ele "' stops at right corner. \"
  (interactive)
  (let ((erg (py-end-of-" ele ")))
    (when erg
      (unless (eobp)
        (forward-line 1)
        (beginning-of-line)
        (setq erg (point))))
  (when (interactive-p) (message \"%s\" erg))
  erg))
"))
        (emacs-lisp-mode)
        (switch-to-buffer (current-buffer))))

(defun py-write-up-forms ()
  " "
  (interactive)
  (set-buffer (get-buffer-create "py-up-forms"))
  (erase-buffer)
  (dolist (ele py-down-forms)
    (insert (concat "
\(defun py-up-" ele " ()
  \"Goto end of line preceding beginning of " ele ".
  Returns position reached, if successful, nil otherwise.

A complementary command travelling right, whilst `py-beginning-of-" ele "' stops at left corner. \"
  (interactive)
  (let ((erg (py-beginning-of-" ele ")))
    (when erg
      (unless (bobp)
        (forward-line -1)
        (end-of-line)
        (skip-chars-backward \" \\t\\r\\n\\f\")
        (setq erg (point))))
  (when (interactive-p) (message \"%s\" erg))
  erg))
"))
    (emacs-lisp-mode)
    (switch-to-buffer (current-buffer))))


(provide 'python-mode-shell-install)
;;; python-mode-shell-install.el ends here
