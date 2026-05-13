#import "config.typ": *

#let separator = []

#let jumpFormat() = [
  #box[#format(
    ("JUMP TARGET", 29),
    ("OP", 3),
  )]

  #caption[Jump Format]
]

#let branchFormat() = [
  #box[#format(
    ("BRANCH OFFSET", 21),
    ("REG", 5),
    ("OPCODE", 6),
  )]

  #caption[Branch Format]
]

#let immOpFormat() = [
  #box[#format(
    ("IMMEDIATE VALUE", 16),
    ("REG B", 5),
    ("REG A", 5),
    ("OPCODE", 6),
  )]

  #caption[Immediate Operate]
]

#let regOpFormat() = [
  #box[#format(
    ("FUNCT", 4),
    ("SHF", 2),
    ("SHAMT", 5),
    ("REG C", 5),
    ("REG B", 5),
    ("REG A", 5),
    ("OPCODE", 6),
  )]

  #caption[Register Operate]
]

#let jumpFormatTable() = [
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`0x6`], [`J IMM29`], [Jump],
    [`0x7`], [`JAL IMM29`], [Jump And Link],
  )
]

#let branchFormatTable() = [
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`0x3D`], [`BEQ RA, IMM21`], [Branch Equal],
    [`0x35`], [`BNE RA, IMM21`], [Branch Not Equal],
    [`0x2D`], [`BLT RA, IMM21`], [Branch Less Than],
    [`0x25`], [`BGT RA, IMM21`], [Branch Greater Than],
    [`0x1D`], [`BLE RA, IMM21`], [Branch Less Than or Equal],
    [`0x15`], [`BGE RA, IMM21`], [Branch Greater Than or Equal],
    [`0x0D`], [`BPE RA, IMM21`], [Branch Parity Even],
    [`0x05`], [`BPO RA, IMM21`], [Branch Parity Odd],
  )
]

#let immOpTable() = [
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`0x3C`], [`ADDI RA, RB, IMM16`], [Add Immediate],
    [`0x34`], [`SUBI RA, RB, IMM16`], [Subtract Immediate],
    [`0x2C`], [`SLTI RA, RB, IMM16`], [Set Less Than Immediate],
    [`0x24`], [`SLTI SIGNED RA, RB, IMM16`], [Set Less Than Immediate, Signed],
    [`0x1C`], [`ANDI RA, RB, IMM16`], [And Immediate],
    [`0x14`], [`XORI RA, RB, IMM16`], [Xor Immediate],
    [`0x0C`], [`ORI RA, RB, IMM16`], [Or Immediate],
    [`0x04`], [`LUI RA, RB, IMM16`], [Load Upper Immediate],
    [`0x3B`], [`MOV RA, BYTE [RB + IMM16]`], [Load Byte, Immediate Offset],
    [`0x33`], [`MOV RA, INT [RB + IMM16]`], [Load Int, Immediate Offset],
    [`0x2B`], [`MOV RA, LONG [RB + IMM16]`], [Load Long, Immediate Offset],
    [`0x3A`], [`MOV BYTE [RA + IMM16], RB`], [Store Byte, Immediate Offset],
    [`0x32`], [`MOV INT [RA + IMM16], RB`], [Store Int, Immediate Offset],
    [`0x2A`], [`MOV LONG [RA + IMM16], RB`], [Store Long, Immediate Offset],
    [`0x1A`], [`MOV BYTE [RA + IMM16], IMM5`], [Store Byte, Small Immediate],
    [`0x12`], [`MOV INT [RA + IMM16], IMM5`], [Store Int, Small Immediate],
    [`0x0A`], [`MOV LONG [RA + IMM16], IMM5`], [Store Long, Small Immediate],
    [`0x38`], [`JALR RA, RB, IMM16`], [Jump And Link, Register],
    [`0x30`], [`ADR RA, IMM16`], [Compute Relative Address],
  )
]

#let instructionDetailsTable(
  longName,
  opcodeName,
  opcode,
  mnemonic
) = [
  #aGroup[
    #roundedTable(
      columns: (auto, auto, 1fr),
      [#opcodeName], [Mnemonic], [Name],
      [#opcode], [#mnemonic], [#longName],
    )
  ]
]

#let instructionDetailsSecondPart(
  pseudocode,
  exceptions,
  description
) = [
  #aGroup[
    #pseudocode
  ]

  #aGroup[ 
    #microHeading("Description")
    #description
  ]

  #aGroup[
    #microHeading("Exceptions")
    #exceptions
  ]
]

#let instructionDetails(
  longName,
  opcodeName,
  opcode,
  mnemonic,
  pseudocode,
  exceptions,
  description
) = [
  #instructionDetailsTable(
    longName,
    opcodeName,
    opcode,
    mnemonic
  )

  #instructionDetailsSecondPart(
    pseudocode,
    exceptions,
    description
  )
]

= Instructions

== Formats

The XR/17032 architecture features only four instruction formats. All instruction formats are 32 bits wide. There are a total of 60 instructions. The following section contains a comprehensive listing of all of the instructions defined by the XR/17032 architecture along with their encodings. The instructions are grouped first by format, and then by major opcode.

Note that the assembly language also supports several "pseudo-instructions" for ease of assembly programming, which are not listed below, as they don't directly correspond to any particular hardware instruction, and are usually translated to a sequence of several hardware instructions. See @pseudoinstructions for a listing of pseudo-instructions.

#pagebreak(weak: true)

== Jump Format

#jumpFormat()

The format for the absolute jump instructions consists of a 3-bit opcode and a 29-bit jump target. The two possible opcodes for jump instructions are 111 and 110.

Note that this opcode field is unique; all other formats have a 6-bit opcode field. This small opcode is to allow the jump target to cover a 2GB range. This is accomplished by shifting the jump target left by 2, which produces a 31-bit address, and then taking the uppermost bit from that of the current program counter. This allows jumping anywhere within a 2GB userspace or kernel space in a single instruction.

#instructionDetails(
  [Jump And Link],
  [Opcode],
  [`111/0x07`],
  [`JAL IMM29`],
  [```pas
Reg[31] = PC + 4
PC = (IMM29 << 2) | (PC & 0x80000000)
```],
  [None.],
  [
The `JAL` instruction provides a lightweight means of calling a function. The next program counter (PC + 4) is saved in the link register (31) and then the PC is set to the target address.

Note that if the called function needs to call another function, it must be sure to save the link register first and then restore it.
  ]
)

#separator

#instructionDetails(
  [Jump],
  [Opcode],
  [`110/0x06`],
  [`J IMM29`],
  [```pas
PC = (IMM29 << 2) | (PC & 0x80000000)
```],
  [None.],
  [
The `J` instruction provides a way to do a long-distance absolute jump to another location, without destroying the contents of the link register.
  ]
)

#pagebreak(weak: true)

#aGroup[
== Branch Format

#branchFormat()

The format for the branch instructions consists of a 6-bit opcode, a 5-bit register number, and a 21-bit branch offset. Every branch instruction has 101 as the low 3 bits of the opcode.

]

There is only one register field in order to maximize the size of the branch offset. This register is compared against zero in various ways. If the branch is taken, then the branch offset is shifted left by two, sign extended, and added to the current program counter. This gives a range of $plus.minus$1M instructions, or $plus.minus$4MB. As this covers the entire text section of most programs, and certainly covers any individual routine you're likely to find, this alleviates some burden that afflicts most RISC toolchains, as cross-procedure jumps will usually be done with absolute jumps anyway.

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`111101/0x3D`], [`BEQ RA, IMM21`], [Branch Equal],
    [`110101/0x35`], [`BNE RA, IMM21`], [Branch Not Equal],
    [`101101/0x2D`], [`BLT RA, IMM21`], [Branch Less Than],
    [`100101/0x25`], [`BGT RA, IMM21`], [Branch Greater Than],
    [`011101/0x1D`], [`BLE RA, IMM21`], [Branch Less Than Or Equal],
    [`010101/0x15`], [`BGE RA, IMM21`], [Branch Greater Than Or Equal],
  )
]

#instructionDetailsSecondPart(
  [```pas
IF Reg[RA] COND 0 THEN
  PC += SignExtend(IMM21) << 2
END
```],
  [None.],
  [
The conditional branch instructions perform a relative jump if the given signed comparison between the contents of Register A and zero evaluates to true.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`001101/0x0D`], [`BPE RA, IMM21`], [Branch Parity Even],
    [`000101/0x05`], [`BPO RA, IMM21`], [Branch Parity Odd],
  )
]

#instructionDetailsSecondPart(
  [```pas
IF Reg[RA] & 0x1 == ? THEN
  PC += SignExtend(IMM21) << 2
END
  ```],
  [None.],
  [
The branch on parity instructions perform a relative jump if Register A has the given parity. That is, for BPE, a test is made whether the low bit is clear. For BPO, a test is made whether the low bit is set.
  ]
)

#v(1fr)

#pagebreak(weak: true)

== Immediate Operate Format

#immOpFormat()

The format for the immediate operate instructions consists of a 6-bit opcode, two 5-bit register numbers, and a 16-bit immediate value. Every immediate operate instruction has either 100, 011, 010, or 000 as the low 3 bits of the opcode.

Note that the immediate value may or may not be sign extended, depending on the instruction.

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`111100/0x3C`], [`ADDI RA, RB, IMM16`], [Add Immediate],
    [`110100/0x34`], [`SUBI RA, RB, IMM16`], [Subtract Immediate],
    [`101100/0x2C`], [`SLTI RA, RB, IMM16`], [Set Less Than Immediate],
    [`100100/0x24`], [`SLTI SIGNED RA, RB, IMM16`], [Set Less Than Immediate, Signed],
    [`011100/0x1C`], [`ANDI RA, RB, IMM16`], [And Immediate],
    [`010100/0x14`], [`XORI RA, RB, IMM16`], [Xor Immediate],
    [`001100/0x0C`], [`ORI RA, RB, IMM16`], [Or Immediate],
    [`000100/0x04`], [`LUI RA, RB, IMM16`], [Load Upper Immediate],
  )
]

#instructionDetailsSecondPart(
  [```pas
Reg[RA] = Reg[RB] OP IMM16
  ```],
  [None.],
  [
The immediate operate instructions perform the given operation between the contents of Register B and a 16-bit immediate value, which is zero-extended, except for `SLTI SIGNED` where it is sign-extended. The result is stored in Register A.

In the case of the comparison instructions, a 1 is stored if the comparison is true, and a 0 otherwise.

In the case of LUI, the operation performed is a bitwise OR. However, the immediate is first shifted 16 bits to the left, enabling the loading of large constants whose low 16 bits are clear. LUI also enables the synthesis of pseudo-instructions for loading arbitrary large constants.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`111011/0x3B`], [`MOV RA, BYTE [RB + IMM16]`], [Load Byte, Immediate Offset],
    [`110011/0x33`], [`MOV RA, INT [RB + IMM16]`], [Load Int, Immediate Offset],
    [`101011/0x2B`], [`MOV RA, LONG [RB + IMM16]`], [Load Long, Immediate Offset],
  )
]

#instructionDetailsSecondPart(
  [```pas
Reg[RA] = Load(Reg[RB] + (IMM16 * width), width)
  ```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGF (Read Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
The load instructions read a value into Register A from the address stored within Register B plus a zero-extended 16-bit immediate offset. To extend the range, the processor multiplies the immediate offset by the width of the access (in bytes) before it is added to the base register. The address must be naturally aligned to the width.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`111010/0x3A`], [`MOV BYTE [RA + IMM16], RB`], [Store Byte, Immediate Offset],
    [`110010/0x32`], [`MOV INT [RA + IMM16], RB`], [Store Int, Immediate Offset],
    [`101010/0x2A`], [`MOV LONG [RA + IMM16], RB`], [Store Long, Immediate Offset],
  )
]

#instructionDetailsSecondPart(
  [```pas
Store(Reg[RA] + (IMM16 * width), Reg[RB], width)
  ```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGW (Write Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit, or a DTB entry with a clear writable bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
The store register instructions store the value contained with Register B to the address stored within Register A plus a zero-extended 16-bit immediate offset. To extend the range, the processor multiplies the immediate offset by the width of the access (in bytes) before it is added to the base register. The address must be naturally aligned to the width.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Opcode], [Mnemonic], [Name],
    [`011010/0x1A`], [`MOV BYTE [RA + IMM16], IMM5`], [Store Byte, Small Immediate],
    [`010010/0x12`], [`MOV INT [RA + IMM16], IMM5`], [Store Int, Small Immediate],
    [`001010/0x0A`], [`MOV LONG [RA + IMM16], IMM5`], [Store Long, Small Immediate],
  )
]

#instructionDetailsSecondPart(
  [```pas
Store(Reg[RA] + (IMM16 * width), SignExt5(IMM5), width)
  ```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGW (Write Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit, or a DTB entry with a clear writable bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
The store small immediate instructions store a sign-extended 5-bit immediate to the address stored within Register A plus a zero-extended 16-bit immediate offset. To extend the range, the processor multiplies the immediate offset by the width of the access (in bytes) before it is added to the base register. The address must be naturally aligned to the width. The 5-bit immediate is encoded in the Register B field of the instruction word.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Jump And Link, Register],
  [Opcode],
  [`111000/0x38`],
  [`JALR RA, RB, IMM16`],
  [```pas
Reg[RA] = PC + 4
PC = Reg[RB] + (IMM16 << 2)
```],
  [None.],
  [
The JALR instruction provides a lightweight means of calling through a function pointer. The next program counter (PC + 4) is saved in Register A, and then the PC is set to the contents of Register B plus a 16-bit zero-extended immediate value shifted left by two.

This instruction can also be used as an indirect jump to an address stored in a register, by setting the destination register to the zero register, thereby discarding the return value.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Compute Relative Address],
  [Opcode],
  [`110000/0x30`],
  [`ADR RA, IMM16`],
  [```pas
Reg[RA] = PC + (IMM16 << 16)
```],
  [None.],
  [
The ADR instruction adds the current program counter and a 16-bit immediate value shifted left by 16. The result is stored in Register A. This instruction is useful for PC-relative addressing modes.

Unlike other immediate operate format instructions, this instruction's Register B field must be zero.
  ]
)

#v(1fr)

#pagebreak(weak: true)

== Register Operate Format

#regOpFormat()

The format for the register operate instructions consists of a 6-bit opcode, three 5-bit register numbers, a 5-bit shift amount, a 2-bit shift type, and a 4-bit function code (which acts as an extended opcode). Every register operate instruction has 001 as the low 3 bits of the opcode, and there are three such opcodes; 111001, 110001, and 101001.

All privileged instructions are in this format and are function codes of the last opcode mentioned, 101001. These instructions will produce a privilege violation exception if executed while usermode is enabled in the RS control register (see @rs).

The value of Register C is shifted in the manner specified by the shift type, by the amount specified by the shift amount.

#align(center)[
#roundedTable(
  columns: (auto, auto),
  align: horizon + left,
  [], [],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *00*
  ], fill: tableHeadingColor),
  [*LSH* Left shift.],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *01*
  ], fill: tableHeadingColor),
  [*RSH* Logical right shift.],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *10*
  ], fill: tableHeadingColor),
  [*ASH* Arithmetic right shift.],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *11*
  ], fill: tableHeadingColor),
  [*ROR* Rotate right.],
)
]
#caption[The 2-bit shift type codes (SHF field).]

#aGroup[

=== Register Operate, Opcode 111001

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`1111/0xF`], [`MOV RA, BYTE [RB + RC xSH IMM5]`], [Load Byte, Register Offset],
    [`1110/0xE`], [`MOV RA, INT [RB + RC xSH IMM5]`], [Load Int, Register Offset],
    [`1101/0xD`], [`MOV RA, LONG [RB + RC xSH IMM5]`], [Load Long, Register Offset],

  )
]

#instructionDetailsSecondPart(
  [```pas
Reg[RA] = Load(Reg[RB] + (Reg[RC] xSH IMM5), width)
  ```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGF (Read Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
These instructions perform a load with an offset contained within a register. A zero-extended value is loaded into Register A from the address computed by adding the value of Register C, shifted in the manner specified, to the value of Register B.
  ]
)

]

#pagebreak(weak: true)

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`1011/0xB`], [`MOV BYTE [RB + RC xSH IMM5], RA`], [Store Byte, Register Offset],
    [`1010/0xA`], [`MOV INT [RB + RC xSH IMM5], RA`], [Store Int, Register Offset],
    [`1001/0x9`], [`MOV LONG [RB + RC xSH IMM5], RA`], [Store Long, Register Offset],
  )
]

#instructionDetailsSecondPart(
  [```pas
Store(Reg[RB] + (Reg[RC] xSH IMM5), Reg[RA], width)
  ```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGW (Write Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit, or a DTB entry with a clear writable bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
These instructions perform a store with an offset contained within a register. The value in Register A is stored to the address computed by adding the value of Register C, shifted in the manner specified, to the value of Register B.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Various Shift By Register],
  [Function],
  [1000 (0x8)],
  [`LSH/RSH/ASH/ROR RA, RC, RB`],
  [```pas
Reg[RA] = Reg[RC] xSH (Reg[RB] & 31)
```],
  [None.],
  [
This instruction shifts the contents of Register C by the contents of Register B and places the result in Register A. It is technically a single function code, but is split into several mnemonics for convenience. The IMM5 shift value encoded in the instruction is ignored, because the shift value is taken from Register B instead.
  ]
)

#separator

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`0111/0x7`], [`ADD RA, RB, RC xSH IMM5`], [Add Register],
    [`0110/0x6`], [`SUB RA, RB, RC xSH IMM5`], [Subtract Register],
    [`0101/0x5`], [`SLT RA, RB, RC xSH IMM5`], [Set Less Than Register],
    [`0100/0x4`], [`SLT SIGNED RA, RB, RC xSH IMM5`], [Set Less Than Register, Signed],
    [`0011/0x3`], [`AND RA, RB, RC xSH IMM5`], [And Register],
    [`0010/0x2`], [`XOR RA, RB, RC xSH IMM5`], [Xor Register],
    [`0001/0x1`], [`OR RA, RB, RC xSH IMM5`], [Or Register],
    [`0000/0x0`], [`NOR RA, RB, RC xSH IMM5`], [Nor Register],
  )
]

#instructionDetailsSecondPart(
  [```pas
Reg[RA] = Reg[RB] OP (Reg[RC] xSH IMM5)
  ```],
  [#box[
None.
  ]],
  [
These instructions perform the specified operation between the contents of Register B and the contents of Register C, and stores the result into Register A. The contents of Register C are first shifted in the manner specified.

In the case of the comparison instructions, a 1 is stored if the comparison is true, and a 0 otherwise.
  ]
)

#v(1fr)

#pagebreak(weak: true)

=== Register Operate, Opcode 110001

#v(1fr)

#aGroup[
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`1111/0xF`], [`MUL RA, RB, RC xSH IMM5`], [Multiply],
    [`1101/0xD`], [`DIV RA, RB, RC xSH IMM5`], [Divide],
    [`1100/0xC`], [`DIV SIGNED RA, RB, RC xSH IMM5`], [Divide, Signed],
    [`1011/0xB`], [`MOD RA, RB, RC xSH IMM5`], [Modulo],
  )
]

#instructionDetailsSecondPart(
  [```pas
Reg[RA] = Reg[RB] OP (Reg[RC] xSH IMM5)
  ```],
  [#box[
None.
  ]],
  [
These instructions perform the specified operation between the contents of Register B and the contents of Register C, and stores the result into Register A. The contents of Register C are first shifted in the manner specified.

The result of division is rounded toward zero, to a whole integer.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Load Locked],
  [Function],
  [`1001/0x9`],
  [`LL RA, RB`],
  [```pas
Locked = TRUE
LockedAddress = Translate(Reg[RB])
Reg[RA] = Load32(Reg[RB])
```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGF (Read Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
This instruction is used to implement atomic sequences. It loads the 32-bit contents of a naturally-aligned memory address contained within Register B into Register A. The "locked" flag is set to TRUE, and the "locked address" is set to the physical address being accessed.

If an RFE (Return From Exception) instruction is executed, the "locked" flag is cleared, causing a future SC instruction on the same processor to fail. This can be used to implement atomic sequences in non-privileged code.

In a multiprocessor system, if any other processor performs a store to this processor's "locked address", this processor's "locked" flag is cleared.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Store Conditional],
  [Function],
  [`1000/0x8`],
  [`SC RA, RB, RC`],
  [```pas
IF Locked THEN
  Store32(Reg[RB], Reg[RC])
END
Reg[RA] = Locked
```],
  [#box[
  - DTB (DTB miss) if paging is enabled and the referenced page mapping is not in the DTB.
  - PGW (Write Page Fault) if paging is enabled and the referenced page matches a DTB entry with a clear valid bit, or a DTB entry with a clear writable bit.
  - BUS (Bus Error) if the memory access causes a timeout on the system bus.
  - UNA (Unaligned Access) if the referenced address is not naturally aligned.
  ]],
  [
This instruction stores the current value of the processor's "locked" flag to Register A. If the "locked" flag is set, it stores the contents of Register C to the address contained within Register B.
  ]
)

#v(1fr)

#instructionDetails(
  [Pause],
  [Function],
  [`0110/0x6`],
  [`PAUSE`],
  [```pas
// Possible implementation.
IF PauseCount++ & 255 == 0 THEN
  Yield()
END
```],
  [None.],
  [
On multiprocessor systems, this instruction should be executed on each iteration of a spin-wait for another processor to do something (e.g. release a spinlock, respond to IPI). It is a hint that the processor isn't doing useful work.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Memory Barrier],
  [Function],
  [`0011/0x3`],
  [`MB`],
  [```pas
// Possible implementation.
FlushWriteBuffer()
SynchronizeLoads()
```],
  [None.],
  [
This instruction ensures that, from the perspective of all processors and I/O devices in the system, no reads or writes performed by this processor are reordered across the MB instruction in either direction. This is sometimes necessary for proper multiprocessor memory ordering.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Write Memory Barrier],
  [Function],
  [`0010/0x2`],
  [`WMB`],
  [```pas
// Possible implementation.
FlushWriteBuffer()
```],
  [None.],
  [
This instruction ensures that, from the perspective of all processors and I/O devices in the system, no writes performed by this processor before the WMB instruction are reordered after the WMB instruction. One example of this instruction on a uniprocessor system is to ensure that a device has seen a sequence of writes to its registers before asking it to perform a command. An example on a multiprocessor system is to ensure data coherency before releasing a spinlock.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Breakpoint],
  [Function],
  [`0001/0x1`],
  [`BRK`],
  [```pas
Exception(BRK)
```],
  [#box[
  - BRK (Breakpoint) is always triggered by this instruction.
  ]],
  [
This instruction causes a breakpoint exception. Its intended use is for debugging purposes. See @exceptionblock for more information on exceptions.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [System Service],
  [Function],
  [`0000/0x0`],
  [`SYS`],
  [```pas
Exception(SYS)
```],
  [#box[
  - SYS (System Service) is always triggered by this instruction.
  ]],
  [
This instruction causes a system service exception. It is useful for usermode to make a call into the system software to request a service (also called a system service or "syscall"). See @exceptionblock for more information on exceptions.
  ]
)

#v(1fr)

#pagebreak(weak: true)

=== Register Operate, Opcode 101001 (Privileged)

#v(1fr)

#instructionDetails(
  [Move From Control Register],
  [Function],
  [`1111/0xF`],
  [`MFCR RA, CR`],
  [```pas
Reg[RA] = ControlReg[CR]
```],
  [#box[
  - PRV (Privilege Violation) if executed while usermode is active.
  ]],
  [
This instruction moves the contents of the specified control register into Register A. The 5-bit control register number is encoded in the place of Register C.

Note that not all control registers are simple memory-like repositories of bits, and may perform special actions when read. See @controlregs for a full listing of control registers and their behaviors.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Move To Control Register],
  [Function],
  [`1110/0xE`],
  [`MTCR CR, RB`],
  [```pas
ControlReg[CR] = Reg[RB]
```],
  [#box[
  - PRV (Privilege Violation) if executed while usermode is active.
  ]],
  [
This instruction moves the contents of Register B into the specified control register. The 5-bit control register number is encoded in the place of Register C. Register A is ignored but should be encoded as zero.

Note that not all control registers are simple memory-like repositories of bits, and may perform special actions when written. See @controlregs for a full listing of control registers and their behaviors.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Halt Until Next Interrupt],
  [Function],
  [`1100/0xC`],
  [`HLT`],
  [```pas
HaltUntilInterrupt()
```],
  [#box[
  - PRV (Privilege Violation) if executed while usermode is active.
  ]],
  [
This instruction pauses execution of the processor until the next external interrupt is received. This can be used as a power-saving measure; for instance, executing HLT in a loop in the low priority idle thread of a multitasking kernel could greatly reduce the idle power consumption of the system. If external interrupts are disabled, this instruction causes the processor to halt forever, that is, until it is physically reset.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Return From Exception],
  [Function],
  [`1011/0xB`],
  [`RFE`],
  [```pas
Locked = FALSE
IF ControlReg[RS].ModeStack & T THEN
  PC = ControlReg[TBPC]
ELSE
  PC = ControlReg[EPC]
END
ControlReg[RS].ModeStack = ControlReg[RS].ModeStack >> 8
```],
  [#box[
  - PRV (Privilege Violation) if executed while usermode is active.
  ]],
  [
This instruction "pops" the "mode stack" of the RS control register (see @rs), and returns execution to the program counter saved in either the TBPC or EPC control register, depending on if the T bit of RS was set or not, respectively (i.e., whether a TB miss handler was active or not; see @tbmiss). It also clears the "locked" flag, causing the next SC (Store Conditional) instruction to fail.
  ]
)

#v(1fr)

#pagebreak(weak: true)

== Pseudo-Instructions <pseudoinstructions>

Some operations are synthesized out of simpler instructions, but are common or inconvenient enough to warrant a "pseudo-instruction", a fake instruction that the assembler converts into a corresponding hardware instruction sequence. The following is a (not necessarily exhaustive, depending on the assembler) list of common pseudo-instructions.

#v(1fr)

#instructionDetails(
  [Unconditional Relative Branch],
  [],
  [],
  [`B IMM21`],
  [```pas
BEQ ZERO, IMM21
```],
  [None.],
  [
This pseudo-instruction performs an unconditional relative branch. This is synthesized from the BEQ (Branch Equal) instruction, used here to compare the contents of the register ZERO with the number zero; by definition, this will always be true, thereby synthesizing an unconditional branch.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Return],
  [],
  [],
  [`RET`],
  [```pas
JALR ZERO, LR, 0
```],
  [None.],
  [
This pseudo-instruction performs a common return-from-subroutine operation. This is synthesized from the JALR (Jump And Link, Register) instruction, by performing a jump-and-link to the contents of the link register LR, and saving the result in ZERO (thereby discarding it).
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Jump to Register],
  [],
  [],
  [`JR RA`],
  [```pas
JALR ZERO, RA, 0
```],
  [None.],
  [
This pseudo-instruction performs a jump to the contents of Register A. This is synthesized from the JALR (Jump And Link, Register) instruction, by performing a jump-and-link to the contents of Register A, and saving the result in ZERO (thereby discarding it).
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Move Register],
  [],
  [],
  [`MOV RA, RB`],
  [```pas
ADD RA, RB, ZERO LSH 0
```],
  [None.],
  [
This pseudo-instruction copies the contents of Register B into Register A. It is synthesized from the ADD (Add Register) instruction, by adding the contents of the ZERO register to the contents of Register B (which is a no-op), and saving the results in Register A.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Load 16-bit Immediate],
  [],
  [],
  [`LI RA, IMM16`],
  [```pas
ADDI RA, ZERO, IMM16
```],
  [None.],
  [
This pseudo-instruction loads a 16-bit immediate into Register A. It is synthesized from the ADDI (Add Immediate) instruction, by adding the immediate to the contents of the ZERO register and saving the results in Register A.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Load 32-bit Immediate],
  [],
  [],
  [`LA RA, IMM32`],
  [```pas
LUI RA, ZERO, (IMM32 >> 16)
ORI RA, RA, (IMM32 & 0xFFFF)
```],
  [None.],
  [
This pseudo-instruction loads a 32-bit immediate into Register A. It is synthesized from the LUI (Load Upper Immediate) and ORI (Or Immediate) instructions, by loading the upper 16 bits of the immediate into the register with LUI, and then bitwise OR-ing the lower 16 bits in with ORI.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [No Operation],
  [],
  [],
  [`NOP`],
  [```pas
ADDI ZERO, ZERO, 0
```],
  [None.],
  [
This pseudo-instruction does nothing, by adding the contents of the ZERO register with the number zero and saving the result in the ZERO register.

Note that the instruction of all zeroes is _not_ a no-op. The instruction set was designed to ensure that the instruction of all zeroes is an invalid instruction, so that an invalid instruction exception will tend to occur more immediately if a mistaken jump occurs.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Various Shift By Immediate],
  [],
  [],
  [`LSHI/RSHI/ASHI/RORI RA, RB, IMM5`],
  [```pas
ADD RA, ZERO, RB xSH IMM5
```],
  [None.],
  [
These pseudo-instructions shift the contents of Register B by the 5-bit immediate, and save the result in Register A. They are synthesized from the ADD (Add Register) instruction, by adding the contents of Register B with the contents of the ZERO register, and shifting it in the specified manner.
  ]
)

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#instructionDetails(
  [Load from 32-bit Address],
  [],
  [],
  [`MOV RA, BYTE/INT/LONG [IMM32]`],
  [```pas
LUI RA, ZERO, (IMM32 >> 16)
MOV RA, BYTE/INT/LONG [RA + (IMM32 & 0xFFFF)]
```],
  [Any exception that can be caused by the load instruction.],
  [
These pseudo-instructions load a value into Register A from a full 32-bit address. They are synthesized from LUI (Load Upper Immediate) and the appropriate offsetted load instruction. The upper 16 bits of the address are loaded into the register with LUI, and then a load is done into the register, with an offset of the low 16 bits of the address.
  ]
)

#separator

#v(1fr)

#instructionDetails(
  [Store to 32-bit Address],
  [],
  [],
  [`MOV BYTE/INT/LONG [IMM32], RA, TMP=RB`],
  [```pas
LUI RB, ZERO, (IMM32 >> 16)
MOV BYTE/INT/LONG [RB + (IMM32 & 0xFFFF)], RA
```],
  [Any exception that can be caused by the store instruction.],
  [
These pseudo-instructions store a value into a full 32-bit address. They are synthesized with LUI (Load Upper Immediate) and the appropriate offsetted store instruction. The upper 16 bits of the address are loaded into a user-supplied temporary register with LUI, and then a store is done with an offset of the low 16 bits of the address.
  ]
)

#v(1fr)

#pagebreak(weak: true)

== Instruction Summary

#v(1fr)

#jumpFormat()

#jumpFormatTable()

#v(1fr)

#branchFormat()

#branchFormatTable()

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#immOpFormat()

#immOpTable()

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#regOpFormat()

#aGroup[
  #microHeading("Major Opcode 111001 (0x39)")

  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`0xF`], [`MOV RA, BYTE [RB + RC xSH IMM5]`], [Load Byte, Register Offset],
    [`0xE`], [`MOV RA, INT [RB + RC xSH IMM5]`], [Load Int, Register Offset],
    [`0xD`], [`MOV RA, LONG [RB + RC xSH IMM5]`], [Load Long, Register Offset],
    [`0xB`], [`MOV BYTE [RB + RC xSH IMM5], RA`], [Store Byte, Register Offset],
    [`0xA`], [`MOV INT [RB + RC xSH IMM5], RA`], [Store Int, Register Offset],
    [`0x9`], [`MOV LONG [RB + RC xSH IMM5], RA`], [Store Long, Register Offset],
    [`0x8`], [`LSH RA, RC, RB`], [Left Shift By Register],
    [`0x8`], [`RSH RA, RC, RB`], [Logical Right Shift By Register],
    [`0x8`], [`ASH RA, RC, RB`], [Arithmetic Right Shift By Register],
    [`0x8`], [`ROR RA, RC, RB`], [Rotate Right By Register],
    [`0x7`], [`ADD RA, RB, RC xSH IMM5`], [Add Register],
    [`0x6`], [`SUB RA, RB, RC xSH IMM5`], [Subtract Register],
    [`0x5`], [`SLT RA, RB, RC xSH IMM5`], [Set Less Than Register],
    [`0x4`], [`SLT SIGNED RA, RB, RC xSH IMM5`], [Set Less Than Register, Signed],
    [`0x3`], [`AND RA, RB, RC xSH IMM5`], [And Register],
    [`0x2`], [`XOR RA, RB, RC xSH IMM5`], [Xor Register],
    [`0x1`], [`OR RA, RB, RC xSH IMM5`], [Or Register],
    [`0x0`], [`NOR RA, RB, RC xSH IMM5`], [Nor Register],
  )
]

#v(1fr)

#pagebreak(weak: true)

#v(1fr)

#aGroup[
  #microHeading("Major Opcode 110001 (0x31)")

  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`0xF`], [`MUL RA, RB, RC`], [Multiply],
    [`0xD`], [`DIV RA, RB, RC`], [Divide],
    [`0xC`], [`DIV SIGNED RA, RB, RC`], [Divide, Signed],
    [`0xB`], [`MOD RA, RB, RC`], [Modulo],
    [`0x9`], [`LL RA, RB`], [Load Locked],
    [`0x8`], [`SC RA, RB, RC`], [Store Conditional],
    [`0x6`], [`PAUSE`], [Pause],
    [`0x3`], [`MB`], [Memory Barrier],
    [`0x2`], [`WMB`], [Write Memory Barrier],
    [`0x1`], [`BRK`], [Breakpoint],
    [`0x0`], [`SYS`], [System Service],
  )
]

#v(1fr)

#aGroup[
  #microHeading("Major Opcode 101001 (0x29, Privileged)")

  #roundedTable(
    columns: (auto, auto, 1fr),
    [Function], [Mnemonic], [Name],
    [`0xF`], [`MFCR RA, CR`], [Move From Control Register],
    [`0xE`], [`MTCR CR, RA`], [Move To Control Register],
    [`0xC`], [`HLT`], [Halt Until Next Interrupt],
    [`0xB`], [`RFE`], [Return From Exception],
  )
]

#v(1fr)