#import "@preview/hydra:0.6.2": hydra

#let contentStartedState = state("contentStartedVariable", false)

#set document(title: "XR/computer Systems Handbook")

#import "config.typ": *

#set page(
	header: context {
		let heading = hydra()

		set text(font: titleFont)

    	h(1fr)
    	[XR/station Project\ ]
		heading
		h(1fr)
		document.title
		line(length: 100%, stroke: 1pt)
	},
	paper: "us-letter",
)

#set text(font: bodyFont, size: bodyFontSize, weight: bodyFontWeight)
#show raw: set text(font: codeFont, codeFontSize)
#show raw.where(block: true): it => pad(left: paragraphOffset, block(
  stroke: codeStrokeColor,
  fill: codeFillColor,
  inset: 10pt,
  radius: roundedRadius,
  width: 100%,
  [
  	#set align(left)
  	#it
  ],
))
#show raw.where(block: true): set text(codeFontColor)
#set heading(numbering: "1.1")
#set par(justify: true)
#show heading: set text(headingColor, font: titleFont)

#include "titlepage.typ"

#pagebreak(weak: true)

#set page(numbering: "i")
#counter(page).update(1)

#include "toc.typ"

#pagebreak(weak: true)

#contentStartedState.update(true)

#set page(numbering: "1", number-align: right)
#counter(page).update(1)

#show par: it => block(inset: (left: paragraphOffset), it)

#include "chapintro.typ"

#pagebreak(weak: true)

#include "chapinter.typ"

#pagebreak(weak: true)

#include "chapcitron.typ"

#pagebreak(weak: true)

#include "chapaudio.typ"

#pagebreak(weak: true)

#include "chapether.typ"

#pagebreak(weak: true)

#include "chapamtsu.typ"

#pagebreak(weak: true)

#include "chapkinnow.typ"

#pagebreak(weak: true)
