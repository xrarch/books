#import "@preview/cetz:0.4.2"

#let decBlue = black
#let titleColor = rgb("#8a9dd1")
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
#let roundedInset = 5pt

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
		#text(font: titleFont, size: theSize, fill: titleColor, tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor, tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor.transparentize(12.5%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor.transparentize(25%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor.transparentize(37.5%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor.transparentize(62.5%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor.transparentize(75%), tracking: theTracking)[
			#theShortTitle
		] \
		#text(font: titleFont, size: theSize, fill: titleColor.transparentize(87.5%), tracking: theTracking)[
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

// The following bitfield function was borrowed from the Aphelion project with permission
#let format(..fields) = layout(ly => cetz.canvas(length: ly.width/32, {
    import cetz.draw: *;
  
    let notch_width = 0.15;
    let bitnum_size = 10pt;
    let name_size = bitnum_size;
    let fields = fields.pos().rev();
    
    // draw text
    let bits = 32;
    for (name, bitwidth) in fields {
        if (name == "MBZ" or name == "MBZ(hidden)" or name == "IGNORED") {
            rect((bits - bitwidth,0), (bits, 2), stroke: 0pt, fill: tableHeadingColor)
        }
        content(
            anchor: "mid", (bits - 0.5, 2.5),
            text(size: bitnum_size)[#{32 - bits}]
        );
        if bitwidth != 1 {
            content(
                anchor: "mid", (bits - bitwidth + 0.5, 2.5),
                text(size: bitnum_size)[#{32 + bitwidth - bits - 1}]
            );
        }
        if (name.match(regex("^[01]+$")) == none) {
          
            if (name != "MBZ(hidden)") {
                content(
                    anchor: "mid", (bits - bitwidth/2, 1),
                    text(size: name_size, fill: (if (name == "MBZ" or name == "IGNORED") {white} else {black}))[#name]
                );
            }
        } else {
            let n = 0;
            for char in name {
                content(
                    anchor: "mid", (bits - bitwidth + 0.5 + n, 1.0),
                    text(size: name_size)[#char]
                );
                n += 1;
            }
        }
        bits -= bitwidth;
    }

    // draw box and lines
    let bits = 32;
    for (name, bitwidth) in fields {
        bits -= bitwidth;
        for i in range(1, bitwidth) {
            line((bits + i, 0), (bits + i, notch_width), stroke: 0.5pt)
            line((bits + i, 2), (bits + i, 2-notch_width), stroke: 0.5pt)
        }
        if bits != 0 {
            line((bits, 0), (bits, 2), stroke: 0.5pt)
        }
    }
    rect((0,0), (32, 2), stroke: 0.5pt);
}))