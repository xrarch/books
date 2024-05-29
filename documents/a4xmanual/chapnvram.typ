#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= NVRAM

XR/computer systems all contain a 4KB non-volatile RAM (NVRAM) which is used by the system firmware to store persistent information in *NVRAM variables*, which can be viewed and set by the user from the command monitor. All NVRAM variable contents are ASCII strings, but the internal format is undocumented and liable to change. A table of the currently defined NVRAM variables follows:

#box([
#tablex(
  columns: (1fr, 1fr, 3.5fr),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Type*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  [*boot-dev*], [String], [If *auto-boot?* is set to *true*, contains the name of a preferred partition to boot from in *dksXsY* format.],
  [*auto-boot?*], [Boolean], [When set to *true*, the system will attempt to automatically boot.],
  [*boot-args*], [String], [Contains the argument string that will be passed to bootstrap software.],
)
])

Any other variables seen may have been created by the embedded legacy *A3X* firmware which is chain-loaded in order to boot legacy operating systems. These variables are undocumented and should be left alone.