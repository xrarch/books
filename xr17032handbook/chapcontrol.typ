#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Processor Control <control>

=== Introduction

The behavior of the processor is primarily controlled by a small set of control registers (CRs). They are summarized by a table in @controlregs, and are explored in much more detail below.

#box([
  
=== RS <rs>
_Processor Status_

#image("rs.png", fit: "stretch")

The *RS* control register contains a three-deep "stack" of mode bits (the top of which contains the primary mode bits that control the state of the processor). The four *ECAUSE* bits identify the cause of the last exception. They are enumerated in @ecause.

], width: 100%)

When an exception is taken, several of the mode bits are overwritten to place the processor into kernel mode with interrupts disabled. Because of the need to return from an exception with the state of the processor intact, there is a need to save the previous mode bits somewhere. In some CISC designs, like fox32
#footnote([fox32 is a trademark of Ryfox Computer Corp.]),
this is accomplished by pushing the old state onto the stack.

However, because this is a design following RISCy philosophy, performing a memory access during exception dispatch is considered unacceptable complexity. Instead, there is a small "stack" of mode bits within the *RS* control register. When an exception is taken, the current mode is shifted left by 8 into the "old mode", which itself is shifted left by 8 into the "old old mode", effectively performing a "push" onto a small stack. Any mode bits in the "old old mode" at this time are destroyed, and so manually saving *RS* is required if it is desired to go more than three levels deep. The *RFE* (Return From Exception) instruction atomically reverses this, popping the old mode bits into the current mode bits.

The reason that this stack is three-deep is to account for this case:
#footnote([The mode stack was once two-deep but was grown to three when software TB miss handling was introduced to the architecture, as this case would otherwise destroy the saved state in the old mode bits. Note also that the mode stack itself is an idea borrowed from the MIPS architecture's *SR* cop0 register.])

1. Normal processing is occurring.
2. An exception occurs, pushing the original state into the old mode.
3. A TB miss exception is taken during the exception handler, before it can save *RS*, pushing the original state into the old old mode.

#box([

The mode bits are defined as follows when set:

#set align(center)
#tablex(
  columns: (auto, auto),
  align: horizon,
  cellx([
    #set text(fill: white)
    #set align(center)
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *U*
  ], fill: rgb(0,0,0,255)),
  [Usermode is active. Privileged instructions, which all have a major opcode of *101001*, are forbidden and will produce a privilege violation exception if executed.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *I*
  ], fill: rgb(0,0,0,255)),
  "External device interrupts are enabled.",
    cellx([
    #set text(fill: white)
    #set align(center)
    *M*
  ], fill: rgb(0,0,0,255)),
  [Paged virtual addressing is enabled. The ITB and DTB are looked up to translate instruction fetches and data accesses, respectively (see @mmu).],
    cellx([
    #set text(fill: white)
    #set align(center)
    *T*
  ], fill: rgb(0,0,0,255)),
  [A TB miss is in progress. This causes the *zero* register to be usable as a full register; i.e., it is not wired to read all zeroes while this bit is set. This is intended to free it as a scratch register for TB miss routines, to avoid having to save any registers. This bit also has special effects on exception handling, which are enumerated in @tbmiss.]
)
#set align(left)

], width: 100%)

Modifying the current mode bits must be done with a read-modify-write procedure; that is, if one wished to enable interrupts, they would need to read *RS* into some register, set the *I* bit, and then write the contents of that register back into *RS*. The same principle applies to the other mode bits.

#box([
=== WHAMI
_Who Am I_

In a multiprocessor system, *WHAMI* contains a numeric ID which is unique to each processor in the system. It should be in a range of \[0, MAXPROC-1\], where MAXPROC is the maximum number of processors supported by the platform. Therefore, on a uniprocessor system, it should always contain zero.

], width: 100%)

#box([
=== EB <exceptionblock>
_Exception Block Base_

#image("eb.png", fit: "stretch")

The *EB* control register indicates the base address of the exception block.

], width: 100%)

When an exception is taken by the processor, the program counter must be redirected to an exception handler. Some architectures use a table of exception vectors, which is indexed and loaded by the processor in order to determine whether to jump. However, as this is a RISC architecture, memory accesses during exception dispatch are unacceptable complexity.

Instead, upon exception, the PC is redirected to an offset within the "exception block". The offset is calculated using the *ECAUSE* code of the exception, which is a 4-bit number between 0 and 15.

The exception block occupies exactly one page frame, which is 4096 bytes in size. As there are 16 possible exception codes, each vector has room for $4096 / 16 = 256$ bytes, or $256 / 4 = 64$ instructions. This provides enough room to handle simple cases of exceptions, such as TB misses, without needing to branch outside of the exception block.

The new program counter is calculated by *EB* | *ECAUSE* << 8, and so the base address of the exception block must be page-aligned, that is, the low 12 bits must be zero, otherwise garbage may be loaded into PC.

Note that as the TB miss handlers themselves reside in the exception block, the system software must place the exception block page into a wired TB entry before virtual addressing is enabled, since the processor will not survive taking an ITB miss on the ITB handler. This also avoids costly TB misses when taking exceptions. See @tbindex or @managetb for more details on wired TB entries.

#box([
==== ECAUSE Codes <ecause>
A table of all defined exception causes follows:
], width: 100%)

#set align(center)
#tablex(
  columns: (auto, auto, auto, auto),
  align: horizon,
  repeat-header: true,
  cellx([
    #set text(fill: white)
    #set align(center)
    *\#*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *EB*
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Occurrence*
  ], fill: rgb(0,0,0,255)),
  "1", "+100", "INT", "An external interrupt has occurred.",
  "2", "+200", "SYS", [A *SYS* instruction has been executed.],
  "4", "+400", "BUS", "A bus error has occurred, usually caused by a non-existent physical address being accessed.",
  "5", "+500", "NMI", "Non-maskable interrupt.",
  "6", "+600", "BRK", [A *BRK* instruction has been executed.],
  "7", "+700", "INV", "An invalid instruction has been executed.",
  "8", "+800", "PRV", "A privileged instruction was executed in usermode.",
  "9", "+900", "UNA", "An unaligned address was accessed.",
  "12", "+C00", "PGF", "A virtual address matched to an unsuitable PTE in the TB during a read, causing a page fault.",
  "13", "+D00", "PFW", "A virtual address matched to an unsuitable PTE in the TB during a write, causing a page fault.",
  "14", "+E00", "ITB", "A virtual address failed to match in the ITB during instruction fetch.",
  "15", "+F00", "DTB", "A virtual address failed to match in the DTB during data access.",
)
_Any absent ECAUSE codes are reserved for future use._
#set align(left)

#box([
=== EPC
_Exception Program Counter_

When an exception is taken, the current program counter is saved into *EPC*. The *RFE* instruction restores the program counter from this control register, atomically with restoring the mode bits (see @rs).

], width: 100%)

#box([
=== EBADADDR
_Exception Bad Address_

When a bus error or page fault exception is taken, *EBADADDR* is filled with the physical or virtual address, respectively, that caused the exception.

], width: 100%)

#box([
=== TBMISSADDR
_Translation Buffer Missed Address_

When a TB miss exception is taken, and the *T* bit is not set in *RS*, *TBMISSADDR* is filled with the virtual address that failed to match in the TB. If the *T* bit is set, however (i.e., the processor is already handling a TB miss), this CR is left alone. This CR, therefore, is not affected upon a nested TB miss exception, and always contains the missed virtual address that caused the first one.

], width: 100%)

#box([
=== TBPC
_Translation Buffer Miss Program Counter_

When a TB miss exception is taken, and the *T* bit is not set in *RS*, the current program counter is saved into *TBPC*. If the *T* bit is set, however (i.e., the processor is already handling a TB miss), this CR is left alone. This CR, therefore, is not affected upon a nested TB miss exception, and always contains the program counter that caused the first one. Additionally, if the *T* bit is set when the *RFE* instruction is executed, it will restore the program counter to the value of *TBPC* rather than that of *EPC*, allowing instant return to the original faulting instruction without having to potentially unwind several levels of nested TB misses. See @tbmiss for more details.

], width: 100%)

#box([
=== SCRATCH0-4
_Arbitrary Scratch_

The system software can use the *SCRATCH0* through *SCRATCH4* control registers for anything. They are fully readable and writable and do not perform any action. The intended usage is to save general purpose registers to free them up as scratch within exception handlers, but other usages are also possible.

], width: 100%)

#box([
=== ITBPTE/DTBPTE <tbpte>
_Translation Buffer Page Table Entry_

#image("tbpte.png", fit: "stretch")

When written, the *ITBPTE* and *DTBPTE* control registers will cause an entry to be written to the ITB or DTB, respectively. The upper 32 bits of the entry are taken from the current value of *ITBTAG* or *DTBTAG*, and the lower 32 bits are taken from the value written to this control register.

], width: 100%)

The low 32 bits of a TB entry are its "value", indicating the page frame that the virtual page maps to. The upper 32 bits, *TBTAG*, are its "key", containing the "matching" *ASID* and the virtual page number mapped by the entry. Note that the low 32 bits form a preferred format for page table entries, hence the name of this control register. See @mmu for more information.

The PTE bits are defined as follows when set:

#set align(center)
#tablex(
  columns: (auto, auto),
  align: horizon,
  cellx([
    #set text(fill: white)
    #set align(center)
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *V*
  ], fill: rgb(0,0,0,255)),
  "The translation is valid. If this bit is clear, accesses within the page will result in the appropriate page fault exception.",
  cellx([
    #set text(fill: white)
    #set align(center)
    *W*
  ], fill: rgb(0,0,0,255)),
  [The page is writable. If this bit is clear, any write within the page will result in a *PFW* (Page Fault Write) exception.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *K*
  ], fill: rgb(0,0,0,255)),
  "The page may only be accessed while the processor is in kernel mode. Accesses from user mode will result in the appropriate page fault exception.",
  cellx([
    #set text(fill: white)
    #set align(center)
    *N*
  ], fill: rgb(0,0,0,255)),
  "Accesses within this page should bypass the caches and go directly to the bus. This is most useful for memory-mapped IO.",
  cellx([
    #set text(fill: white)
    #set align(center)
    *G*
  ], fill: rgb(0,0,0,255)),
  [This translation is global; the virtual page number will match this entry, regardless of the current *ASID*.],
)
#set align(left)

#box([
=== ITBTAG/DTBTAG <tbtag>
_Translation Buffer Tag_

#image("tbtag.png", fit: "stretch")

The *ITBTAG* and *DTBTAG* control registers contain the current *ASID* (Address Space ID), and the last virtual page number that incurred a TB miss. This control register also doubles as the uppermost 32 bits of the entry that is written to the TB when a write occurs to the *ITBPTE* or *DTBPTE* control register (see @tbpte and @tbmiss).  

], width: 100%)

#box([
=== ITBINDEX/DTBINDEX <tbindex>
_Translation Buffer Index_

The *ITBINDEX* and *DTBINDEX* control registers contain the next replacement index for the ITB and DTB, respectively. See @tbmiss for more information.

], width: 100%)

#box([
=== ITBCTRL/DTBCTRL <tbctrl>
_Translation Buffer Control_

#image("tbctrl.png", fit: "stretch")

Writes to *ITBCTRL* and *DTBCTRL* can be used to invalidate entries in the ITB or DTB, respectively. The 32-bit value written to the control register should be in one of the three formats enumerated above, distinguished by the low two bits. Any other combination of low bits will yield unpredictable results. The action of each format is as follows:

], width: 100%)

#set align(center)
#tablex(
  columns: (auto, auto),
  align: horizon,
  cellx([
    #set text(fill: white)
    #set align(center)
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *11*
  ], fill: rgb(0,0,0,255)),
  [Every entry in the TB is cleared, including entries with the *G* bit set. Note that in general, this should not be done while virtual address translation is enabled, as this may clear wired entries like the exception block, and any TB miss taken will then be fatal.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *10*
  ], fill: rgb(0,0,0,255)),
  [Clear all non-wired private entries from the TB, i.e., non-wired entries with the *G* bit clear.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *01*
  ], fill: rgb(0,0,0,255)),
  [Clear all non-wired entries from the TB, including global entries.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *00*
  ], fill: rgb(0,0,0,255)),
  [Clear all TB entries that map the given virtual address. *ASIDs* are ignored; if there are multiple TB entries with the same virtual address but different *ASIDs*, they will all be cleared.],
)
#set align(left)

Note that reads from these control registers yield unpredictable (non-useful!) results. If one wishes to determine the size of the ITB or DTB, they can set *ITBINDEX* or *DTBINDEX* to zero, and write values to *ITBPTE* or *DTBPTE* until they see the replacement index wrap. The last value of the replacement index before it wraps, plus one, is the size of that TB.

#box([
=== ICACHECTRL/DCACHECTRL <cachectrl>
_Cache Control_

#image("cachectrl.png", fit: "stretch")

Reads from the *ICACHECTRL* and *DCACHECTRL* control registers yield a 32-bit value whose bit fields indicate the parameters of the Icache and Dcache respectively; the number of lines in the cache, the number of ways (i.e. the set associativity) of the cache, and the size of a cache line are each given, in the form of a binary logarithm. I.e., if the line count field contains 8, then there are $2^8 = 256$ lines in the cache.

], width: 100%)

Writes to the *ICACHECTRL* and *DCACHECTRL* control registers cause various invalidations to occur. The 32-bit value written to the control register should be in one of the two formats enumerated above, distinguished by the low two bits. Any other combination of low bits will yield unpredictable results. The action of each format is as follows:

#set align(center)
#tablex(
  columns: (auto, auto),
  align: horizon,
  cellx([
    #set text(fill: white)
    #set align(center)
  ], fill: rgb(0,0,0,255)), cellx([
    #set text(fill: white)
    #set align(center)
    *Function*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *11*
  ], fill: rgb(0,0,0,255)),
  [Every line in the cache is invalidated. This is useful for, for example, keeping the Icache coherent after things like dynamic linking that modify the instruction stream in ways that are hard to predict.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *10*
  ], fill: rgb(0,0,0,255)),
  [Every line in the cache that is logically within the given page frame is invalidated. This is useful for, for example, keeping coherency within the Dcache after a DMA operation.],
)
#set align(left)

#box([
=== ITBADDR/DTBADDR
_Translation Buffer Miss, Page Table Entry Address_

#image("tbaddr.png", fit: "stretch")

The *ITBADDR* and *DTBADDR* control registers exist solely for the benefit of TB miss routines, and serve no other functional purpose. When a TB miss exception is taken, this control register is filled with the virtual address of the PTE to load from the virtually linear page table, saving a TB miss handler that implements this scheme from having to calculate this itself.

System software should write the upper 10 bits of this control register with the upper 10 bits of the virtual address of a virtually linear page table. As this scheme has no way to handle a page table base containing non-zero bits in the low 22 bits, the page table base should be naturally aligned to the size of the page table, i.e. $2^22$ = 4MB-aligned.

When a TB miss exception occurs, the low 22 bits of this control register are filled by the processor with the index at which the relevant PTE can be found within the virtually linear page table. As the page table is a linear array, this index is trivial to calculate; it consists simply of the upper 20 bits of the missed virtual address.

The TB miss routine can load this control register into a general purpose register and use the contents as a virtual address with which to load the 32-bit PTE directly from the virtually linear page table. If the table page happens to be resident in the DTB already, this will succeed immediately. Otherwise, a nested DTB miss may be taken. See @tbmiss for more details.

], width: 100%)

== NMI Masking Events

A problem with non-maskable interrupts (NMIs) arises on RISC architectures. If an NMI is delivered while an exception handler is saving or restoring critical state, then this can be a fatal condition.

Therefore, in order to maximize the usefulness of NMIs, the XR/17032 architecture specifies several events which delay NMI delivery for at least 64 cycles. Each occurrence of one of these events resets an internal counter that decrements once per cycle, and NMIs can only be delivered while this counter is equivalent to zero.

The following events mask NMIs for a short period of at least 64 cycles:

1. An exception is taken.
2. The *MTCR* instruction is executed.
3. The *MFCR* instruction is executed.