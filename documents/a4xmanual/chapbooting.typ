#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Booting

This section describes the boot protocol used by the A4X firmware. The old A3X boot protocol is also supported via an embedded A3X firmware which is chain-loaded when a legacy operating system is selected, but will not be documented.

A partition is bootable if it contains a valid OS record at an offset of 1 sector from the partition base (bytes 512-1023 within the partition). The OS record sector has the following layout:

```
STRUCT AptOsRecord
    // The 32-bit magic number must read 0x796D6173.
    Magic : ULONG,

    // A 15-character, null-terminated label for the installed
    // operating system.
    OsName : UBYTE[16],

    // The sector offset within the partition, at which the bootstrap
    // program begins.
    BootstrapSector : ULONG,

    // The count of sectors in the bootstrap program.
    BootstrapCount : ULONG,
END
```

If a valid OS record is found, the partition is assumed to be bootable. In the following sector (sector 2), a 64x64 monochrome bitmap is located. This is used as an icon in the boot picker.

== The Bootstrap Program

When booting from a partition, the bootstrap sectors are loaded in sequence off the disk into physical memory beginning at address 0x3000. The first 32 bits of the bootstrap must read 0x676F646E in order to be considered valid. Control is then transferred to address 0x3004, through the Jackal function pointer with the following signature:

#box([
```
FNPTR FwBootstrapEntrypoint (
    IN devicedatabase : ^FwDeviceDatabaseRecord,
    IN apitable : ^FwApiTableRecord,
    IN bootpartition : ^FwDiskPartitionInfo,
    IN args : ^UBYTE,
) : UWORD
```
])

That is, as per the Jackal ABI for XR/17032, a pointer to the *device database* is supplied in register *a0*, a pointer to the *API table* is supplied in register *a1*, a handle to the (opaque) boot partition structure is supplied in register *a2*, and an argument string is supplied in register *a3*. The bootstrap program can return a value in register *a3*.

Note that memory in the range of 0x0 through 0x2FFF should _not_ be modified until A4X services will no longer be called, as this region is used to store its runtime data (such as the initial stack).

== The Device Database

The device database is a simple structure constructed in low memory by the firmware. It contains information about all of the devices that were detected. It has the following layout:

```
STRUCT FwDeviceDatabaseRecord
    // 32-bit count of the total RAM detected in the system.
    TotalRamBytes : ULONG,

    // The number of processors detected.
    ProcessorCount : UBYTE,

    // The number of bootable partitions found.
    BootableCount : UBYTE,

    Padding : UBYTE[2],

    // A table of information about all of the RAM slots.
    Ram : FwRamRecord[FW_RAM_MAX],

    // A table of information about all of the physical disks.
    Dks : FwDksInfoRecord[FW_DISK_MAX],

    // A table of information about devices attached to the Amtsu
    // peripheral bus.
    Amtsu : FwAmtsuInfoRecord[FW_AMTSU_MAX],

    // A table of information about the boards attached to the EBUS
    // expansion slots.
    Boards : FwBoardInfoRecord[FW_BOARD_MAX],

    // A table of information about each processor detected in the
    // system.
    Processors : FwProcessorInfoRecord[FW_PROCESSOR_MAX],

    // Information about the boot framebuffer, or lack thereof.
    Framebuffer : FwFramebufferInfoRecord,

    // Information about the boot keyboard, or lack thereof.
    Keyboard : FwKeyboardInfoRecord,

    // The machine type --
    // XR_STATION, XR_MP, or XR_FRAME.
    MachineType : FwMachineType,
END
```

Note that the `Headers/a4xClient.hjk` header file located in the `a4x` source tree should be used to access the device database and other A4X structures - this incomplete information is only provided here for quick reference.

== The API Table

A pointer to an API table is passed to the bootstrap program. The API table consists of function pointers that can be called to receive services from the firmware. The currently defined APIs follow:

#box([
#tablex(
  columns: (1fr, 3fr),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Name*
  ], fill: rgb(0,0,0,255)),
  cellx([
    #set text(fill: white)
    #set align(center)
    *Signature*
  ], fill: rgb(0,0,0,255)),
  [*PutCharacter*], [```FNPTR FwApiPutCharacterF (
    IN byte : UWORD,
)```],
  [*GetCharacter*], [```FNPTR FwApiGetCharacterF () : UWORD```],
  [*ReadDisk*], [```FNPTR FwApiReadDiskF (
    IN partition : ^FwDiskPartitionInfo,
    IN buffer : ^VOID,
    IN sector : ULONG,
    IN count : ULONG,
) : UWORD```

*NOTE:* The buffer base address MUST be aligned to a sector size.],
  [*PutString*], [```FNPTR FwApiPutStringF (
    IN str : ^UBYTE,
)```],
  [*KickProcessor*], [```FNPTR FwApiKickProcessorF (
    IN number : UWORD,
    IN context : ^VOID,
    IN callback : FwKickProcessorCallbackF,
)```],
)
])