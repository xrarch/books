#import "config.typ": *

#let jumpFormat() = [
  #bitfield((
    (name: "JUMP TARGET", bits: 29),
    (name: "OP", bits: 3),
  ))

  #caption[Jump Format]
]

#let branchFormat() = [
  #bitfield((
    (name: "BRANCH OFFSET", bits: 21),
    (name: "REG", bits: 5),
    (name: "OPCODE", bits: 6),
  ))

  #caption[Branch Format]
]

#let immOpFormat() = [
  #bitfield((
    (name: "IMMEDIATE VALUE", bits: 16),
    (name: "REG B", bits: 5),
    (name: "REG A", bits: 5),
    (name: "OPCODE", bits: 6),
  ))

  #caption[Immediate Operate]
]

#let regOpFormat() = [
  #bitfield((
    (name: "FUNCT", bits: 4),
    (name: "SHF", bits: 2),
    (name: "SHAMT", bits: 5),
    (name: "REG C", bits: 5),
    (name: "REG B", bits: 5),
    (name: "REG A", bits: 5),
    (name: "OPCODE", bits: 6),
  ))

  #caption[Register Operate]
]

#let jumpFormatTable() = [
  #microHeading("Jump Instructions")

  #roundedTable(
    columns: (auto, 1fr),
    [Mnemonic], [Function],
    [`J IMM29`], [Jump],
    [`JAL IMM29`], [Jump And Link],
  )
]

#let branchFormatTable() = [
  #microHeading("Branch Instructions")

  #roundedTable(
    columns: (auto, 1fr),
    [Mnemonic], [Function],
    [`BEQ RA, IMM21`], [Branch Equal],
    [`BNE RA, IMM21`], [Branch Not Equal],
    [`BLT RA, IMM21`], [Branch Less Than],
    [`BGT RA, IMM21`], [Branch Greater Than],
    [`BGE RA, IMM21`], [Branch Greater Than or Equal],
    [`BLE RA, IMM21`], [Branch Less Than or Equal],
    [`BPE RA, IMM21`], [Branch Parity Even],
    [`BPO RA, IMM21`], [Branch Parity Odd],
  )
]

#let immOpTable() = [
  #microHeading("Immediate Operate Instructions")

  #roundedTable(
    columns: (auto, 1fr),
    [Mnemonic], [Function],
    [`ADDI RA, RB, IMM16`], [Add Immediate],
    [`SUBI RA, RB, IMM16`], [Subtract Immediate],
    [`SLTI RA, RB, IMM16`], [Set Less Than Immediate],
    [`SLTI SIGNED RA, RB, IMM16`], [Set Less Than Immediate, Signed],
    [`ANDI RA, RB, IMM16`], [And Immediate],
    [`XORI RA, RB, IMM16`], [Xor Immediate],
    [`ORI RA, RB, IMM16`], [Or Immediate],
    [`LUI RA, RB, IMM16`], [Load Upper Immediate],
    [`MOV RA, BYTE [RB + IMM16]`], [Load Byte, Immediate Offset],
    [`MOV RA, INT [RB + IMM16]`], [Load Int, Immediate Offset],
    [`MOV RA, LONG [RB + IMM16]`], [Load Long, Immediate Offset],
    [`MOV BYTE [RA + IMM16], RB`], [Store Byte, Immediate Offset],
    [`MOV INT [RA + IMM16], RB`], [Store Int, Immediate Offset],
    [`MOV LONG [RA + IMM16], RB`], [Store Long, Immediate Offset],
    [`MOV BYTE [RA + IMM16], IMM5`], [Store Byte, Small Immediate],
    [`MOV INT [RA + IMM16], IMM5`], [Store Int, Small Immediate],
    [`MOV LONG [RA + IMM16], IMM5`], [Store Long, Small Immediate],
    [`JALR RA, RB, IMM16`], [Jump And Link, Register],
    [`ADR RA, IMM16`], [Compute Relative Address],
  )
]

#let regOpTable() = [
  #microHeading("Register Operate Instructions")

  #roundedTable(
    columns: (auto, 1fr),
    [Mnemonic], [Function],
    [`MOV RA, BYTE [RB + RC xSH IMM5]`], [Load Byte, Register Offset],
    [`MOV RA, INT [RB + RC xSH IMM5]`], [Load Int, Register Offset],
    [`MOV RA, LONG [RB + RC xSH IMM5]`], [Load Long, Register Offset],
    [`MOV BYTE [RB + RC xSH IMM5], RA`], [Store Byte, Register Offset],
    [`MOV INT [RB + RC xSH IMM5], RA`], [Store Int, Register Offset],
    [`MOV LONG [RB + RC xSH IMM5], RA`], [Store Long, Register Offset],
    [`LSH RA, RC, RB`], [Left Shift By Register Amount],
    [`RSH RA, RC, RB`], [Logical Right Shift By Register Amount],
    [`ASH RA, RC, RB`], [Arithmetic Right Shift By Register Amount],
    [`ROR RA, RC, RB`], [Rotate Right By Register Amount],
    [`ADD RA, RB, RC xSH IMM5`], [Add Register],
    [`SUB RA, RB, RC xSH IMM5`], [Subtract Register],
    [`SLT RA, RB, RC xSH IMM5`], [Set Less Than Register],
    [`SLT SIGNED RA, RB, RC xSH IMM5`], [Set Less Than Register, Signed],
    [`AND RA, RB, RC xSH IMM5`], [And Register],
    [`XOR RA, RB, RC xSH IMM5`], [Xor Register],
    [`OR RA, RB, RC xSH IMM5`], [Or Register],
    [`NOR RA, RB, RC xSH IMM5`], [Nor Register],
    [`MUL RA, RB, RC`], [Multiply],
    [`DIV RA, RB, RC`], [Divide],
    [`DIV SIGNED RA, RB, RC`], [Divide, Signed],
    [`MOD RA, RB, RC`], [Modulo],
    [`LL RA, RB`], [Load Locked],
    [`SC RA, RB, RC`], [Store Conditional],
    [`PAUSE`], [Pause],
    [`MB`], [Memory Barrier],
    [`WMB`], [Write Memory Barrier],
    [`BRK`], [Breakpoint],
    [`SYS`], [System Service],
    [`MFCR RA, CR`], [Move From Control Register],
    [`MTCR CR, RA`], [Move To Control Register],
    [`HLT`], [Halt Until Next Interrupt],
    [`RFE`], [Return From Exception],
  )
]

#let instructionDetailsTable(
  longName,
  opcodeName,
  opcode,
  mnemonic
) = [
  #roundedTable(
    columns: (auto, auto, 1fr),
    [Mnemonic], [#opcodeName], [Name],
    [#mnemonic], [#opcode], [#longName],
  )
]

#let instructionDetailsSecondPart(
  pseudocode,
  exceptions,
  description
) = [
  #pseudocode
  
  #microHeading("Description")
  #description

  #microHeading("Exceptions")
  #exceptions
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

The XR/17032 architecture features only four instruction formats, and each are 32 bits wide. There are a total of 60 instructions, which are summarized below. A more comprehensive description of each format and instruction can be found in @instlisting.

#jumpFormat()

#branchFormat()

#immOpFormat()

#regOpFormat()

#pagebreak(weak: true)

#aGroup[

== Instruction Summaries

#jumpFormatTable()

#branchFormatTable()

]

#aGroup[

#immOpTable()

]

#aGroup[

#regOpTable()

]

== Instruction Listing <instlisting>
The following section contains a comprehensive listing of all of the instructions defined by the XR/17032 architecture along with their encodings. The instructions are grouped first by format, and then by major opcode.

Note that the assembly language also supports several "pseudo-instructions" for ease of assembly programming, which are not listed below, as they don't directly correspond to any particular hardware instruction, and are usually translated to a sequence of several hardware instructions. See @pseudoinstructions for a listing of pseudo-instructions.

#pagebreak(weak: true)

=== Jump Format

#jumpFormat()

The format for the absolute jump instructions consists of a 3-bit opcode and a 29-bit jump target. The two possible opcodes for jump instructions are 111 and 110.

Note that this opcode field is unique; all other formats have a 6-bit opcode field. This small opcode is to allow the jump target to cover a 2GB range. This is accomplished by shifting the jump target left by 2, which produces a 31-bit address, and then taking the uppermost bit from that of the current program counter. This allows jumping anywhere within a 2GB userspace or kernel space in a single instruction.

#jumpFormatTable()

#pagebreak(weak: true)

==== Listing

#instructionDetails(
  [Jump And Link],
  [Opcode],
  [111 (0x07)],
  [`JAL IMM29`],
  [```
Reg[31] = PC + 4
PC = (IMM29 << 2) | (PC & 0x80000000)
```],
  [None.],
  [
The `JAL` instruction provides a lightweight means of calling a function. The next program counter (PC + 4) is saved in the link register (31) and then the PC is set to the target address.

Note that if the called function needs to call another function, it must be sure to save the link register first and then restore it.
  ]
)

#pagebreak(weak: true)

#instructionDetails(
  [Jump],
  [Opcode],
  [110 (0x06)],
  [`J IMM29`],
  [```
PC = (IMM29 << 2) | (PC & 0x80000000)
```],
  [None.],
  [
The `J` instruction provides a way to do a long-distance absolute jump to another location, without destroying the contents of the link register.
  ]
)

#pagebreak(weak: true)

#aGroup[
=== Branch Format

#branchFormat()

The format for the branch instructions consists of a 6-bit opcode, a 5-bit register number, and a 21-bit branch offset. Every branch instruction has 101 as the low 3 bits of the opcode.

]

There is only one register field in order to maximize the size of the branch offset. This register is compared against zero in various ways. If the branch is taken, then the branch offset is shifted left by two, sign extended, and added to the current program counter. This gives a range of $plus.minus$1M instructions, or $plus.minus$4MB. As this covers the entire text section of most programs, and certainly covers any individual routine you're likely to find, this alleviates some burden that afflicts most RISC toolchains, as cross-procedure jumps will usually be done with absolute jumps anyway.

#branchFormatTable()

#pagebreak(weak: true)

==== Listing

#instructionDetailsTable(
  [Branch Equal],
  [Opcode],
  [111101 (0x3D)],
  [`BEQ RA, IMM21`]
)

#instructionDetailsTable(
  [Branch Not Equal],
  [Opcode],
  [110101 (0x35)],
  [`BNE RA, IMM21`]
)

#instructionDetailsTable(
  [Branch Less Than],
  [Opcode],
  [101101 (0x2D)],
  [`BLT RA, IMM21`]
)

#instructionDetailsTable(
  [Branch Greater Than],
  [Opcode],
  [100101 (0x25)],
  [`BGT RA, IMM21`]
)

#instructionDetailsTable(
  [Branch Less Than Or Equal],
  [Opcode],
  [011101 (0x1D)],
  [`BLE RA, IMM21`]
)

#instructionDetailsTable(
  [Branch Greater Than Or Equal],
  [Opcode],
  [010101 (0x15)],
  [`BGE RA, IMM21`]
)

#instructionDetailsSecondPart(
  [```
IF Reg[RA] COND 0 THEN
  PC += SignExtend(IMM21) << 2
END
```],
  [None.],
  [
The conditional branch instructions perform a relative jump if the given signed comparison between the contents of Register A and zero evaluates to true.
  ]
)

#pagebreak(weak: true)

#instructionDetailsTable(
  [Branch Parity Even],
  [Opcode],
  [001101 (0x0D)],
  [`BPE RA, IMM21`]
)

#instructionDetailsTable(
  [Branch Parity Odd],
  [Opcode],
  [000101 (0x05)],
  [`BPO RA, IMM21`]
)

#instructionDetailsSecondPart(
  [```
IF Reg[RA] & 0x1 == ? THEN
  PC += SignExtend(IMM21) << 2
END
  ```],
  [None.],
  [
The branch on parity instructions perform a relative jump if Register A has the given parity. That is, for BPE, a test is made whether the low bit is clear. For BPO, a test is made whether the low bit is set.
  ]
)

#pagebreak(weak: true)

=== Immediate Operate Format

#immOpFormat()

The format for the immediate operate instructions consists of a 6-bit opcode, two 5-bit register numbers, and a 16-bit immediate value. Every immediate operate instruction has either 100, 011, 010, or 000 as the low 3 bits of the opcode.

Note that the immediate value may or may not be sign extended, depending on the instruction.

#immOpTable()

#pagebreak(weak: true)

==== Listing, 100 Group

#instructionDetailsTable(
  [Add Immediate],
  [Opcode],
  [111100 (0x3C)],
  [`ADDI RA, RB, IMM16`],
)

#instructionDetailsTable(
  [Subtract Immediate],
  [Opcode],
  [110100 (0x34)],
  [`SUBI RA, RB, IMM16`],
)

#instructionDetailsTable(
  [Set Less Than Immediate],
  [Opcode],
  [101100 (0x2C)],
  [`SLTI RA, RB, IMM16`],
)

#instructionDetailsTable(
  [Set Less Than Immediate, Signed],
  [Opcode],
  [100100 (0x24)],
  [`SLTI SIGNED RA, RB, IMM16`],
)

#instructionDetailsTable(
  [And Immediate],
  [Opcode],
  [011100 (0x1C)],
  [`ANDI RA, RB, IMM16`],
)

#instructionDetailsTable(
  [Xor Immediate],
  [Opcode],
  [010100 (0x14)],
  [`XORI RA, RB, IMM16`],
)

#instructionDetailsTable(
  [Or Immediate],
  [Opcode],
  [001100 (0x0C)],
  [`ORI RA, RB, IMM16`],
)

#instructionDetailsSecondPart(
  [```
Reg[RA] = Reg[RB] OP IMM16
  ```],
  [None.],
  [
The immediate operate instructions perform the given operation between the contents of Register B and a 16-bit immediate value, which is zero-extended, except for `SLTI SIGNED` where it is sign-extended. The result is stored in Register A. For comparisons, a 1 is stored if the comparison is true, and a 0 otherwise.
  ]
)

#pagebreak(weak: true)

#instructionDetails(
  [Load Upper Immediate],
  [Opcode],
  [000100 (0x04)],
  [`LUI RA, RB, IMM16`],
  [```
Reg[RA] = Reg[RB] | (IMM16 << 16)
```],
  [None.],
  [
The LUI instruction performs a bitwise OR between the contents of Register B and a zero-extended 16-bit immediate value which is shifted 16 bits to the left, storing the result in Register A.
  ]
)

#pagebreak(weak: true)

==== Listing, 011 Group

#box([

#align(center, [
#rect([
*MOV RA, BYTE [RB + IMM16]* \
_Load Byte, Immediate Offset_ \
Opcode: *111011* (0x3B)
```
Reg[RA] = Load8(Reg[RB] + IMM16)
```
], width: 100%)])

This instruction loads an 8-bit value into *Register A* from the address stored within *Register B* plus a zero-extended 16-bit immediate offset.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV RA, INT [RB + IMM16]* \
_Load Int, Immediate Offset_ \
Opcode: *110011* (0x33)
```
Reg[RA] = Load16(Reg[RB] + (IMM16 << 1))
```
], width: 100%)])

This instruction loads a 16-bit value into *Register A* from the address stored within *Register B* plus a zero-extended 16-bit immediate offset shifted to the left by one.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV RA, LONG [RB + IMM16]* \
_Load Long, Immediate Offset_ \
Opcode: *101011* (0x2B)
```
Reg[RA] = Load32(Reg[RB] + (IMM16 << 2))
```
], width: 100%)])

This instruction loads a 32-bit value into *Register A* from the address stored within *Register B* plus a zero-extended 16-bit immediate offset shifted to the left by two.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [*010 Group*])
  
#align(center, [
#rect([
*MOV BYTE [RA + IMM16], RB* \
_Store Byte, Immediate Offset_ \
Opcode: *111010* (0x3A)
```
Store8(Reg[RA] + IMM16, Reg[RB])
```
], width: 100%)])

This instruction stores the contents of *Register B* as an 8-bit value to the address stored within *Register A* plus a zero-extended 16-bit immediate offset.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV INT [RA + IMM16], RB* \
_Store Int, Immediate Offset_ \
Opcode: *110010* (0x32)
```
Store16(Reg[RA] + (IMM16 << 1), Reg[RB])
```
], width: 100%)])

This instruction stores the contents of *Register B* as a 16-bit value to the address stored within *Register A* plus a zero-extended 16-bit immediate offset shifted to the left by one.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV LONG [RA + IMM16], RB* \
_Store Long, Immediate Offset_ \
Opcode: *101010* (0x2A)
```
Store32(Reg[RA] + (IMM16 << 2), Reg[RB])
```
], width: 100%)])

This instruction stores the contents of *Register B* as a 32-bit value to the address stored within *Register A* plus a zero-extended 16-bit immediate offset shifted to the left by two.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV BYTE [RA + IMM16], IMM5* \
_Store Byte, Small Immediate_ \
Opcode: *011010* (0x1A)
```
Store8(Reg[RA] + IMM16, SignExtend(IMM5))
```
], width: 100%)])

This instruction stores a sign-extended 5-bit immediate as an 8-bit value to the address stored within *Register A* plus a zero-extended 16-bit immediate offset. The *Register B* field of the instruction is interpreted as the 5-bit immediate.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV INT [RA + IMM16], IMM5* \
_Store Int, Small Immediate_ \
Opcode: *010010* (0x12)
```
Store16(Reg[RA] + (IMM16 << 1), SignExtend(IMM5))
```
], width: 100%)])

This instruction stores a sign-extended 5-bit immediate as a 16-bit value to the address stored within *Register A* plus a zero-extended 16-bit immediate offset shifted left by one. The *Register B* field of the instruction is interpreted as the 5-bit immediate.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV LONG [RA + IMM16], IMM5* \
_Store Long, Small Immediate_ \
Opcode: *001010* (0x0A)
```
Store32(Reg[RA] + (IMM16 << 2), SignExtend(IMM5))
```
], width: 100%)])

This instruction stores a sign-extended 5-bit immediate as a 32-bit value to the address stored within *Register A* plus a zero-extended 16-bit immediate offset shifted left by two. The *Register B* field of the instruction is interpreted as the 5-bit immediate.

#line(length: 100%)

], width: 100%)

#align(center, [*000 Group*])

#box([

#align(center, [
#rect([
*JALR RA, RB, IMM16* \
_Jump And Link, Register_ \
Opcode: *111000* (0x38)
```
Reg[RA] = PC + 4
PC = Reg[RB] + (IMM16 << 2)
```
], width: 100%)])

The *JALR* instruction provides a lightweight means of calling through a function pointer. The next program counter (PC + 4) is saved in *Register A*, and then the PC is set to the contents of *Register B* plus a 16-bit zero-extended immediate value shifted left by two.

This instruction can also be used to jump to the contents of a register in general, by setting the destination register to the *zero* register, thereby discarding the results.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*ADR RA, IMM16* \
_Compute Relative Address_ \
Opcode: *110000* (0x30)
```
Reg[RA] = PC + (IMM16 << 16)
```
], width: 100%)])

The *ADR* instruction adds the current program counter and a 16-bit immediate value shifted left by 16. The result is stored in *Register A*. This instruction is useful for PC-relative addressing modes.

Unlike other immediate operate format instructions, this instruction's *Register B* field must be zero.

#line(length: 100%)

], width: 100%)

#pagebreak(weak: true)

#box([
=== Register Operate Format

#image("regopformat.png", fit: "stretch")

The format for the register operate instructions consists of a 6-bit opcode, three 5-bit register numbers, a 5-bit shift amount, a 2-bit shift type, and a 4-bit function code (which acts as an extended opcode). Every register operate instruction has *001* as the low 3 bits of the opcode, and there are three such opcodes; *111001*, *110001*, and *101001*.

All privileged instructions are in this format and are function codes of the last opcode mentioned, *101001*. These instructions will produce a privilege violation exception if executed while usermode is enabled in the *RS* control register (see @rs).

], width: 100%)

The value of Register C is shifted in the manner specified by the shift type, by the amount specified by the shift amount. A table of shift types follows:

#set align(center)
#table(
  columns: (auto, auto),
  align: horizon + left,
  table.cell([
    #set text(fill: white)
    #set align(center)
    *00*
  ], fill: rgb(0,0,0,255)),
  [*LSH* Left shift.],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *01*
  ], fill: rgb(0,0,0,255)),
  [*RSH* Logical right shift.],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *10*
  ], fill: rgb(0,0,0,255)),
  [*ASH* Arithmetic right shift.],
  table.cell([
    #set text(fill: white)
    #set align(center)
    *11*
  ], fill: rgb(0,0,0,255)),
  [*ROR* Rotate right.],
)
#set align(left)

#box([

#align(center, [*Opcode 111001*])
  
#align(center, [
#rect([
*MOV RA, BYTE [RB + RC xSH IMM5]* \
_Load Byte, Register Offset_ \
Function Code: *1111* (0xF)
```
Reg[RA] = Load8(Reg[RB] + (Reg[RC] xSH IMM5))
```
], width: 100%)])

This instruction loads an 8-bit value into *Register A* from the address stored within *Register B*, plus the value of *Register C* shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV RA, INT [RB + RC xSH IMM5]* \
_Load Int, Register Offset_ \
Function Code: *1110* (0xE)
```
Reg[RA] = Load16(Reg[RB] + (Reg[RC] xSH IMM5))
```
], width: 100%)])

This instruction loads a 16-bit value into *Register A* from the address stored within *Register B*, plus the value of *Register C* shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV RA, LONG [RB + RC xSH IMM5]* \
_Load Long, Register Offset_ \
Function Code: *1101* (0xD)
```
Reg[RA] = Load32(Reg[RB] + (Reg[RC] xSH IMM5))
```
], width: 100%)])

This instruction loads a 32-bit value into *Register A* from the address stored within *Register B*, plus the value of *Register C* shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV BYTE [RB + RC xSH IMM5], RA* \
_Store Byte, Register Offset_ \
Function Code: *1011* (0xB)
```
Store8(Reg[RB] + (Reg[RC] xSH IMM5), Reg[RA])
```
], width: 100%)])

This instruction stores the contents of *Register A* as an 8-bit value to the address stored within *Register B*, plus the value of *Register C* shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV INT [RB + RC xSH IMM5], RA* \
_Store Int, Register Offset_ \
Function Code: *1010* (0xA)
```
Store16(Reg[RB] + (Reg[RC] xSH IMM5), Reg[RA])
```
], width: 100%)])

This instruction stores the contents of *Register A* as a 16-bit value to the address stored within *Register B*, plus the value of *Register C* shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV LONG [RB + RC xSH IMM5], RA* \
_Store Long, Register Offset_ \
Function Code: *1001* (0x9)
```
Store32(Reg[RB] + (Reg[RC] xSH IMM5), Reg[RA])
```
], width: 100%)])

This instruction stores the contents of *Register A* as a 32-bit value to the address stored within *Register B*, plus the value of *Register C* shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*LSH/RSH/ASH/ROR RA, RC, RB* \
_Various Shift By Register Amount_ \
Function Code: *1000* (0x8)
```
Reg[RA] = Reg[RC] xSH (Reg[RB] & 31)
```
], width: 100%)])

This instruction shifts the contents of *Register C* by the contents of *Register B* and places the result in *Register A*. It is technically a single function code, but is split into several mnemonics for convenience. The *IMM5* shift value is ignored, and is taken from *Register B* instead.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*ADD RA, RB, RC xSH IMM5* \
_Add Register_ \
Function Code: *0111* (0x7)
```
Reg[RA] = Reg[RB] + (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction adds the contents of *Register B* to the contents of *Register C*, and stores the result into *Register A*. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SUB RA, RB, RC xSH IMM5* \
_Subtract Register_ \
Function Code: *0110* (0x6)
```
Reg[RA] = Reg[RB] - (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction subtracts the contents of *Register B* by the contents of *Register C*, and stores the result into *Register A*. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SLT RA, RB, RC xSH IMM5* \
_Set Less Than Register_ \
Function Code: *0101* (0x5)
```
Reg[RA] = Reg[RB] < (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction sets *Register A* to the result of an unsigned less-than comparison between the contents of *Register B* and the contents of *Register C*. The result is *1* if the comparison is true, and *0* otherwise. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SLT SIGNED RA, RB, RC xSH IMM5* \
_Set Less Than Register, Signed_ \
Function Code: *0100* (0x4)
```
Reg[RA] = Reg[RB] s< (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction sets *Register A* to the result of a signed less-than comparison between the contents of *Register B* and the contents of *Register C*. The result is *1* if the comparison is true, and *0* otherwise. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*AND RA, RB, RC xSH IMM5* \
_And Register_ \
Function Code: *0011* (0x3)
```
Reg[RA] = Reg[RB] & (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction performs a bitwise AND between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*XOR RA, RB, RC xSH IMM5* \
_Xor Register_ \
Function Code: *0010* (0x2)
```
Reg[RA] = Reg[RB] $ (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction performs a bitwise XOR between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*OR RA, RB, RC xSH IMM5* \
_Or Register_ \
Function Code: *0001* (0x1)
```
Reg[RA] = Reg[RB] | (Reg[RC] xSH IMM5)
```
], width: 100%)])

This instruction performs a bitwise OR between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*NOR RA, RB, RC xSH IMM5* \
_Nor Register_ \
Function Code: *0000* (0x0)
```
Reg[RA] = ~(Reg[RB] | (Reg[RC] xSH IMM5))
```
], width: 100%)])

This instruction performs a bitwise NOR between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The contents of *Register C* are first shifted in the manner specified.

#line(length: 100%)

], width: 100%)

#align(center, [*Opcode 110001*])

#box([

#align(center, [
#rect([
*MUL RA, RB, RC* \
_Multiply_ \
Function Code: *1111* (0xF)
```
Reg[RA] = Reg[RB] * Reg[RC]
```
], width: 100%)])

This instruction performs an integer multiplication between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*DIV RA, RB, RC* \
_Divide_ \
Function Code: *1101* (0xD)
```
Reg[RA] = Reg[RB] / Reg[RC]
```
], width: 100%)])

This instruction performs an unsigned integer division between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The result of the division is rounded down to the last whole integer.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*DIV SIGNED RA, RB, RC* \
_Divide, Signed_ \
Function Code: *1100* (0xC)
```
Reg[RA] = Reg[RB] s/ Reg[RC]
```
], width: 100%)])

This instruction performs a signed integer division between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The result of the division is rounded toward zero to a whole integer.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOD RA, RB, RC* \
_Modulo_ \
Function Code: *1011* (0xB)
```
Reg[RA] = Reg[RB] % Reg[RC]
```
], width: 100%)])

This instruction performs an unsigned modulo between the contents of *Register B* and the contents of *Register C*, and stores the result into *Register A*. The modulo is the remainder part of the result of an unsigned division.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*LL RA, RB* \
_Load Locked_ \
Function Code: *1001* (0x9)
```
Locked = TRUE
LockedAddress = Translate(Reg[RB])
Reg[RA] = Load32(Reg[RB])
```
], width: 100%)])

This instruction is used to implement atomic sequences. It loads the 32-bit contents of a naturally-aligned memory address within *Register B* into *Register A*. It also sets two "registers" associated with the current processor: a "locked" flag is set to TRUE, and a "locked address" is set to the physical address being accessed. Though it is implementation-dependent, these "registers" likely do not reside on the processor itself, and may be implemented in any way as long as it provides the same semantics.

If the *RFE* _Return From Exception_ instruction is executed on the current processor, the "locked" flag is cleared, causing a future *SC* instruction on this processor to fail. This is the only required behavior in a uniprocessor system. In a multiprocessor system, if any other processor performs a store instruction to this processor's "locked address", this processor's "locked" flag is cleared. This can be used to implement atomic sequences in non-privileged (i.e. usermode) code.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SC RA, RB, RC* \
_Store Conditional_ \
Function Code: *1000* (0x8)
```
IF Locked THEN
  Store32(Reg[RB], Reg[RC])
END
Reg[RA] = Locked
```
], width: 100%)])

This instruction stores the current value of the processor's "locked" flag to *Register A*. If the "locked" flag is set, it stores the contents of *Register C* to the address contained within *Register B*, and (like any other store instruction) clears the "locked" flag of any other processor with the same physical address locked by the *LL* _Load Locked_ instruction.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*PAUSE* \
_Pause_ \
Function Code: *0110* (0x6)
```
// Possible implementation.
PauseCount += 1
IF PauseCount >= 256 THEN
  PauseCount = 0
  Yield()
END
```
], width: 100%)])

On multiprocessor systems, this instruction should be executed on each iteration of a spin-wait loop for another processor to do something (release a spinlock, acknowledge an IPI, etc). It serves as a hint that the processor isn't doing useful work, which can be used to optimize emulation software among other things.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MB* \
_Memory Barrier_ \
Function Code: *0011* (0x3)
```
// Possible implementation.
FlushWriteBuffer()
RetireAllLoads()
```
], width: 100%)])

This instruction ensures that, from the perspective of all other processors and I/O devices in the system, no reads or writes performed by this processor are reordered across the *MB* instruction in either direction.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*WMB* \
_Write Memory Barrier_ \
Function Code: *0010* (0x2)
```
// Possible implementation.
FlushWriteBuffer()
```
], width: 100%)])

This instruction ensures that, from the perspective of all other processors and I/O devices in the system, no writes performed by this processor before the *WMB* instruction are reordered after the *WMB* instruction. One example of this instruction on a uniprocessor system is to ensure that a device has seen a sequence of writes to its registers before asking it to perform a command. An example on a multiprocessor system is to ensure data coherency before releasing a spinlock.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*BRK* \
_Breakpoint_ \
Function Code: *0001* (0x1)
```
Exception(BRK)
```
], width: 100%)])

This instruction causes a breakpoint exception. Its intended use is for debugging purposes. See @exceptionblock.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SYS* \
_System Service_ \
Function Code: *0000* (0x0)
```
Exception(SYS)
```
], width: 100%)])

This instruction causes a system service exception. It is useful for usermode to make a call into the system software to request a service (also called a system call or "syscall"). See @exceptionblock.

#line(length: 100%)

], width: 100%)

#align(center, [*Opcode 101001 (Privileged Instructions)*])

These instructions all produce a *PRV* exception if executed while usermode is active. See @exceptionblock.

#box([

#align(center, [
#rect([
*MFCR RA, CR* \
_Move From Control Register_ \
Function Code: *1111* (0xF)
```
Reg[RA] = ControlReg[CR]
```
], width: 100%)])

This instruction moves the contents of the specified control register into *Register A*. The 5-bit control register number is encoded in the place of *Register C*. See @controlregs for a full listing of control registers and their behaviors.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MTCR CR, RB* \
_Move To Control Register_ \
Function Code: *1110* (0xE)
```
ControlReg[CR] = Reg[RB]
```
], width: 100%)])

This instruction moves the contents of *Register B* into the specified control register. The 5-bit control register number is encoded in the place of *Register C*. *Register A* is ignored but should be encoded as zero. See @controlregs for a full listing of control registers and their behaviors.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*HLT* \
_Halt Until Next Interrupt_ \
Function Code: *1100* (0xC)
```
Halt()
```
], width: 100%)])

This instruction pauses execution of the processor until the next external interrupt is received. This can be used as a power-saving measure; for instance, executing *HLT* in a loop in the low priority idle thread of a multitasking kernel could greatly reduce the idle power consumption of the system. If external interrupts are disabled, this instruction causes the processor to halt until it is reset.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*RFE* \
_Return From Exception_ \
Function Code: *1011* (0xB)
```
Locked = FALSE
IF ControlReg[RS].ModeStack & T THEN
  PC = ControlReg[TBPC]
ELSE
  PC = ControlReg[EPC]
END
ControlReg[RS].ModeStack = ControlReg[RS].ModeStack >> 8
```
], width: 100%)])

This instruction pops the "mode stack" of the *RS* control register (see @rs), and returns execution to the program counter saved in either the *TBPC* or *EPC* control register, depending on if the *T* bit of *RS* was set or not, respectively (i.e., whether a TB miss handler was active or not; see @tbmiss). It also clears the "locked" flag, causing the next *SC* _Store Conditional_ instruction to fail.

#line(length: 100%)

], width: 100%)

#pagebreak(weak: true)

== Pseudo-Instructions <pseudoinstructions>
Some operations are synthesized out of simpler instructions, but are common or inconvenient enough to warrant a "pseudo-instruction", a fake instruction that the assembler converts into a corresponding hardware instruction sequence. The following is a (not necessarily exhaustive, depending on the assembler) list of common pseudo-instructions.

#box([

#align(center, [
#rect([
*B IMM21* \
_Unconditional Relative Branch_
```
BEQ ZERO, IMM21
```
], width: 100%)])

This pseudo-instruction performs an unconditional relative branch. This is synthesized out of the *BEQ* _Branch Equal_ instruction, by comparing the contents of the register *ZERO* with the number zero; by definition, this will always be true.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*RET* \
_Return_
```
JALR ZERO, LR, 0
```
], width: 100%)])

This pseudo-instruction performs a common return from subroutine operation. This is synthesized out of the *JALR* _Jump And Link, Register_ instruction, by performing a jump-and-link to the contents of the link register *LR*, and saving the result in *ZERO* (thereby discarding it).

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*JR RA* \
_Jump to Register_
```
JALR ZERO, RA, 0
```
], width: 100%)])

This pseudo-instruction performs a jump to the contents of *Register A*. This is synthesized out of the *JALR* _Jump And Link, Register_ instruction, by performing a jump-and-link to the contents of *Register A*, and saving the result in *ZERO* (thereby discarding it).

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV RA, RB* \
_Move Register_
```
ADD RA, RB, ZERO LSH 0
```
], width: 100%)])

This pseudo-instruction copies the contents of *Register B* into *Register A*. It is synthesized out of the *ADD* _Add Register_ instruction, by adding the contents of the *ZERO* register to the contents of *Register B* (which is a no-op), and saving the results in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*LI RA, IMM16* \
_Load 16-bit Immediate_
```
ADDI RA, ZERO, IMM16
```
], width: 100%)])

This pseudo-instruction loads a 16-bit immediate into *Register A*. It is synthesized out of the *ADDI* _Add Immediate_ instruction, by adding the immediate to the contents of the *ZERO* register and saving the results in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*LA RA, IMM32* \
_Load 32-bit Immediate_
```
LUI RA, ZERO, (IMM32 >> 16)
ORI RA, RA, (IMM32 & 0xFFFF)
```
], width: 100%)])

This pseudo-instruction loads a 32-bit immediate into *Register A*. It is synthesized out of the *LUI* _Load Upper Immediate_ and *ORI* _Or Immediate_ instructions, by loading the upper 16 bits of the immediate into the register with *LUI*, and then bitwise OR-ing the lower 16 bits in with *ORI*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*NOP* \
_No Operation_
```
ADDI ZERO, ZERO, 0
```
], width: 100%)])

This pseudo-instruction does nothing, by adding the contents of the *ZERO* register with the number zero and saving the result in the *ZERO* register.

Note that the instruction of all zeroes is _not_ a no-op, and this instruction set was carefully designed to ensure that that is an invalid instruction, so that exceptions will occur if the processor jumps off "into nowhere".

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*LSHI/RSHI/ASHI/RORI RA, RB, IMM5* \
_Various Shift By Immediate Amount_
```
ADD RA, ZERO, RB xSH IMM5
```
], width: 100%)])

These pseudo-instructions shift the contents of *Register B* by the 5-bit immediate, and saves the result in *Register A*. They are synthesized with the *ADD* _Add Register_ instruction, by adding the contents of *Register B* with the contents of the *ZERO* register, and shifting it in the specified manner.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV RA, BYTE/INT/LONG [IMM32]* \
_Load From 32-bit Address_
```
LUI RA, ZERO, (IMM32 >> 16)
MOV RA, BYTE/INT/LONG [RA + (IMM32 & 0xFFFF)]
```
], width: 100%)])

These pseudo-instructions load a value into *Register A* from a full 32-bit address. They are synthesized with *LUI* _Load Upper Immediate_ and the appropriate offsetted load instructions. The upper 16 bits of the address are loaded into the register with *LUI*, and then a load is done into the register with the offset being the low 16 bits of the address.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*MOV BYTE/INT/LONG [IMM32], RA, TMP=RB* \
_Store To 32-bit Address_
```
LUI RB, ZERO, (IMM32 >> 16)
MOV BYTE/INT/LONG [RB + (IMM32 & 0xFFFF)], RA
```
], width: 100%)])

These pseudo-instructions store a value into a full 32-bit address. They are synthesized with *LUI* _Load Upper Immediate_ and the appropriate offsetted store instructions. The upper 16 bits of the address are loaded into a user-supplied temporary register with *LUI*, and then a store is done with the offset being the low 16 bits of the address.

#line(length: 100%)

], width: 100%)
