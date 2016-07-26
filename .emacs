;;; .emacs --- Renato Lucindo's .emacs file
;;; Commentary:

;;;;
;;;; General Functions
;;;;

;;; Code:

(defun indent-buffer ()
  "Indent hole buffer."
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))

(defun untabify-buffer ()
  "Untabify current buffer."
  (interactive)
  (untabify (point-min) (point-max)))

(defun fullscreen (&optional f)
  "Set Emacs to fullscreen mode.  Parameter F must be either 'fullscreen or 'fullbouth."
  (interactive)
  (if (featurep 'aquamacs)
      (aquamacs-toggle-full-frame)
    (set-frame-parameter f 'fullscreen (if (frame-parameter f 'fullscreen) nil 'fullboth))))

;;;;
;;;; Emacs Customizations
;;;;

(setq
 inhibit-startup-message t
 next-line-add-newlines nil
 require-final-newline t
 delete-old-versions t
 delete-auto-save-files t
 make-backup-files nil
 scroll-step 1
 scroll-preserve-screen-position t
 mouse-yank-at-point t
 search-highlight t
 compilation-scroll-output t
 apropos-do-all nil
 auto-save-interval 512
 auto-save-list-file-prefix "~/.backups/save-"
 indent-line-function 'indent-relative-maybe
 default-frame-alist (cons '(cursor-type . bar) (copy-alist default-frame-alist))
 c-default-style "ellemtel"
 tab-width 4
 c-basic-offset 4
 default-tab-width 4
 indent-tabs-mode nil)

(fset 'yes-or-no-p (symbol-function 'y-or-n-p))
(column-number-mode t)
(line-number-mode t)
(show-paren-mode t)
(ido-mode t)

(when (display-graphic-p)
  (set-scroll-bar-mode 'right)
  (tool-bar-mode 0))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(global-set-key [home]        'beginning-of-buffer)
(global-set-key [end]         'end-of-buffer)
(global-set-key [(control z)] 'undo)
(global-set-key "\C-xg"       'goto-line)
(global-set-key "\M-g"        'goto-line)
(global-set-key [f2]          'save-buffer)
(global-set-key [f7]          'compile)
(global-set-key [f11]         'fullscreen)
(global-set-key (quote [S-iso-lefttab]) (quote dabbrev-expand))
(global-set-key (quote [S-tab]) (quote dabbrev-expand))

;;;;
;;;; Extra modes via MELPA
;;;;

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar lucindo/packages
  '(neotree               ;; NERDTree for emacs: https://github.com/jaypei/emacs-neotree
    anzu                  ;; better search highlight: https://github.com/syohex/emacs-anzu
    markdown-mode
    magit
    web-mode
    expand-region         ;; context aware select regeion with "C-=": https://github.com/magnars/expand-region.el
    go-mode
    flymake-go
    company-go
    go-eldoc
    exec-path-from-shell  ;; to set GOPATH inside Emacs
    graphene))

(dolist (pkg lucindo/packages)
  (when (not (package-installed-p pkg))
    (package-install pkg)))

;; to update package list run (package-refresh-contents)

;;;;
;;;; Editing
;;;;

(global-set-key (kbd "C-=") 'er/expand-region)

(global-anzu-mode +1)

(setq linum-format " %d ")
(global-linum-mode t)

(defun lucindo/neotree-hook (_unused)
  (setq truncate-lines t)
  (linum-mode -1))
(add-hook 'neo-after-create-hook 'lucindo/neotree-hook)
(setq neo-theme (quote nerd))
(setq neo-smart-open t)

(set-fringe-mode '(1 . 0))

;; https://github.com/rdallasgray/graphene
(require 'graphene)

;;;;
;;;; Programming
;;;;

;; Golang
;;
;; source: http://dominik.honnef.co/posts/2014/12/an_incomplete_list_of_go_tools/
;; make sure to configure correctly GOPATH env
;; install:
;;    go get -u -v golang.org/x/tools/cmd/goimports
;;    go get -u -v golang.org/x/tools/cmd/oracle
;;    go get -u -v golang.org/x/tools/cmd/cover
;;    go get -u -v golang.org/x/tools/cmd/vet
;;    go get -u -v golang.org/x/tools/cmd/gorename
;;    go get -u -v golang.org/x/tools/cmd/godoc
;;    go get -u -v github.com/nsf/gocode
;; extra tools:
;;    go get -u -v golang.org/x/tools/cmd/guru
;;    go get -u -v github.com/rogpeppe/godef
;;    go get -u -v github.com/golang/lint/golint
;;    go get -u -v github.com/lukehoban/go-outline
;;    go get -u -v sourcegraph.com/sqs/goreturns
;;    go get -u -v github.com/tpng/gopkgs
;;    go get -u -v github.com/newhook/go-symbols


(exec-path-from-shell-initialize)
(exec-path-from-shell-copy-env "GOPATH")

(load "$GOPATH/src/golang.org/x/tools/cmd/oracle/oracle.el")

;; (defun setup-go-mode ()
;;   (setq gofmt-command "goimports")
;;   (add-hook 'before-save-hook 'gofmt-before-save)
;;   (if (not (string-match "go" compile-command))
;;       (set (make-local-variable 'compile-command)
;;            "go build -v && go test -v && go vet"))
;;   (local-set-key (kbd "M-.") 'godef-jump)
;;   (local-set-key (kbd "M-,") 'pop-global-mark))

;; (add-hook 'go-mode-hook 'setup-go-mode)

(add-hook 'go-mode-hook 'go-oracle-mode)

(add-hook 'go-mode-hook 'go-eldoc-setup)

(add-hook 'go-mode-hook
          (lambda ()
            (setq gofmt-command "goimports")
            (add-hook 'before-save-hook 'gofmt-before-save)
            (set (make-local-variable 'company-backends) '(company-go))
            (company-mode)))

;;;
;;; Web (HTML, CSS, JS)
;;;

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;;;;
;;;; font and window size
;;;;

(defun get-default-height ()
  (/ (- (display-pixel-height) 120)
     (frame-char-height)))

(add-to-list 'default-frame-alist '(width . 180))
(add-to-list 'default-frame-alist (cons 'height (get-default-height)))

(provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 '(custom-enabled-themes (quote (leuven))))
