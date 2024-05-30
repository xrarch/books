#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Booting

This section describes the boot protocol used by the A4X firmware. The old A3X boot protocol is also supported via an embedded A3X firmware which is chain-loaded when a legacy operating system is selected, but will not be documented.

Note that all of the client-facing structures and services described here (in general, everything prefixed with `Fw`) can be found in the `Headers/a4xClient.hjk` header file located in the `a4x` source tree, which should be included in order to access them.

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
    IN bootpartition : ^VOID,
    IN args : ^UBYTE,
) : UWORD
```
])

That is, as per the Jackal ABI for XR/17032, a pointer to the *DeviceDatabase* is supplied in register *a0*, a pointer to the *ApiTable* is supplied in register *a1*, a handle to the boot partition is supplied in register *a2*, and an argument string is supplied in register *a3*. The bootstrap program can return a value in register *a3*.

Note that memory in the range of 0x0 through 0x2FFF should _not_ be modified until A4X services will no longer be called, as this region is used to store its runtime data (such as the initial stack).

== The Device Database

The *DeviceDatabase* is a simple structure constructed in low memory by the firmware. It contains information about all of the devices that were detected. It has the following layout:

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

```
STRUCT FwApiTableRecord
    PutCharacter : FwApiPutCharacterF,
    GetCharacter : FwApiGetCharacterF,
    ReadDisk : FwApiReadDiskF,
    PutString : FwApiPutStringF,
    KickProcessor : FwApiKickProcessorF,
END
```

#pagebreak(weak: true)

=== PutCharacter

```FNPTR FwApiPutCharacterF (
    IN byte : UWORD,
)```

Puts a single character to the firmware console.

=== GetCharacter

```FNPTR FwApiGetCharacterF () : UWORD```

Returns a single byte from the firmware console. This is non-blocking and returns -1 (0xFFFFFFFF) if no bytes are available.

=== ReadDisk

```
FNPTR FwApiReadDiskF (
    IN partition : ^VOID,
    IN buffer : ^VOID,
    IN sector : ULONG,
    IN count : ULONG,
) : UWORD
```

Reads a number of sectors from the specified partition handle into the buffer. The base address of the buffer _must_ be aligned to a sector size boundary. Returns *TRUE* (non-zero) if successful, *FALSE* (zero) otherwise.

=== PutString

```
FNPTR FwApiPutStringF (
    IN str : ^UBYTE,
)
```

Puts a null-terminated string of bytes to the firmware console. Could be easily synthesized from *PutCharacter* but is provided for convenience to small boot sectors written in assembly language.

=== KickProcessor

```
FNPTR FwApiKickProcessorF (
    IN number : UWORD,
    IN context : ^VOID,
    IN callback : FwKickProcessorCallbackF,
)
```

Causes the processor with the specified number to execute the provided callback. The callback routine is called with the opaque context value and with the number of the processor. Its signature follows:

```
FNPTR FwKickProcessorCallbackF (
    IN number : UWORD,
    IN context : ^VOID,
)
```

*KickProcessor* does not wait for the callback to be executed; execution continues on both processors asynchronously. If synchronization is required, it must be implemented manually.

If the processor with the given number (equivalent to its index in the *DeviceDatabase*) does not exist, the results are undefined.

Also note that the firmware does not contain multiprocessor synchronization, so if firmware services may be invoked by multiple processors concurrently, locking must be provided by the user.

The size of the initial stack provided by the firmware for processors other than the boot processor is not explicitly defined here, but is quite small, so the depth of the call stack during execution of the callback must either be very small, or the recipient processor must switch quickly to a new stack.