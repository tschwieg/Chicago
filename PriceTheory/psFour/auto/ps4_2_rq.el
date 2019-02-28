(TeX-add-style-hook
 "ps4_2_rq"
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
    "tikz"
    "Schwieg"))
 :latex)

