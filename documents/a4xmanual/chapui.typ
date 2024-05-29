#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= User Interface

The firmware contains both a textual user interface (TUI) and a simple graphical user interface (GUI). The TUI is referred to as the "command monitor", and consists of a simple command interface that supports several commands. The GUI consists of a very simple "boot picker".

== Boot Picker

The boot picker appears at system startup when the firmware detects more than one bootable partition is available, and a display adapter is attached. It provides a simple way for the user to select which partition should be booted.

#set align(center)
#image("bootpicker.png", width: 50%)
_The appearance of the A4X Boot Picker._
#set align(left)

== Command Monitor

The command monitor is available both graphically via an extremely simplistic terminal emulator, and over the serial port. It can be entered graphically via striking ESC at the boot picker, or over Serial Port A by performing a headless boot (i.e. with no displays attached) with either zero or multiple bootable partitions installed.

Note that partitions are named in the format *dksXsY*, where *X* is the integer identifier of the disk device, and *Y* is the integer identifier of the partition. If *Y* is 8, such as in *dks0s8*, the entire disk is addressed.

A list of commands available at the time of writing is provided:

#box([
#tablex(
  columns: (1fr, 5fr),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Command*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  [*help*], [Display help text about all commands.],
  [*autoboot*], [Boot with default parameters.],
  [*reset*], [Reset the system.],
  [*nvreset*], [Reset the system NVRAM.],
  [*listenv*], [List the NVRAM variables.],
  [*setenv*], [[name] [contents] Set an NVRAM variable.],
  [*delenv*], [[name] Delete an NVRAM variable.],
  [*boot*], [[device (dksNsN)] [args ...] Boot from specified device.],
  [*listdisk*], [List all disks, their bootable partitions, and any operating systems installed.],
  [*clear*], [Clear the command monitor.]
)
])