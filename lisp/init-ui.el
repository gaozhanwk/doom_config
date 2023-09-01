;;; lisp/init-ui.el -*- lexical-binding: t; -*-

(add-hook! 'window-setup-hook #'toggle-frame-fullscreen) ;最大化启动
(display-time-mode t)   ;开启时间状态栏

(provide 'init-ui)
