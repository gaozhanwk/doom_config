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

(setq doom-theme (let ((themes '(doom-vibrant
                                 doom-fairy-floss
                                 doom-dracula
                                 doom-Iosvkem
                                 doom-moonlight
                                 doom-monokai-pro
                                 doom-tokyo-night)))
                   (elt themes (random (length themes)))))

;; 彩虹猫 UI
(use-package! nyan-mode
  :config
  (setq nyan-animate-nyancat t
        nyan-wavy-trail t
        nyan-cat-face-number 4
        nyan-bar-length 16
        nyan-minimum-window-width 64)
  (add-hook! 'doom-modeline-hook #'nyan-mode))


(after! doom-modeline
  (custom-set-variables '(doom-modeline-buffer-file-name-style 'relative-to-project)
                        '(doom-modeline-major-mode-icon t)
                        '(doom-modeline-modal-icon nil))
  (nyan-mode t))

(setq! frame-title-format
      '("%b – Doom Emacs"
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format "  -  [%s]" project-name))))))

(provide 'init-ui)
