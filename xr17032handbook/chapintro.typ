#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Overview
== Introduction
XR/17032 is a 32-bit RISC architecture. This document describes it informally and is meant to be used as a reference handbook; it is intended for readers who are already somewhat familiar with computer architecture, or who are at least familiar with computer programming and have good independent research skills.

This handbook need not be read in order; the reader is encouraged to skip around as unfamiliar terms appear. A brief description of the architecture follows.

== Starting at the beginning...
The architecture’s registers and the virtual address space are 32-bit, and 32-bit values are the widest that it can load or store. It has no floating-point operations, and 64-bit wide arithmetic must be synthesized from smaller operations. This architecture is intended to be relatively simple; it includes only 60 instructions.

In the interest of supporting fancy operating system design, XR/17032 supports paged virtual addressing, as well as a distinction between user mode and kernel mode. Like most RISCs, memory accesses must be aligned to their size or else they will incur an exception, and, likewise, all instructions are 32 bits (4 bytes) wide and must be aligned to 32-bit boundaries. The architecture is little-endian.

== Registers
The architecture defines 32 general purpose registers (GPRs), usable by any instruction that takes register operands. They are each 32 bits wide. The zeroth GPR, zero, almost always reads as zero and ignores writes. This is a common RISC design tactic that simplifies the encoding of many instructions. A table of GPRs follows:

#set align(center)
#tablex(
  columns: (auto, auto, auto),
  align: horizon,
  repeat-header: true,
  cellx([
    #set text(fill: white)
    #set align(center)
    *\#*
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *ABI Assignment*
  ], fill: rgb(0,0,0,255)),
  "0", "zero", "Always reads as zero, ignores writes.",
  "1-6", "t0-5", "6 temporary registers (caller-saved).",
  "7-10", "a0-3", "First 4 arguments and return values (caller-saved).",
  "11-28", "s0-17", "18 local variable registers (callee-saved).",
  "29", "tp", "Thread-local storage pointer.",
  "30", "sp", "Stack pointer.",
  "31", "lr", "Link register."
)
#set align(left)

== Control Registers <controlregs>
The architecture defines 32 control registers (CRs). They are each 32 bits wide. As their name suggests, CRs are used to control the behavior of the processor, and are therefore only accessible via the privileged kernel mode instructions *MTCR* and *MFCR*. A table containing a summary of all defined control registers follows:

#set align(center)
#tablex(
  columns: (auto, auto, auto),
  align: horizon,
  repeat-header: true,
  cellx([
    #set text(fill: white)
    #set align(center)
    *\#*
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  "0", "RS", "Current and previous processor mode bits.",
  "1", "WHAMI", "Unique ID for this processor in a multiprocessor system.",
  "5", "EB", "Exception block base address.",
  "6", "EPC", "Program counter before the last exception.",
  "7", "EBADADDR", "Bad address that triggered the last exception (if relevant).",
  "9", "TBMISSADDR", "Bad address that triggered the last TB miss exception.",
  "10", "TBPC", "Program counter before the last TB miss exception.",
  "11-15", "SCRATCH0-4", "Permanently reserved for arbitrary system software usage.",
  "16", "ITBPTE", "Lower 32 bits of an entry to insert in the ITB. Causes ITB insertion when written.",
  "17", "ITBTAG", [Upper 32 bits of an entry to insert in the ITB. Doubles as the current *ASID*, and *VPN* of the last virtual address that missed in the ITB.],
  "18", "ITBINDEX", "Next replacement index for the ITB.",
  "19", "ITBCTRL", "Causes ITB invalidations when written.",
  "20", "ICACHECTRL", "Yields Icache size parameters when read, causes Icache invalidations when written.",
  "21", "ITBADDR", "Pre-calculated virtual PTE address for use upon ITB miss.",
  "24", "DTBPTE", "Lower 32 bits of an entry to insert in the DTB. Causes DTB insertion when written.",
  "25", "DTBTAG", [Upper 32 bits of an entry to insert in the DTB. Doubles as the current *ASID*, and *VPN* of the last virtual address that missed in the DTB.],
  "26", "DTBINDEX", "Next replacement index for the DTB.",
  "27", "DTBCTRL", "Causes DTB invalidations when written.",
  "28", "DCACHECTRL", "Yields Dcache size parameters when read, causes Dcache invalidations when written.",
  "29", "DTBADDR", "Pre-calculated virtual PTE address for use upon DTB miss.",
)
_Any absent CR numbers have undefined behavior if read or written._
#set align(left)

See @control for a more detailed description of each control register.

== Reset

When the processor is reset, for instance during a reboot or a power-on, the *RS* control register is cleared to zero. The processor is thus forced to kernel mode, virtual address translation is disabled, exposing the physical address space. The program counter is set to the address 0xFFFE1000, with the idea that a boot ROM is located at 0xFFFE0000 and is followed by an initial 4096 byte exception block.