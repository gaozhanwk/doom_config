;;; init-org.el --- Org mode settings -*- lexical-binding: t -*-
;;; Commentary:

;;; Code:

(use-package! org
  :hook (org-mode . visual-line-mode)
  :commands (org-find-exact-headline-in-buffer org-set-tags)
  :custom-face
  ;; 设置Org mode标题以及每级标题行的大小
  (org-document-title ((t (:height 1.2 :weight bold))))
  (org-level-1 ((t (:height 1.15 :weight bold))))
  (org-level-2 ((t (:height 1.1 :weight bold))))
  (org-level-3 ((t (:height 1.05 :weight bold))))
  (org-level-4 ((t (:height 1.0 :weight bold))))
  (org-level-5 ((t (:height 1.0 :weight bold))))
  (org-level-6 ((t (:height 1.0 :weight bold))))
  (org-level-7 ((t (:height 1.0 :weight bold))))
  (org-level-8 ((t (:height 1.0 :weight bold))))
  (org-level-9 ((t (:height 1.0 :weight bold))))
  ;; 设置代码块用上下边线包裹
  (org-block-begin-line ((t (:underline t :background unspecified))))
  (org-block-end-line ((t (:overline t :underline nil :background unspecified))))
  )

(use-package! org-bullets
  :hook (org-mode . org-bullets-mode))

(defun my-yank-image-from-win-clipboard-through-powershell()
  "to simplify the logic, use c:/Users/Public as temporary directoy, and move it into current directoy"
  (interactive)
  (let* ((powershell "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe")
         (file-name (format-time-string "screenshot_%Y%m%d_%H%M%S.png"))
         ;; (file-path-powershell (concat "c:/Users/\$env:USERNAME/" file-name))
         (file-path-wsl (concat "./images/" file-name))
         )
    ;; (shell-command (concat powershell " -command \"(Get-Clipboard -Format Image).Save(\\\"C:/Users/\\$env:USERNAME/" file-name "\\\")\""))
    (shell-command (concat powershell " -command \"(Get-Clipboard -Format Image).Save(\\\"C:/Users/Public/" file-name "\\\")\""))
    (rename-file (concat "/mnt/c/Users/Public/" file-name) file-path-wsl)
    (insert (concat "[[file:" file-path-wsl "]]"))
    (message "insert DONE.")
    ))

(global-set-key (kbd "<f12>") 'my-yank-image-from-win-clipboard-through-powershell)

;; wsl调用window浏览器
(defun my/browse-url-generic (url &optional _new-window)
  ;; new-window ignored
  "Ask the WWW browser defined by `browse-url-generic-program' to load URL.
Default to the URL around or before point.  A fresh copy of the
browser is started up in a new process with possible additional arguments
`browse-url-generic-args'.  This is appropriate for browsers which
don't offer a form of remote control."
  (interactive (browse-url-interactive-arg "URL: "))
  (if (not browse-url-generic-program)
      (error "No browser defined (`browse-url-generic-program')"))
  (apply 'call-process browse-url-generic-program nil
	 0 nil
	 (append browse-url-generic-args
                 (list (format "start %s"
                               (replace-regexp-in-string "&" "^&" url))))))

(when (and (eq system-type 'gnu/linux)
           (string-match
            "Linux.*Microsoft.*Linux"
            (shell-command-to-string "uname -a")))
  (setq
   browse-url-generic-program  "/mnt/c/Windows/System32/cmd.exe"
   browse-url-generic-args     '("/c")
   browse-url-browser-function #'my/browse-url-generic))


;; dnote
(use-package! denote
  :hook (dired-mode . denote-dired-mode)
  :bind (("C-c d n" . denote)
         ("C-c d f" . denote-open-or-create))
  :config
  (setq denote-directory (expand-file-name "~/org/"))
  (setq denote-known-keywords '("emacs" "android" "reading" "studying")))

(provide 'init-org)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-org.el ends here
