#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Interrupt Architecture
== Introduction

Interrupts on the XR/computer platform are mediated between the devices and the processors by the Local Symmetric Interrupt Controller (LSIC), of which there is one for each processor in the system. The XR/17032 microprocessor contains only one IRQ line, which causes a trap to the operating system for interrupt handling when it is asserted. As there is no direct way to determine which device caused the interrupt, an external interrupt controller is required.

== LSIC

The LSIC has 64 interrupt inputs. They are assigned as follows on the XR/computer platform:

#tablex(
  columns: (1fr, 6fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x02*
  ], fill: rgb(0,0,0,255)),
  [Interval Timer],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x03*
  ], fill: rgb(0,0,0,255)),
  [Disk Controller],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x04*
  ], fill: rgb(0,0,0,255)),
  [Serial Port A],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x05*
  ], fill: rgb(0,0,0,255)),
  [Serial Port B],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x28-0x2E*
  ], fill: rgb(0,0,0,255)),
  [Expansion Boards],

  cellx([
    #set text(fill: white)
    #set align(center)
    *0x30-0x33*
  ], fill: rgb(0,0,0,255)),
  [Amtsu Devices],
)

Each LSIC has several 32-bit registers which control its behavior. The zeroth LSIC is located at 0xF8030000 in the physical address space, and successive LSICs are arranged at offsets of 32 bytes. In effect, there is an "array" of LSICs which is indexed by the corresponding processor's number (which can be found in the *WHAMI* control register on that processor, and is in the range of [0-3] on XR/computer systems).

The LSIC registers' behavior on write and read is enumerated below:

#box([

#tablex(
  columns: (1fr, 1fr, 6fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Offset*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Function on Write*
  ], fill: rgb(0,0,0,255)),
  [DISA0], [+0x00], [Set the disable bits for IRQ0-31.],
  [DISA1], [+0x04], [Set the disable bits for IRQ32-63.],
  [PEND0], [+0x08], [Atomically OR the written value into the pending bits for IRQ0-31. However, if the written value is zero, these pending bits are cleared.],
  [PEND1], [+0x0C], [Atomically OR the written value into the pending bits for IRQ32-63. However, if the written value is zero, these pending bits are cleared.],
  [COMPL], [+0x10], [Atomically clear the pending bit for the IRQ whose number is written into the register.],
  [IPL], [+0x14], [Set the current interrupt priority level. Must be of the range [0-63].],
)

])

#box([

#tablex(
  columns: (1fr, 1fr, 6fr),

  cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Offset*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Return on Read*
  ], fill: rgb(0,0,0,255)),
  [DISA0], [+0x00], [The disable bits for IRQ0-31.],
  [DISA1], [+0x04], [The disable bits for IRQ32-63.],
  [PEND0], [+0x08], [The pending bits for IRQ0-31.],
  [PEND1], [+0x0C], [The pending bits for IRQ32-63.],
  [CLAIM], [+0x10], [The current lowest-numbered, unmasked, pending IRQ.],
  [IPL], [+0x14], [The current interrupt priority level.],
)

])

The state of the IRQ line is a function of the pending bits, as masked off by the disable bits. Therefore it is given by the following function:

```
IrqPending := (PEND0 & ~DISA0) != 0 OR (PEND1 & ~DISA1) != 0
```

With the additional restriction that any interrupt with a number greater than or equal to the value of the *IPL* register is also masked off.

Note that writing a value into the *PEND0* or *PEND1* register of another processor's LSIC can be used to trigger an inter-processor interrupt (IPI) of an arbitrary number, which is useful for tasks such as TB and Dcache shootdown.

== Interrupts

When a device raises an interrupt, it is latched into the corresponding *PEND* register of every LSIC in the system simultaneously. This means that the LSIC interrupts are level-triggered and must be explicitly dismissed by a write of the interrupt number to the *COMPL* register by all processors that took the interrupt.

Note that the input of the device into the LSIC may be either edge-triggered or level-triggered. If it is level-triggered, then clearing the pending bit in the LSIC may have no effect as it will simply be latched again instantaneously if the device is still asserting its interrupt line. In this case, the device must therefore be serviced first in some device-specific manner in order to convince it to drop its interrupt line.

== Interrupt Routing

By "default", all LSICs receive all interrupts. If it is desired that particular interrupts are only serviced by particular processors in the system, then the disable bits for all processors' LSICs should be set such that none will take the interrupt except those which are desired. In this way, arbitrary interrupt routing can be accomplished.