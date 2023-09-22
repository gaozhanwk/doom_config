;;; lisp/init-edit.el -*- lexical-binding: t; -*-

;;;Code:

(use-package! rime
  :custom
  (default-input-method "rime")
  :config
  (setq rime-translate-keybindings
        '("C-f" "C-b" "C-n" "C-p" "C-g" "<left>" "<right>" "<up>" "<down>" "<prior>" "<next>" "<delete>"))
  )

(provide 'init-edit)
