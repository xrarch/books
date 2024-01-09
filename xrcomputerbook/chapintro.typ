#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Overview
== Introduction
The XR/computer platform is a general hardware design that is shared by the XR/station uniprocessor desktop workstation, and the XR/MP multiprocessor deskside server.

The platform is designed around the 32-bit XR/17032 RISC microprocessor, which itself is described in the _XR/17032 Architecture Handbook_. This document describes the platform as it is seen from the perspective of a system software writer; that is, details such as physical design and electrical characteristics are not discussed.

The product range encompassed by the XR/computer platform consists of:

#tablex(
  columns: (1fr, 1fr),
  auto-vlines: false,
  cellx([
    #set text(fill: white)
    #set align(center)
    *XR/MP*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *XR/station*
  ], fill: rgb(0,0,0,255)),
  [Deskside Server],
  [Desktop Workstation],
  [\$30K-120K],
  [\$8K-30K],
  [2-4 XR/17032 CPUs \@ 25 MHz],
  [1 XR/17032 CPU \@ 20 MHz],
  [8MB-128MB RAM],
  [4MB-64MB RAM],
  [1-8 200MB-1GB Hard Disks],
  [1-2 200MB-1GB Hard Disks],
  cellx([
    #set align(center)
    1024x768 \@ 8-bit Color
  ], colspan: 2),
)

#set align(center)
#image("xrcomputersabstract.png", width: 80%)
#set align(left)

#pagebreak(weak: true)

== Machine Organization

A simplified diagram of the XR/computer platform follows:

#image("xrcomputer.svg")

Note that this diagram shows a four-processor XR/MP 1500 model, the maximum extent of what an XR/computer based machine may contain. The actual models implement only a subset of this:

1. XR/station contains only one processor module, and entirely lacks an S-cache. There is only physical space for up to 4 hard disks. Finally, there are only two slots for memory sticks, limiting the machine to 64MB.
2. The XR/MP 1000 model contains only two processor modules, with a 128KB S-cache.

The Kinnow framebuffer card is part of the default configuration of all models, and is therefore described in this document, but can be excluded by order if the customer only requires a headless machine (for a discount!).

Note that since the XR/17032 architecture specifies accesses to physical addresses above 0xC0000000 (3GB) to be noncached, all memory mapped device registers are placed above this address by this platform. Additionally, the machine is entirely little-endian.

#box([

== Memory

There is a memory subsystem which contains up to 4 slots that may each hold one memory stick. A memory stick can have a capacity of 4MB, 8MB, 16MB, or 32MB. The slots are sequentially placed into the physical address space at offsets of 32MB starting at address zero, and the contents of a single stick are presented in a physically contiguous manner beginning at the base of the slot area. That is, the zeroth slot resides at 0x00000000, the first slot resides at 0x02000000, the second is at 0x04000000, etc. This creates a 128MB region in the low physical address space in which memory can be found.

])

Memory sticks need not be placed into the slots in a manner that is physically contiguous. For instance, it is possible to place a 4MB stick in slot 0 and another 4MB stick in slot 1, leaving a 28MB gap inbetween them in the physical address space. The system software will deal with this correctly. However, slot 0 must always contain some memory for use by the system ROM code.

=== Probing the Size of Memory

Accesses to empty memory slots will produce bus error exceptions after a short timeout. Therefore, the size of the memory stick in each slot (or absence thereof) can be determined by probing along the slot area until either the end of the slot is reached or a bus error occurs.

Note that the system PROM code will do this automatically, and should be consulted to acquire a map of physical memory at boot time if required.

== System PROM

The 128KB system PROM is placed into the final 128KB of the physical address space (starting at 0xFFFE0000) and contains the reset vector for the XR/17032 microprocessor. This is the first code that runs in the system during startup and is responsible for presenting a simple interface that allows the user to select a boot device, and for booting the operating system.#footnote([The _A4X_ boot firmware contained within the system PROM is described in the document _A4X Firmware Manual_.])

== NVRAM

Beginning at 0xF8001000, there is a small 4KB battery-backed non-volatile RAM (NVRAM). This is used by the boot firmware to store certain persistent variables, such as the user's preferred boot device. 

== S-cache

The secondary cache, or S-cache, is only found on multiprocessor XR/computer systems.

It is a large cache of recently accessed memory, which is much faster to access than the main DRAM but is still significantly slower than the on-chip primary caches aboard the XR/17032 microprocessors (which can be accessed in a single cycle). It is also used as a single source of truth by the cache coherency protocol.

There is no way to directly access the S-cache, and its existence is completely transparent to system software, as it is kept coherent with external device activity via a snooping write-update scheme. However, the primary caches are not kept coherent with the S-cache or with the rest of the system's autonomous activity (i.e. DMA) and must be manually invalidated by system software in certain situations.

== Expansion Slots

There are 7 slots for expansion cards which can be inserted into an XR/computer system to extend its functionality. Each slot is mapped sequentially into the physical address space at offsets of 128MB beginning at 0xC0000000, and accesses into these 128MB regions are serviced directly by the card. If a card is not present in a slot, an access will result in a short timeout followed by a bus error exception. This can be used to detect if a card is present in a slot or not.

Each slot has only one interrupt line, whose IRQ number is 0x28 + N where N is the slot number from [0, 6]. The usage of this interrupt line is up to the logic on the card. Additionally, the layout and function of the slot space is completely the province of the hardware on the card, except that it must present the following read-only data structure starting at offset zero within its slot space:

```
STRUCT SlotInfo
  // The 32-bit magic number must read 0x0C007CA1.
  Magic : ULONG,

  // The 32-bit board ID number indicates the type of the board.
  BoardId : ULONG,

  // A 15-character, null-terminated string containing a human readable
  // name for the board.
  Name : UBYTE[16],

  // 232 reserved bytes for future expansion.
  Reserved : UBYTE[232],
END
```

The following is a table of the currently defined board identifiers:

#tablex(
  columns: (0.8fr, 1fr, 1fr),
  align: center,
  cellx([
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *BoardId*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)),
  [Kinnow Framebuffer],
  [0x4B494E36],
  [kinnowfb,8],
)

== Reset Register

Writing the magical 32-bit value 0xAABBCCDD into the "reset register" located at 0xF8800000 will assert the reset line on the bus for several cycles, inducing all devices to enter a quiescent (i.e. non-interrupting) state. Nothing else about the state of the devices may be assumed except that they will not produce an interrupt until again instructed that they may do so, in whatever device-specific manner. Expansion cards must be sure to respect this.

Note that this is already done by the system PROM at startup time and need not be done again under normal circumstances.

== Revision Register

Reading from the "revision register" located at 0xF8000800 yields a 32-bit revision code for the motherboard which is divided into two 16-bit components. The upper 16 bits indicate the "major" revision, and the low 16 bits indicate the "minor" revision.