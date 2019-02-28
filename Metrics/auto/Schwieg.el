(TeX-add-style-hook
 "Schwieg"
 (lambda ()
   (TeX-run-style-hooks
    "amsmath"
    "bm"
    "amsthm"
    "mathtools")
   (TeX-add-symbols
    '("mean" ["argument"] 1)
    '("indicate" 1)
    '("est" 1)
    '("Vari" 1)
    '("exV" 1)
    '("compl" 1)
    '("inv" 1)
    '("set" 1)
    '("close" 1)
    '("conj" 1)
    '("seq" 1)
    '("abs" 1)
    '("cbrak" 1)
    '("brak" 1)
    '("met" 1)
    "diam"
    "interior"
    "Lim"
    "compose"
    "setMinus"
    "setR"
    "setQ"
    "setZ"
    "setN"
    "plim"
    "convDist")
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

