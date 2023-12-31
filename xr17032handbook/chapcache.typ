= Memory Caching
== Introduction
Modern computer systems contain memory subsystems that produce results in a time several factors slower than the processing unit can accept them, creating a substantial performance bottleneck. The general solution to this is to add fast "cache" memory close to the processor, in which frequently or recently used memory is kept, and waits upon the machine's memory subsystem to respond can be avoided.

== Managing the Caches
The XR/17032 architecture contains a "split cache" scheme, where instruction bytes and data bytes are cached separately in an Icache and Dcache, respectively. The software-visible effects that these caches have are as follows:

1. The Icache is never automatically kept in sync with the Dcache or with the contents of memory. If the instruction stream is written into, for instance due to copying a program in memory, the Icache must be manually flushed. Otherwise, stale instruction bytes may be executed, causing problems that are hard to diagnose.
2. Depending on the platform, the Dcache may or may not be kept in sync with external device activity (i.e. a DMA transfer into memory from a disk controller). If it isn't, then manual Dcache flushes are required after these events, or stale data bytes might be seen.
3. This is an explicit statement of something that must _not_ be visible to software: in a multiprocessor system, the Dcache of each processor _must_ be kept in sync with the Dcache of all other processors in the system through some coherency protocol.

Due to these issues, among other reasons, the paging architecture includes an *N* bit in the PTE format which indicates that accesses to that page should bypass the Dcache. This bit should be used when mapping pages containing device registers for driver access.

While virtual address translation is disabled, for instance at system reset, the cache is bypassed for all accesses to physical addresses at or above 0xC0000000 (3GB). For this reason, it is advisable for a platform to place device registers in this region of the physical address space, to allow boot firmware to easily manipulate them. It is also advised to immediately copy the boot firmware from the ROM in high memory to RAM in low memory and execute it from there instead, or else it will execute noncached (that is, extremely slowly).

For detailed information on how to flush either a single page or the entirety of the Icache or Dcache, see @cachectrl.

== The Caches and XR/computer Systems

This information is included here for quick reference, and strictly speaking, belongs in these systems' respective manuals.

Neither the XR/station desktop, the XR/MP deskside server, nor the XR/frame minicomputer keep Dcache coherency with device activity. When a DMA transfer completes, the system software must be sure to flush the Dcache appropriately.

On multiprocessor configurations such as the XR/MP and XR/frame systems, the processor that handles an I/O request completion must be sure to send an IPI (inter-processor interrupt) to the other processors to ensure that they flush their Dcache as well (a "Dcache shootdown").