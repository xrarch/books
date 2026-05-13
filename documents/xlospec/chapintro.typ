#import "config.typ": *

= Overview

The XR/SDK Linkable Object (XLO) file format is the native object file format of the XR/SDK suite of tools. It is the only file format emitted by the XR/ASM assembler, and  the only file format accepted by the XR/LINK linker. It is suitable for use as an intermediate object code format, as an executable file format, as a static library format, and as a dynamic library format.

It is designed to be portable and simple, with current support for the XR/17032 and fox32 architectures, and planned support for the Aphelion 64-bit architecture. Architecture-specific details are limited to the definition of new relocation entry types. It is designed for flexibility, with the ability to specify arbitrary sections. The tables are laid out for rapid iteration of relevant entries during the process of load-time program relocation and dynamic linking, and an link-time relocation scheme helps avoid both of these costs entirely.

A module file consists of a header followed by a number of tables, linked together via file pointers (byte offsets into the file). At the end is the data for each section. The metadata contained within the file, that is, the header and the tables, are referred to collectively as the "head" of the file. The "head length" of a module file is the length of all of the contents up to the end of the last metadata.

An maximal module file will contain a header, a section table, relocation tables, a symbol table, an extern table, an unresolved fixups table, an import table, an import fixups table, a string table, and finally section data.

Definitions are given in the syntax of the Jackal language. Note for reference that in Jackal, a UBYTE is 8 bits, a UINT is 16 bits, a ULONG is 32 bits, a UQUAD is 64 bits, and a UWORD is an integer that is the same size as a pointer on the target machine.

#pagebreak(weak: true)

#aGroup[

= Header

The header of an XLO file contains general information about the module file, and provides information required to find and parse the tables of metadata. There are two variants of the header, "normal" and "extended". These vary only by the extended header featuring two extra fields. The extended header is present within "fragment" modules, that is, modules that have the FRAGMENT flag (bit 0) set within the Flags field of the normal header.

In future revisions, extra fields may be added beyond the end of the extended header, but the header's length will always remain 64-bit aligned.

```
STRUCT XloHeader
    Magic : ULONG,

    SymbolTableOffset : ULONG,
    SymbolCount : ULONG,

    StringTableOffset : ULONG,
    StringTableSize : ULONG,

    TargetArchitecture : ULONG,

    HeadLength : ULONG,
    
    ImportTableOffset : ULONG,
    
    Flags : ULONG,
    Timestamp : ULONG,
    
    SectionTableOffset : ULONG,
    ExternTableOffset : ULONG,
    
    ExternCount : ULONG,
    SectionCount : UINT,
    ImportCount : UINT,
END

STRUCT XloHeaderExtended
    Hdr : XloHeader,

    UnresolvedFixupTableOffset : ULONG,
    UnresolvedFixupCount : ULONG,
END
```

#caption[The definition of the XLO header in the Jackal language.]

]

#aGroup[
#microHeading("Magic")
Magic contains the 32-bit magic number that indicates this is an XLO file. It should read 0x6174737F.


```
Little-endian:          Big-endian:
Magic[0] = 0x7F         Magic[0] = 0x61
Magic[1] = 0x73         Magic[1] = 0x74
Magic[2] = 0x74         Magic[2] = 0x73
Magic[3] = 0x61         Magic[3] = 0x7F
```
#caption[The in-memory layout of the magic number.]

]

#aGroup[
#microHeading("SymbolTableOffset and SymbolCount")
SymbolTableOffset contains the file pointer of the table which describes the symbols exposed by the module. SymbolCount contains the number of entries within that table. If SymbolCount is zero, SymbolTableOffset has undefined meaning.
]

#aGroup[
#microHeading("StringTableOffset and StringTableSize")
StringTableOffset contains the file pointer of the "string table", which is the hunk of all null-terminated ASCII strings used by metadata within the module. StringTableSize contains its length, up to (and including) the null terminator of the final string. If StringTableSize is zero, StringTableOffset has undefined meaning.
]


#aGroup[
#microHeading("TargetArchitecture")
TargetArchitecture contains the 32-bit architecture code indicating which instruction set the code within the module is for.

#roundedTable(
  columns: (auto, 1fr),
  [], [Architecture],
  [0], [Unknown or not applicable],
  [1], [XR/17032],
  [2], [Fox32],
  [3], [Aphelion],
  [4], [AMD64],
)

#caption[Currently defined architecture codes.]

]

#aGroup[
#microHeading("HeadLength")
HeadLength contains the length in bytes of all of the metadata for the module. It must therefore be grouped together at the beginning of the file to form a region known as the "head" that precedes all section data.
]

#aGroup[
#microHeading("ImportTableOffset and ImportCount")
ImportTableOffset contains the file pointer of the "import table", a flat array of entries which describe the dynamically linked libraries that are depended upon by this module. ImportCount contains the 16-bit count [0, 65535] of entries in this table. If the module is a fragment (FRAGMENT is set in the Flags field), ImportCount must be zero. When ImportCount is zero, the meaning of ImportTableOffset is undefined.
]

#aGroup[
#microHeading("Flags")
Flags contains up to 32 flags indicating characteristics of the module file.

#roundedTable(
  columns: (auto, auto, 1fr),
  [], [Name], [Meaning],
  [0], [FRAGMENT], [This file is a fragment; it has an extended header and is not yet suitable for relocation or dynamic linking. These files are produced directly by the assembler.],
  [1], [STRIPPED], [This file was stripped of its internal relocations. Its sections can only be loaded in the address space at the location to which they were linked.],
)

#caption[Currently defined module flags.]

]

#aGroup[
#microHeading("Timestamp")
Timestamp contains a 32-bit Unix Epoch timestamp (in seconds) of when the module file was encoded to disk. It is intended primarily to provide a unique versioning among multiple versions of the same dynamic library. When a dynamic library is linked against, its Timestamp field is captured in the import table entry. Mismatched timestamps indicate to the runtime dynamic linker that the library was updated, and that any modules that reference the old version must be fixed up.
]

#aGroup[
#microHeading("SectionTableOffset and SectionCount")
SectionTableOffset contains the file pointer of the "section table", a flat array of "section headers" that describe the sections contained within the module file. SectionCount contains the 8-bit number [0, 255] of entries in this table. When it is zero, the meaning of SectionTableOffset is undefined. SectionCount can physically contain a 16-bit count, but other fields within the format limit the number of sections in a single module to 255.
]

#aGroup[
#microHeading("ExternTableOffset and ExternCount")
ExternTableOffset contains the file pointer of the "extern table", a flat array that describes all required symbols that reside in other modules. ExternCount is the 16-bit number [0, 65535] of entries in this table. When it is zero, the meaning of ExternTableOffset is undefined.
]

#aGroup[
#microHeading("UnresolvedFixupTableOffset and UnresolvedFixupCount")
These two entries reside in the extended header and therefore only exist in fragment modules. UnresolvedFixupTableOffset contains the file pointer of the "unresolved fixup table", a flat array of relocation entries that depend on the value of unresolved extern symbols in order to be processed. UnresolvedFixupCount contains the number of entries in this table. If it is zero, the meaning of UnresolvedFixupTableOffset is undefined.
]

#pagebreak(weak: true)

#aGroup[

= Symbol Table

The symbol table is an array of symbol entries, each representing a named value that is exposed by the module. This structure is essential for linking (both static and dynamic) and debugging (for stack traces, etc). A symbol normally corresponds to a function, variable, or data structure defined in a high-level language like Jackal.

```
STRUCT XloSymbolEntry
    SectionIndex : UBYTE,
    Type : UBYTE,
    Flags : UBYTE,
    Padding : UBYTE,
    SectionOffset : ULONG,
    NameOffset : ULONG,
END
```

#caption[The definition of a symbol entry.]

]


#aGroup[
#microHeading("SectionIndex")
SectionIndex is the 8-bit index [0, 255] into the section table of the section that this symbol resides in; i.e. the section that the SectionOffset field is relative to.
]

#aGroup[
#microHeading("Type")
Type is the 8-bit type code indicating properties of the symbol.

#roundedTable(
  columns: (auto, auto, 1fr),
  [], [Name], [Meaning],
  [1], [GLOBAL], [This symbol is visible to other modules in a statically linked compilation unit, but will not be included in the symbol table of a final executable or dynamic library.],
  [2], [EXPORT], [This symbol is visible to other modules in both a statically and dynamically linked unit. Is included in a final symbol table after linking.],
  [3], [WEAK], [This symbol is visible to other modules in a statically linked compilation unit, but will not be included in the symbol table of a final executable or dynamic library. References to this symbol may be redirected to references to another symbol with the same name.],
)

#caption[Currently defined symbol type codes.]

]

#aGroup[
#microHeading("Flags")
Flags contains up to 8 bit flags indicating characteristics of the symbol. No symbol flags are currently defined.
]

#aGroup[
#microHeading("SectionOffset")
SectionOffset is the offset within the section at which the symbol resides.
]

#aGroup[
#microHeading("NameOffset")
NameOffset is the offset from the base of the string table at which the null-terminated ASCII symbol name resides.
]

#pagebreak(weak: true)

#aGroup[
= Import Table

The import table is the array of entries that describe the dynamic libraries upon which this module depends at runtime. The loader must walk this table and load all dependent libraries.

```
STRUCT XloImportEntry
    NameOffset : ULONG,
    ExpectedTimestamp : ULONG,
    FixupTableOffset : ULONG,
    FixupCount : ULONG,
END
```

#caption[The definition of an XLO import entry.]

]

#aGroup[
#microHeading("NameOffset")
NameOffset is the offset from the base of the string table at which the null-terminated ASCII dynamic library name resides. The exact interpretation of this name is operating system dependent.
]

#aGroup[
#microHeading("ExpectedTimestamp")
ExpectedTimestamp contains a 32-bit Unix Epoch timestamp (in seconds), captured from the Timestamp field of the dynamic library's header. It is intended primarily to provide a unique versioning among multiple versions of the same dynamic library. When a dynamic library is linked against, its Timestamp field is captured here. Mismatched timestamps indicate to the runtime dynamic linker that the library was updated, and that this module must be fixed up.
]

#aGroup[
#microHeading("FixupTableOffset and FixupCount")
FixupTableOffset contains the file pointer of a "fixup table", containing all of the relocations that must be performed at runtime should this dynamic library have a mismatched version, or fail to load at its preferred base address. FixupCount contains the number of entries in this table.
]

#pagebreak(weak: true)

#aGroup[
= Relocation and Fixup Tables

There are several "relocation tables" within the XLO format:

#box[

- The per-section relocation tables, describing all of the "internal" relocations that must be performed if that section is moved in the virtual address space.
- The unresolved fixup table, containing all of the external relocations that must be performed against the value of extern symbols that are still of totally unknown origin. These are common in fragment modules that have just been produced by an assembler and are destined to be linked into an executable or library.
- The per-import fixup tables, containing all of the "external" relocations that must be performed if that imported dynamic library is of an unexpected version, or if it fails to load at its preferred base address.

]

The entries of the per-section relocation tables and the unresolved fixup table share a common format.

It's important to note that all relocations except for import fixups are performed relative to the value that is already encoded in that location. For instance, if a section is relocated from virtual address 0x10000000 to 0x10010000, the relocations in that section's table will be performed by adding the difference (0x10000) to all of the values already encoded there.

Import fixups are performed by calculating the address of the referenced symbol, adding the sign-extended contents of the OriginalValue field of the fixup to it, and replacing the value entirely.

```
STRUCT XloRelocEntry
    SectionOffset : ULONG,
    ExternIndex : UINT,
    Type : UBYTE,
    SectionIndex : UBYTE,
END
```

#caption[The definition of a relocation entry.]


```
STRUCT XloImportFixupEntry
    SectionOffset : ULONG,
    ExternIndex : UINT,
    Type : UBYTE,
    SectionIndex : UBYTE,
    OriginalValue : ULONG,
END
```

#caption[The definition of an import fixup entry.]

]

#aGroup[
#microHeading("SectionOffset")
SectionOffset contains the offset within the "target section" of the pointer that must be relocated.
]

#aGroup[
#microHeading("ExternIndex")
ExternIndex contains the 16-bit index [0, 65535] of the entry within the extern table that describes the external symbol this relocation relies upon. This field has no meaning and is unused if this is an internal (i.e. per-section table) relocation.
]

#aGroup[
#microHeading("Type")
Type contains the 8-bit type code [0, 255] of the pointer that must be relocated.

#roundedTable(
  columns: (auto, auto, 1fr),
  [], [Name], [Meaning],
  [1], [PTR], [32 or 64-bit pointer, depending on the bitness of the module's target architecture.],
  [2], [XR17032_ABSJ], [An XR/17032 absolute jump instruction.],
  [3], [XR17032_LA], [An XR/17032 LA pseudo-instruction.],
  [4], [XR17032_FAR_INT], [An XR/17032 far-int access pseudo-instruction.],
  [5], [XR17032_FAR_LONG], [An XR/17032 far-long access pseudo-instruction.],
  [6], [FOX32_CALL], [A fox32 CALL instruction.]
)

#caption[Currently defined relocation type codes.]

]

#aGroup[
#microHeading("SectionIndex")
SectionIndex is the 8-bit index [0, 255] into the section table of the "target section" that this relocation modifies; i.e., the section that the SectionOffset is relative to.
]

#aGroup[
#microHeading("OriginalValue")
OriginalValue is a field exclusive to the import fixup entry structure (it is not present in the relocation entry structure). It provides a sign-extended 32-bit value that should be used as the addend value for the relocation, rather than a value encoded in the instructions.
]

#pagebreak(weak: true)

#aGroup[
= Extern Table

The extern table is an array of "external symbol" entries, each representing a named value that is external to, but depended upon by the module. This structure is essential for linking. An extern normally corresponds to a function, variable, or data structure defined in a high-level language like Jackal.

```
STRUCT XloExternEntry
    NameOffset : ULONG,
    Type : UBYTE,
    Padding : UBYTE,
    ImportIndex : UINT,
    Padding2 : ULONG,
    Padding3 : ULONG,
END
```

#caption[The definition of an extern entry.]

]

#aGroup[
#microHeading("NameOffset")
NameOffset contains the offset from the base of the string table at which the null-terminated ASCII name of the external symbol resides.
]

#aGroup[
#microHeading("Type")
Type contains the 8-bit type code indicating properties of the extern symbol.

#roundedTable(
  columns: (auto, auto, 1fr),
  [], [Name], [Meaning],
  [1], [UNRESOLVED], [This external symbol is completely unresolved.],
  [2], [IMPORTED], [This external symbol resides in a known dynamic library.]
)

#caption[Currently defined extern symbol type codes.]

]

#aGroup[
#microHeading("ImportIndex")
ImportIndex contains the 16-bit index [0, 65535] of the import table entry that describes the dynamic library this external symbol resides in. If this external symbol is not of type IMPORTED, this field has no meaning.
]

#pagebreak(weak: true)

#aGroup[
= Section Table

The section table is a flat array of "section headers" that describe hunks of data and code contained by this module. The file pointer of the section table must be 64-bit aligned as the section header contains a 64-bit field.

```
STRUCT XloSectionHeader

#IF ( == BITS 64 )
    VirtualAddress : UQUAD,
#ELSE
    VirtualAddress : ULONG,
    Reserved : ULONG,
#END

    NameOffset : ULONG,
    FileOffset : ULONG,
    DataLength : ULONG,
    VirtualLength : ULONG,
    RelocTableOffset : ULONG,
    RelocCount : ULONG,
    Flags : ULONG,
    Reserved2 : ULONG,
END
```

#caption[The definition of a section header.]

]

#aGroup[
#microHeading("VirtualAddress")
VirtualAddress contains the "link-time" base address to which the section has been placed; that is, the "assumed" address that all pointers to the section have been offsetted by. If at runtime the section cannot be placed at this address, internal relocations for this module (and external fixups for other modules that may be dynamically linked to it) must be performed.

This field is either 32 bits or 64 bits depending on the bitness of the target architecture. This allows sections to be located anywhere within a 64-bit address space, but their sizes are still limited to 4GB each, due to pervasive use of 32-bit section offsets. For 32-bit modules, the space where the upper 32 bits of the virtual address would be should be zero, to ensure compatibility with 64-bit tools.
]

#aGroup[
#microHeading("NameOffset")
NameOffset contains the offset from the base of the string table at which the null-terminated ASCII name of the section resides.
]

#aGroup[
#microHeading("FileOffset")
FileOffset contains the file pointer of the section contents within the module.
]

#aGroup[
#microHeading("DataLength")
DataLength contains the on-disk length of the section contents.
]

#aGroup[
#microHeading("VirtualLength")
VirtualLength contains the virtual length of the section contents after being loaded into memory. The difference between DataLength and VirtualLength is filled with zeroes by the loader.
]

#aGroup[
#microHeading("RelocTableOffset and RelocCount")
RelocTableOffset contains the file pointer of the section's relocation table, containing all of the internal relocations that must be performed at runtime should this section fail to be placed at its preferred virtual address. RelocCount contains the number of entries within this table.
]

#aGroup[
#microHeading("Flags")
Flags contains up to 32 bit flags that indicate characteristics of the section.

#roundedTable(
  columns: (auto, auto, 1fr),
  [], [Name], [Meaning],
  [0], [ZERO], [The section has no on-disk data and is full of zeroes. This flag is primarily a hint to the linker.],
  [1], [CODE], [The section contains code and should be mapped as executable.],
  [2], [MAP], [The section has in-memory presence at load time. If this isn't set, it only has on-disk data such as debug information.],
  [3], [PAGED], [The section is pageable and can be safely swapped to disk. This is only relevant for privileged mode programs.],
  [4], [SPLIT], [The section is safe to be split into subsections on symbol boundaries. See @section-subsections for more information.],
)

#caption[Currently defined section flag bits.]

]

== Subsections <section-subsections>

If a section has the SPLIT flag enabled, the section is safe to be split into subsections, such that each subsection starts at a symbol definition and ends before the next symbol definition (or the end of the section itself). If a subsection's associated symbol has a type other than EXPORT and is unreferenced after symbol resolution, it is safe to be removed altogether.

This feature is designed to support link-time dead code elimination and, in combination with the WEAK symbol flag, de-duplication of "generic" entities in high-level compiled languages. 

Linkers are technically safe to ignore the SPLIT flag, though this may lead to an excess of dead code and data in objects that use it.
