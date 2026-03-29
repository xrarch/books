#import "@preview/hydra:0.6.2": hydra

#set page(header: context {
  let h3 = hydra(3);
  if h3 != none {
    h3
  } else {
    hydra(2)
  }
}, paper: "iso-b5")

#set document(title: "XR/17032 Architecture Handbook")
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

#pagebreak(weak: true)

#include "chapmmu.typ"

#pagebreak(weak: true)

#include "chapcache.typ"

#pagebreak(weak: true)

#include "chapcontrol.typ"

#pagebreak(weak: true)

#include "chapinstructions.typ"

#pagebreak(weak: true)
