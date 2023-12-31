#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Instructions
== Instruction Formats Summary

The XR/17032 architecture features only four instruction formats, and each are 32 bits wide. There are a total of 60 instructions, which are summarized below. A more comprehensive description of each format and instruction can be found in @instlisting.

#image("formats.png", fit: "stretch")

=== Jump Instructions Summary

- *J IMM29* _Jump_
- *JAL IMM29* _Jump And Link_

=== Branch Instructions Summary

- *BEQ RA, IMM21* _Branch Equal_
- *BNE RA, IMM21* _Branch Not Equal_
- *BLT RA, IMM21* _Branch Less Than_
- *BGT RA, IMM21* _Branch Greater Than_
- *BGE RA, IMM21* _Branch Greater Than or Equal_
- *BLE RA, IMM21* _Branch Less Than or Equal_
- *BPE RA, IMM21* _Branch Parity Even_
- *BPO RA, IMM21* _Branch Parity Odd_

=== Immediate Operate Instructions Summary

- *ADDI RA, RB, IMM16* _Add Immediate_
- *SUBI RA, RB, IMM16* _Subtract Immediate_
- *SLTI RA, RB, IMM16* _Set Less Than Immediate_
- *SLTI SIGNED RA, RB, IMM16* _Set Less Than Immediate, Signed_
- *ANDI RA, RB, IMM16* _And Immediate_
- *XORI RA, RB, IMM16* _Xor Immediate_
- *ORI RA, RB, IMM16* _Or Immediate_
- *LUI RA, RB, IMM16* _Load Upper Immediate_
- *MOV RA, BYTE [RB + IMM16]* _Load Byte, Immediate Offset_
- *MOV RA, INT [RB + IMM16]* _Load Int, Immediate Offset_
- *MOV RA, LONG [RB + IMM16]* _Load Long, Immediate Offset_
- *MOV BYTE [RA + IMM16], RB* _Store Byte, Immediate Offset_
- *MOV INT [RA + IMM16], RB* _Store Int, Immediate Offset_
- *MOV LONG [RA + IMM16], RB* _Store Long, Immediate Offset_
- *MOV BYTE [RA + IMM16], IMM5* _Store Byte, Small Immediate_
- *MOV INT [RA + IMM16], IMM5* _Store Int, Small Immediate_
- *MOV LONG [RA + IMM16], IMM5* _Store Long, Small Immediate_
- *JALR RA, RB, IMM16* _Jump And Link, Register_

=== Register Operate Instructions Summary

*Major Opcode 111001*
- *MOV RA, BYTE [RB + RC xSH IMM5]* _Load Byte, Register Offset_
- *MOV RA, INT [RB + RC xSH IMM5]* _Load Int, Register Offset_
- *MOV RA, LONG [RB + RC xSH IMM5]* _Load Long, Register Offset_
- *MOV BYTE [RB + RC xSH IMM5], RA* _Store Byte, Register Offset_
- *MOV INT [RB + RC xSH IMM5], RA* _Store Int, Register Offset_
- *MOV LONG [RB + RC xSH IMM5], RA* _Store Long, Register Offset_
- *LSH RA, RB, RC* _Left Shift By Register Amount_
- *RSH RA, RB, RC* _Logical Right Shift By Register Amount_
- *ASH RA, RB, RC* _Arithmetic Right Shift By Register Amount_
- *ROR RA, RB, RC* _Rotate Right By Register Amount_
- *ADD RA, RB, RC xSH IMM5* _Add Register_
- *SUB RA, RB, RC xSH IMM5* _Subtract Register_
- *SLT RA, RB, RC xSH IMM5* _Set Less Than Register_
- *SLT SIGNED RA, RB, RC xSH IMM5* _Set Less Than Register, Signed_
- *AND RA, RB, RC xSH IMM5* _And Register_
- *XOR RA, RB, RC xSH IMM5* _Xor Register_
- *OR RA, RB, RC xSH IMM5* _Or Register_
- *NOR RA, RB, RC xSH IMM5* _Nor Register_
*Major Opcode 110001*
- *MUL RA, RB, RC* _Multiply_
- *DIV RA, RB, RC* _Divide_
- *DIV SIGNED RA, RB, RC* _Divide, Signed_
- *MOD RA, RB, RC* _Modulo_
- *LL RA, RB* _Load Locked_
- *SC RA, RB, RC* _Store Conditional_
- *MB* _Memory Barrier_
- *WMB* _Write Memory Barrier_
- *BRK* _Breakpoint_
- *SYS* _System Service_
*Major Opcode 101001 (Privileged Instructions)*
- *MFCR RA, CR* _Move From Control Register_
- *MTCR CR, RA* _Move To Control Register_
- *HLT* _Halt Until Next Interrupt_
- *RFE* _Return From Exception_

== Instruction Listing <instlisting>
The following section contains a comprehensive listing of all of the instructions defined by the XR/17032 architecture along with their encodings. The instructions are grouped first by format, and then by major opcode.

Note that the assembly language also supports several "pseudo-instructions" for ease of assembly programming, which are not listed below, as they don't directly correspond to any particular hardware instruction, and are usually translated to a sequence of several hardware instructions. See @pseudoinstructions for a listing of pseudo-instructions.

#pagebreak(weak: true)

#box([

=== Jump Format

#image("jumpformat.png", fit: "stretch")

The format for the absolute jump instructions consists of a 3-bit opcode and a 29-bit jump target. The two possible opcodes for jump instructions are *111* and *110*.

], width: 100%)

Note that this opcode field is unique; all other formats have a 6-bit opcode field. This small opcode is to allow the jump target to cover a 2GB range. This is accomplished by shifting the jump target left by 2, which produces a 31-bit address, and then taking the uppermost bit from that of the current program counter. This allows jumping anywhere within a 2GB userspace or kernel space in a single instruction.

#box([

#line(length: 100%)
#align(center, [
#rect([
*JAL IMM29* \
_Jump And Link_ \
Opcode: *111* (0x07)
```
Reg[31] = PC + 4
PC = (IMM29 << 2) | (PC & 0x80000000)
```
], width: 100%)])

The *JAL* instruction provides a lightweight means of calling a function. The next program counter (PC + 4) is saved in the link register (31) and then the PC is set to the target address.

Note that if the called function needs to call another function, it must be sure to save the link register first and then restore it.

], width: 100%)

#box([

#line(length: 100%)
#align(center, [
#rect([
*J IMM29* \
_Jump_ \
Opcode: *110* (0x06)
```
PC = (IMM29 << 2) | (PC & 0x80000000)
```
], width: 100%)])
The *J* instruction provides a way to do a long-distance absolute jump to another location, without destroying the contents of the link register.

], width: 100%)

#line(length: 100%)

#pagebreak(weak: true)

#box([
=== Branch Format

#image("branchformat.png", fit: "stretch")

The format for the branch instructions consists of a 6-bit opcode, a 5-bit register number, and a 21-bit branch offset. Every branch instruction has *101* as the low 3 bits of the opcode.

], width: 100%)

There is only one register field in order to maximize the size of the branch offset. This register is compared against zero in various ways. If the branch is taken, then the branch offset is shifted left by two, sign extended, and added to the current program counter. This gives a range of $plus.minus$1M instructions, or $plus.minus$4MB. As this covers the entire text section of most programs, and certainly covers any individual routine you're likely to find, this alleviates some burden that afflicts most RISC toolchains, as cross-procedure jumps will usually be done with absolute jumps anyway.

#box([

#align(center, [
#rect([
*BEQ RA, IMM21* \
_Branch Equal_ \
Opcode: *111101* (0x3D)
```
IF Reg[RA] == 0 THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BEQ* instruction performs a relative jump if the contents of *Register A* are equal to zero.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*BNE RA, IMM21* \
_Branch Not Equal_ \
Opcode: *110101* (0x35)
```
IF Reg[RA] != 0 THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BNE* instruction performs a relative jump if the contents of *Register A* are not equal to zero.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*BLT RA, IMM21* \
_Branch Less Than_ \
Opcode: *101101* (0x2D)
```
IF Reg[RA] & 0x80000000 THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BLT* instruction performs a relative jump if the contents of *Register A* are less than zero, i.e., the sign bit is set.

#line(length: 100%)

], width: 100%)

#box([
#align(center, [
#rect([
*BGT RA, IMM21* \
_Branch Greater Than_ \
Opcode: *100101* (0x25)
```
IF NOT (Reg[RA] & 0x80000000) AND Reg[RA] != 0 THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BGT* instruction performs a relative jump if the contents of *Register A* are greater than zero, i.e., the sign bit is clear and the register is not equal to zero.

#line(length: 100%)

], width: 100%)

#box([

#box([

#align(center, [
#rect([
*BLE RA, IMM21* \
_Branch Less Than Or Equal_ \
Opcode: *011101* (0x15)
```
IF Reg[RA] & 0x80000000 OR Reg[RA] == 0 THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BLE* instruction performs a relative jump if the contents of *Register A* are less than or equal to zero, i.e., the sign bit is set or the register is equal to zero.

#line(length: 100%)

], width: 100%)
  
#align(center, [
#rect([
*BGE RA, IMM21* \
_Branch Greater Than Or Equal_ \
Opcode: *010101* (0x1D)
```
IF NOT (Reg[RA] & 0x80000000) THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BGE* instruction performs a relative jump if the contents of *Register A* are greater than or equal to zero, i.e., the sign bit is clear.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*BPE RA, IMM21* \
_Branch Parity Even_ \
Opcode: *001101* (0x0D)
```
IF NOT (Reg[RA] & 0x1) THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BPE* instruction performs a relative jump if the contents of *Register A* are even, i.e., the low bit is clear.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*BPO RA, IMM21* \
_Branch Parity Odd_ \
Opcode: *000101* (0x05)
```
IF Reg[RA] & 0x1 THEN
  PC += SignExtend(IMM21)
END
```
], width: 100%)])

The *BPO* instruction performs a relative jump if the contents of *Register A* are odd, i.e., the low bit is set.

#line(length: 100%)

], width: 100%)

#pagebreak(weak: true)

#box([
=== Immediate Operate Format

#image("immopformat.png", fit: "stretch")

The format for the immediate operate instructions consists of a 6-bit opcode, two 5-bit register numbers, and a 16-bit immediate value. Every immediate operate instruction has either *100*, *011*, *010*, or *000* as the low 3 bits of the opcode.

], width: 100%)

Note that the immediate value may or may not be sign extended, depending on the instruction.

#align(center, [*100 Group*])

#box([

#align(center, [
#rect([
*ADDI RA, RB, IMM16* \
_Add Immediate_ \
Opcode: *111100* (0x3C)
```
Reg[RA] = Reg[RB] + IMM16
```
], width: 100%)])

The *ADDI* instruction performs an addition between the contents of *Register B* and a zero-extended 16-bit immediate value, storing the result in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SUBI RA, RB, IMM16* \
_Subtract Immediate_ \
Opcode: *110100* (0x34)
```
Reg[RA] = Reg[RB] - IMM16
```
], width: 100%)])

The *SUBI* instruction performs a subtraction between the contents of *Register B* and a zero-extended 16-bit immediate value, storing the result in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SLTI RA, RB, IMM16* \
_Set Less Than Immediate_ \
Opcode: *101100* (0x2C)
```
Reg[RA] = Reg[RB] < IMM16
```
], width: 100%)])

The *SLTI* instruction performs an unsigned less-than comparison between the contents of *Register B* and a zero-extended 16-bit immediate value. If the comparison is true, a *1* is stored in *Register A*. Otherwise, a *0* is stored.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*SLTI SIGNED RA, RB, IMM16* \
_Set Less Than Immediate, Signed_ \
Opcode: *100100* (0x24)
```
Reg[RA] = Reg[RB] s< SignExtend(IMM16)
```
], width: 100%)])

The *SLTI SIGNED* instruction performs a signed comparison between the contents of *Register B* and a sign-extended 16-bit immediate value. If the comparison is true, a *1* is stored in *Register A*. Otherwise, a *0* is stored.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*ANDI RA, RB, IMM16* \
_And Immediate_ \
Opcode: *011100* (0x1C)
```
Reg[RA] = Reg[RB] & IMM16
```
], width: 100%)])

The *ANDI* instruction performs a bitwise AND between the contents of *Register B* and a zero-extended 16-bit immediate value, storing the result in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*XORI RA, RB, IMM16* \
_Xor Immediate_ \
Opcode: *010100* (0x14)
```
Reg[RA] = Reg[RB] $ IMM16
```
], width: 100%)])

The *XORI* instruction performs a bitwise XOR between the contents of *Register B* and a zero-extended 16-bit immediate value, storing the result in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*ORI RA, RB, IMM16* \
_Or Immediate_ \
Opcode: *001100* (0x0C)
```
Reg[RA] = Reg[RB] | IMM16
```
], width: 100%)])

The *ORI* instruction performs a bitwise OR between the contents of *Register B* and a zero-extended 16-bit immediate value, storing the result in *Register A*.

#line(length: 100%)

], width: 100%)

#box([

#align(center, [
#rect([
*LUI RA, RB, IMM16* \
_Load Upper Immediate_ \
Opcode: *000100* (0x04)
```
Reg[RA] = Reg[RB] | (IMM16 << 16)
```
], width: 100%)])

The *LUI* instruction performs a bitwise OR between the contents of *Register B* and a zero-extended 16-bit immediate value which is shifted 16 bits to the left, storing the result in *Register A*.

#line(length: 100%)

], width: 100%)

#align(center, [*011 Group*])

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
PC = Reg[RB] + (SignExtend(IMM16) << 2)
```
], width: 100%)])

The *JALR* instruction provides a lightweight means of calling through a function pointer. The next program counter (PC + 4) is saved in *Register A*, and then the PC is set to the contents of *Register B* plus a 16-bit sign-extended immediate value shifted left by two.

This instruction can also be used to jump to the contents of a register in general, by setting the destination register to the *zero* register, thereby discarding the results.

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
#tablex(
  columns: (auto, auto),
  align: horizon,
  cellx([
    #set text(fill: white)
    #set align(center)
    *00*
  ], fill: rgb(0,0,0,255)),
  [*LSH* Left shift.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *01*
  ], fill: rgb(0,0,0,255)),
  [*RSH* Logical right shift.],
  cellx([
    #set text(fill: white)
    #set align(center)
    *10*
  ], fill: rgb(0,0,0,255)),
  [*ASH* Arithmetic right shift.],
  cellx([
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
Reg[RA] = Reg[RC] xSH Reg[RB]
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

If the *RFE* _Return From Exception_ instruction is executed on the current processor, the "locked" flag is cleared, causing a future *SC* instruction on this processor to fail. This is the only required behavior in a uniprocessor system. In a multiprocessor system, if any other processor performs an *SC* _Store Conditional_ instruction to this processor's "locked address", this processor's "locked" flag is cleared. This can be used to implement atomic sequences in non-privileged (i.e. usermode) code.

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
  ClearOtherLockedFlags(Translate(Reg[RC]))
  Store32(Reg[RB], Reg[RC])
END
Reg[RA] = Locked
```
], width: 100%)])

This instruction stores the current value of the processor's "locked" flag to *Register A*. If the "locked" flag is set, it stores the contents of *Register C* to the address contained within *Register B*, and clears the "locked" flag of any other processor with the same physical address locked by the *LL* _Load Locked_ instruction.

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

This instruction need not be executed in a uniprocessor system. In a multiprocessor system, it ensures that, from the perspective of all other processors and I/O devices in the system, all prior writes performed by this processor have completed, as have all reads. One example of the usage of this instruction is to ensure data coherency after acquiring a spinlock.

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

This instruction ensures that, from the perspective of all other processors and I/O devices in the system, all writes performed by this processor have completed. One example of this instruction on a uniprocessor system is to ensure that a device has seen a sequence of writes to its registers before asking it to perform a command. An example on a multiprocessor system is to ensure data coherency before releasing a spinlock.

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

This instruction causes a breakpoint exception. Its intended use is for debugging purposes. See @ecause.

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

This instruction causes a system service exception. It is useful for usermode to make a call into the system software to request a service (also called a system call or "syscall"). See @ecause.

#line(length: 100%)

], width: 100%)

#align(center, [*Opcode 101001 (Privileged Instructions)*])

These instructions all produce a *PRV* exception if executed while usermode is active. See @ecause.

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
ControlReg[CR] = Reg[RA]
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