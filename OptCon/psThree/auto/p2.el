(TeX-add-style-hook
 "p2"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("geometry" "margin=1in") ("ulem" "normalem")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"
    "inputenc"
    "fontenc"
    "geometry"
    "amsmath"
    "bm"
    "amsthm"
    "mathtools"
    "amsfonts"
    "bbm"
    "graphicx"
    "minted"
    "longtable"
    "wrapfig"
    "rotating"
    "ulem"
    "textcomp"
    "amssymb"
    "capt-of"
    "tikz"
    "fontspec")
   (TeX-add-symbols
    '("altest" ["argument"] 1)
    '("est" ["argument"] 1)
    '("mean" ["argument"] 1)
    '("deriv" 2)
    '("indicate" 1)
    '("Vari" 1)
    '("exV" 1)
    '("compl" 1)
    '("inv" 1)
    '("set" 1)
    '("conj" 1)
    '("seq" 1)
    '("abs" 1)
    '("cbrak" 1)
    '("brak" 1)
    '("met" 1)
    "Lim"
    "compose"
    "setR"
    "setQ"
    "setZ"
    "setN"
    "plim"
    "convDist"
    "unif"
    "normal"
    "eye"
    "bigO"
    "Lagrange")
   (LaTeX-add-mathtools-DeclarePairedDelimiters
    '("ceil" "")
    '("floor" "")
    '("norm" "")))
 :latex)

