;;; lisp/init-ui.el -*- lexical-binding: t; -*-

;;(add-hook! 'window-setup-hook #'toggle-frame-fullscreen) ;最大化启动

;;(add-hook! 'window-setup-hook #'toggle-frame-maximized)
(display-time-mode t)   ;开启时间状态栏

(use-package! all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode)
  )

(use-package! all-the-icons-completion
  :hook ((after-init . all-the-icons-completion-mode)
         (marginalia-mode . all-the-icons-completion-marginalia-setup))
  )

(provide 'init-ui)
