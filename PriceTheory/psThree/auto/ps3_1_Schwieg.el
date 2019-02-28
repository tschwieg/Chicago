(TeX-add-style-hook
 "ps3_1_Schwieg"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margins=1in")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"
    "Schwieg"
    "tikz"
    "geometry"))
 :latex)

