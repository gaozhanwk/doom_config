;;; lisp/init-keybinding.el -*- lexical-binding: t; -*-

;; 快速打开ssh 文件
;;; Code:
;;(defun open-ssh-112()
;;  (interactive)
;;  (find-file "/ssh:gaoz@192.168.0.112:/home/gaoz/"))
;;(global-set-key (kbd "<f5>") 'open-ssh-112)
;;(keymap-global-set "<f5>" 'open-ssh-112)

;;
;;(package-install 'consult)
;;replace swiper
(global-set-key (kbd "C-s") 'consult-line)
(global-set-key (kbd "C-c f r") 'counsel-rg)
(global-set-key (kbd "C-c f f") 'fd-dired)
(global-set-key (kbd "<f5>") 'toggle-company-english-helper)
(global-set-key (kbd "C-c s") 'sdcv-search-pointer+)
;;(global-set-key (kbd "C-c f f") 'consult-find)
;;consult-imenu


(provide 'init-keybinding)
