(TeX-add-style-hook
 "p1"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=1in")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"
    "geometry"
    "amsmath"
    "bm"
    "amsthm"
    "mathtools"
    "amsfonts"
    "bbm"
    "graphicx")
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
    "diam"
    "interior"
    "close"
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

