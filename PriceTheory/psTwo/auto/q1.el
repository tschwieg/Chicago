(TeX-add-style-hook
 "q1"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=.75in")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"
    "Schwieg"
    "geometry"
    "tikz"))
 :latex)

