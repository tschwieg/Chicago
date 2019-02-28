(TeX-add-style-hook
 "Schwieg"
 (lambda ()
   (TeX-run-style-hooks
    "amsmath"
    "bm"
    "amsthm"
    "mathtools"
    "amsfonts"
    "bbm")
   (TeX-add-symbols
    '("est" ["argument"] 1)
    '("mean" ["argument"] 1)
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
    "normal")
   (LaTeX-add-amsthm-newtheorems
    "definition"
    "theorem"
    "question"
    "answer")
   (LaTeX-add-mathtools-DeclarePairedDelimiters
    '("ceil" "")
    '("floor" "")
    '("norm" "")))
 :latex)

