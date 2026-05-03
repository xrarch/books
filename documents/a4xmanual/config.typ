#let decBlue = rgb("#8a9dd1")
#let headingColor = decBlue.darken(20%)
#let tableHeadingColor = decBlue

#let pageHeaderTextColor = headingColor

#let bodyFont = "EB Garamond"
#let bodyFontSize = 11pt
#let bodyFontWeight = "light"
#let captionFontSize = bodyFontSize - 2pt

#let microHeadingFillColor = none
#let microHeadingTextColor = headingColor
#let microHeadingStrokeColor = headingColor
#let microHeadingFontSize = bodyFontSize

#let codeFont = "Courier"
#let codeFontSize = 9pt
#let codeStrokeColor = black
#let codeFillColor = none
#let codeFontColor = black

#let titleFont = "EB Garamond"

#let paragraphOffset = 2cm
#let roundedRadius = 3pt
#let roundedInset = 4pt

#let caption(theText) = {
	v(-0.5em)
	text(size: captionFontSize)[
		#align(center)[
			#theText
		]
	]
}

#let microHeading(theText) = {
	box[
		#block(
		  stroke: microHeadingStrokeColor + 1pt,
		  fill: microHeadingFillColor,
		  inset: roundedInset,
		  radius: roundedRadius,
		)[
			#text(fill: microHeadingTextColor, size: microHeadingFontSize)[
				#theText
			]
		]
	]
	text[\ ]
	v(-0.7em)
}

#let aGroup(text) = {
	block(breakable: false)[
		#text
	]
}

#let aTitle(theShortTitle, theSize, theRevisionHistory) = {
	let theTracking = -2pt

	align(right + horizon)[
		#text(font: titleFont, size: theSize, fill: decBlue, tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue, tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue.transparentize(12.5%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue.transparentize(25%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue.transparentize(37.5%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue.transparentize(62.5%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue.transparentize(75%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: decBlue.transparentize(87.5%), tracking: theTracking)[
			#theShortTitle
		]
	]

	pagebreak()

	text(font: titleFont)[
		*#context { document.title }* \
	]

	theRevisionHistory
}

