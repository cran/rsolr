(TeX-add-style-hook
 "intro"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "11pt")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art11")
   (LaTeX-add-labels
    "sec-1"
    "sec-2"
    "sec-2-1"
    "sec-2-2"
    "sec-2-3"
    "sec-2-4"
    "sec-2-5"
    "sec-2-6"
    "sec-2-6-1"
    "sec-2-7"))
 :latex)

