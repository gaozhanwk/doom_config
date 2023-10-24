;;; lisp/init-edit.el -*- lexical-binding: t; -*-

;;;Code:

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

;; 窗口标题, 被修改过显示*
(setq frame-title-format
      '(""
        (:eval
         (if (string-match-p (regexp-quote (or (bound-and-true-p org-roam-directory) "\u0000"))
                             (or buffer-file-name ""))
             (replace-regexp-in-string
              ".*/[0-9]*-?" "☰ "
              (subst-char-in-string ?_ ?\s buffer-file-name))
           "%b"))
        (:eval
         (when-let ((project-name (and (featurep 'projectile) (projectile-project-name))))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p)  " * %s" " ● %s") project-name))))))

;; sdcv
(setq sdcv-say-word-p t)               ;say word after translation
(setq sdcv-dictionary-data-dir "/usr/share/stardict/dic/") ;setup directory of stardict dictionary

(setq sdcv-dictionary-simple-list    ;setup dictionary list for simple search
      '("懒虫简明英汉词典"
        "懒虫简明汉英词典"
        "KDic11万英汉词典"))

(setq sdcv-dictionary-complete-list     ;setup dictionary list for complete search
      '(
        "懒虫简明英汉词典"
        "懒虫简明汉英词典"
        "KDic11万英汉词典"
        "朗道汉英字典5.0"
       ))

(provide 'init-edit)
