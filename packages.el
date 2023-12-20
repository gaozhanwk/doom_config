;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; [[file:config.org::*iedit 多行编辑工具][iedit 多行编辑工具:1]]
(package! iedit :recipe (:host github :repo "victorhge/iedit"))
;; iedit 多行编辑工具:1 ends here

;; [[file:config.org::*hungry delete][hungry delete:1]]
(package! hungry-delete :recipe (:host github :repo "nflath/hungry-delete"))
;; hungry delete:1 ends here

(package! magit-delta :recipe (:host github :repo "dandavison/magit-delta"))

;; [[file:config.org::*Screenshot][Screenshot:1]]
(package! screenshot
  :recipe (:host github :repo "tecosaur/screenshot" :build (:not compile))
  )
;; Screenshot:1 ends here

;; [[file:config.org::*rime][rime:1]]
(package! rime)
(package! posframe)
;; rime:1 ends here

;; [[file:config.org::*counsel][counsel:1]]
(package! counsel :disable t)
;; counsel:1 ends here

;; [[file:config.org::*denote][denote:1]]
(package! denote)
;; denote:1 ends here

;; [[file:config.org::*Nyan][Nyan:1]]
(package! nyan-mode :recipe (:host github :repo "TeMPOraL/nyan-mode"))
;; Nyan:1 ends here

;; [[file:config.org::*Theme Magic][Theme Magic:1]]
(package! theme-magic :disable t)
;; Theme Magic:1 ends here

;; [[file:config.org::*cnfonts 字体][cnfonts 字体:1]]
(package! cnfonts)
;; cnfonts 字体:1 ends here

(package! org-pandoc-import :recipe
  (:host github :repo "tecosaur/org-pandoc-import" :files ("*.el" "filters" "preprocessors")))

(package! org-ol-tree :recipe (:host github :repo "Townk/org-ol-tree"))

(package! org-modern)

(package! org-appear
  :recipe (:host github :repo "awth13/org-appear"))

;; [[file:config.org::*dts mode][dts mode:1]]
(package! dts-mode)
;; dts mode:1 ends here
