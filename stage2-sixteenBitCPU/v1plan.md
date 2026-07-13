# 16-Bit CPU ISA v1.0 Specification

> **Status:** Design specification / implementation plan  
> **Target:** SystemVerilog CPU and Python assembler  
> **Instruction/data width:** 16 bits  
> **Registers:** Eight writable registers (`R0`–`R7`)  
> **Memory:** Unified, word-addressed instruction and data memory

This document expands the handwritten encoding sheet into a detailed GitHub-ready plan. It defines instruction behavior, encodings, extension rules, assembler directives, pseudo-instructions, examples, and implementation expectations.

---

## 1. Architecture

### Registers

| Register | Encoding |
|---|---:|
| `R0` | `000` |
| `R1` | `001` |
| `R2` | `010` |
| `R3` | `011` |
| `R4` | `100` |
| `R5` | `101` |
| `R6` | `110` |
| `R7` | `111` |

All registers are writable. `R7` is the conventional return-address register used by `JAL` and `JALR`.

### Program counter rule

All PC-relative targets use the incremented PC:

```text
target = PC + 1 + sign_extend(offset)
```

### Unified memory

Instructions and data share one 16-bit word-addressed memory. The same memory is used for instruction fetch, loads/stores, indirect memory operations, and `.WORD` data. The CPU is therefore planned as a multi-cycle design.

### Extension rules

**Sign-extend:**

- `ADDI`, `SUBI`, `MULI`, `CMPI`
- `LI`
- every PC-relative offset
- every base-register offset

**Zero-extend:**

- `ANDI`, `ORI`, `XORI`
- shift/rotate amounts

Signed arithmetic uses 16-bit two's-complement values.

---

## 2. Opcode Map

| Opcode | Instruction or family |
|---|---|
| `0000` | `ADD` / `ADDI` |
| `0001` | `SUB` / `SUBI` |
| `0010` | `MUL` / `MULI` |
| `0011` | `AND` / `ANDI` |
| `0100` | `OR` / `ORI` |
| `0101` | `XOR` / `XORI` |
| `0110` | `NOT` |
| `0111` | Shift/rotate family |
| `1000` | `LD`, `ST`, `LDI`, `STI` |
| `1001` | `LDR`, `STR` |
| `1010` | `LI`, `LEA` |
| `1011` | `JAL`, `JMP`, `JALR` |
| `1100` | Reserved |
| `1101` | `CMP`, `CMPI` |
| `1110` | Branch family |
| `1111` | `NOP`, `HALT` |

---

# 3. Arithmetic and Logic

## Shared register format

```text
15          12 11       9 8        6 5 4 3 2        0
+-------------+-----------+----------+-+---+----------+
|   opcode    |    DR     |   SR1    |0|00 |   SR2    |
+-------------+-----------+----------+-+---+----------+
```

Pattern:

```text
oooo ddd sss 0 00 rrr
```

## Shared immediate format

```text
15          12 11       9 8        6 5 4             0
+-------------+-----------+----------+-+---------------+
|   opcode    |    DR     |    SR    |1|     imm5      |
+-------------+-----------+----------+-+---------------+
```

Pattern:

```text
oooo ddd sss 1 iiiii
```

Arithmetic `imm5` values range from `-16` to `+15`. Logical `imm5` values range from `0` to `31`.

## ADD / ADDI — `0000`

```asm
ADD  DR, SR1, SR2
ADDI DR, SR, imm5
```

```text
ADD:  DR = SR1 + SR2
ADDI: DR = SR + sign_extend(imm5)
```

Example:

```asm
ADD R1, R2, R3
```

With `R2=7` and `R3=4`, `R1=11`:

```text
0000 0000 0000 0111
+ 0000 0000 0000 0100
= 0000 0000 0000 1011
```

Encoding:

```text
0000 001 010 0 00 011
```

## SUB / SUBI — `0001`

```asm
SUB  DR, SR1, SR2
SUBI DR, SR, imm5
```

```text
SUB:  DR = SR1 - SR2
SUBI: DR = SR - sign_extend(imm5)
```

Example: `12 - 5 = 7`.

## MUL / MULI — `0010`

```asm
MUL  DR, SR1, SR2
MULI DR, SR, imm5
```

Multiplication is signed two's-complement multiplication:

```text
full_product = signed_operand1 × signed_operand2
DR = full_product[15:0]
```

Example:

```asm
MULI R1, R2, 4
```

With `R2=6`, `R1=24`:

```text
0000 0000 0001 1000
```

A full product may require 32 bits. Version 1 keeps the lower 16 bits. Planned overflow detection compares the upper half against the sign extension of bit 15.

## AND / ANDI — `0011`

```asm
AND  DR, SR1, SR2
ANDI DR, SR, imm5
```

```text
AND:  DR = SR1 & SR2
ANDI: DR = SR & zero_extend(imm5)
```

Example:

```text
1100 AND 1010 = 1000
```

`ANDI R1, R1, 15` masks off every bit except the lowest four.

## OR / ORI — `0100`

```asm
OR  DR, SR1, SR2
ORI DR, SR, imm5
```

```text
OR:  DR = SR1 | SR2
ORI: DR = SR | zero_extend(imm5)
```

Example:

```text
1100 OR 1010 = 1110
```

## XOR / XORI — `0101`

```asm
XOR  DR, SR1, SR2
XORI DR, SR, imm5
```

```text
XOR:  DR = SR1 ^ SR2
XORI: DR = SR ^ zero_extend(imm5)
```

Example:

```text
1100 XOR 1010 = 0110
```

## NOT — `0110`

Format:

```text
0110 ddd sss 000000
```

```asm
NOT DR, SR
```

```text
DR = ~SR
```

Example:

```text
0000 0000 0000 1111
→ 1111 1111 1111 0000
```

---

# 4. Shift/Rotate Family — `0111`

Format:

```text
0111 ddd sss ff aaaa
```

| `ff` | Instruction | Meaning |
|---|---|---|
| `00` | `SHL` | Logical shift left |
| `01` | `SHR` | Logical shift right |
| `10` | `SHA` | Arithmetic shift right |
| `11` | `ROR` | Rotate right |

The unsigned amount ranges from `0` through `15`.

## SHL

```asm
SHL DR, SR, amount
```

Zeros enter from the right. `5 << 3 = 40`:

```text
0000 0000 0000 0101
→ 0000 0000 0010 1000
```

## SHR

```asm
SHR DR, SR, amount
```

Zeros enter from the left. This is appropriate for unsigned values.

## SHA

```asm
SHA DR, SR, amount
```

Copies the sign bit into newly opened upper positions.

```text
-8 = 1111 1111 1111 1000
SHA by 1
-4 = 1111 1111 1111 1100
```

## ROR

```asm
ROR DR, SR, amount
```

Bits shifted off the right side re-enter on the left.

---

# 5. PC-Relative Memory Family — `1000`

Format:

```text
1000 rrr mm ooooooo
```

| `mm` | Instruction |
|---|---|
| `00` | `LD` |
| `01` | `ST` |
| `10` | `LDI` |
| `11` | `STI` |

`PCOffset7` is signed, with a range of `-64` through `+63` words.

```text
address = PC + 1 + sign_extend(PCOffset7)
```

## LD

```asm
LD DR, label
```

```text
DR = memory[PC + 1 + offset]
```

Example: if the instruction is at address `20`, the incremented PC is `21`, the offset is `5`, and `memory[26]=42`, then `DR=42`.

## ST

```asm
ST SR, label
```

```text
memory[PC + 1 + offset] = SR
```

## LDI

```asm
LDI DR, pointer_label
```

```text
pointer_address = PC + 1 + offset
final_address   = memory[pointer_address]
DR              = memory[final_address]
```

Example:

```text
PC=10, offset=4
memory[15]=200
memory[200]=77
DR becomes 77
```

## STI

```asm
STI SR, pointer_label
```

```text
pointer_address       = PC + 1 + offset
final_address         = memory[pointer_address]
memory[final_address] = SR
```

---

# 6. Base-Relative Memory Family — `1001`

Format:

```text
1001 rrr D bbb ooooo
```

| `D` | Instruction |
|---|---|
| `0` | `LDR` |
| `1` | `STR` |

`offset5` is signed, with a range of `-16` through `+15`.

## LDR

```asm
LDR DR, BaseR, offset5
```

or:

```asm
LDR DR, offset5(BaseR)
```

```text
DR = memory[BaseR + sign_extend(offset5)]
```

Example: if `R2=100`, offset is `6`, and `memory[106]=25`, then `LDR R1,R2,6` makes `R1=25`.

## STR

```asm
STR SR, BaseR, offset5
```

```text
memory[BaseR + sign_extend(offset5)] = SR
```

---

# 7. Immediate/Address Family — `1010`

Format:

```text
1010 ddd M vvvvvvvv
```

| `M` | Instruction |
|---|---|
| `0` | `LI` |
| `1` | `LEA` |

## LI

```asm
LI DR, imm8
```

```text
DR = sign_extend(imm8)
```

Range: `-128` through `+127`.

Example:

```asm
LI R1, -5
```

```text
imm8 = 1111 1011
R1   = 1111 1111 1111 1011
```

## LEA

```asm
LEA DR, label
```

```text
DR = PC + 1 + sign_extend(PCOffset8)
```

`LEA` loads the address of the label, not the value stored there.

---

# 8. Jump Family — `1011`

| Mode | Instruction | Target | Saves `PC+1` in `R7`? |
|---|---|---|---|
| `00` | `JAL` | PC-relative | Yes |
| `01` | `JMP` | Base register + offset | No |
| `10` | `JALR` | Base register + offset | Yes |
| `11` | Reserved | — | — |

## JAL

Format:

```text
1011 00 PCOffset10
```

```asm
JAL label
```

```text
R7 = PC + 1
PC = PC + 1 + sign_extend(PCOffset10)
```

Range: `-512` through `+511` instructions.

## JMP

Format:

```text
1011 01 BaseR offset7
```

```asm
JMP BaseR, offset7
```

```text
PC = BaseR + sign_extend(offset7)
```

## JALR

Format:

```text
1011 10 BaseR offset7
```

```asm
JALR BaseR, offset7
```

```text
target = BaseR + sign_extend(offset7)
R7     = PC + 1
PC     = target
```

The target must be calculated before `R7` is written.

---

# 9. Reserved Opcode — `1100`

Opcode `1100` is intentionally unused in v1. Unsupported encodings should safely halt or enter an illegal-instruction state.

Potential future uses include high-half multiplication, byte operations, debugging, interrupts, or custom hardware extensions.

---

# 10. Compare Family — `1101`

`CMP` and `CMPI` write no general-purpose register. They update exactly one of three flags:

```text
L = first operand is less than second operand
E = operands are equal
G = first operand is greater than second operand
```

## CMP

Format:

```text
1101 sss 000 0 00 rrr
```

```asm
CMP SR1, SR2
```

Signed comparison behavior:

```text
SR1 < SR2 → L=1,E=0,G=0
SR1 = SR2 → L=0,E=1,G=0
SR1 > SR2 → L=0,E=0,G=1
```

## CMPI

Format:

```text
1101 sss 000 1 iiiii
```

```asm
CMPI SR, imm5
```

Compares signed `SR` against `sign_extend(imm5)`.

Example:

```asm
CMPI R1, 0
```

If `R1=-3`, the flags become `L=1,E=0,G=0`.

Only `CMP` and `CMPI` update `L/E/G` in v1.

---

# 11. Branch Family — `1110`

Format:

```text
1110 LEG PCOffset9
```

| `LEG` | Mnemonic | Condition |
|---|---|---|
| `000` | Reserved | Never branch |
| `001` | `BGT` | Greater than |
| `010` | `BEQ` | Equal |
| `011` | `BGE` | Greater than or equal |
| `100` | `BLT` | Less than |
| `101` | `BNE` | Not equal |
| `110` | `BLE` | Less than or equal |
| `111` | `BR` | Unconditional |

`PCOffset9` is signed, with a range of `-256` through `+255` instructions.

When taken:

```text
PC = PC + 1 + sign_extend(PCOffset9)
```

Examples:

```asm
CMP R1, R2
BEQ SAME
```

```asm
CMPI R3, 0
BLE NON_POSITIVE
```

```asm
BR LOOP
```

---

# 12. System Family — `1111`

## NOP

Encoding:

```text
1111 00 0000000000
```

```asm
NOP
```

Advances the PC without changing registers, memory, or comparison flags.

## HALT

Encoding:

```text
1111 11 0000000000
```

```asm
HALT
```

Stops PC advancement, register writes, and memory writes until reset.

Modes `01` and `10` are reserved.

---

# 13. Assembler Directives

Assembler directives affect memory layout and are not executed by the CPU.

## `.ORIG`

Sets the current assembly address.

```asm
.ORIG x3000
```

or:

```asm
.ORIG 100
```

## `.WORD`

Places one 16-bit value into memory.

```asm
COUNT:
.WORD 25
```

## `.SPACE`

Reserves words in memory.

```asm
STACK:
.SPACE 10
```

## `.END`

Marks the end of the source file.

```asm
.END
```

---

# 14. Pseudo-Instructions

These are expanded by the Python assembler and require no additional hardware.

| Pseudo-instruction | Expansion |
|---|---|
| `CLR Rd` | `ANDI Rd, Rd, 0` |
| `INC Rd` | `ADDI Rd, Rd, 1` |
| `DEC Rd` | `SUBI Rd, Rd, 1` |
| `NEG Rd` | `NOT Rd, Rd` then `ADDI Rd, Rd, 1` |
| `RET` | `JMP R7, 0` |
| `CMPZ Rs` | `CMPI Rs, 0` |

---

# 15. Example Program

```asm
.ORIG 100

LI   R1, 10
LI   R2, 0

LOOP:
DEC  R1
CMPI R1, 0
BGT  LOOP

ST   R1, RESULT
HALT

RESULT:
.WORD 99

.END
```

The program counts `R1` down from 10 to 0, stores the final value in `RESULT`, and halts.

---

# 16. Planned Multi-Cycle Execution

```text
ALU:   FETCH → DECODE → EXECUTE → WRITEBACK
LD:    FETCH → DECODE → ADDRESS → MEMORY_READ → WRITEBACK
ST:    FETCH → DECODE → ADDRESS → MEMORY_WRITE
LDI:   FETCH → DECODE → POINTER_READ → DATA_READ → WRITEBACK
STI:   FETCH → DECODE → POINTER_READ → DATA_WRITE
CMP:   FETCH → DECODE → COMPARE
BRANCH:FETCH → DECODE → TEST_FLAGS → UPDATE_PC
```

---

# 17. Remaining Implementation Decisions

The instruction encodings are treated as v1.0. These hardware details still need final definitions:

1. Exact arithmetic status flags (`N`, `Z`, `C`, `V`) and software visibility.
2. Overflow behavior for `ADD`, `SUB`, `MUL`, and immediate variants.
3. Illegal-instruction behavior for reserved encodings.
4. Unified-memory initialization format (`.mem`, `.hex`, or generated SystemVerilog).
5. Exact accepted assembler syntax for decimal, hexadecimal, and binary literals.
