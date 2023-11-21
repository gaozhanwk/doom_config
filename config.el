;;; config.el -*- lexical-binding: t; -*-

;; [[file:config.org::*基础配置][基础配置:3]]
(setq user-full-name "GinShio"
      user-mail-address "ginshio78@gmail.com"
      user-gpg-key "9E2949D214995C7E"
      org-directory "~/cyberlive"
      )
;; 基础配置:3 ends here

;; [[file:config.org::*设置默认值][设置默认值:1]]
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

;; [[file:config.org::*设置默认值][设置默认值:4]]
(map! :map ctl-x-map
      "<left>"   #'windmove-left
      "<down>"   #'windmove-down
      "<up>"     #'windmove-up
      "<right>"  #'windmove-right
      )
;; 设置默认值:4 ends here

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

(defun ginshio/doom-init-ui-misc()
  (menu-bar-mode -1)               ;; disable menu-bar
  (tab-bar-mode -1)                ;; disable tab-bar
  (setq-default cursor-type 'box)  ;; set box style cursor
  (blink-cursor-mode -1)           ;; cursor not blink
  
  (if (display-graphic-p)
      (progn
        ;; NOTE: ONLY GUI
        ;; set font
        (dolist (charset '(kana han symbol cjk-misc bopomofo gb18030))
          (set-fontset-font (frame-parameter nil 'font) charset
                            (font-spec :family "Source Han Mono")))
        (appendq! face-font-rescale-alist
                  '(("Source Han Mono" . 1.2)
                    ))
        
        ;; random banner image from bing.com, NOTE: https://emacs-china.org/t/topic/264/33
        )
    (progn
      ;; NOTE: ONLY TUI
      
      )))
(add-hook! 'doom-init-ui-hook #'ginshio/doom-init-ui-misc)

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

;; [[file:config.org::*Tramp][Tramp:1]]
(setq tramp-auto-save-directory "~/tmp/tramp/")
(setq tramp-chunksize 2000)
;; Tramp:1 ends here

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

;; [[file:config.org::*Spell Check][Spell Check:4]]
(setq! ispell-dictionary "en-custom")
;; Spell Check:4 ends here

;; [[file:config.org::*String Inflection][String Inflection:2]]
(use-package! string-inflection
  :defer t
  :init
  (map! :leader :prefix ("cS" . "naming convention")
        :desc "cycle" "~" #'string-inflection-all-cycle
        :desc "toggle" "t" #'string-inflection-toggle
        :desc "CamelCase" "c" #'string-inflection-camelcase
        :desc "downCase" "d" #'string-inflection-lower-camelcase
        :desc "kebab-case" "k" #'string-inflection-kebab-case
        :desc "under_score" "u" #'string-inflection-underscore
        :desc "Upper_Score" "_" #'string-inflection-capital-underscore
        :desc "UP_CASE" "U" #'string-inflection-upcase))
;; String Inflection:2 ends here

;; [[file:config.org::*iedit][iedit:2]]
(use-package! iedit :defer t)
;; iedit:2 ends here

;; [[file:config.org::*hungry delete][hungry delete:2]]
(use-package! hungry-delete
  :config
  (setq-default hungry-delete-chars-to-skip " \t\v")
  (add-hook! 'after-init-hook #'global-hungry-delete-mode))
;; hungry delete:2 ends here

;; [[file:config.org::*Dired][Dired:1]]
(after! dired
  (require 'dired-async)
  (define-key! dired-mode-map "RET" #'dired-find-alternate-file)
  (define-key! dired-mode-map "C" #'dired-async-do-copy)
  (define-key! dired-mode-map "H" #'dired-async-do-hardlink)
  (define-key! dired-mode-map "R" #'dired-async-do-rename)
  (define-key! dired-mode-map "S" #'dired-async-do-symlink)
  (define-key! dired-mode-map "n" #'dired-next-marked-file)
  (define-key! dired-mode-map "p" #'dired-prev-marked-file)
  (define-key! dired-mode-map "=" #'ginshio/dired-ediff-files)
  (define-key! dired-mode-map "<mouse-2>" #'dired-mouse-find-file)
  (defun ginshio/dired-ediff-files ()
    "Mark files and ediff in dired mode, you can mark 1, 2 or 3 files and diff.
see: https://oremacs.com/2017/03/18/dired-ediff/"
    (let ((files (dired-get-marked-files)))
      (cond ((= (length files) 0))
            ((= (length files) 1)
             (let ((file1 (nth 0 files))
                   (file2 (read-file-name "file: " (dired-dwim-target-directory))))
               (ediff-files file1 file2)))
            ((= (length files) 2)
             (let ((file1 (nth 0 files)) (file2 (nth 1 files)))
               (ediff-files file1 file2)))
            ((= (length files) 3)
             (let ((file1 (car files)) (file2 (nth 1 files)) (file3 (nth 2 files)))
               (ediff-files3 file1 file2 file3)))
            (t (error "no more than 3 files should be marked")))))
  (define-advice dired-do-print (:override (&optional _))
    "show/hide dotfiles in current dired
see: https://www.emacswiki.org/emacs/DiredOmitMode"
    (cond ((or (not (boundp 'dired-dotfiles-show-p)) dired-dotfiles-show-p)
           (setq-local dired-dotfiles-show-p nil)
           (dired-mark-files-regexp "^\\.")
           (dired-do-kill-lines))
          (t (revert-buffer)
             (setq-local dired-dotfiles-show-p t))))
  (define-advice dired-up-directory (:override (&optional _))
    "goto up directory in this buffer"
    (find-alternate-file ".."))
  (define-advice dired-do-compress-to (:override (&optional _))
    "Compress selected files and directories to an archive."
    (let* ((output (read-file-name "Compress to: "))
           (command-assoc (assoc output dired-compress-files-alist 'string-match))
           (files-str (mapconcat 'identity (dired-get-marked-files t) " ")))
      (when (and command-assoc (not (string= "" files-str)))
        (let ((command (format-spec (cdr command-assoc)
                                    `((?o . ,output)
                                      (?i . ,files-str)))))
          (async-start (lambda () (shell-command command)) nil))))))
;; Dired:1 ends here

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

;; [[file:config.org::*VTerm][VTerm:1]]
(setq! vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=yes")
;; VTerm:1 ends here

;; [[file:config.org::*YASnippet][YASnippet:1]]
(setq yas-triggers-in-field t)
;; YASnippet:1 ends here

;; [[file:config.org::*Screenshot][Screenshot:2]]
(use-package! screenshot :defer t)
;; Screenshot:2 ends here

;; [[file:config.org::*Ebooks][Ebooks:2]]
(use-package! calibredb
  :defer t
  :init
  (setq! calibredb-root-dir "~/library/ebooks"
         calibredb-db-dir '((expand-file-name "metadata.db" calibredb-root-dir))
         calibredb-library-alist '(("~/library/ebooks")
                                   ("~/library/papers"))
         calibredb-format-all-the-icons t)
  :config
  (map! :map calibredb-show-mode-map
        "?" #'calibredb-entry-dispatch
        "o" #'calibredb-find-file
        "O" #'calibredb-find-file-other-frame
        "V" #'calibredb-open-file-with-default-tool
        "s" #'calibredb-set-metadata-dispatch
        "e" #'calibredb-export-dispatch
        "q" #'calibredb-entry-quit
        "y" #'calibredb-yank-dispatch
        "." #'calibredb-open-dired
        [tab] #'calibredb-toggle-view-at-point
        "M-t" #'calibredb-set-metadata--tags
        "M-a" #'calibredb-set-metadata--author_sort
        "M-A" #'calibredb-set-metadata--authors
        "M-T" #'calibredb-set-metadata--title
        "M-c" #'calibredb-set-metadata--comments)
  (map! :map calibredb-search-mode-map
        [mouse-3] #'calibredb-search-mouse
        "RET" #'calibredb-find-file
        "?" #'calibredb-dispatch
        "a" #'calibredb-add
        "A" #'calibredb-add-dir
        "c" #'calibredb-clone
        "d" #'calibredb-remove
        "D" #'calibredb-remove-marked-items
        "j" #'calibredb-next-entry
        "k" #'calibredb-previous-entry
        "l" #'calibredb-virtual-library-list
        "L" #'calibredb-library-list
        "n" #'calibredb-virtual-library-next
        "N" #'calibredb-library-next
        "p" #'calibredb-virtual-library-previous
        "P" #'calibredb-library-previous
        "s" #'calibredb-set-metadata-dispatch
        "S" #'calibredb-switch-library
        "o" #'calibredb-find-file
        "O" #'calibredb-find-file-other-frame
        "v" #'calibredb-view
        "V" #'calibredb-open-file-with-default-tool
        "." #'calibredb-open-dired
        "y" #'calibredb-yank-dispatch
        "b" #'calibredb-catalog-bib-dispatch
        "e" #'calibredb-export-dispatch
        "r" #'calibredb-search-refresh-and-clear-filter
        "R" #'calibredb-search-clear-filter
        "q" #'calibredb-search-quit
        "m" #'calibredb-mark-and-forward
        "f" #'calibredb-toggle-favorite-at-point
        "x" #'calibredb-toggle-archive-at-point
        "h" #'calibredb-toggle-highlight-at-point
        "u" #'calibredb-unmark-and-forward
        "i" #'calibredb-edit-annotation
        "DEL" #'calibredb-unmark-and-backward
        [backtab] #'calibredb-toggle-view
        [tab] #'calibredb-toggle-view-at-point
        "M-n" #'calibredb-show-next-entry
        "M-p" #'calibredb-show-previous-entry
        "/" #'calibredb-search-live-filter
        "M-t" #'calibredb-set-metadata--tags
        "M-a" #'calibredb-set-metadata--author_sort
        "M-A" #'calibredb-set-metadata--authors
        "M-T" #'calibredb-set-metadata--title
        "M-c" #'calibredb-set-metadata--comments))
;; Ebooks:2 ends here

;; [[file:config.org::*cite][cite:1]]
(after! org-ref
  (setq! org-ref-get-pdf-filename-function 'org-ref-get-mendeley-filename))
;; cite:1 ends here

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

;; [[file:config.org::*Theme Magic][Theme Magic:3]]
(use-package! theme-magic
  :defer t
  :after +doom-dashboard
  :config
  (defadvice! theme-magic--auto-extract-16-doom-colors ()
    :override #'theme-magic--auto-extract-16-colors
    (list
     (face-attribute 'default :background)
     (doom-color 'error)
     (doom-color 'success)
     (doom-color 'type)
     (doom-color 'keywords)
     (doom-color 'constants)
     (doom-color 'functions)
     (face-attribute 'default :foreground)
     (face-attribute 'shadow :foreground)
     (doom-blend 'base8 'error 0.1)
     (doom-blend 'base8 'success 0.1)
     (doom-blend 'base8 'type 0.1)
     (doom-blend 'base8 'keywords 0.1)
     (doom-blend 'base8 'constants 0.1)
     (doom-blend 'base8 'functions 0.1)
     (face-attribute 'default :foreground))))
;; Theme Magic:3 ends here

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

;; [[file:config.org::*xkcd][xkcd:2]]
(after! xkcd
  (setq xkcd-cache-dir (expand-file-name "xkcd/" doom-cache-dir)
        xkcd-cache-latest (concat xkcd-cache-dir "latest"))
  (unless (file-exists-p xkcd-cache-dir)
    (make-directory xkcd-cache-dir)))
;; xkcd:2 ends here

;; [[file:config.org::*xkcd][xkcd:3]]
(after! org
  (org-link-set-parameters "xkcd"
                           :image-data-fun #'+org-xkcd-image-fn
                           :follow #'+org-xkcd-open-fn
                           :export #'+org-xkcd-export))

;;;###autoload
(defun ginshio/xkcd-file-info (&optional num)
  "Get xkcd image info"
  (require 'xkcd)
  (let* ((url (format "https://xkcd.com/%d/info.0.json" num))
         (json-assoc (json-read-from-string (xkcd-get-json url num))))
    `(:img ,(cdr (assoc 'img json-assoc))
      :alt ,(cdr (assoc 'alt json-assoc))
      :title ,(cdr (assoc 'title json-assoc)))))

;;;###autoload
(defun +org-xkcd-open-fn (link)
  (+org-xkcd-image-fn nil link nil))

;;;###autoload
(defun +org-xkcd-image-fn (protocol link description)
  "Get image data for xkcd num LINK"
  (let* ((xkcd-info (ginshio/xkcd-file-info (string-to-number link)))
         (img (plist-get xkcd-info :img))
         (alt (plist-get xkcd-info :alt)))
    (+org-image-file-data-fn protocol (xkcd-download img (string-to-number link)) description)))

;;;###autoload
(defun +org-xkcd-export (num desc backend _com)
  "Convert xkcd to html/LaTeX/Markdown form"
  (let* ((xkcd-info (ginshio/xkcd-file-info (string-to-number num)))
         (img (plist-get xkcd-info :img))
         (alt (plist-get xkcd-info :alt))
         (title (plist-get xkcd-info :title))
         (file (xkcd-download img (string-to-number num))))
    (cond ((org-export-derived-backend-p backend 'hugo)
           (format "{{< figure src=\"%s\" alt=\"%s\" >}}" img (subst-char-in-string ?\" ?“ alt)))
          ((org-export-derived-backend-p backend 'html)
           (format "<img class='invertible' src='%s' title=\"%s\" alt='%s'>" img (subst-char-in-string ?\" ?“ alt) title))
          ((org-export-derived-backend-p backend 'latex)
           (format "\\begin{figure}[!htb]
  \\centering
  \\includegraphics[scale=0.4]{%s}%s
\\end{figure}" file (if (equal desc (format "xkcd:%s" num)) ""
                      (format "\n  \\caption*{\\label{xkcd:%s} %s}"
                              num
                              (or desc
                                  (format "\\textbf{%s} %s" title alt))))))
          ((org-export-derived-backend-p backend 'markdown)
           (format "![%s](https://xkcd.com/%s)" (subst-char-in-string ?\" ?“ alt) num))
          (t (format "https://xkcd.com/%s" num)))))
;; xkcd:3 ends here

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
(appendq! +ligatures-extra-symbols
          (list :list_property "∷"
                :em_dash       "—"
                :ellipses      "…"
                :arrow_right   "→"
                :arrow_left    "←"
                :arrow_lr      "↔"
                :properties    "⚙"
                :end           "∎"))

(defadvice! +org-init-appearance-h--no-ligatures-a ()
  :after #'+org-init-appearance-h
  (set-ligatures! 'org-mode nil)
  (set-ligatures! 'org-mode
    :list_property "::"
    :em_dash       "---"
    :ellipsis      "..."
    :arrow_right   "->"
    :arrow_left    "<-"
    :arrow_lr      "<->"
    :properties    ":PROPERTIES:"
    :end           ":END:"))
(setq! org-highlight-latex-and-related '(native script entities))
(require 'org-src)
(add-to-list 'org-src-block-faces '("latex" (:inherit default :extend t)))
(setq! org-preview-latex-default-process 'dvisvgm
       org-preview-latex-process-alist
       '((dvipng :programs
                 ("lualatex" "dvipng")
                 :description "dvi > png" :message "you need to install the programs: latex and dvipng." :image-input-type "dvi" :image-output-type "png" :image-size-adjust
                 (1.0 . 1.0)
                 :latex-compiler
                 ("lualatex -output-format dvi -interaction nonstopmode -output-directory %o %f")
                 :image-converter
                 ("dvipng -D %D -T tight -bg Transparent -o %O %f"))
         (dvisvgm :programs
                  ("latex" "dvisvgm")
                  :description "dvi > svg" :message "you need to install the programs: latex and dvisvgm." :use-xcolor t :image-input-type "xdv" :image-output-type "svg" :image-size-adjust
                  (1.7 . 1.5)
                  :latex-compiler
                  ("xelatex -no-pdf -interaction nonstopmode -output-directory %o %f")
                  :image-converter
                  ("dvisvgm %f -n -b min -c %S -o %O"))
         (imagemagick :programs
                      ("latex" "convert")
                      :description "pdf > png" :message "you need to install the programs: latex and imagemagick." :use-xcolor t :image-input-type "pdf" :image-output-type "png" :image-size-adjust
                      (1.0 . 1.0)
                      :latex-compiler
                      ("xelatex -no-pdf -interaction nonstopmode -output-directory %o %f")
                      :image-converter
                      ("convert -density %D -trim -antialias %f -quality 100 %O"))))
(setq! org-format-latex-header "\\documentclass{article}
\\usepackage[usenames]{xcolor}
\\usepackage[T1]{fontenc}
\\usepackage{booktabs}
\\pagestyle{empty}             % do not remove
% The settings below are copied from fullpage.sty
\\setlength{\\textwidth}{\\paperwidth}
\\addtolength{\\textwidth}{-3cm}
\\setlength{\\oddsidemargin}{1.5cm}
\\addtolength{\\oddsidemargin}{-2.54cm}
\\setlength{\\evensidemargin}{\\oddsidemargin}
\\setlength{\\textheight}{\\paperheight}
\\addtolength{\\textheight}{-\\headheight}
\\addtolength{\\textheight}{-\\headsep}
\\addtolength{\\textheight}{-\\footskip}
\\addtolength{\\textheight}{-3cm}
\\setlength{\\topmargin}{1.5cm}
\\addtolength{\\topmargin}{-2.54cm}
\\usepackage{amsmath,amsxtra,mathtools,upgreek,extarrows}
\\usepackage{arev}
"
       org-format-latex-options
       (plist-put org-format-latex-options :background "Transparent"))
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

(use-package! org-crypt
  :defer t
  :after org
  :custom
  (org-crypt-key user-gpg-key)
  (org-tags-exclude-from-inheritance '("crypt")) ;; avoid repeated encryption
  :config
  (org-crypt-use-before-save-magic) ;; encrypt when writing back to the hard disk
  (map! :map org-mode-map
        :localleader
        :desc "org-encrypt" "C" nil
        :desc "encrypt current" "C e" #'org-encrypt-entry
        :desc "encrypt all" "C E" #'org-encrypt-entries
        :desc "decrypt current" "C d" #'org-decrypt-entry
        :desc "decrypt all" "C D" #'org-decrypt-entries))

(use-package! org-pandoc-import
  :after org)

(use-package! org-ol-tree
  :defer t
  :after org
  :commands org-ol-tree
  :config
  (setq org-ol-tree-ui-icon-set
        (if (and (display-graphic-p)
                 (fboundp 'all-the-icons-material))
            'all-the-icons
          'unicode))
  (org-ol-tree-ui--update-icon-set)
  (map! :map org-mode-map
        :localleader
        :desc "Outline" "O" #'org-ol-tree))

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

(after! org-capture
  (defun ginshio/find-project-tree(priority)
    "find or create project headline
https://www.zmonster.me/2018/02/28/org-mode-capture.html"
    (let* ((hl (let ((headlines (org-element-map (org-element-parse-buffer 'headline) 'headline
                                  (lambda (hl) (and (= (org-element-property :level hl) 1)
                                               (org-element-property :title hl))))))
                 (completing-read "Project Name: " headlines))))
      (goto-char (point-min))
      (if (re-search-forward
           (format org-complex-heading-regexp-format (regexp-quote hl)) nil t)
          (goto-char (point-at-bol))
        (progn
          (or (bolp) (insert "\n"))
          (if (/= (point) (point-min)) (org-end-of-subtree))
          (insert (format "* %s :project:%s:\n:properties:\n:homepage: %s\n:repo: \
%s\n:end:\n\n** urgancy :urgancy:\n\n** soon :soon:\n\n** as soon as\
 possible :asap:\n\n** at some point :asp:\n\n** eventually :eventually:\n"
                          hl hl (read-string "homepage: ") (read-string "repo: ")))
          (beginning-of-line 0)
          (org-up-heading-safe))))
    (re-search-forward
     (format org-complex-heading-regexp-format
             (regexp-quote priority))
     (save-excursion (org-end-of-subtree t t)) t)
    (org-end-of-subtree))
  (setq! org-capture-dir (expand-file-name "capture" org-directory)
         org-capture-snippet-file (expand-file-name "snippets.org" org-capture-dir)
         org-capture-comment-file (expand-file-name "comments.org" org-capture-dir)
         org-capture-note-file (expand-file-name "notes.org" org-capture-dir)
         org-capture-blog-file (expand-file-name "blogs.org" org-capture-dir)
         )
  ;; http://www.howardism.org/Technical/Emacs/journaling-org.html
  ;; https://www.zmonster.me/2018/02/28/org-mode-capture.html
  (setq org-capture-templates
        `(("B" "Blog TODO List" entry (file ,org-capture-blog-file)
           "* TODO [#%^{priority|D|A|B|C|E}] %^{blog_title}\n:properties:\n:categories: %^{categories}\n:tags: %^{tags}\n:title: %\\1\n:file_name: %^{file_name}\n:end:\n%?"
           :empty-lines 1)
          ("c" "Comment")
          ("cb" "Book" entry (file+weektree ,org-capture-comment-file)
           "* %^{book} :book:%\\1:\n%?" :empty-lines 1)
          ("cm" "Movie" entry (file+weektree ,org-capture-comment-file)
           "* %^{movie} :movie:%\\1:\n%?" :empty-lines 1)
          ("g" "GTD")
          ("gt" "Todo" entry (file+headline org-agenda-todo-file "Personal")
           "* TODO [#%^{priority|A|B|C|D|E}] %^{task}\n  SCHEDULED: %^T DEADLINE: %^T\n:properties:\n:end:\n%?"
           :empty-lines 1)
          ("gi" "Interview" entry (file+headline ,org-agenda-todo-file "Interview")
           "* WAIT [#%^{priority|B|A|C|D}] %^{company} - %^{position}\t:%\\2:\nSCHEDULED: %^T DEADLINE: %^T\n:properties:\n:url: %^{link}\n:end:\n%?"
           :prepend t :empty-lines 1)
          ("gd" "Daily" entry (file+headline ,org-agenda-todo-file "Daily")
           "* TODO [#%^{priority|C|A|B|D|E}] %^{task}\n SCHEDULED:  %<<%Y-%m-%d %a %H:%M ++1d>>\n:properties:\n:end:\n%?"
           :empty-lines 1)
          ("gw" "Weekly" entry (file+headline ,org-agenda-todo-file "Weekly")
           "* TODO [#%^{priority|B|A|C|D|E}] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M ++1w>>\n:properties:\n:end:\n%?"
           :empty-lines 1)
          ("gm" "Monthly" entry (file+headline ,org-agenda-todo-file "Monthly")
           "* TODO [#%^{priority|C|A|B|D|E}] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M ++1m>>\n:properties:\n:end:\n%?"
           :empty-lines 1)
          ("n" "Note")
          ("nc" "Computer" entry (file+headline ,org-capture-note-file "Computer")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ("ne" "Emacs" entry (file+headline ,org-capture-note-file "Emacs")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ("ng" "Game" entry (file+headline ,org-capture-note-file "Game")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ;; ("p" "Project")
          ;; ("pa" "Urgance" entry (file+function ,org-agenda-project-file
          ;;                                      (lambda () (ginshio/find-project-tree "urgancy")))
          ;;  "*** TODO [#A] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M>> DEADLINE: %^T\n    :properties:\n    :end:\n%?"
          ;;  :empty-lines 1)
          ;; ("pb" "Soon" entry (file+function ,org-agenda-project-file
          ;;                                   (lambda () (ginshio/find-project-tree "soon")))
          ;;  "*** TODO [#B] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M>> DEADLINE: %^T\n    :properties:\n    :end:\n%?"
          ;;  :empty-lines 1)
          ;; ("pc" "As Soon As Possiple" entry (file+function ,org-agenda-project-file
          ;;                                                  (lambda () (ginshio/find-project-tree "as soon as possiple")))
          ;;  "*** TODO [#C] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M>> DEADLINE: %^T\n    :properties:\n    :end:\n%?"
          ;;  :empty-lines 1)
          ;; ("pd" "At Some Point" entry (file+function ,org-agenda-project-file
          ;;                                            (lambda () (ginshio/find-project-tree "at some point")))
          ;;  "*** TODO [#D] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M>> DEADLINE: %^T\n    :properties:\n    :end:\n%?"
          ;;  :empty-lines 1)
          ;; ("pe" "Eventually" entry (file+function ,org-agenda-project-file
          ;;                                         (lambda () (ginshio/find-project-tree "eventually")))
          ;;  "*** TODO [#E] %^{task}\n SCHEDULED: %<<%Y-%m-%d %a %H:%M>> DEADLINE: %^T\n    :properties:\n    :end:\n%?"
          ;;  :empty-lines 1)
          ("s" "Code Snippet" entry (file ,org-capture-snippet-file)
           "* %^{heading} :code:%\\2:\n:properties:\n:language: %^{language}\n:end:\n\n#+begin_src %\\2\n%?\n#+end_src"
           :empty-lines 1)
          )))

(use-package! citar
  :defer t
  :after (:any org TeX markdown)
  :init
  (setq! citar-symbols
         `((file ,(all-the-icons-faicon "file-o" :face 'all-the-icons-green :v-adjust -0.1) . " ")
           (note ,(all-the-icons-material "speaker_notes" :face 'all-the-icons-blue :v-adjust -0.3) . " ")
           (link ,(all-the-icons-octicon "link" :face 'all-the-icons-orange :v-adjust 0.01) . " "))
         citar-symbol-separator "  ")
  (map! :map (org-mode-map TeX-mode-map markdown-mode-map)
        "C-c b" #'citar-insert-citation)
  (map! :map minibuffer-local-map
        "M-b" #'citar-insert-preset)
  :custom
  ;; (org-cite-global-bibliography '("~/library/ebooks/catalog.bib"
  ;;                                 "~/library/papers/catalog.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  :config
  (add-to-list 'citar-major-mode-functions
               '((gfm-mode)
                 (insert-keys . citar-markdown-insert-keys)
                 (insert-citation . citar-markdown-insert-citation)
                 (insert-edit . citar-markdown-insert-edit)
                 (key-at-point . citar-markdown-key-at-point)
                 (citation-at-point . citar-markdown-citation-at-point)
                 (list-keys . citar-markdown-list-keys))))

(use-package! org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq org-modern-star '("♇" "♆" "♅" "♄" "♃" "♂" "♀" "☿")
        ;; (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
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

(use-package! org-fragtog :hook (org-mode . org-fragtog-mode))

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
  (setq! org-html-mathjax-options
        '((path "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js" )
          (scale "1")
          (autonumber "ams")
          (multlinewidth "85%")
          (tagindent ".8em")
          (tagside "right")))
  
  (setq! org-html-mathjax-template
        "<script>
  MathJax = {
    loader: {
      load: ['[tex]/ams', '[tex]/upgreek', '[tex]/mathtools']
    },
    chtml: {
      scale: %SCALE
    },
    svg: {
      scale: %SCALE,
      fontCache: \"global\"
    },
    tex: {
      packages: {'[+]': ['ams', 'upgreek', 'mathtools']},
      tags: \"%AUTONUMBER\",
      multlineWidth: \"%MULTLINEWIDTH\",
      tagSide: \"%TAGSIDE\",
      tagIndent: \"%TAGINDENT\"
    }
  };
  </script>
  <script id=\"MathJax-script\" async
          src=\"%PATH\"></script>")
)

(after! ox-latex
  ;; org-latex-compilers = ("pdflatex" "xelatex" "lualatex"), which are the possible values for %latex
  (setq! org-latex-pdf-process '("latexmk -f -pdf -%latex -shell-escape -interaction=nonstopmode -output-directory=%o %f"))
  (defun +org-export-latex-fancy-item-checkboxes (text backend info)
    (when (org-export-derived-backend-p backend 'latex)
      (replace-regexp-in-string
       "\\\\item\\[{$\\\\\\(\\w+\\)$}\\]"
       (lambda (fullmatch)
         (concat "\\\\item[" (pcase (substring fullmatch 9 -3) ; content of capture group
                               ("square"   "\\\\checkboxUnchecked")
                               ("boxminus" "\\\\checkboxTransitive")
                               ("boxtimes" "\\\\checkboxChecked")
                               (_ (substring fullmatch 9 -3))) "]"))
       text)))
  
  (add-to-list 'org-export-filter-item-functions
               '+org-export-latex-fancy-item-checkboxes)
  (let* ((article-sections '(("\\section{%s}" . "\\section*{%s}")
                             ("\\subsection{%s}" . "\\subsection*{%s}")
                             ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                             ("\\paragraph{%s}" . "\\paragraph*{%s}")
                             ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
         (book-sections (append '(("\\chapter{%s}" . "\\chapter*{%s}"))
                                article-sections))
         (hanging-secnum-preamble "
  \\renewcommand\\sectionformat{\\llap{\\thesection\\autodot\\enskip}}
  \\renewcommand\\subsectionformat{\\llap{\\thesubsection\\autodot\\enskip}}
  \\renewcommand\\subsubsectionformat{\\llap{\\thesubsubsection\\autodot\\enskip}}
  \\makeatletter
  \\g@addto@macro\\tableofcontents{\\clearpage\\setcounter{page}{1}\\pagenumbering{arabic}}
  \\makeatother
  \\setcounter{page}{1}
  \\pagenumbering{Roman}
  ")
         (big-chap-preamble "
  \\RedeclareSectionCommand[afterindent=false, beforeskip=0pt, afterskip=0pt, innerskip=0pt]{chapter}
  \\setkomafont{chapter}{\\normalfont\\Huge}
  \\renewcommand*{\\chapterheadstartvskip}{\\vspace*{0\\baselineskip}}
  \\renewcommand*{\\chapterheadendvskip}{\\vspace*{0\\baselineskip}}
  \\renewcommand*{\\chapterformat}{%
    \\fontsize{60}{30}\\selectfont\\rlap{\\hspace{6pt}\\thechapter}}
  \\renewcommand*\\chapterlinesformat[3]{%
    \\parbox[b]{\\dimexpr\\textwidth-0.5em\\relax}{%
      \\raggedleft{{\\large\\scshape\\bfseries\\chapapp}\\vspace{-0.5ex}\\par\\Huge#3}}%
      \\hfill\\makebox[0pt][l]{#2}}
  "))
    (setcdr (assoc "article" org-latex-classes)
            `(,(concat "\\documentclass{scrartcl}" hanging-secnum-preamble)
              ,@article-sections))
    (setcdr (assoc "article" org-latex-classes)
            `(,(concat "\\documentclass{scrartcl}" hanging-secnum-preamble)
              ,@article-sections))
    (setcdr (assoc "report" org-latex-classes)
            `(,(concat "\\documentclass{scrartcl}" hanging-secnum-preamble)
              ,@article-sections))
    (setcdr (assoc "book" org-latex-classes)
            `(,(concat "\\documentclass[twoside=false]{scrbook}"
                       big-chap-preamble hanging-secnum-preamble)
              ,@book-sections)))
  
  (setq! org-latex-tables-booktabs t
         org-latex-hyperref-template "
  \\providecolor{url}{HTML}{0077bb}
  \\providecolor{link}{HTML}{882255}
  \\providecolor{cite}{HTML}{999933}
  \\hypersetup{
    pdfauthor={%a},
    pdftitle={%t},
    pdfkeywords={%k},
    pdfsubject={%d},
    pdfcreator={%c},
    pdflang={%L},
    breaklinks=true,
    colorlinks=true,
    linkcolor=link,
    urlcolor=url,
    citecolor=cite\n}
  \\urlstyle{same}
  "
         org-latex-reference-command "\\cref{%s}")
  (defvar org-latex-caption-preamble "
  \\usepackage{subcaption}
  \\usepackage[hypcap=true]{caption}
  \\setkomafont{caption}{\\sffamily\\small}
  \\setkomafont{captionlabel}{\\upshape\\bfseries}
  \\captionsetup{justification=raggedright,singlelinecheck=true}
  \\usepackage{capt-of} % required by Org
  "
    "Preamble that improves captions.")
  
  (defvar org-latex-checkbox-preamble "
  \\newcommand{\\checkboxUnchecked}{$\\square$}
  \\newcommand{\\checkboxTransitive}{\\rlap{\\raisebox{-0.1ex}{\\hspace{0.35ex}\\Large\\textbf -}}$\\square$}
  \\newcommand{\\checkboxChecked}{\\rlap{\\raisebox{0.2ex}{\\hspace{0.35ex}\\scriptsize \\ding{52}}}$\\square$}
  "
    "Preamble that improves checkboxes.")
  
  (defvar org-latex-box-preamble "
  \\ExplSyntaxOn
  \\NewCoffin\\Content
  \\NewCoffin\\SideRule
  \\NewDocumentCommand{\\defsimplebox}{O{\\ding{117}} O{0.36em} m m m}{%
    % #1 ding, #2 ding offset, #3 name, #4 colour, #5 default label
    \\definecolor{#3}{HTML}{#4}
    \\NewDocumentEnvironment{#3}{ O{#5} }
    {
      \\vcoffin_set:Nnw \\Content { \\linewidth }
      \\noindent \\ignorespaces
      \\par\\vspace{-0.7\\baselineskip}%
      \\textcolor{#3}{#1}~\\textcolor{#3}{\\textbf{##1}}%
      \\vspace{-0.8\\baselineskip}
      \\begin{addmargin}[1em]{1em}
      }
      {
      \\end{addmargin}
      \\vspace{-0.5\\baselineskip}
      \\vcoffin_set_end:
      \\SetHorizontalCoffin\\SideRule{\\color{#3}\\rule{1pt}{\\CoffinTotalHeight\\Content}}
      \\JoinCoffins*\\Content[l,t]\\SideRule[l,t](#2,-0.7em)
      \\noindent\\TypesetCoffin\\Content
      \\vspace*{\\CoffinTotalHeight\\Content}\\bigskip
      \\vspace{-2\\baselineskip}
    }
  }
  \\ExplSyntaxOff
  "
    "Preamble that provides a macro for custom boxes.")
  (defvar org-latex-italic-quotes t
    "Make \"quote\" environments italic.")
  (defvar org-latex-par-sep t
    "Vertically seperate paragraphs, and remove indentation.")
  
  (defvar org-latex-conditional-features
    '(("\\[\\[\\(?:file\\|https?\\):\\(?:[^]]\\|\\\\\\]\\)+?\\.\\(?:eps\\|pdf\\|png\\|jpeg\\|jpg\\|jbig2\\)\\]\\]\\|\\\\includegraphics[\\[{]" . image)
      ("\\[\\[\\(?:file\\|https?\\):\\(?:[^]]+?\\|\\\\\\]\\)\\.svg\\]\\]\\|\\\\includesvg[\\[{]" . svg)
      ("\\\\(\\|\\\\\\[\\|\\\\begin{\\(?:math\\|displaymath\\|equation\\|align\\|flalign\\|multiline\\|gather\\)[a-z]*\\*?}" . maths)
      ("^[ \t]*|" . table)
      ("cref:\\|\\cref{\\|\\[\\[[^\\]+\n?[^\\]\\]\\]" . cleveref)
      ("[;\\\\]?\\b[A-Z][A-Z]+s?[^A-Za-z]" . acronym)
      ("\\+[^ ].*[^ ]\\+\\|_[^ ].*[^ ]_\\|\\\\uu?line\\|\\\\uwave\\|\\\\sout\\|\\\\xout\\|\\\\dashuline\\|\\dotuline\\|\\markoverwith" . underline)
      (":float wrap" . float-wrap)
      (":float sideways" . rotate)
      ("^[ \t]*#\\+caption:\\|\\\\caption" . caption)
      ("\\[\\[xkcd:" . (image caption))
      ((and org-latex-italic-quotes "^[ \t]*#\\+begin_quote\\|\\\\begin{quote}") . italic-quotes)
      (org-latex-par-sep . par-sep)
      ("^[ \t]*\\(?:[-+*]\\|[0-9]+[.)]\\|[A-Za-z]+[.)]\\) \\[[ -X]\\]" . checkbox)
      ("^[ \t]*#\\+begin_warning\\|\\\\begin{warning}" . box-warning)
      ("^[ \t]*#\\+begin_info\\|\\\\begin{info}"       . box-info)
      ("^[ \t]*#\\+begin_notes\\|\\\\begin{notes}"     . box-notes)
      ("^[ \t]*#\\+begin_success\\|\\\\begin{success}" . box-success)
      ("^[ \t]*#\\+begin_error\\|\\\\begin{error}"     . box-error))
    "Org feature tests and associated LaTeX feature flags.
  
  Alist where the car is a test for the presense of the feature,
  and the cdr is either a single feature symbol or list of feature symbols.
  
  When a string, it is used as a regex search in the buffer.
  The feature is registered as present when there is a match.
  
  The car can also be a
  - symbol, the value of which is fetched
  - function, which is called with info as an argument
  - list, which is `eval'uated
  
  If the symbol, function, or list produces a string: that is used as a regex
  search in the buffer. Otherwise any non-nil return value will indicate the
  existance of the feature.")
  (defvar org-latex-feature-implementations
    '((image         :snippet "\\usepackage{graphicx}" :order 2)
      (svg           :snippet "\\usepackage[inkscapelatex=false]{svg}" :order 2)
      (maths         :snippet "\\usepackage{amsmath,amsxtra,amsfonts,amssymb,amsthm,mathtools,upgreek,extarrows}\n\\usepackage[math-style=ISO]{unicode-math}" :order 0.2)
      (table         :snippet "\\usepackage{longtable}\n\\usepackage{booktabs}" :order 2)
      (cleveref      :snippet "\\usepackage[capitalize]{cleveref}" :order 1) ; after bmc-maths
      (underline     :snippet "\\usepackage[normalem]{ulem}" :order 0.5)
      (float-wrap    :snippet "\\usepackage{wrapfig}" :order 2)
      (rotate        :snippet "\\usepackage{rotating}" :order 2)
      (caption       :snippet org-latex-caption-preamble :order 2.1)
      ;; (microtype     :snippet "\\usepackage[activate={true,nocompatibility},final,tracking=true,kerning=true,spacing=true,factor=2000]{microtype}\n" :order 0.1)
      (acronym       :snippet "\\newcommand{\\acr}[1]{\\protect\\textls*[110]{\\scshape #1}}\n\\newcommand{\\acrs}{\\protect\\scalebox{.91}[.84]{\\hspace{0.15ex}s}}" :order 0.4)
      (italic-quotes :snippet "\\renewcommand{\\quote}{\\list{}{\\rightmargin\\leftmargin}\\item\\relax\\em}\n" :order 0.5)
      (par-sep       :snippet "\\setlength{\\parskip}{\\baselineskip}\n\\setlength{\\parindent}{0pt}\n" :order 0.5)
      (.pifont       :snippet "\\usepackage{pifont}")
      (.xcoffins     :snippet "\\usepackage{xcoffins}")
      (checkbox      :requires .pifont :order 3
                     :snippet (concat (unless (memq 'maths features)
                                        "\\usepackage{amssymb} % provides \\square")
                                      org-latex-checkbox-preamble))
      (.fancy-box    :requires (.pifont .xcoffins) :snippet org-latex-box-preamble :order 3.9)
      (box-warning   :requires .fancy-box :snippet "\\defsimplebox{warning}{e66100}{Warning}" :order 4)
      (box-info      :requires .fancy-box :snippet "\\defsimplebox{info}{3584e4}{Information}" :order 4)
      (box-notes     :requires .fancy-box :snippet "\\defsimplebox{notes}{26a269}{Notes}" :order 4)
      (box-success   :requires .fancy-box :snippet "\\defsimplebox{success}{26a269}{\\vspace{-\\baselineskip}}" :order 4)
      (box-error     :requires .fancy-box :snippet "\\defsimplebox{error}{c01c28}{Important}" :order 4))
    "LaTeX features and details required to implement them.
  
  List where the car is the feature symbol, and the rest forms a plist with the
  following keys:
  - :snippet, which may be either
    - a string which should be included in the preamble
    - a symbol, the value of which is included in the preamble
    - a function, which is evaluated with the list of feature flags as its
      single argument. The result of which is included in the preamble
    - a list, which is passed to `eval', with a list of feature flags available
      as \"features\"
  
  - :requires, a feature or list of features that must be available
  - :when, a feature or list of features that when all available should cause this
      to be automatically enabled.
  - :prevents, a feature or list of features that should be masked
  - :order, for when ordering is important. Lower values appear first.
      The default is 0.
  - :eager, when non-nil the feature will be eagerly loaded, i.e. without being detected.")
  (defun org-latex-detect-features (&optional buffer info)
    "List features from `org-latex-conditional-features' detected in BUFFER."
    (let ((case-fold-search nil))
      (with-current-buffer (or buffer (current-buffer))
        (delete-dups
         (mapcan (lambda (construct-feature)
                   (when (let ((out (pcase (car construct-feature)
                                      ((pred stringp) (car construct-feature))
                                      ((pred functionp) (funcall (car construct-feature) info))
                                      ((pred listp) (eval (car construct-feature)))
                                      ((pred symbolp) (symbol-value (car construct-feature)))
                                      (_ (user-error "org-latex-conditional-features key %s unable to be used" (car construct-feature))))))
                           (if (stringp out)
                               (save-excursion
                                 (goto-char (point-min))
                                 (re-search-forward out nil t))
                             out))
                     (if (listp (cdr construct-feature)) (cdr construct-feature) (list (cdr construct-feature)))))
                 org-latex-conditional-features)))))
  (defun org-latex-expand-features (features)
    "For each feature in FEATURES process :requires, :when, and :prevents keywords and sort according to :order."
    (dolist (feature features)
      (unless (assoc feature org-latex-feature-implementations)
        (message "Feature %s not provided in org-latex-feature-implementations, ignoring." feature)
        (setq features (remove feature features))))
    (setq current features)
    (while current
      (when-let ((requirements (plist-get (cdr (assq (car current) org-latex-feature-implementations)) :requires)))
        (setcdr current (if (listp requirements)
                            (append requirements (cdr current))
                          (cons requirements (cdr current)))))
      (setq current (cdr current)))
    (dolist (potential-feature
             (append features (delq nil (mapcar (lambda (feat)
                                                  (when (plist-get (cdr feat) :eager)
                                                    (car feat)))
                                                org-latex-feature-implementations))))
      (when-let ((prerequisites (plist-get (cdr (assoc potential-feature org-latex-feature-implementations)) :when)))
        (setf features (if (if (listp prerequisites)
                               (cl-every (lambda (preq) (memq preq features)) prerequisites)
                             (memq prerequisites features))
                           (append (list potential-feature) features)
                         (delq potential-feature features)))))
    (dolist (feature features)
      (when-let ((prevents (plist-get (cdr (assoc feature org-latex-feature-implementations)) :prevents)))
        (setf features (cl-set-difference features (if (listp prevents) prevents (list prevents))))))
    (sort (delete-dups features)
          (lambda (feat1 feat2)
            (if (< (or (plist-get (cdr (assoc feat1 org-latex-feature-implementations)) :order) 1)
                   (or (plist-get (cdr (assoc feat2 org-latex-feature-implementations)) :order) 1))
                t nil))))
  (defun org-latex-generate-features-preamble (features)
    "Generate the LaTeX preamble content required to provide FEATURES.
  This is done according to `org-latex-feature-implementations'"
    (let ((expanded-features (org-latex-expand-features features)))
      (concat
       (format "\n%% features: %s\n" expanded-features)
       (mapconcat (lambda (feature)
                    (when-let ((snippet (plist-get (cdr (assoc feature org-latex-feature-implementations)) :snippet)))
                      (concat
                       (pcase snippet
                         ((pred stringp) snippet)
                         ((pred functionp) (funcall snippet features))
                         ((pred listp) (eval `(let ((features ',features)) (,@snippet))))
                         ((pred symbolp) (symbol-value snippet))
                         (_ (user-error "org-latex-feature-implementations :snippet value %s unable to be used" snippet)))
                       "\n")))
                  expanded-features
                  "")
       "% end features\n")))
  (defvar info--tmp nil)
  
  (defadvice! org-latex-save-info (info &optional t_ s_)
    :before #'org-latex-make-preamble
    (setq info--tmp info))
  
  (defadvice! org-splice-latex-header-and-generated-preamble-a (orig-fn tpl def-pkg pkg snippets-p &optional extra)
    "Dynamically insert preamble content based on `org-latex-conditional-preambles'."
    :around #'org-splice-latex-header
    (let ((header (funcall orig-fn tpl def-pkg pkg snippets-p extra)))
      (if snippets-p header
        (concat header
                (org-latex-generate-features-preamble (org-latex-detect-features nil info--tmp))
                "\n"))))
  (setq! org-latex-default-packages-alist
         '(("AUTO" "inputenc" t ("pdflatex"))
           ("T1" "fontenc" t ("pdflatex"))
           ("" "xcolor" nil) ; Generally useful
           ("" "hyperref" nil)))
  (defvar org-latex-default-fontset 'alegreya
    "Fontset from `org-latex-fontsets' to use by default.
  As cm (computer modern) is TeX's default, that causes nothing
  to be added to the document.
  
  If \"nil\" no custom fonts will ever be used.")
  
  (eval '(cl-pushnew '(:latex-font-set nil "fontset" org-latex-default-fontset)
                     (org-export-backend-options (org-export-get-backend 'latex))))
  (defun org-latex-fontset-entry ()
    "Get the fontset spec of the current file.
  Has format \"name\" or \"name-style\" where 'name' is one of
  the cars in `org-latex-fontsets'."
    (let ((fontset-spec
           (symbol-name
            (or (car (delq nil
                           (mapcar
                            (lambda (opt-line)
                              (plist-get (org-export--parse-option-keyword opt-line 'latex)
                                         :latex-font-set))
                            (cdar (org-collect-keywords '("OPTIONS"))))))
                org-latex-default-fontset))))
      (cons (intern (car (split-string fontset-spec "-")))
            (when (cadr (split-string fontset-spec "-"))
              (intern (concat ":" (cadr (split-string fontset-spec "-"))))))))
  
  (defun org-latex-fontset (&rest desired-styles)
    "Generate a LaTeX preamble snippet which applies the current fontset for DESIRED-STYLES."
    (let* ((fontset-spec (org-latex-fontset-entry))
           (fontset (alist-get (car fontset-spec) org-latex-fontsets)))
      (if fontset
          (concat
           (mapconcat
            (lambda (style)
              (when (plist-get fontset style)
                (concat (plist-get fontset style) "\n")))
            desired-styles
            "")
           (when (memq (cdr fontset-spec) desired-styles)
             (pcase (cdr fontset-spec)
               (:serif "\\renewcommand{\\familydefault}{\\rmdefault}\n")
               (:sans "\\renewcommand{\\familydefault}{\\sfdefault}\n")
               (:mono "\\renewcommand{\\familydefault}{\\ttdefault}\n"))))
        (error "Font-set %s is not provided in org-latex-fontsets" (car fontset-spec)))))
  (add-to-list 'org-latex-conditional-features '(org-latex-default-fontset . custom-font) t)
  (add-to-list 'org-latex-feature-implementations '(custom-font :snippet (org-latex-fontset :serif :sans :mono) :order 0) t)
  (add-to-list 'org-latex-feature-implementations '(.custom-maths-font :eager t :when (custom-font maths) :snippet (org-latex-fontset :maths) :order 0.3) t)
  (defvar org-latex-fontsets
    '((cm nil) ; computer modern
      (## nil) ; no font set
      (alegreya
       :serif "\\usepackage[osf]{Alegreya}"
       :sans "\\usepackage{AlegreyaSans}"
       :mono "\\usepackage[scale=0.88]{sourcecodepro}"
       :maths "\\usepackage{newtxsf}")
      (biolinum
       :serif "\\usepackage[osf]{libertineRoman}"
       :sans "\\usepackage[sfdefault,osf]{biolinum}"
       :mono "\\usepackage[scale=0.88]{sourcecodepro}"
       :maths "\\usepackage{newtxsf}")
      (fira
       :sans "\\usepackage[sfdefault,scale=0.85]{FiraSans}"
       :mono "\\usepackage[scale=0.80]{FiraMono}"
       :maths "\\usepackage{newtxsf} % change to firamath in future?")
      (kp
       :serif "\\usepackage{kpfonts}")
      (newpx
       :serif "\\usepackage{newpxtext}"
       :sans "\\usepackage{gillius}"
       :mono "\\usepackage[scale=0.9]{sourcecodepro}"
       :maths "\\usepackage[varbb]{newpxmath}")
      (noto
       :serif "\\usepackage[osf]{noto-serif}"
       :sans "\\usepackage[osf]{noto-sans}"
       :mono "\\usepackage[scale=0.96]{noto-mono}"
       :maths "\\usepackage{notomath}")
      (plex
       :serif "\\usepackage{plex-serif}"
       :sans "\\usepackage{plex-sans}"
       :mono "\\usepackage[scale=0.95]{plex-mono}"
       :maths "\\usepackage{newtxmath}") ; may be plex-based in future
      (source
       :serif "\\usepackage[osf,semibold]{sourceserifpro}"
       :sans "\\usepackage[osf,semibold]{sourcesanspro}"
       :mono "\\usepackage[scale=0.92]{sourcecodepro}"
       :maths "\\usepackage{newtxmath}") ; may be sourceserifpro-based in future
      (times
       :serif "\\usepackage{newtxtext}"
       :maths "\\usepackage{newtxmath}"))
    "Alist of fontset specifications.
  Each car is the name of the fontset (which cannot include \"-\").
  
  Each cdr is a plist with (optional) keys :serif, :sans, :mono, and :maths.
  A key's value is a LaTeX snippet which loads such a font.")
  (defvar org-latex-extra-special-string-regexps
    '(("<->" . "\\\\(\\\↔{}\\\\)")
      ("->" . "\\\\textrightarrow{}")
      ("<-" . "\\\\textleftarrow{}")))
  
  (defun org-latex-convert-extra-special-strings (string)
    "Convert special characters in STRING to LaTeX."
    (dolist (a org-latex-extra-special-string-regexps string)
      (let ((re (car a))
            (rpl (cdr a)))
        (setq string (replace-regexp-in-string re rpl string t)))))
  
  (defadvice! org-latex-plain-text-extra-special-a (orig-fn text info)
    "Make `org-latex-plain-text' handle some extra special strings."
    :around #'org-latex-plain-text
    (let ((output (funcall orig-fn text info)))
      (when (plist-get info :with-special-strings)
        (setq output (org-latex-convert-extra-special-strings output)))
      output))
  (defvar org-latex-cover-page 'auto
    "When t, use a cover page by default.
  When auto, use a cover page when the document's wordcount exceeds
  `org-latex-cover-page-wordcount-threshold'.
  
  Set with #+option: coverpage:{yes,auto,no} in org buffers.")
  (defvar org-latex-cover-page-wordcount-threshold 5000
    "Document word count at which a cover page will be used automatically.
  This condition is applied when cover page option is set to auto.")
  (defvar org-latex-subtitle-coverpage-format "\\\\\\bigskip\n\\LARGE\\mdseries\\itshape\\color{black!80} %s\\par"
    "Variant of `org-latex-subtitle-format' to use with the cover page.")
  (defvar org-latex-cover-page-maketitle "
  \\usepackage{tikz}
  \\usetikzlibrary{shapes.geometric}
  \\usetikzlibrary{calc}
  
  \\newsavebox\\orgicon
  \\begin{lrbox}{\\orgicon}
    \\begin{tikzpicture}[y=0.80pt, x=0.80pt, inner sep=0pt, outer sep=0pt]
      \\path[fill=black!6] (16.15,24.00) .. controls (15.58,24.00) and (13.99,20.69) .. (12.77,18.06)arc(215.55:180.20:2.19) .. controls (12.33,19.91) and (11.27,19.09) .. (11.43,18.05) .. controls (11.36,18.09) and (10.17,17.83) .. (10.17,17.82) .. controls (9.94,18.75) and (9.37,19.44) .. (9.02,18.39) .. controls (8.32,16.72) and (8.14,15.40) .. (9.13,13.80) .. controls (8.22,9.74) and (2.18,7.75) .. (2.81,4.47) .. controls (2.99,4.47) and (4.45,0.99) .. (9.15,2.41) .. controls (14.71,3.99) and (17.77,0.30) .. (18.13,0.04) .. controls (18.65,-0.49) and (16.78,4.61) .. (12.83,6.90) .. controls (10.49,8.18) and (11.96,10.38) .. (12.12,11.15) .. controls (12.12,11.15) and (14.00,9.84) .. (15.36,11.85) .. controls (16.58,11.53) and (17.40,12.07) .. (18.46,11.69) .. controls (19.10,11.41) and (21.79,11.58) .. (20.79,13.08) .. controls (20.79,13.08) and (21.71,13.90) .. (21.80,13.99) .. controls (21.97,14.75) and (21.59,14.91) .. (21.47,15.12) .. controls (21.44,15.60) and (21.04,15.79) .. (20.55,15.44) .. controls (19.45,15.64) and (18.36,15.55) .. (17.83,15.59) .. controls (16.65,15.76) and (15.67,16.38) .. (15.67,16.38) .. controls (15.40,17.19) and (14.82,17.01) .. (14.09,17.32) .. controls (14.70,18.69) and (14.76,19.32) .. (15.50,21.32) .. controls (15.76,22.37) and (16.54,24.00) .. (16.15,24.00) -- cycle(7.83,16.74) .. controls (6.83,15.71) and (5.72,15.70) .. (4.05,15.42) .. controls (2.75,15.19) and (0.39,12.97) .. (0.02,10.68) .. controls (-0.02,10.07) and (-0.06,8.50) .. (0.45,7.18) .. controls (0.94,6.05) and (1.27,5.45) .. (2.29,4.85) .. controls (1.41,8.02) and (7.59,10.18) .. (8.55,13.80) -- (8.55,13.80) .. controls (7.73,15.00) and (7.80,15.64) .. (7.83,16.74) -- cycle;
    \\end{tikzpicture}
  \\end{lrbox}
  
  \\makeatletter
  \\renewcommand\\maketitle{
    \\thispagestyle{empty}
    \\hyphenpenalty=10000 % hyphens look bad in titles
    \\renewcommand{\\baselinestretch}{1.1}
    \\let\\oldtoday\\today
    \\renewcommand{\\today}{\\LARGE\\number\\year\\\\\\large%
      \\ifcase \\month \\or Jan\\or Feb\\or Mar\\or Apr\\or May \\or Jun\\or Jul\\or Aug\\or Sep\\or Oct\\or Nov\\or Dec\\fi
      ~\\number\\day}
    \\begin{tikzpicture}[remember picture,overlay]
      %% Background Polygons %%
      \\foreach \\i in {2.5,...,22} % bottom left
      {\\node[rounded corners,black!3.5,draw,regular polygon,regular polygon sides=6, minimum size=\\i cm,ultra thick] at ($(current page.west)+(2.5,-4.2)$) {} ;}
      \\foreach \\i in {0.5,...,22} % top left
      {\\node[rounded corners,black!5,draw,regular polygon,regular polygon sides=6, minimum size=\\i cm,ultra thick] at ($(current page.north west)+(2.5,2)$) {} ;}
      \\node[rounded corners,fill=black!4,regular polygon,regular polygon sides=6, minimum size=5.5 cm,ultra thick] at ($(current page.north west)+(2.5,2)$) {};
      \\foreach \\i in {0.5,...,24} % top right
      {\\node[rounded corners,black!2,draw,regular polygon,regular polygon sides=6, minimum size=\\i cm,ultra thick] at ($(current page.north east)+(0,-8.5)$) {} ;}
      \\node[fill=black!3,rounded corners,regular polygon,regular polygon sides=6, minimum size=2.5 cm,ultra thick] at ($(current page.north east)+(0,-8.5)$) {};
      \\foreach \\i in {21,...,3} % bottom right
      {\\node[black!3,rounded corners,draw,regular polygon,regular polygon sides=6, minimum size=\\i cm,ultra thick] at ($(current page.south east)+(-1.5,0.75)$) {} ;}
      \\node[fill=black!3,rounded corners,regular polygon,regular polygon sides=6, minimum size=2 cm,ultra thick] at ($(current page.south east)+(-1.5,0.75)$) {};
      \\node[align=center, scale=1.4] at ($(current page.south east)+(-1.5,0.75)$) {\\usebox\\orgicon};
      %% Text %%
      \\node[left, align=right, black, text width=0.8\\paperwidth, minimum height=3cm, rounded corners,font=\\Huge\\bfseries] at ($(current page.north east)+(-2,-8.5)$)
      {\\@title};
      \\node[left, align=right, black, text width=0.8\\paperwidth, minimum height=2cm, rounded corners, font=\\Large] at ($(current page.north east)+(-2,-11.8)$)
      {\\scshape \\@author};
      \\renewcommand{\\baselinestretch}{0.75}
      \\node[align=center,rounded corners,fill=black!3,text=black,regular polygon,regular polygon sides=6, minimum size=2.5 cm,inner sep=0, font=\\Large\\bfseries ] at ($(current page.west)+(2.5,-4.2)$)
      {\\@date};
    \\end{tikzpicture}
    \\let\\today\\oldtoday
    \\clearpage}
  \\makeatother
  "
    "LaTeX snippet for the preamble that sets \\maketitle to produce a cover page.")
  
  (eval '(cl-pushnew '(:latex-cover-page nil "coverpage" org-latex-cover-page)
                     (org-export-backend-options (org-export-get-backend 'latex))))
  
  (defun org-latex-cover-page-p ()
    "Whether a cover page should be used when exporting this Org file."
    (pcase (car
            (delq nil
                  (mapcar
                   (lambda (opt-line)
                     (plist-get (org-export--parse-option-keyword opt-line 'latex) :latex-cover-page))
                   (cdar (org-collect-keywords '("OPTIONS"))))))
      ('t t)
      ('auto (when (> (count-words (point-min) (point-max)) org-latex-cover-page-wordcount-threshold) t))
      (_ nil)))
  
  (defadvice! org-latex-set-coverpage-subtitle-format-a (contents info)
    "Set the subtitle format when a cover page is being used."
    :before #'org-latex-template
    (when (org-latex-cover-page-p)
      (setf info (plist-put info :latex-subtitle-format org-latex-subtitle-coverpage-format))))
  
  (add-to-list 'org-latex-feature-implementations '(cover-page :snippet org-latex-cover-page-maketitle :order 9) t)
  (add-to-list 'org-latex-conditional-features '((org-latex-cover-page-p) . cover-page) t)
  (setq! org-latex-listings 'tcblisting
         org-latex-tcblisting-code-preamble "
  \\usepackage{accsupp}
  \\usepackage[most,breakable,minted]{tcolorbox}
  \\definecolor{solarized-light-background}{HTML}{FDF6E3}
  \\definecolor{solarized-light-frame}{HTML}{EEE8D6}
  \\definecolor{solarized-light-title}{HTML}{979797}
  \\definecolor{solarized-light-lineno}{HTML}{237D99}
  \\newcommand{\\SetFancyVerbLine}{
    \\renewcommand{\\theFancyVerbLine}{
      \\protect\\BeginAccSupp{ActualText={}}\\sffamily\\textcolor{solarized-light-lineno}{\\scriptsize\\oldstylenums{\\arabic{FancyVerbLine}}}\\protect\\EndAccSupp{}
    }
  }
  \\newenvironment{orglisting}[2][]{
    \\SetFancyVerbLine
    \\tcblisting{
      frame empty,
      enhanced jigsaw,
      drop fuzzy shadow,
      breakable,
      center,
      width=\\linewidth,
      bottom=1mm, top=1mm, left=6mm,
      fonttitle=\\bfseries,
      listing only,
      listing engine=minted,
      colback=solarized-light-background,
      colframe=solarized-light-frame,
      coltitle=solarized-light-title,
      minted style=solarized-light,
      minted language=#2,
      minted options={
        breaklines=t,
        breakbefore=.,
        samepage=nil,
        encoding=utf8,
        fontsize=\\small,
        mathescape=t,
        escapeinside=,
        autogobble=t,
        breakautoindent=t,
        tabsize=4,
        numbersep=2mm,
        % numbers=left,
        numberblanklines=t,
        firstline=1,
        firstnumber=1,
        % lastline=,
        showspaces=nil,
        space=\\textvisiblespace, %% only showspaces=true
        obeytabs=nil,
        showtabs=nil,
        #1
      },
    }
  }{
    \\endtcblisting
  }
  ")
  (defadvice! org-latex-src-block-tcblisting (orig-fn src-block contents info)
    "Like `org-latex-src-block', but supporting an tcblisting backend"
    :around #'org-latex-src-block
    (if (eq 'tcblisting (plist-get info :latex-listings))
        (ginshio/org-latex-scr-block src-block contents info)
      (funcall orig-fn src-block contents info)))
  
  (defun ginshio/org-latex-scr-block (src-block contents info)
    (let* ((lang (org-element-property :language src-block))
           (attributes (org-export-read-attribute :attr_latex src-block))
           (float (plist-get attributes :float))
           (num-start (org-export-get-loc src-block info))
           (retain-labels (org-element-property :retain-labels src-block))
           (caption (org-element-property :caption src-block))
           (caption-above-p (org-latex--caption-above-p src-block info))
           (caption-str (org-latex--caption/label-string src-block info))
           (placement (or (org-unbracket-string "[" "]" (plist-get attributes :placement))
                          (plist-get info :latex-default-figure-position)))
           (float-env
            (cond
             ((string= "multicolumn" float)
              (format "\\begin{listing*}[%s]\n%s%%s\n%s\\end{listing*}"
                      placement
                      (if caption-above-p caption-str "")
                      (if caption-above-p "" caption-str)))
             (caption
              (format "\\begin{listing}[%s]\n%s%%s\n%s\\end{listing}"
                      placement
                      (if caption-above-p caption-str "")
                      (if caption-above-p "" caption-str)))
             ((string= "t" float)
              (concat (format "\\begin{listing}[%s]\n" placement)
                      "%s\n\\end{listing}"))
             (t "%s")))
           (options (plist-get info :latex-minted-options))
           (body
            (format
             "\\begin{orglisting}[%s]{%s}\n%s\\end{orglisting}"
             ;; Options.
             (concat
              (org-latex--make-option-string
               (if (or (not num-start) (assoc "linenos" options))
                   options
                 (append
                  `(("linenos")
                    ("firstnumber" ,(number-to-string (1+ num-start))))
                  options)))
              (let ((local-options (plist-get attributes :options)))
                (and local-options (concat "," local-options))))
             ;; Language.
             (or (cadr (assq (intern lang)
                             (plist-get info :latex-minted-langs)))
                 (downcase lang))
             ;; Source code.
             (let* ((code-info (org-export-unravel-code src-block))
                    (max-width
                     (apply 'max
                            (mapcar 'length
                                    (org-split-string (car code-info)
                                                      "\n")))))
               (org-export-format-code
                (car code-info)
                (lambda (loc _num ref)
                  (concat
                   loc
                   (when ref
                     ;; Ensure references are flushed to the right,
                     ;; separated with 6 spaces from the widest line
                     ;; of code.
                     (concat (make-string (+ (- max-width (length loc)) 6)
                                          ?\s)
                             (format "(%s)" ref)))))
                nil (and retain-labels (cdr code-info)))))))
      ;; Return value.
      (format float-env body)))
  (defadvice! org-latex-inline-src-block-tcblisting (orig-fn inline-src-block contents info)
    "Like `org-latex-inline-src-block', but supporting an tcblisting backend"
    :around #'org-latex-inline-src-block
    (if (eq 'tcblisting (plist-get info :latex-listings))
        ;; (funcall orig-fn inline-src-block contents (plist-put info :latex-listings 'minted))
        (ginshio/org-latex-inline-src-block inline-src-block contents info)
      (funcall orig-fn inline-src-block contents info)))
  
  (defun ginshio/org-latex-inline-src-block (inline-src-block _contents info)
    (let* ((code (org-element-property :value inline-src-block))
           (separator (org-latex--find-verb-separator code))
           (org-lang (org-element-property :language inline-src-block))
           (mint-lang (or (cadr (assq (intern org-lang)
                                      (plist-get info :latex-minted-langs)))
                          (downcase org-lang)))
           (options (org-latex--make-option-string
                     (plist-get info :latex-minted-options))))
      (format "\\mintinline%s{%s}{%s}"
              (if (string= options "") "" (format "[%s]" options))
              mint-lang code)))
  (add-to-list 'org-latex-conditional-features '("^[ \t]*#\\+begin_src\\|^[ \t]*#\\+BEGIN_SRC\\|src_[A-Za-z]" . tcblisting-code-preamble) t)
  (add-to-list 'org-latex-feature-implementations '(tcblisting-code-preamble :snippet org-latex-tcblisting-code-preamble :order 99) t)
  (setq! org-latex-text-markup-alist
         '((bold . "\\textbf{%s}")
           (code . protectedtexttt)
           (italic . "\\emph{%s}")
           (strike-through . "\\sout{%s}")
           (underline . "\\uline{%s}")
           (verbatim . verb)))
  (setq! org-beamer-theme "[progressbar=foot]metropolis")
  (defun org-beamer-p (info)
    (eq 'beamer (and (plist-get info :back-end) (org-export-backend-name (plist-get info :back-end)))))
  
  (add-to-list 'org-latex-conditional-features '(org-beamer-p . beamer) t)
  (add-to-list 'org-latex-feature-implementations '(beamer :requires .missing-koma :prevents (italic-quotes condensed-lists)) t)
  (add-to-list 'org-latex-feature-implementations '(.missing-koma :snippet "\\usepackage{scrextend}" :order 2) t)
  (setq! org-beamer-frame-level 2))

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

(setq! LaTeX-biblatex-use-Biber t)
(custom-set-variables '(LaTeX-section-label '(("part" . "part:")
                                              ("chapter" . "chap:")
                                              ("section" . "sec:")
                                              ("subsection" . "subsec:")
                                              ("subsubsection" . "subsubsec:")))
                      '(TeX-auto-local "auto")
                      '(TeX-command-extra-options "-shell-escape"))
(after! latex
  (setq! TeX-save-query nil
         TeX-show-compilation t
         LaTeX-clean-intermediate-suffixes (append TeX-clean-default-intermediate-suffixes
                                                   '("\\.acn" "\\.acr" "\\.alg" "\\.glg"
                                                     "\\.ist" "\\.listing" "\\.fdb_latexmk")))
  (add-to-list 'TeX-command-list '("LatexMk (XeLaTeX)" "latexmk -pdf -xelatex -8bit %S%(mode) %(file-line-error) %(extraopts) %t" TeX-run-latexmk nil
                                   (plain-tex-mode latex-mode doctex-mode)
                                   :help "Run LatexMk (XeLaTeX)"))
  (setcar (assoc "⋆" LaTeX-fold-math-spec-list) "★")
  
  (setq! TeX-fold-math-spec-list
         `(;; missing/better symbols
           ("≤" ("le"))
           ("≥" ("ge"))
           ("≠" ("ne"))
           ;; convenience shorts -- these don't work nicely ATM
           ;; ("‹" ("left"))
           ;; ("›" ("right"))
           ;; private macros
           ("ℝ" ("RR"))
           ("ℕ" ("NN"))
           ("ℤ" ("ZZ"))
           ("ℚ" ("QQ"))
           ("ℂ" ("CC"))
           ("ℙ" ("PP"))
           ("ℍ" ("HH"))
           ("𝔼" ("EE"))
           ("𝑑" ("dd"))
           ;; known commands
           ("" ("phantom"))
           (,(lambda (num den) (if (and (TeX-string-single-token-p num) (TeX-string-single-token-p den))
                                   (concat num "／" den)
                                 (concat "❪" num "／" den "❫"))) ("frac"))
           (,(lambda (arg) (concat "√" (TeX-fold-parenthesize-as-necessary arg))) ("sqrt"))
           (,(lambda (arg) (concat "⭡" (TeX-fold-parenthesize-as-necessary arg))) ("vec"))
           ("‘{1}’" ("text"))
           ;; private commands
           ("|{1}|" ("abs"))
           ("‖{1}‖" ("norm"))
           ("⌊{1}⌋" ("floor"))
           ("⌈{1}⌉" ("ceil"))
           ("⌊{1}⌉" ("round"))
           ("𝑑{1}/𝑑{2}" ("dv"))
           ("∂{1}/∂{2}" ("pdv"))
           ;; fancification
           ("{1}" ("mathrm"))
           (,(lambda (word) (string-offset-roman-chars 119743 word)) ("mathbf"))
           (,(lambda (word) (string-offset-roman-chars 119951 word)) ("mathcal"))
           (,(lambda (word) (string-offset-roman-chars 120003 word)) ("mathfrak"))
           (,(lambda (word) (string-offset-roman-chars 120055 word)) ("mathbb"))
           (,(lambda (word) (string-offset-roman-chars 120159 word)) ("mathsf"))
           (,(lambda (word) (string-offset-roman-chars 120367 word)) ("mathtt"))
           )
         TeX-fold-macro-spec-list
         '(;; as the defaults
           ("[f]" ("footnote" "marginpar"))
           ("[c]" ("cite"))
           ("[l]" ("label"))
           ("[r]" ("ref" "pageref" "eqref"))
           ("[i]" ("index" "glossary"))
           ("..." ("dots"))
           ("{1}" ("emph" "textit" "textsl" "textmd" "textrm" "textsf" "texttt"
                   "textbf" "textsc" "textup"))
           ;; tweaked defaults
           ("©" ("copyright"))
           ("®" ("textregistered"))
           ("™"  ("texttrademark"))
           ("[1]:||►" ("item"))
           ("❡❡ {1}" ("part" "part*"))
           ("❡ {1}" ("chapter" "chapter*"))
           ("§ {1}" ("section" "section*"))
           ("§§ {1}" ("subsection" "subsection*"))
           ("§§§ {1}" ("subsubsection" "subsubsection*"))
           ("¶ {1}" ("paragraph" "paragraph*"))
           ("¶¶ {1}" ("subparagraph" "subparagraph*"))
           ;; extra
           ("⬖ {1}" ("begin"))
           ("⬗ {1}" ("end"))
           ))
  
  (defun string-offset-roman-chars (offset word)
    "Shift the codepoint of each character in WORD by OFFSET with an extra -6 shift if the letter is lowercase"
    (apply 'string
           (mapcar (lambda (c)
                     (string-offset-apply-roman-char-exceptions
                      (+ (if (>= c 97) (- c 6) c) offset)))
                   word)))
  
  (defvar string-offset-roman-char-exceptions
    '(;; lowercase serif
      (119892 .  8462) ; ℎ
      ;; lowercase caligraphic
      (119994 . 8495) ; ℯ
      (119996 . 8458) ; ℊ
      (120004 . 8500) ; ℴ
      ;; caligraphic
      (119965 . 8492) ; ℬ
      (119968 . 8496) ; ℰ
      (119969 . 8497) ; ℱ
      (119971 . 8459) ; ℋ
      (119972 . 8464) ; ℐ
      (119975 . 8466) ; ℒ
      (119976 . 8499) ; ℳ
      (119981 . 8475) ; ℛ
      ;; fraktur
      (120070 . 8493) ; ℭ
      (120075 . 8460) ; ℌ
      (120076 . 8465) ; ℑ
      (120085 . 8476) ; ℜ
      (120092 . 8488) ; ℨ
      ;; blackboard
      (120122 . 8450) ; ℂ
      (120127 . 8461) ; ℍ
      (120133 . 8469) ; ℕ
      (120135 . 8473) ; ℙ
      (120136 . 8474) ; ℚ
      (120137 . 8477) ; ℝ
      (120145 . 8484) ; ℤ
      )
    "An alist of deceptive codepoints, and then where the glyph actually resides.")
  
  (defun string-offset-apply-roman-char-exceptions (char)
    "Sometimes the codepoint doesn't contain the char you expect.
  Such special cases should be remapped to another value, as given in `string-offset-roman-char-exceptions'."
    (if (assoc char string-offset-roman-char-exceptions)
        (cdr (assoc char string-offset-roman-char-exceptions))
      char))
  
  (defun TeX-fold-parenthesize-as-necessary (tokens &optional suppress-left suppress-right)
    "Add ❪ ❫ parenthesis as if multiple LaTeX tokens appear to be present"
    (if (TeX-string-single-token-p tokens) tokens
      (concat (if suppress-left "" "❪")
              tokens
              (if suppress-right "" "❫"))))
  
  (defun TeX-string-single-token-p (teststring)
    "Return t if TESTSTRING appears to be a single token, nil otherwise"
    (if (string-match-p "^\\\\?\\w+$" teststring) t nil))
  (after! tex
    (map!
     :map LaTeX-mode-map
     :ei [C-return] #'LaTeX-insert-item)
    (setq TeX-electric-math '("\\(" . "")))
  ;; Making \( \) less visible
  (defface unimportant-latex-face
    '((t :inherit font-lock-comment-face :weight extra-light))
    "Face used to make \\(\\), \\[\\] less visible."
    :group 'LaTeX-math)
  
  (font-lock-add-keywords
   'latex-mode
   `(("\\\\[]()[]" 0 'unimportant-latex-face prepend))
   'end)
  
  ;; (font-lock-add-keywords
  ;;  'latex-mode
  ;;  '(("\\\\[[:word:]]+" 0 'font-lock-keyword-face prepend))
  ;;  'end)
  (when EMACS28+
    (add-hook 'latex-mode-hook #'TeX-latex-mode))
  )

(after! cdlatex
  (setq cdlatex-env-alist
        '(("bmatrix" "\\begin{bmatrix}\n?\n\\end{bmatrix}" nil)
          ("equation*" "\\begin{equation*}\n?\n\\end{equation*}" nil)))
  (setq ;; cdlatex-math-symbol-prefix ?\; ;; doesn't work at the moment :(
   cdlatex-math-symbol-alist
   '( ;; adding missing functions to 3rd level symbols
     (?_    ("\\downarrow"  ""           "\\inf"))
     (?2    ("^2"           "\\sqrt{?}"     ""     ))
     (?3    ("^3"           "\\sqrt[3]{?}"  ""     ))
     (?^    ("\\uparrow"    ""           "\\sup"))
     (?k    ("\\kappa"      ""           "\\ker"))
     (?m    ("\\mu"         ""           "\\lim"))
     (?c    (""             "\\circ"     "\\cos"))
     (?d    ("\\delta"      "\\partial"  "\\dim"))
     (?D    ("\\Delta"      "\\nabla"    "\\deg"))
     ;; no idea why \Phi isnt on 'F' in first place, \phi is on 'f'.
     (?F    ("\\Phi"))
     ;; now just convenience
     (?.    ("\\cdot" "\\dots"))
     (?:    ("\\vdots" "\\ddots"))
     (?*    ("\\times" "\\star" "\\ast")))
   cdlatex-math-modify-alist
   '( ;; my own stuff
     (?B    "\\mathbb"        nil          t    nil  nil)
     (?a    "\\abs"           nil          t    nil  nil))))

;; [[file:config.org::*C++][C++:1]]
(add-to-list 'auto-mode-alist '("\\.tcc\\'" . c++-mode))
(set-formatter! 'clang-format
  '("clang-format" "--Wno-error=unknown" ("-assume-filename=%S" (or buffer-file-name mode-result "")))
  :modes '(c-mode c++-mode))
;; C++:1 ends here

;; [[file:config.org::*C++][C++:2]]
(after! c++-mode
  (require 'dap-gdb-lldb)
  )
;; C++:2 ends here
