#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= A3X Partition Table

The partition table format understood by this firmware is the *A3X Partition Table* format, or APT. The following is an overview of this format.

If a disk is formatted with APT, sector 0 (bytes 0-511 on disk) will contain the partition table with the following layout:

```
STRUCT AptBootBlock
    // Space for 15 bytes of boot code on relevant platforms.
    BootCode : UBYTE[15],

    // Always contains 0xFF.
    FfIfVariant : UBYTE,

    // Eight partition table entries.
    Partitions : AptEntry[8],

    // The 32-bit magic number must read 0x4E4D494D.
    Magic : ULONG,

    // A 15-character, null-terminated label for the disk.
    Label : UBYTE[16],
END

STRUCT AptEntry
    // A 7-character, null-terminated label for the partition.
    Label : UBYTE[8],

    // A 32-bit count of sectors in the partition.
    SectorCount : ULONG,

    // The status of the partition. Contains zero if the partition
    // table entry is unused. Otherwise, it contains any non-zero
    // value.
    Status : ULONG,
END
```