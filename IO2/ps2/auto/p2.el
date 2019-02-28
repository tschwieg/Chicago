(TeX-add-style-hook
 "p2"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper12"))
 :latex)

