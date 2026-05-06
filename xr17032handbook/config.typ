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

#let roundedTable(..args) = {
	show table: it => pad(left: paragraphOffset, [
		#block(
			radius: roundedRadius,
			clip: true,
			[
				#it
				#v(1pt)
			],
		)
	])
	set table(
		fill: (_, y) => if y == 0 { tableHeadingColor },
		stroke: (x, y) => {
			if y == 0 {
				(top: 1pt + tableHeadingColor, left: none, right: 1pt + tableHeadingColor, bottom: 1pt + tableHeadingColor)
			} else {
				(top: none, bottom: 1pt + tableHeadingColor, left: none, right: none)
			}
		},
	)

	show table.cell.where(y: 0): set text(fill: white)
	show table.cell: set align(horizon)
	table(..args)
}

#let bitfield(fields, total-bits: 32) = {
  let cols = fields.map(f => f.bits * 1fr)

  let (_, bit-ranges) = fields.fold(
    ((total-bits, ())),

    ((current, acc), f) => {
      let start = current - 1
      let end = start - f.bits + 1

      (
        end,
        acc + ((
          if start == end {
            // Single-bit field
            [#start]
          } else {
            // Multi-bit field
            [
              #start
              #h(1fr)
              #end
            ]
          }
        ),),
      )
    },
  )

	show table: it => pad(left: paragraphOffset, [
		#block(
			radius: roundedRadius,
			clip: true,
			[
				#it
				#v(1pt)
			],
		)
	])
	set table(
		fill: (_, y) => if y == 0 { tableHeadingColor },
		stroke: (top: 1pt + tableHeadingColor, left: 1pt + tableHeadingColor, right: 1pt + tableHeadingColor, bottom: none)
	)

	show table.cell.where(y: 0): set text(fill: white)
	show table.cell: set align(horizon)

  table(
    columns: cols,

    // Bit spans
    ..bit-ranges.map(r =>
      table.cell(
        [#r],
      )
    ),

    // Field names
    ..fields.map(f =>
      table.cell(
        align: center + horizon,
        [#f.name],
      )
    ),
  )
}