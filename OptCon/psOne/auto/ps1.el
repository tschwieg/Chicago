(TeX-add-style-hook
 "ps1"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem")))
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"
    "inputenc"
    "fontenc"
    "graphicx"
    "longtable"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "textcomp"
    "amssymb"
    "capt-of"
    "tikz"
    "bm"
    "minted"
    "amsthm"
    "mathtools"
    "amsfonts"
    "bbm")
   (TeX-add-symbols
    '("altest" ["argument"] 1)
    '("est" ["argument"] 1)
    '("mean" ["argument"] 1)
    '("deriv" 2)
    '("indicate" 1)
    '("Vari" 1)
    '("exV" 1)
    "plim"
    "convDist"
    "unif"
    "normal"
    "eye"
    "bigO"
    "Lagrange")
   (LaTeX-add-labels
    "sec:org0b5fbc5"
    "sec:orgf0b1dad"
    "sec:org33f5cb9"
    "sec:orgab5ca7a"
    "sec:org7130e01"
    "sec:org80c94a5"
    "sec:orga7ec8ff"
    "fig:test3"
    "fig:test4"
    "sec:org667b640"
    "sec:orgf102039"
    "sec:orgd42d3c7")
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

