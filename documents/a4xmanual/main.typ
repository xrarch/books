#import "@preview/hydra:0.2.0": hydra

#set page(header: hydra(paper: "us-letter"), paper: "us-letter")

#set document(title: "A4X Firmware Manual")
#set text(font: "IBM Plex Mono", size: 9pt)
#show math.equation: set text(font: "Fira Math")
#show raw: set text(font: "Cascadia Code", size: 9pt)
#set heading(numbering: "1.")
#set par(justify: true)

#include "titlepage.typ"

#pagebreak(weak: true)

#set page(numbering: "i")
#counter(page).update(1)

#include "toc.typ"

#pagebreak(weak: true)

#set page(numbering: "1", number-align: right)
#counter(page).update(1)

#include "chapintro.typ"

#include "chapui.typ"

#include "chapnvram.typ"

#include "chapapt.typ"

#include "chapbooting.typ"