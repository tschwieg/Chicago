(TeX-add-style-hook
 "q7_2"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=1in")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"
    "fullpage"
    "parskip"
    "tikz"
    "amsmath"
    "hyperref"
    "geometry"))
 :latex)

