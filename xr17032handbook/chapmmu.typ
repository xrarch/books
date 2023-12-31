#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Virtual Addressing <mmu>
== Introduction
For many reasons, it is useful to be able to dynamically re-map sections of the address space to other regions of physical memory, thereby creating a "virtual address space". A few such reasons are listed below:

1. Process isolation: Programs can be completely protected from eachother by giving them their own unique address spaces.
2. Demand zero: The allocation of memory can be delayed until it is actually needed.
3. Memory-mapped files: Files on disk can be mapped into the virtual address space, giving the illusion that they are a range of bytes that can be accessed like any other memory.
4. Shared memory: Popular physical memory (such as executable code) can be shared among multiple virtual addresses in multiple address spaces, thereby saving memory.
5. Virtual memory: Disk space can be transparently used as extra memory via swapping.

The mechanism that the XR/17032 architecture uses for this is _paged_ virtual addressing, also known as "paging". In a paging scheme, the virtual address space is divided into evenly sized "pages" which can be individually re-mapped to arbitrary physical addresses. As this is a 32-bit architecture, the virtual addresses are 32 bits, leading to a $2^32$ = 4GB virtual address space. For simplicity, the only supported page size on the XR/17032 processor is 4096 bytes, or 4KB. This means that the virtual address space is evenly tiled by 4GB / 4KB = 1048576 pages.

There is now a question of how to achieve this translation. If the translation of the virtual page to the physical page is performed by looking up a physically linear page table, with 32-bit table entries, it would therefore consume 1048576 \* 4 bytes = 4MB of memory (per process!), which is obviously unacceptable overhead.

In many architectures, such as fox32 and Intel 386, the virtual address space is therefore managed by a two-level page table. The indices into the two levels of the page table are usually extracted from bit fields of the 32-bit virtual address in the manner shown:

#image("vaddr.png", fit: "stretch")

The two 10-bit fields from 22:31 and from 12:21 contain the index into the level 2 table and the level 1 table, respectively.

As these indices are 10 bits, and the entries are 4 bytes wide, these tables are both $2^10$ \* 4 = 4096 bytes in size.#footnote([Note that this is one reason for the usage of the 4KB page size: this is the page size for which the division of the virtual address into these three fields causes the tables to consume single page frames, which simplifies memory management.])

To translate a virtual address, the level 2 table is indexed first, yielding a 32-bit entry that contains the physical address of the level 1 table. This level 1 table is indexed next, yielding the 20-bit page frame number to which this virtual page is mapped. The 12-bit byte offset is appended to this, yielding the final 32-bit physical address to which the memory access should be performed. Note that each address space needs its own level 2 page table, which may point to up to 1024 level 1 page tables, which each map 1024 virtual pages to physical pages.

This scheme allows the omission of large sections of the page table that are not needed. In practice, virtual address spaces tend to be very sparse, so this usually reduces the original 4MB page table overhead to a mere handful of kilobytes per process.

However, there is one major problem: you now have to perform two extra memory accesses for each memory access! The solution to this is, as with many things in computer science, a cache: processors that employ this scheme contain a translation buffer, or TB,#footnote([Also called a "translation lookaside buffer" or TLB.]) which is a small memory typically containing 8 to 64 cached page table entries. The TB is usually fully associative, meaning that it can be indexed directly by virtual address; the virtual page number is compared simultaneously with all of the entries in the TB, and if any of them contain a matching entry, it is returned. This can easily be done within a single cycle, and a hit in the TB avoids the cost of looking up the page tables.

In the case that a needed virtual page translation is not cached in the TB, a "TB miss" occurs. On architectures like the aforementioned fox32 and Intel 386, this results in a page table walk done automatically by the hardware, which then inserts the page table entry in the TB. The instruction is then transparently re-executed and hopefully succeeds this time.

This, still, has two major problems:

1. Complicated: The logic to perform a page table lookup in hardware is quite complex; it takes up many extra gates on the chip and can be difficult to debug during the development of prototype hardware.
2. Inflexible: If the system software wishes to manage its own custom paging structures, it is out of luck. It must use the hardware-enforced page tables.

For these reasons, XR/17032 instead uses a "software refill" design. In such a design, the management of the TB is exposed directly to software. When a TB miss occurs, an exception is taken, which redirects execution to a software routine which looks up the paging structure, loads the page table entry (PTE), and writes it into the TB. This exception handler returns, causing the re-execution of the original instruction, which hopefully succeeds this time.

In a software refill scheme, the system software has the ability to implement any paging structure it sees fit, and much complexity is removed from the hardware logic.

You can see this as the previously mentioned paging scheme "flipped on its head" -- instead of a two-level page table being the primary governor of paging and the TB existing only as a nearly-transparent cache for it, the fixed-size TB is the first class citizen. The TB contains all of the currently valid mappings, and needs to be manually refilled from some other paging structure (such as a two-level page table).

#image("tbexample.png", fit: "stretch")

In the example above, there is a 4-entry TB, containing entries for the virtual page numbers 00AA5, 00B36, 00CCD, and 003C4. The program references a virtual address 00B36499, which is provided as the input to the TB. The page number, 00B36, is compared with all entries in the TB simultaneously. Luckily, one of the entries matches, and produces the physical page number 3045A. The byte offset from the original virtual address is appended to this physical page number, producing the final physical address with which the processor will perform the memory access.

Had there not been a matching entry in the TB, a TB miss exception would have occurred. The TB miss handler would have inserted the correct entry into the TB, and the original instruction would have re-executed; beginning this process again, but matching in the TB this time and succeeding.

== The Translation Buffers <managetb>

The XR/17032 architecture has two TBs. In fact, it could be seen as having two MMUs; an IMMU and a DMMU, providing translations for instruction fetch and data access respectively. This is to simplify pipelined implementations where a FETCH and MEMORY stage may want to access the TB to translate a virtual address simultaneously. The TB management scheme is architected such that the actual size of each TB is transparent to system software and may vary from processor to processor.

When the *M* bit is set in the *RS* control register (see @rs), instruction fetches are translated by the ITB, and data accesses are translated by the DTB. The TB entries are each 64 bits wide. The upper 32 bits contain the *TBTAG*, which is the 12-bit *ASID* (Address Space ID) and 20-bit *VPN* (Virtual Page Number) that will match the TB entry. The lower 32 bits contain the *TBPTE*, containing the 20-bit physical page number along with some flag bits. The *TBPTE* is the "preferred" format for a page table entry. See @tbtag for the format of the *TBTAG*, and @tbpte for the format of the *TBPTE*.

Something important to note is the difference between a TB miss exception, and a page fault exception. A TB miss exception occurs when a key consisting of a *VPN* and the current *ASID* fails to match in the TB. A page fault occurs when it _does_ match, but matches to a PTE whose *V* _Valid_ bit is clear. This is behavior that differs significantly from other architectures like Intel 386: it is possible to have a TB entry that matches a virtual page, but is invalid and causes a page fault.

This seemingly strange behavior makes more sense when you recall that we perform software TB miss handling. This behavior makes it possible to perform an optimization in which an invalid PTE can be "blindly" inserted into the TB, the faulting instruction can be re-executed, and a page fault then occurs. If this were not the case, the TB miss handler would need to have a branch to make sure that the PTE is valid before it inserts it into the TB, and branch to the page fault handler if it isn't. Adding a branch to what may be the hottest codepath in the entire system is a bad plan, as opposed to allowing invalid PTEs to match in the TB.

Note that this has implications on TB management. A page must be flushed from the TB not only when it is transitioned from valid to invalid, but also when it is transitioned from invalid to valid. Otherwise a stale TB entry may continue to track the page as invalid, causing erroneous page fault exceptions when it is accessed.

=== Address Space IDs

To describe *ASIDs*, it is useful to describe the problem they solve. Most multitasking operating systems operate under a scheme where each process has its own isolated address space. As a result, when a context switch occurs, the address space is also switched. The contents of the TB are irrelevant to the new address space. In some architectures, this necessitates flushing the entire contents of the TB, which incurs many extra expensive TB misses and is therefore quite wasteful.

One trick that helps alleviate some of the burden is to add a *G* bit, or global bit, to the page table entry. This indicates that any entry for that page should be left in the TB upon address space switch, and is useful to set for globally shared mappings such as those in kernel space. However, this solution still isn't perfect, as you still lose many TB entries from other processes' userspace that may have been useful to have after switching back to that process.

One extra feature that you can place atop *G* bits is the concept of an address space ID, or *ASID*. Each TB entry has a 12-bit *ASID* associated with it, along with the virtual page number. If the *G* bit is clear in a TB entry, it will only match a virtual address if the current *ASID* stored in the *ITBTAG* or *DTBTAG* control register (depending on which TB it is#footnote([Note that in general, the *ASID* field should be the same in the *ITBTAG* and *DTBTAG* control registers; it's hard to imagine a situation where it would be useful for them to differ. However, this is not prohibited.])) is equivalent to the one stored in the TB entry. If the *G* bit is set, the TB entry will match the virtual address regardless of the current *ASID*; it will match in all address spaces.

By assigning a different *ASID* to each process, you can now have the TB entries for multiple address spaces residing in the TB simultaneously without fearing virtual address collisions, and can completely avoid flushes on context switch. Logically, if it helps, you can think of the *ASID* as being an extra 12 bits on the virtual address, in order to differentiate identical virtual page numbers that belong to different address spaces. If this doesn't help, then forget that sentence and try to live the rest of your life in bliss.

=== Translation Buffer Invalidation

See @tbctrl for a thorough explanation on how to invalidate entries in the TB by writing to the *ITBCTRL* and *DTBCTRL* control registers.

== Translation Buffer Miss <tbmiss>

As explained earlier, the XR/17032 architecture invokes a software exception handler when a TB miss occurs. There are two TB miss exception vectors, one for ITB miss and one for DTB miss (see @ecause for the exact offsets). This makes the miss handlers shorter as they do not need to figure out which TB to insert the entry into; there can simply be a distinct miss handler which deals only with that TB.

The behavior of the processor when a TB miss occurs is contingent on whether the *T* bit was set in the *RS* control register's current mode bits. This bit is also set by a TB miss, so in reality, it is contingent on whether the TB miss is "nested" within another TB miss or not. The reason you would want to take a TB miss within a TB miss handler will be elucidated later.

#box([

#tablex(
  columns: (1fr, 1fr),
  align: horizon,
  width: 100%,
  auto-vlines: false,
  cellx([
    #set align(center)
    #set text(fill: white)
    *TB Miss Exception Behavior*
  ], fill: rgb(0,0,0,255), colspan: 2),
  cellx([
    #set text(fill: white)
    *T=0*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    *T=1*
  ], fill: rgb(0,0,0,255)),
  [
    The *TBMISSADDR* control register is set to the missed virtual address.
  ],
  [
    The *TBMISSADDR* control register is left alone.
  ],
  [
    Normal exception logic occurs; the *RS* mode stack is pushed. However, the exception program counter is saved in the *TBPC* control register instead of the *EPC* control register.
  ],
  [
    None of the normal exception logic occurs except to redirect the program counter to the appropriate exception vector. The *RS* mode stack is not pushed.
  ],
  [
    The *T* bit is set.
  ],
  [
    The *T* bit remains set.
  ]
)

], width: 100%)

There are also some special cases for page faults that occur while the *T* bit is set. Note that this behavior essentially causes the new page fault to look like a page fault on the original virtual address that missed in the TB, instead of a page fault on the virtual address referenced by the TB miss handler.

#box([

#tablex(
  columns: (1fr, 1fr),
  align: horizon,
  width: 100%,
  auto-vlines: false,
  cellx([
    #set align(center)
    #set text(fill: white)
    *Page Fault Exception Behavior*
  ], fill: rgb(0,0,0,255), colspan: 2),
  cellx([
    #set text(fill: white)
    *T=0*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    *T=1*
  ], fill: rgb(0,0,0,255)),
  [
    The *EBADADDR* control register is set to the faulting address.
  ],
  [
    The *EBADADDR* control register is set to the value of the *TBMISSADDR* control register.
  ],
  [
    A Page Fault Read exception is triggered if the access was a read, or Page Fault Write otherwise.
  ],
  [
    If the last TB miss exception that occurred while the *T* bit was clear was a read, a Page Fault Read exception is generated, otherwise Page Fault Write.
  ],
  [
    Normal exception logic occurs. The *RS* mode stack is pushed.
  ],
  [
    None of the normal exception logic occurs except to redirect the program counter to the appropriate exception vector. The *RS* mode stack is not pushed. The *T* bit is cleared. The *EPC* control register is set to the value of the *TBPC* control register.
  ]
)

], width: 100%)

Aside from the special cases in TB miss and page fault handling, there is another major effect of the *T* bit being set, which is that the *ZERO* register is no longer hardwired to read all zeroes. It can therefore be used freely as a scratch register by TB miss routines, without needing to be saved or restored.

In either case, the low 20 bits of the *ITBTAG* or *DTBTAG* control register are automatically filled with the virtual page number of the virtual address that failed to match in the TB. This also shortens the TB miss handler, because it doesn't need to assemble the upper 32 bits of the TB entry: the appropriate *ASID* for the mapping (the same as the current one) is already set, and now so is the appropriate *VPN*. It only needs to load the PTE for the mapping and insert it into the TB by writing it to either the *ITBPTE* or *DTBPTE* control register. The upper 32 bits of the resulting TB entry are taken from the current value of *ITBTAG* or *DTBTAG*, and the lower 32 bits are taken from the PTE written to the control register.

The index into the TB that is overwritten with the new entry is taken from the control register *ITBINDEX* or *DTBINDEX*, which is then automatically incremented, creating a FIFO behavior for TB replacement. When the replacement index reaches the end of the TB, it wraps back to 4 instead of 0. This means that entries [0-3] will never be replaced naturally, and are permanent or "wired" entries that can be used to create permanent virtual page mappings for any purpose.#footnote([As an example of the usage of wired entries, system software will typically map the exception block (see @exceptionblock) permanently with one wired entry of the ITB to avoid taking an ITB miss on the ITB miss handler, which for obvious reasons is an unrecoverable situation.])

With all of this information, you can now imagine a TB miss handler which does a manual page table walk; it calculates an offset within the level 2 page table and loads the level 2 PTE, decodes this to get the address of the level 1 page table, and then loads the level 1 PTE. The level 1 PTE can be written to the appropriate *ITBPTE* or *DTBPTE* control register to write the TB entry, and then the miss routine can return.

This scheme would work, and is in fact used by the _AISIX_ kernel, which runs with memory mapping disabled in kernel mode. However, it has several significant issues:

1. It requires access to the physical address space. As memory mapping is not disabled when an exception is taken, you would have to ensure that the exception block is identity mapped. This would allow you to disable paging on the fly within the exception block, perform the miss handling, and then return.
2. Two memory loads must be done in all cases.
3. It is quite a lengthy codepath, and requires several branches.

It is possible to do much better. In fact, it is possible with a small amount of extra work in the architecture and system software to accomplish a two-level page table TB miss routine which looks like this, as taken from the _MINTIA_ executive:

#rect([
```
DtbMissRoutine:
  mfcr zero, dtbaddr
  mov  zero, long [zero]
  mtcr dtbpte, zero
  rfe
```
], width: 100%)

At a mere four instructions, with zero branches, this is fairly close to optimal. In essence, this routine works by running in the virtual address space and loading the PTE directly from a linear page table, and then writing it to the TB. Unfortunately, explaining how this works requires some labor.

To begin, we have to understand the concept of a "virtually linear page table". It turns out that placing the level 2 page table as an entry into itself creates a region of virtual address space which maps the two-level page tables as if they were a linear array indexed by virtual page number.#footnote([This is also sometimes referred to as "recursive mapping" or "recursive paging".])  The reason for this is that accessing memory within this region causes the level 2 page table to be treated as a level 1 page table, and so all of its entries directly map the level 1 page tables. The level 2 page table itself can also be found within this region.

Pseudo-code for calculating the base address of the virtually linear page table is provided:

#rect([
```
// Assume INDEX is a constant containing the index of the level 2 page
// table that has been set to create the virtually linear page table
// mapping. Any index can be chosen to place the linear page table within
// the address space as desired.

// Since each level 1 page table maps 1024 pages of 4096 bytes each,
// the following formula can be used to find the base address. Note that
// it is always 4 megabyte aligned.

LinearPageTableBase := INDEX * 1024 * 4096

// Since each level 1 page table is mapped as a 4096 byte page within
// the virtually linear page table, the following formula can be used
// to find the address of the level 2 table itself.

Level2Table := LinearPageTableBase + INDEX * 4096
```
], width: 100%)

The architectural support provided for loading the PTE out of a virtually linear page table comes in the form of the *ITBADDR* and *DTBADDR* control registers. When a TB miss occurs, the low 22 bits of this control register are filled with the virtual page number of the missed address, shifted left by 2. If the upper 10 bits of the control register was previously filled with the 4 megabyte aligned base address of the linear page table, then upon a TB miss, this control register will contain the address from which the PTE can be loaded. This saves several instructions that would otherwise be required to calculate this address.

There are now two cases that are concerning. The first is the case where the page table in which the PTE resides is not present in the DTB. A nested TB miss will occur upon an attempt to load the PTE. This sounds like it would always be a fatal condition, until three facts are recalled from earlier in this chapter:

1. The TB has support for 4 "wired" or permanent entries which are never replaced.
2. The PTE address for the miss on the page table page will always reside within the level 2 page table.
3. There is special cased behavior for TB misses, enabled by the *T* bit of *RS* which is set when a TB miss is taken.

If system software maps the level 2 table page with one wired entry of the DTB, this will provide an "anchor point" which will halt the chain of DTB misses. The nested DTB miss will load the level 2 page table entry for the page table and insert it into the DTB. Due to the special cased behavior of nested TB misses, the exception state of the original TB miss was left completely intact, and so the nested TB miss will return directly to the instruction that caused the original miss. This instruction re-executes, and misses again, as the original page it needed is still not in the TB. However, the TB miss handler will now succeed in loading the PTE from the virtually linear page table, as we inserted the page table page into the DTB during the nested TB miss earlier.

Careful readers will now understand how the four instruction TB miss routine from earlier works. You may also note that this scheme has an extra benefit, whereby only one memory access is needed to load the PTE from the two-level page table, as long as the containing level 1 page table is already present in the DTB. Note that the nested TB miss which loads the level 1 page table into the DTB does not require any special code, the processor merely (re-)executes the exact same normal DTB miss handler.

There is one small snag, which is the second concerning case from earlier. If the level 1 page table does not actually exist, then the nested DTB miss will load an invalid level 2 page table entry into the DTB. In this case, a page fault will occur in the TB miss handler when it attempts to load the PTE from the level 1 page table again. The special cased page fault behavior listed earlier addresses this case, by clearing the *T* bit and setting *EBADADDR* to the value of *TBMISSADDR*. It also keeps the exception state intact in a similar manner to the nested TB miss special case. The page fault exception handler is thereby "fooled" into thinking that the original instruction caused a page fault on the original missed address.#footnote([Note that a processor implementation must keep a latch somewhere that remembers whether the last non-nested TB miss (the last one that occurred while the *T* bit was clear) was caused by a read or write instruction, so that this page fault case will result in the appropriate page fault exception.])