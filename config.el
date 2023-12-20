;;; config.el -*- lexical-binding: t; -*-

;; [[file:config.org::*基础配置][基础配置:3]]
(setq user-full-name "gaozhan"
      user-mail-address "gaozhan@seirobotics.net"
      org-directory "/mnt/d/JGcloud/Nutstore/org"
      )
;; 基础配置:3 ends here

;; [[file:config.org::*设置默认值][设置默认值:1]]
;;(add-hook! 'window-setup-hook #'toggle-frame-fullscreen)
(display-time-mode t)   ;开启时间状态栏

(define-key! global-map "C-s" #'+default/search-buffer)
(map! (:leader (:desc "load a saved workspace" :g "wr" #'+workspace/load))) ;; workspace load keybind

(when IS-WINDOWS
  (setq-default buffer-file-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (prefer-coding-system 'utf-8-unix))
                                    ; 将 Windows 上的编码改为 UTF-8 Unix 换行

(custom-set-variables '(delete-selection-mode t) ;; delete when you select region and modify
                      '(delete-by-moving-to-trash t) ;; delete && move to transh
                      '(inhibit-compacting-font-caches t) ;; don’t compact font caches during GC.
                      '(gc-cons-percentage 1))

(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace 1)))
                                    ; 编程模式下让结尾的空白符亮起
;; 设置默认值:1 ends here

;; [[file:config.org::*设置默认值][设置默认值:2]]
(after! general
  (general-create-definer ginshio/leader :prefix "s-y"))
;; 设置默认值:2 ends here

;; [[file:config.org::*设置默认值][设置默认值:3]]
(setq-default custom-file (expand-file-name ".custom.el" doom-private-dir))
(when (file-exists-p custom-file) (load custom-file))
;; 设置默认值:3 ends here

;; [[file:config.org::*设置默认值][设置默认值:5]]
(map! :map evil-window-map
      "SPC" #'rotate-layout
      ;; 方向
      "<left>"   #'evil-window-left
      "<down>"   #'evil-window-down
      "<up>"     #'evil-window-up
      "<right>"  #'evil-window-right
      ;; 交换窗口
      "C-<left>"   #'+evil/window-move-left
      "C-<down>"   #'+evil/window-move-down
      "C-<up>"     #'+evil/window-move-up
      "C-<right>"  #'+evil/window-move-right
      )
;; 设置默认值:5 ends here

;; [[file:config.org::*设置默认值][设置默认值:6]]
(setq org-modules-loaded t)
;; 设置默认值:6 ends here

;; [[file:config.org::*字体设置][字体设置:1]]
;; TODO
;; 字体设置:1 ends here

;; [[file:config.org::*主题和 modeline][主题和 modeline:2]]
(setq doom-theme 'doom-vibrant)
;; 主题和 modeline:2 ends here

;; [[file:config.org::*主题和 modeline][主题和 modeline:3]]
(after! doom-modeline
  (custom-set-variables '(doom-modeline-buffer-file-name-style 'relative-to-project)
                        '(doom-modeline-major-mode-icon t)
                        '(doom-modeline-modal-icon nil))
  (nyan-mode t))
;; 主题和 modeline:3 ends here

;; [[file:config.org::*杂项][杂项:1]]
;;(setq display-line-numbers-type 'relative)
(setq display-line-numbers-type t)
;; 杂项:1 ends here

;; [[file:config.org::*杂项][杂项:2]]
(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom")
;; 杂项:2 ends here

;; [[file:config.org::*窗口标题][窗口标题:1]]
(setq! frame-title-format
      '("%b – Doom Emacs"
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format "  -  [%s]" project-name))))))
;; 窗口标题:1 ends here

;; [[file:config.org::*截图][截图:1]]
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
;; 截图:1 ends here

;; [[file:config.org::*浏览器][浏览器:1]]
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
;; 浏览器:1 ends here

;; [[file:config.org::*rg && find][rg && find:1]]
;; 设置 ripgrep 命令
;; 打开文件后默认可编辑
(setq-default buffer-read-only nil)
(setq grep-command "rg -u --no-heading -n ")
;; rg && find:1 ends here

;; [[file:config.org::*Spell Check][Spell Check:1]]
(set-company-backend!
  '(text-mode
    markdown-mode
    gfm-mode)
  '(:seperate
    company-ispell
    company-files
    company-yasnippet))
;; Spell Check:1 ends here

;; [[file:config.org::*iedit 多行编辑工具][iedit 多行编辑工具:2]]
(use-package! iedit :defer t)
;; iedit 多行编辑工具:2 ends here

;; [[file:config.org::*hungry delete][hungry delete:2]]
(use-package! hungry-delete
  :config
  (setq-default hungry-delete-chars-to-skip " \t\v")
  (add-hook! 'after-init-hook #'global-hungry-delete-mode))
;; hungry delete:2 ends here

;; [[file:config.org::*Completion][Completion:1]]
(after! company
  (setq! company-idle-delay 0.3
         company-minimum-prefix-length 2
         company-show-numbers t)
  ) ;; make aborting less annoying.
;; Completion:1 ends here

;; [[file:config.org::*Completion][Completion:2]]
(setq-default history-length 1024
              prescient-history-length 1024)
;; Completion:2 ends here

;; [[file:config.org::*Completion][Completion:3]]
(custom-set-variables '(company-show-numbers t))
;; Completion:3 ends here

;; [[file:config.org::*LSP][LSP:1]]
(after! lsp-ui
  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-update-mode 'line

        lsp-ui-peek-enable t
        lsp-ui-peek-always-show t

        lsp-ui-doc-enable t
        lsp-ui-doc-use-childframe t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-delay 0.5
        ))
;; LSP:1 ends here

;; [[file:config.org::*提示区域][提示区域:1]]
(after! tramp
  (setenv "SHELL" "/bin/bash")
  (setq tramp-auto-save-directory "~/tmp/tramp/")
  (setq tramp-chunksize 2000)
  (setq tramp-shell-prompt-pattern
        "\\(?:^\\|
\\)[^]#$%>\n]*#?[]#$%>] *\\(\\[[0-9;]*[a-zA-Z] *\\)*"))  ;; default + 
;; 提示区域:1 ends here

;; [[file:config.org::*Guix][Guix:1]]
(after! tramp
  (appendq! tramp-remote-path
            '("~/.guix-profile/bin" "~/.guix-profile/sbin"
              "/run/current-system/profile/bin"
              "/run/current-system/profile/sbin")))
;; Guix:1 ends here

;; [[file:config.org::*YASnippet][YASnippet:1]]
(setq yas-triggers-in-field t)
;; YASnippet:1 ends here

;; [[file:config.org::*Screenshot][Screenshot:2]]
(use-package! screenshot :defer t)
;; Screenshot:2 ends here

;; [[file:config.org::*rime][rime:2]]
(use-package! rime
  :config
  (setq rime-user-data-dir "~/.config/fcitx/rime")
  (setq rime-posframe-properties
      (list :background-color "#333333"
            :foreground-color "#dcdccc"
            :font "SimSun"
            :internal-border-width 10))
  (setq default-input-method "rime"
      rime-show-candidate 'posframe)
  (setq rime-translate-keybindings
        '("C-f" "C-b" "C-n" "C-p" "C-g" "<left>" "<right>" "<up>" "<down>" "<prior>" "<next>" "<delete>"))
  :bind
  (:map rime-mode-map
        ("C-`" . 'rime-send-keybinding))
  )
;; rime:2 ends here

;; [[file:config.org::*denote][denote:2]]
(use-package denote
  :bind
  ;(("C-c n n" . denote)
   ;("C-c n i" . denote-link-or-create)
   ;("C-c n I" . denote-link)
   ;("C-c n b" . denote-link-backlinks)
   ;("C-c n a" . denote-add-front-matter)
   ;("C-c n r" . denote-rename-file)
   ;("C-c n R" . denote-rename-file-using-front-matter)
   ;)
)

(setq denote-directory (expand-file-name "/mnt/d/JGcloud/Nutstore/org")
      denote-infer-keywords t
      denote-sort-keywords t
      denote-allow-multi-word-keywords t
      denote-date-prompt-use-org-read-date t
      denote-link-fontify-backlinks t
      denote-front-matter-date-format 'org-timestamp
      denote-prompts '(title keywords))
;; denote:2 ends here

;; [[file:config.org::*org-roam][org-roam:2]]
(use-package! org-roam
  :after org
  :commands
  (org-roam-buffer
   org-roam-setup
   org-roam-capture
   org-roam-node-find)
  :config
  (setq org-roam-directory "/mnt/d/JGcloud/Nutstore/org/")
  ;;(setq org-roam-mode-sections
  ;;      (list #'org-roam-backlinks-insert-section
  ;;            #'org-roam-reflinks-insert-section
  ;;            #'org-roam-unlinked-references-insert-section))
  (org-roam-setup))
;; org-roam:2 ends here

;; [[file:config.org::*为以前非org-roam 创建的笔记创建头部ID][为以前非org-roam 创建的笔记创建头部ID:1]]
(defun my/add-id-each-org-file-in-dir ()
  " 为笔记目录下的所有org 文件加上ID 以便 roam 索引"
  (interactive)
  (let* ((roam-dir (expand-file-name "/mnt/d/JGcloud/Nutstore/org/"))
         all-org-files
         file-content)
    ;; (message "roam-dir : %s" roam-dir)
    (setq all-org-files (directory-files-recursively roam-dir (rx ".org" eos)))
    (dolist (each-file all-org-files)
      ;; (dolist (each-file (cl-subseq all-org-files 1 4))
      ;; (message "each-file : %s" each-file)
      (setq file-content (f-read-text each-file))
      ;; 跳过org 中的头部的注释  抄自 org-roam-strip-comments
      (setq file-content  (with-temp-buffer
                            (insert file-content)
                            (goto-char (point-min))
                            (while (not (eobp))
                              (if (org-at-comment-p)
                                  (delete-region (point-at-bol) (progn (forward-line) (point)))
                                (forward-line)))
                            (buffer-string)))

      ;; 判断是否有ID 头 如果没有就创建
      ;; :PROPERTIES:
      ;; :ID:       6ad2b2ed-6961-4db9-852d-06523d0a5c43
      ;; :END:
      (unless (or (string-match "\*.*\n:PROPERTIES:\n:ID:.*\n:END:" (s-left 400 file-content)) (string-match ":PROPERTIES:\n:ID:.*\n:END:" (s-left 200 file-content)))   ;; string-match 不匹配换行符 一定要加上换行符才行
        (message "%s insert ID" each-file)
        (find-file each-file)
        (goto-char (point-min))
        (org-id-store-link)
        (save-buffer)
        (kill-buffer)))))
;; 为以前非org-roam 创建的笔记创建头部ID:1 ends here

;; [[file:config.org::*Nyan][Nyan:2]]
(use-package! nyan-mode
  :config
  (setq nyan-animate-nyancat t
        nyan-wavy-trail t
        nyan-cat-face-number 4
        nyan-bar-length 16
        nyan-minimum-window-width 64)
  (add-hook! 'doom-modeline-hook #'nyan-mode))
;; Nyan:2 ends here

;; [[file:config.org::*Eros][Eros:1]]
(setq eros-eval-result-prefix "⟹ ") ; default =>
;; Eros:1 ends here

;; [[file:config.org::*Tabs][Tabs:1]]
(after! centaur-tabs
  (setq! centaur-tabs-style "bar"
         centaur-tabs-set-icons t
         centaur-tabs-plain-icons nil
         centaur-tabs-set-modified-marker t
         centaur-tabs-show-navigation-buttons nil
         centaur-tabs-gray-out-icons 'buffer
         centaur-tabs-set-bar 'under
         x-underline-at-descent-line t
         centaur-tabs-label-fixed-length 9)
  (defun centaur-tabs-hide-tab (x)
    "Do no to show buffer X in tabs."
    (let ((name (format "%s" x)))
      (or
       ;; Current window is not dedicated window.
       (window-dedicated-p (selected-window))
       ;; Buffer name not match below blacklist.
       (string-prefix-p "*epc" name)
       (string-prefix-p "*helm" name)
       (string-prefix-p "*Helm" name)
       (string-prefix-p "*Compile-Log*" name)
       (string-prefix-p "*lsp" name)
       (string-prefix-p "*company" name)
       (string-prefix-p "*Flycheck" name)
       (string-prefix-p "*tramp" name)
       (string-prefix-p " *Mini" name)
       (string-prefix-p "*help" name)
       (string-prefix-p "*straight" name)
       (string-prefix-p " *temp" name)
       (string-prefix-p "*Help" name)
       (string-prefix-p "*mybuf" name)
       (string-prefix-p "► Doom" name)
       ;; Is not magit buffer.
       (and (string-prefix-p "magit" name)
            (not (file-name-extension name)))
       )))
  (centaur-tabs-group-by-projectile-project)
  (centaur-tabs-mode t))
;; Tabs:1 ends here

;; [[file:config.org::*Tabs][Tabs:2]]
(map! :map ctl-x-map
      :prefix ("t" . "Tab and Treemacs")
      "a"   #'centaur-tabs-select-beg-tab
      "e"   #'centaur-tabs-select-end-tab
      "f"   #'centaur-tabs-forward-tab
      "F"   #'centaur-tabs-forward-group
      "b"   #'centaur-tabs-backward-tab
      "B"   #'centaur-tabs-backward-group
      "g"   #'centaur-tabs-switch-group
      "G"   #'centaur-tabs-toggle-groups
      "l"   #'centaur-tabs-move-current-tab-to-left
      "r"   #'centaur-tabs-move-current-tab-to-right
      "k"   #'centaur-tabs-kill-other-buffers-in-current-group
      "K"   #'centaur-tabs-kill-unmodified-buffers-in-current-group
      "C-5" #'centaur-tabs-extract-window-to-new-frame
      "C-o" #'centaur-tabs-open-in-external-application
      "C-d" #'centaur-tabs-open-directory-in-external-application
      )
;; Tabs:2 ends here

;; [[file:config.org::*Treemacs][Treemacs:1]]
(after! treemacs
  (setq! doom-themes-treemacs-theme               "doom-colors"
         treemacs-deferred-git-apply-delay        0.5
         treemacs-directory-name-transformer      #'identity
         treemacs-display-in-side-window          t
         treemacs-file-event-delay                1000
         treemacs-file-follow-delay               0.1
         treemacs-file-name-transformer           #'identity
         treemacs-hide-dot-git-directory          t
         treemacs-indent-guide-style              'block
         treemacs-show-hidden-files               t)
  (treemacs-indent-guide-mode t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-git-mode 'deferred)
  (treemacs-hide-gitignored-files-mode t)
  )
;; Treemacs:1 ends here

;; [[file:config.org::*Treemacs][Treemacs:2]]
(map! :map ctl-x-map
      :prefix "t"
      "0"   #'treemacs-select-window
      "1"   #'treemacs-delete-other-windows
      "d"   #'treemacs-select-directory
      "C-e" #'treemacs-edit-workspaces
      "C-f" #'treemacs-find-file
      "C-t" #'treemacs-find-tag
      )
;; Treemacs:2 ends here

;; [[file:config.org::*hl todo][hl todo:1]]
(custom-set-variables
 '(hl-todo-keyword-faces '(("NOTE" font-lock-builtin-face bold) ;; needs discussion or further investigation.
                           ("REVIEW" font-lock-keyword-face bold) ;; review was conducted.
                           ("HACK" font-lock-variable-name-face bold) ;; workaround a known problem.
                           ("DEPRECATED" region bold) ;; why it was deprecated and to suggest an alternative.
                           ("XXX+" font-lock-constant-face bold) ;; warn other programmers of problematic or misguiding code.
                           ("TODO" font-lock-function-name-face bold) ;; tasks/features to be done.
                           ("FIXME" font-lock-warning-face bold) ;; problematic or ugly code needing refactoring or cleanup.
                           ("KLUDGE" font-lock-preprocessor-face bold )
                           ("BUG" error bold) ;; a known bug that should be corrected.
                           )))
;; hl todo:1 ends here

;; [[file:config.org::*cnfonts 字体][cnfonts 字体:2]]
(cnfonts-mode 1)
;; cnfonts 字体:2 ends here

;; [[file:config.org::*ANSI 色彩][ANSI 色彩:1]]
(after! text-mode
  (add-hook! 'text-mode-hook
    (unless (derived-mode-p 'org-mode)
      ;; Apply ANSI color codes
      (with-silent-modifications
        (ansi-color-apply-on-region (point-min) (point-max) t)))))
;; ANSI 色彩:1 ends here

;; [[file:config.org::*无行号边距][无行号边距:1]]
(defvar +text-mode-left-margin-width 1
  "The `left-margin-width' to be used in `text-mode' buffers.")

(defun +setup-text-mode-left-margin ()
  (when (and (derived-mode-p 'text-mode)
             (eq (current-buffer) ; Check current buffer is active.
                 (window-buffer (frame-selected-window))))
    (setq left-margin-width (if display-line-numbers
                                0 +text-mode-left-margin-width))
    (set-window-buffer (get-buffer-window (current-buffer))
                       (current-buffer))))
;; 无行号边距:1 ends here

;; [[file:config.org::*无行号边距][无行号边距:2]]
(add-hook 'window-configuration-change-hook #'+setup-text-mode-left-margin)
(add-hook 'display-line-numbers-mode-hook #'+setup-text-mode-left-margin)
(add-hook 'text-mode-hook #'+setup-text-mode-left-margin)
;; 无行号边距:2 ends here

;; [[file:config.org::*无行号边距][无行号边距:3]]
(defadvice! +doom/toggle-line-numbers--call-hook-a ()
  :after #'doom/toggle-line-numbers
  (run-hooks 'display-line-numbers-mode-hook))
;; 无行号边距:3 ends here

(after! org
  (setq! org-use-property-inheritance t         ; it's convenient to have properties inherited
       org-log-done 'time                     ; having the time a item is done sounds convenient
       org-list-allow-alphabetical t          ; have a. A. a) A) list bullets
       ;; org-export-in-background t             ; run export processes in external emacs process
       org-catch-invisible-edits 'smart       ; try not to accidently do weird stuff in invisible regions
       org-export-with-sub-superscripts '{}   ; don't treat lone _ / ^ as sub/superscripts, require _{} / ^{}
       org-image-actual-width '(0.9)          ; Make the in-buffer display closer to the exported result..
       )
(map! :map org-mode-map
      :leader
      :desc "zero-width-space" "SPC" (cmd! (insert "\u200B")))
(defun +org-export-remove-zero-width-space (text _backend _info)
  "Remove zero width spaces from TEXT."
  (unless (org-export-derived-backend-p 'org)
    (replace-regexp-in-string "\u200B" "" text)))

(after! ox
  (add-to-list 'org-export-filter-final-output-functions #'+org-export-remove-zero-width-space t))
(use-package! org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  ;;(setq org-modern-star '("♇" "♆" "♅" "♄" "♃" "♂" "♀" "☿")
  (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-list '((43 . "➤")
                          (45 . "–")
                          (42 . "•"))
        org-modern-todo-faces '(("TODO" :inverse-video t :inherit org-todo)
                                ("PROJ" :inverse-video t :inherit +org-todo-project)
                                ("STRT" :inverse-video t :inherit +org-todo-active)
                                ("[-]"  :inverse-video t :inherit +org-todo-active)
                                ("HOLD" :inverse-video t :inherit +org-todo-onhold)
                                ("WAIT" :inverse-video t :inherit +org-todo-onhold)
                                ("[?]"  :inverse-video t :inherit +org-todo-onhold)
                                ("KILL" :inverse-video t :inherit +org-todo-cancel)
                                ("NO"   :inverse-video t :inherit +org-todo-cancel))
        org-modern-footnote (cons nil (cadr org-script-display))
        org-modern-progress nil
        org-modern-priority nil
        org-modern-horizontal-rule (make-string 36 ?─)

        org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-hide-emphasis-markers t

        org-agenda-tags-column  0
        org-agenda-block-separator ?─
        org-agenda-time-grid '((daily today require-timed)
                               (800 1000 1200 1400 1600 1800 2000)
                               " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string "⭠ now ─────────────────────────────────────────────────"
        )
  (custom-set-faces! '(org-modern-statistics :inherit org-checkbox-statistics-todo)))
(after! spell-fu
  (cl-pushnew 'org-modern-tag (alist-get 'org-mode +spell-excluded-faces-alist)))
(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))
(setq! org-ellipsis " ▾ "
       org-hide-leading-stars t
       org-priority-highest ?A
       org-priority-lowest ?E
       org-priority-faces
       '((?A . 'all-the-icons-red)
         (?B . 'all-the-icons-orange)
         (?C . 'all-the-icons-yellow)
         (?D . 'all-the-icons-green)
         (?E . 'all-the-icons-blue)))
(setq org-inline-src-prettify-results '("⟨" . "⟩"))
(setq doom-themes-org-fontify-special-tags nil)
(setq! org-export-headline-levels 5)
(require 'ox-extra)
(ox-extras-activate '(ignore-headlines))
(setq org-export-creator-string
      (format "Emacs %s (Org mode %s–%s)" emacs-version (org-release) (org-git-version))))

(use-package! toc-org
  :defer t
  :after (:any org markdown)
  :config
  (toc-org-mode t)
  (add-hook! '(org-mode-hook markdown-mode-hook) #'toc-org-mode)
  (define-key! org-mode-map "C-c C-i" #'toc-org-insert-toc)
  (define-key! markdown-mode-map "C-c M-t" #'toc-org-insert-toc))

(use-package! org-pandoc-import
  :after org)

(defvar org-agenda-dir (concat org-directory "/" "agenda"))
(defvar org-agenda-todo-file (expand-file-name "todo.org" org-agenda-dir))
(defvar org-agenda-project-file (expand-file-name "project.org" org-agenda-dir))
(after! org-agenda
  ;;urgancy|soon|as soon as possible|at some point|eventually
  ;;
  (setq! org-agenda-files `(,org-agenda-todo-file
                            ,org-agenda-project-file)
         org-agenda-skip-scheduled-if-done t
         org-agenda-skip-deadline-if-done t
         org-agenda-include-deadlines t
         org-agenda-block-separator nil
         org-agenda-tags-column 100 ;; from testing this seems to be a good value
         org-agenda-compact-blocks t))

(use-package! org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  ;;(setq org-modern-star '("♇" "♆" "♅" "♄" "♃" "♂" "♀" "☿")
  (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-list '((43 . "➤")
                          (45 . "–")
                          (42 . "•"))
        org-modern-todo-faces '(("TODO" :inverse-video t :inherit org-todo)
                                ("PROJ" :inverse-video t :inherit +org-todo-project)
                                ("STRT" :inverse-video t :inherit +org-todo-active)
                                ("[-]"  :inverse-video t :inherit +org-todo-active)
                                ("HOLD" :inverse-video t :inherit +org-todo-onhold)
                                ("WAIT" :inverse-video t :inherit +org-todo-onhold)
                                ("[?]"  :inverse-video t :inherit +org-todo-onhold)
                                ("KILL" :inverse-video t :inherit +org-todo-cancel)
                                ("NO"   :inverse-video t :inherit +org-todo-cancel))
        org-modern-footnote (cons nil (cadr org-script-display))
        org-modern-progress nil
        org-modern-priority nil
        org-modern-horizontal-rule (make-string 36 ?─)

        org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-hide-emphasis-markers t

        org-agenda-tags-column  0
        org-agenda-block-separator ?─
        org-agenda-time-grid '((daily today require-timed)
                               (800 1000 1200 1400 1600 1800 2000)
                               " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string "⭠ now ─────────────────────────────────────────────────"
        )
  (custom-set-faces! '(org-modern-statistics :inherit org-checkbox-statistics-todo)))

(after! spell-fu
  (cl-pushnew 'org-modern-tag (alist-get 'org-mode +spell-excluded-faces-alist)))

(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))

(after! org-fancy-priorities
  (custom-set-variables '(org-lowest-priority ?E))
  (setq! org-fancy-priorities-list '("⚡" "↑" "↓" "☕" "❓")))

(defvar +org-plot-term-size '(1050 . 650)
  "The size of the GNUPlot terminal, in the form (WIDTH . HEIGHT).")

(after! org-plot
  (defun +org-plot-generate-theme (_type)
    "Use the current Doom theme colours to generate a GnuPlot preamble."
    (format "
fgt = \"textcolor rgb '%s'\" # foreground text
fgat = \"textcolor rgb '%s'\" # foreground alt text
fgl = \"linecolor rgb '%s'\" # foreground line
fgal = \"linecolor rgb '%s'\" # foreground alt line

# foreground colors
set border lc rgb '%s'
# change text colors of  tics
set xtics @fgt
set ytics @fgt
# change text colors of labels
set title @fgt
set xlabel @fgt
set ylabel @fgt
# change a text color of key
set key @fgt

# line styles
set linetype 1 lw 2 lc rgb '%s' # red
set linetype 2 lw 2 lc rgb '%s' # blue
set linetype 3 lw 2 lc rgb '%s' # green
set linetype 4 lw 2 lc rgb '%s' # magenta
set linetype 5 lw 2 lc rgb '%s' # orange
set linetype 6 lw 2 lc rgb '%s' # yellow
set linetype 7 lw 2 lc rgb '%s' # teal
set linetype 8 lw 2 lc rgb '%s' # violet

# border styles
set tics out nomirror
set border 3

# palette
set palette maxcolors 8
set palette defined ( 0 '%s',\
1 '%s',\
2 '%s',\
3 '%s',\
4 '%s',\
5 '%s',\
6 '%s',\
7 '%s' )
"
            (doom-color 'fg)
            (doom-color 'fg-alt)
            (doom-color 'fg)
            (doom-color 'fg-alt)
            (doom-color 'fg)
            ;; colours
            (doom-color 'red)
            (doom-color 'blue)
            (doom-color 'green)
            (doom-color 'magenta)
            (doom-color 'orange)
            (doom-color 'yellow)
            (doom-color 'teal)
            (doom-color 'violet)
            ;; duplicated
            (doom-color 'red)
            (doom-color 'blue)
            (doom-color 'green)
            (doom-color 'magenta)
            (doom-color 'orange)
            (doom-color 'yellow)
            (doom-color 'teal)
            (doom-color 'violet)))

  (defun +org-plot-gnuplot-term-properties (_type)
    (format "background rgb '%s' size %s,%s"
            (doom-color 'bg) (car +org-plot-term-size) (cdr +org-plot-term-size)))

  (setq org-plot/gnuplot-script-preamble #'+org-plot-generate-theme)
  (setq org-plot/gnuplot-term-extra #'+org-plot-gnuplot-term-properties))

(after! ox-html
  (define-minor-mode org-fancy-html-export-mode
    "Toggle my fabulous org export tweaks. While this mode itself does a little bit,
  the vast majority of the change in behaviour comes from switch statements in:
   - `org-html-template-fancier'
   - `org-html--build-meta-info-extended'
   - `org-html-src-block-collapsable'
   - `org-html-block-collapsable'
   - `org-html-table-wrapped'
   - `org-html--format-toc-headline-colapseable'
   - `org-html--toc-text-stripped-leaves'
   - `org-export-html-headline-anchor'"
    :global t
    :init-value t
    (if org-fancy-html-export-mode
        (setq org-html-style-default org-html-style-fancy
              org-html-meta-tags #'org-html-meta-tags-fancy
              org-html-checkbox-type 'html-span)
      (setq org-html-style-default org-html-style-plain
            org-html-meta-tags #'org-html-meta-tags-default
            org-html-checkbox-type 'html)))
  (defadvice! org-html-template-fancier (orig-fn contents info)
    "Return complete document string after HTML conversion.
  CONTENTS is the transcoded contents string.  INFO is a plist
  holding export options. Adds a few extra things to the body
  compared to the default implementation."
    :around #'org-html-template
    (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
        (funcall orig-fn contents info)
      (concat
       (when (and (not (org-html-html5-p info)) (org-html-xhtml-p info))
         (let* ((xml-declaration (plist-get info :html-xml-declaration))
                (decl (or (and (stringp xml-declaration) xml-declaration)
                          (cdr (assoc (plist-get info :html-extension)
                                      xml-declaration))
                          (cdr (assoc "html" xml-declaration))
                          "")))
           (when (not (or (not decl) (string= "" decl)))
             (format "%s\n"
                     (format decl
                             (or (and org-html-coding-system
                                      (fboundp 'coding-system-get)
                                      (coding-system-get org-html-coding-system 'mime-charset))
                                 "utf-8"))))))
       (org-html-doctype info)
       "\n"
       (concat "<html"
               (cond ((org-html-xhtml-p info)
                      (format
                       " xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"%s\" xml:lang=\"%s\""
                       (plist-get info :language) (plist-get info :language)))
                     ((org-html-html5-p info)
                      (format " lang=\"%s\"" (plist-get info :language))))
               ">\n")
       "<head>\n"
       (org-html--build-meta-info info)
       (org-html--build-head info)
       (org-html--build-mathjax-config info)
       "</head>\n"
       "<body>\n<input type='checkbox' id='theme-switch'><div id='page'><label id='switch-label' for='theme-switch'></label>"
       (let ((link-up (org-trim (plist-get info :html-link-up)))
             (link-home (org-trim (plist-get info :html-link-home))))
         (unless (and (string= link-up "") (string= link-home ""))
           (format (plist-get info :html-home/up-format)
                   (or link-up link-home)
                   (or link-home link-up))))
       ;; Preamble.
       (org-html--build-pre/postamble 'preamble info)
       ;; Document contents.
       (let ((div (assq 'content (plist-get info :html-divs))))
         (format "<%s id=\"%s\">\n" (nth 1 div) (nth 2 div)))
       ;; Document title.
       (when (plist-get info :with-title)
         (let ((title (and (plist-get info :with-title)
                           (plist-get info :title)))
               (subtitle (plist-get info :subtitle))
               (html5-fancy (org-html--html5-fancy-p info)))
           (when title
             (format
              (if html5-fancy
                  "<header class=\"page-header\">%s\n<h1 class=\"title\">%s</h1>\n%s</header>"
                "<h1 class=\"title\">%s%s</h1>\n")
              (if (or (plist-get info :with-date)
                      (plist-get info :with-author))
                  (concat "<div class=\"page-meta\">"
                          (when (plist-get info :with-date)
                            (org-export-data (plist-get info :date) info))
                          (when (and (plist-get info :with-date) (plist-get info :with-author)) ", ")
                          (when (plist-get info :with-author)
                            (org-export-data (plist-get info :author) info))
                          "</div>\n")
                "")
              (org-export-data title info)
              (if subtitle
                  (format
                   (if html5-fancy
                       "<p class=\"subtitle\" role=\"doc-subtitle\">%s</p>\n"
                     (concat "\n" (org-html-close-tag "br" nil info) "\n"
                             "<span class=\"subtitle\">%s</span>\n"))
                   (org-export-data subtitle info))
                "")))))
       contents
       (format "</%s>\n" (nth 1 (assq 'content (plist-get info :html-divs))))
       ;; Postamble.
       (org-html--build-pre/postamble 'postamble info)
       ;; Possibly use the Klipse library live code blocks.
       (when (plist-get info :html-klipsify-src)
         (concat "<script>" (plist-get info :html-klipse-selection-script)
                 "</script><script src=\""
                 org-html-klipse-js
                 "\"></script><link rel=\"stylesheet\" type=\"text/css\" href=\""
                 org-html-klipse-css "\"/>"))
       ;; Closing document.
       "</div>\n</body>\n</html>")))
  (setq! org-html-style-plain org-html-style-default
         org-html-htmlize-output-type 'css
         org-html-doctype "html5"
         org-html-html5-fancy t)
  
  (defun org-html-reload-fancy-style ()
    (interactive)
    (setq org-html-style-fancy
          (concat (f-read-text (expand-file-name "misc/org-export-header.html" doom-private-dir))
                  "<script>\n"
                  (f-read-text (expand-file-name "misc/org-css/main.js" doom-private-dir))
                  "</script>\n<style>\n"
                  (f-read-text (expand-file-name "misc/org-css/main.min.css" doom-private-dir))
                  "</style>"))
    (when org-fancy-html-export-mode
      (setq org-html-style-default org-html-style-fancy)))
  (org-html-reload-fancy-style)
  (defvar org-html-export-collapsed nil)
  (eval '(cl-pushnew '(:collapsed "COLLAPSED" "collapsed" org-html-export-collapsed t)
                     (org-export-backend-options (org-export-get-backend 'html))))
  (add-to-list 'org-default-properties "EXPORT_COLLAPSED")
  (defadvice! org-html-src-block-collapsable (orig-fn src-block contents info)
    "Wrap the usual <pre> block in a <details>"
    :around #'org-html-src-block
    (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
        (funcall orig-fn src-block contents info)
      (let* ((properties (cadr src-block))
             (lang (mode-name-to-lang-name
                    (plist-get properties :language)))
             (name (plist-get properties :name))
             (ref (org-export-get-reference src-block info))
             (collapsed-p (member (or (org-export-read-attribute :attr_html src-block :collapsed)
                                      (plist-get info :collapsed))
                                  '("y" "yes" "t" t "true" "all"))))
        (format
         "<details id='%s' class='code'%s><summary%s>%s</summary>
  <div class='gutter'>
  <a href='#%s'>#</a>
  <button title='Copy to clipboard' onclick='copyPreToClipbord(this)'>⎘</button>\
  </div>
  %s
  </details>"
         ref
         (if collapsed-p "" " open")
         (if name " class='named'" "")
         (concat
          (when name (concat "<span class=\"name\">" name "</span>"))
          "<span class=\"lang\">" lang "</span>")
         ref
         (if name
             (replace-regexp-in-string (format "<pre\\( class=\"[^\"]+\"\\)? id=\"%s\">" ref) "<pre\\1>"
                                       (funcall orig-fn src-block contents info))
           (funcall orig-fn src-block contents info))))))
  
  (defun mode-name-to-lang-name (mode)
    (or (cadr (assoc mode
                     '(("asymptote" "Asymptote")
                       ("awk" "Awk")
                       ("C" "C")
                       ("clojure" "Clojure")
                       ("css" "CSS")
                       ("D" "D")
                       ("ditaa" "ditaa")
                       ("dot" "Graphviz")
                       ("calc" "Emacs Calc")
                       ("emacs-lisp" "Emacs Lisp")
                       ("fortran" "Fortran")
                       ("gnuplot" "gnuplot")
                       ("haskell" "Haskell")
                       ("hledger" "hledger")
                       ("java" "Java")
                       ("js" "Javascript")
                       ("latex" "LaTeX")
                       ("ledger" "Ledger")
                       ("lisp" "Lisp")
                       ("lilypond" "Lilypond")
                       ("lua" "Lua")
                       ("matlab" "MATLAB")
                       ("mscgen" "Mscgen")
                       ("ocaml" "Objective Caml")
                       ("octave" "Octave")
                       ("org" "Org mode")
                       ("oz" "OZ")
                       ("plantuml" "Plantuml")
                       ("processing" "Processing.js")
                       ("python" "Python")
                       ("R" "R")
                       ("ruby" "Ruby")
                       ("sass" "Sass")
                       ("scheme" "Scheme")
                       ("screen" "Gnu Screen")
                       ("sed" "Sed")
                       ("sh" "shell")
                       ("sql" "SQL")
                       ("sqlite" "SQLite")
                       ("forth" "Forth")
                       ("io" "IO")
                       ("J" "J")
                       ("makefile" "Makefile")
                       ("maxima" "Maxima")
                       ("perl" "Perl")
                       ("picolisp" "Pico Lisp")
                       ("scala" "Scala")
                       ("shell" "Shell Script")
                       ("ebnf2ps" "ebfn2ps")
                       ("cpp" "C++")
                       ("abc" "ABC")
                       ("coq" "Coq")
                       ("groovy" "Groovy")
                       ("bash" "bash")
                       ("csh" "csh")
                       ("ash" "ash")
                       ("dash" "dash")
                       ("ksh" "ksh")
                       ("mksh" "mksh")
                       ("posh" "posh")
                       ("ada" "Ada")
                       ("asm" "Assembler")
                       ("caml" "Caml")
                       ("delphi" "Delphi")
                       ("html" "HTML")
                       ("idl" "IDL")
                       ("mercury" "Mercury")
                       ("metapost" "MetaPost")
                       ("modula-2" "Modula-2")
                       ("pascal" "Pascal")
                       ("ps" "PostScript")
                       ("prolog" "Prolog")
                       ("simula" "Simula")
                       ("tcl" "tcl")
                       ("tex" "LaTeX")
                       ("plain-tex" "TeX")
                       ("verilog" "Verilog")
                       ("vhdl" "VHDL")
                       ("xml" "XML")
                       ("nxml" "XML")
                       ("conf" "Configuration File"))))
        mode))
  (autoload #'highlight-numbers--turn-on "highlight-numbers")
  (add-hook 'htmlize-before-hook #'highlight-numbers--turn-on)
  (defadvice! org-html-table-wrapped (orig-fn table contents info)
    "Wrap the usual <table> in a <div>"
    :around #'org-html-table
    (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
        (funcall orig-fn table contents info)
      (let* ((name (plist-get (cadr table) :name))
             (ref (org-export-get-reference table info)))
        (format "<div id='%s' class='table'>
  <div class='gutter'><a href='#%s'>#</a></div>
  <div class='tabular'>
  %s
  </div>\
  </div>"
                ref ref
                (if name
                    (replace-regexp-in-string (format "<table id=\"%s\"" ref) "<table"
                                              (funcall orig-fn table contents info))
                  (funcall orig-fn table contents info))))))
  (defadvice! org-html--format-toc-headline-colapseable (orig-fn headline info)
    "Add a label and checkbox to `org-html--format-toc-headline's usual output,
  to allow the TOC to be a collapseable tree."
    :around #'org-html--format-toc-headline
    (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
        (funcall orig-fn headline info)
      (let ((id (or (org-element-property :CUSTOM_ID headline)
                    (org-export-get-reference headline info))))
        (format "<input type='checkbox' id='toc--%s'/><label for='toc--%s'>%s</label>"
                id id (funcall orig-fn headline info)))))
  (defadvice! org-html--toc-text-stripped-leaves (orig-fn toc-entries)
    "Remove label"
    :around #'org-html--toc-text
    (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
        (funcall orig-fn toc-entries)
      (replace-regexp-in-string "<input [^>]+><label [^>]+>\\(.+?\\)</label></li>" "\\1</li>"
                                (funcall orig-fn toc-entries))))
  (setq org-html-text-markup-alist
        '((bold . "<b>%s</b>")
          (code . "<code>%s</code>")
          (italic . "<i>%s</i>")
          (strike-through . "<del>%s</del>")
          (underline . "<span class=\"underline\">%s</span>")
          (verbatim . "<kbd>%s</kbd>")))
  (appendq! org-html-checkbox-types
            '((html-span
               (on . "<span class='checkbox'></span>")
               (off . "<span class='checkbox'></span>")
               (trans . "<span class='checkbox'></span>"))))
  (setq org-html-checkbox-type 'html-span)
  (pushnew! org-html-special-string-regexps
            '("-&gt;" . "&#8594;")
            '("&lt;-" . "&#8592;"))
  (defun org-export-html-headline-anchor (text backend info)
    (when (and (org-export-derived-backend-p backend 'html)
               (not (org-export-derived-backend-p backend 're-reveal))
               org-fancy-html-export-mode)
      (unless (bound-and-true-p org-msg-export-in-progress)
        (replace-regexp-in-string
         "<h\\([0-9]\\) id=\"\\([a-z0-9-]+\\)\">\\(.*[^ ]\\)<\\/h[0-9]>" ; this is quite restrictive, but due to `org-reference-contraction' I can do this
         "<h\\1 id=\"\\2\">\\3<a aria-hidden=\"true\" href=\"#\\2\">#</a> </h\\1>"
         text))))
  
  (add-to-list 'org-export-filter-headline-functions
               'org-export-html-headline-anchor)
  (org-link-set-parameters "Https"
                           :follow (lambda (url arg) (browse-url (concat "https:" url) arg))
                           :export #'org-url-fancy-export)
  (defun org-url-fancy-export (url _desc backend)
    (let ((metadata (org-url-unfurl-metadata (concat "https:" url))))
      (cond
       ((org-export-derived-backend-p backend 'html)
        (concat
         "<div class=\"link-preview\">"
         (format "<a href=\"%s\">" (concat "https:" url))
         (when (plist-get metadata :image)
           (format "<img src=\"%s\"/>" (plist-get metadata :image)))
         "<small>"
         (replace-regexp-in-string "//\\(?:www\\.\\)?\\([^/]+\\)/?.*" "\\1" url)
         "</small><p>"
         (when (plist-get metadata :title)
           (concat "<b>" (org-html-encode-plain-text (plist-get metadata :title)) "</b></br>"))
         (when (plist-get metadata :description)
           (org-html-encode-plain-text (plist-get metadata :description)))
         "</p></a></div>"))
       (t url))))
  (setq! org-url-unfurl-metadata--cache nil)
  (defun org-url-unfurl-metadata (url)
    (cdr (or (assoc url org-url-unfurl-metadata--cache)
             (car (push
                   (cons
                    url
                    (let* ((head-data
                            (-filter #'listp
                                     (cdaddr
                                      (with-current-buffer (progn (message "Fetching metadata from %s" url)
                                                                  (url-retrieve-synchronously url t t 5))
                                        (goto-char (point-min))
                                        (delete-region (point-min) (- (search-forward "<head") 6))
                                        (delete-region (search-forward "</head>") (point-max))
                                        (goto-char (point-min))
                                        (while (re-search-forward "<script[^\u2800]+?</script>" nil t)
                                          (replace-match ""))
                                        (goto-char (point-min))
                                        (while (re-search-forward "<style[^\u2800]+?</style>" nil t)
                                          (replace-match ""))
                                        (libxml-parse-html-region (point-min) (point-max))))))
                           (meta (delq nil
                                       (mapcar
                                        (lambda (tag)
                                          (when (eq 'meta (car tag))
                                            (cons (or (cdr (assoc 'name (cadr tag)))
                                                      (cdr (assoc 'property (cadr tag))))
                                                  (cdr (assoc 'content (cadr tag))))))
                                        head-data))))
                      (let ((title (or (cdr (assoc "og:title" meta))
                                       (cdr (assoc "twitter:title" meta))
                                       (nth 2 (assq 'title head-data))))
                            (description (or (cdr (assoc "og:description" meta))
                                             (cdr (assoc "twitter:description" meta))
                                             (cdr (assoc "description" meta))))
                            (image (or (cdr (assoc "og:image" meta))
                                       (cdr (assoc "twitter:image" meta)))))
                        (when image
                          (setq image (replace-regexp-in-string
                                       "^/" (concat "https://" (replace-regexp-in-string "//\\([^/]+\\)/?.*" "\\1" url) "/")
                                       (replace-regexp-in-string
                                        "^//" "https://"
                                        image))))
                        (list :title title :description description :image image))))
                   org-url-unfurl-metadata--cache)))))
)

(after! ox-md
  (defun org-md-latex-fragment (latex-fragment _contents info)
    "Transcode a LATEX-FRAGMENT object from Org to Markdown."
    (let ((frag (org-element-property :value latex-fragment)))
      (cond
       ((string-match-p "^\\\\(" frag)
        (concat "$" (substring frag 2 -2) "$"))
       ((string-match-p "^\\\\\\[" frag)
        (concat "$$" (substring frag 2 -2) "$$"))
       (t (message "unrecognised fragment: %s" frag)
          frag))))

  (defun org-md-latex-environment (latex-environment contents info)
    "Transcode a LATEX-ENVIRONMENT object from Org to Markdown."
    (concat "$$\n"
            (org-html-latex-environment latex-environment contents info)
            "$$\n"))

  (defun org-utf8-entity (entity _contents _info)
    "Transcode an ENTITY object from Org to utf-8.
CONTENTS are the definition itself.  INFO is a plist holding
contextual information."
    (org-element-property :utf-8 entity))

  ;; We can't let this be immediately parsed and evaluated,
  ;; because eager macro-expansion tries to call as-of-yet
  ;; undefined functions.
  ;; NOTE in the near future this shouldn't be required
  (eval
   '(dolist (extra-transcoder
             '((latex-fragment . org-md-latex-fragment)
               (latex-environment . org-md-latex-environment)
               (entity . org-utf8-entity)))
      (unless (member extra-transcoder (org-export-backend-transcoders
                                        (org-export-get-backend 'md)))
        (push extra-transcoder (org-export-backend-transcoders
                                (org-export-get-backend 'md))))))
  (defadvice! org-md-plain-text-unicode-a (orig-fn text info)
    "Locally rebind `org-html-special-string-regexps'"
    :around #'org-md-plain-text
    (let ((org-html-special-string-regexps
           '(("\\\\-" . "-")
             ("---\\([^-]\\|$\\)" . "—\\1")
             ("--\\([^-]\\|$\\)" . "–\\1")
             ("\\.\\.\\." . "…")
             ("<->" . "⟷")
             ("->" . "→")
             ("<-" . "←"))))
      (funcall orig-fn text (plist-put info :with-smart-quotes nil)))))
