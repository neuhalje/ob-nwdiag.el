;;; ob-nwdiag.el --- org-babel functions for nwdiag evaluation

;; This is a fork of ob-blockdiag

;; Copyright (C) 2021 Jens Neuhalfen
;; Copyright (C) 2017 Dmitry Moskowski

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; Author: Dmitry Moskowski / Jens Neuhalfen
;; Keywords: tools, convenience
;; Package-Version: 20220721.01
;; Package-Requires: ((emacs "24.5"))
;; Homepage: https://github.com/neuhalje/ob-nwdiag.el

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; Org-Babel support for evaluating nwdiag source code.

;;; Requirements:

;; - nwdiag :: http://nwdiag.com/en/

;;; Code:
(require 'ob)
(require 'cl-extra)
(defgroup ob-nwdiag nil "Customization for ob-nwdiag." :group 'org-babel)

(defcustom ob-nwdiag-tool
  '("nwdiag" "nwdiag3")
  "Name of the nwdiag tool. E.g. \=nwdiag3\= on Ubuntu.
The first found executable is used." :group 'ob-nwdiag :type '(repeat file))

(defcustom ob-nwdiag-debug
  nil
  "Enable debugging." :group 'ob-nwdiag :type 'boolean)

(defvar org-babel-default-header-args:nwdiag
  `(
    (:results . "file")
    (:exports . "results")
    (:tool    . ,ob-nwdiag-tool)
    (:transparency . nil)
    (:antialias . nil)
    (:font    . nil)
    (:size    . nil)
    (:type    . nil))
  "Default arguments for drawing a nwdiag image.")

(add-to-list 'org-src-lang-modes '("nwdiag" . nwdiag))

(defun org-babel-execute:nwdiag (body params)
  (let* ((file (cdr (assoc :file params)))
        (tools (cdr (assoc :tool params)))
        (tools (if (listp tools) tools (list tools)))
        (tool  (cl-some  #'executable-find tools))
        (transparency (cdr (assoc :transparency params)))
        (antialias (cdr (assoc :antialias params)))
        (font (cdr (assoc :font params)))
        (size (cdr (assoc :size params)))
        (type (cdr (assoc :type params)))
        (is-debug (or (cdr (assoc :debug params)) ob-nwdiag-debug))

        (buffer-name "*ob-nwdiag*")
        (error-template "Subprocess '%s' exited with code '%d', see output in '%s' buffer"))
    (if (not tool) (error "ob-nwdiag: Could not find an nwdiag executable in %s" tools))
    (if (not file) (error "ob-nwdiag: No ':file' set in source block %s" (nth 4 (org-babel-get-src-block-info))))
    (message "nwdiag: Using tool %s" tool)
    (save-window-excursion
      (let ((buffer (get-buffer buffer-name)))(if buffer (kill-buffer buffer-name) nil))
      (let ((data-file (org-babel-temp-file "nwdiag-input"))
            (args (append (list "-o" file)
                          (if transparency (list) (list "--no-transparency"))
                          (if antialias (list "--antialias") (list))
                          (if size (list "--size" size) (list))
                          (if font (list "--font" font) (list))
                          (if is-debug (list "--debug") (list))
                          (if type (list "-T" type) (list))))
            (buffer (get-buffer-create buffer-name)))
        (with-temp-file data-file (insert body))
        (message "Calling %s %s" tool (append args (list data-file)))
        (let
            ((exit-code (apply #'call-process tool nil buffer nil (append args (list data-file)))))
          (if (= 0 exit-code) nil (error (format error-template tool exit-code buffer-name))))))))

(provide 'ob-nwdiag)
;;; ob-nwdiag.el ends here
