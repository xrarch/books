#import "config.typ": *

= Kinnow Framebuffer
== Introduction

The Kinnow framebuffer card provides a very simple linear 1024x768 framebuffer with 8-bit pixels.

#roundedTable(
  columns: (auto, 1fr),

  [Offset], [Purpose],
  [+0x000000], [SlotInfo],
  [+0x003000], [Kinnow Registers],
  [+0x004000], [Kinnow Palette],
  [+0x100000], [Framebuffer Memory]
)

#caption[The KinnowFB slot space.]

#roundedTable(
  columns: (auto, 1fr),

  [Offset], [Purpose],
  [+0x0], [Display Size],
  [+0x4], [Framebuffer Memory Size],
)

#caption[The defined device registers.]

The display size register contains two 12-bit fields. The low 12 bits [0:11] contain the width of the display in pixels, and the next 12 bits [12:23] contain the height of the display in pixels. The framebuffer memory size register contains the size in bytes of the framebuffer memory. It will always be at least large enough to contain the display pixel data, calculated by a simple multiplication of width by height as each pixel occupies only 1 byte.

The framebuffer memory begins at an offset of 0x100000 and is laid out in row-major order. That is, the first row of a 1024 pixel wide display is stored as a contiguous sequence of 1024 bytes, the next row is the next 1024 bytes, and so on. Therefore, the offset for a particular (X,Y) pair can be calculated by:

```
Offset := (y * Width) + x
```

And, likewise, an offset can be converted to an (X,Y) pair by:

```
Y = Floor(Offset / Width)
X = Offset % Width
```

== Palette

The pixel color is computed by looking up each 8-bit pixel value in a programmable palette of 256 colors, beginning at an offset of 0x4000. Each palette entry is little-endian and 32 bits wide, making the palette a total of 1024 bytes wide. The entries take the form of `0x??RRGGBB`, where the uppermost 8 bits of each palette entry is ignored.
