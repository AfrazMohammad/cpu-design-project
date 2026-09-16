# Custom 16-Bit CPU & Two-Pass Assembler

A custom 16-bit processor designed in SystemVerilog with its own instruction set architecture (ISA) and a Python-based two-pass assembler.

The project was developed from the ground up, beginning with fundamental digital logic and a small 4-bit CPU before progressing into a complete 16-bit processor capable of executing custom assembly programs.

---

# How to Run the CPU

A standalone version of the completed CPU and assembler is provided in:

```text
runnable-cpu-simulator/
```

Download this folder, open it in VS Code, write a program in `program.asm`, and follow the steps below to assemble and execute it.

## Requirements

Install:

- Python 3
- Icarus Verilog
- VS Code or another code editor with a terminal

## 1. Download the Simulator

Download the `runnable-cpu-simulator` folder from this repository.

It contains:

```text
runnable-cpu-simulator/
├── assembler.py
├── design.sv
├── testbench.sv
├── program.asm
└── program.svh
```

| File | Purpose |
|---|---|
| `program.asm` | Assembly program executed by the CPU |
| `assembler.py` | Custom two-pass assembler |
| `program.svh` | Generated machine-code memory image |
| `design.sv` | Complete 16-bit CPU hardware |
| `testbench.sv` | CPU simulation and output |

## 2. Open the Folder in VS Code

Open `runnable-cpu-simulator` as a folder in VS Code.

All commands below should be executed from this directory.

## 3. Write an Assembly Program

Open:

```text
program.asm
```

Write a program using the custom assembly language.

For example:

```assembly
.ORIG x0000

       LI   R0, #0
       LI   R1, #10

LOOP   ADDI R0, R0, #1
       CMP  R0, R1
       BLT  LOOP

       HALT

.END
```

Save `program.asm` before continuing.

## 4. Run the Assembler

Run:

```bash
python assembler.py
```

The assembler:

- Parses the assembly program
- Validates instructions and operands
- Builds the symbol table
- Resolves labels
- Calculates PC-relative offsets
- Encodes instructions into 16-bit machine code
- Generates `program.svh`

If an error is found, the assembler reports the problem and its source line instead of silently generating incorrect machine code.

## 5. Compile the CPU

Open the VS Code terminal and run:

```bash
iverilog -g2012 -o cpu design.sv testbench.sv
```

This compiles the CPU design and testbench into a simulation executable named `cpu`.

## 6. Run the CPU

Run:

```bash
vvp cpu
```

The assembled program will execute on the simulated processor.

The testbench displays the final CPU state, including register values, memory changes, instruction count, and cycle count.

---

# Overview

This project contains two major components.

## 16-Bit CPU

A custom processor implemented in SystemVerilog featuring:

- 16-bit datapath
- 8 general-purpose registers (`R0`–`R7`)
- Fixed-width 16-bit instructions
- Custom instruction set architecture
- Register and immediate arithmetic
- Bitwise logical operations
- Shift and rotate operations
- Multiple memory addressing modes
- Comparison and condition flags
- Conditional branches
- Jumps and subroutine calls
- Custom datapath and control unit

## Two-Pass Python Assembler

A custom assembler that converts programs written in the CPU's assembly language into executable 16-bit machine code.

The complete execution path is:

```text
Assembly Program
       ↓
Two-Pass Assembler
       ↓
16-Bit Machine Code
       ↓
Instruction Decoder
       ↓
Control Unit
       ↓
Datapath
       ↓
Hardware Execution
```

---

# Processor Architecture

## Registers

The CPU contains eight 16-bit general-purpose registers.

| Register | Encoding |
|---|---|
| `R0` | `000` |
| `R1` | `001` |
| `R2` | `010` |
| `R3` | `011` |
| `R4` | `100` |
| `R5` | `101` |
| `R6` | `110` |
| `R7` | `111` |

`R7` is also used as the **link register** by subroutine instructions. `JAL` and `JALR` save the return address in `R7`.

---

# Instruction Set Architecture

Every machine instruction is exactly **16 bits** wide.

Depending on the instruction, the 16-bit word contains fields representing:

- Opcode
- Destination register
- Source register(s)
- Immediate value
- Shift amount
- Base register
- Addressing mode
- PC-relative offset
- Branch condition

---

## Instruction Encodings

<!-- Add the ISA encoding images to the repository and update these paths if necessary -->

### Arithmetic, Logical, Shift, and Direct Memory Instructions

![ISA Encoding Page 1](<img width="304" height="371" alt="isa-encoding-1 png" src="https://github.com/user-attachments/assets/355e0a30-7681-44fa-b71a-d9b9c6848297" />)

### Memory, Control Flow, Comparison, and System Instructions

![ISA Encoding Page 2](<img width="305" height="374" alt="isa-encoding-2 png" src="https://github.com/user-attachments/assets/2eee65aa-fa41-4415-b81e-e381fb750356" />)

---

# Arithmetic Instructions

## `ADD` / `ADDI`

Adds two values and stores the result in the destination register.

### Register Form

```assembly
; Before:
; R1 = x0005
; R2 = x0003

ADD R0, R1, R2

; After:
; R0 = x0008
```

```text
R0 ← R1 + R2
```

### Immediate Form

```assembly
; Before:
; R1 = x0005

ADDI R0, R1, #3

; After:
; R0 = x0008
```

```text
R0 ← R1 + 3
```

---

## `SUB` / `SUBI`

Subtracts the second operand from the first.

### Register Form

```assembly
; Before:
; R1 = x000A
; R2 = x0003

SUB R0, R1, R2

; After:
; R0 = x0007
```

```text
R0 ← R1 - R2
```

### Immediate Form

```assembly
; Before:
; R1 = x000A

SUBI R0, R1, #3

; After:
; R0 = x0007
```

```text
R0 ← R1 - 3
```

---

## `MUL` / `MULI`

Multiplies two values and stores the result in the destination register.

### Register Form

```assembly
; Before:
; R1 = x0005
; R2 = x0003

MUL R0, R1, R2

; After:
; R0 = x000F
```

```text
R0 ← R1 × R2
```

### Immediate Form

```assembly
; Before:
; R1 = x0005

MULI R0, R1, #3

; After:
; R0 = x000F
```

```text
R0 ← R1 × 3
```

---

# Logical Instructions

## `AND` / `ANDI`

Performs a bitwise AND operation.

```assembly
; Before:
; R1 = b1100
; R2 = b1010

AND R0, R1, R2

; After:
; R0 = b1000
```

Immediate form:

```assembly
; Before:
; R1 = b1100

ANDI R0, R1, b1010

; After:
; R0 = b1000
```

---

## `OR` / `ORI`

Performs a bitwise OR operation.

```assembly
; Before:
; R1 = b1100
; R2 = b1010

OR R0, R1, R2

; After:
; R0 = b1110
```

Immediate form:

```assembly
; Before:
; R1 = b1100

ORI R0, R1, b1010

; After:
; R0 = b1110
```

---

## `XOR` / `XORI`

Performs a bitwise exclusive OR operation.

```assembly
; Before:
; R1 = b1100
; R2 = b1010

XOR R0, R1, R2

; After:
; R0 = b0110
```

Immediate form:

```assembly
; Before:
; R1 = b1100

XORI R0, R1, b1010

; After:
; R0 = b0110
```

---

## `NOT`

Inverts every bit of the source register.

```assembly
; Before:
; R1 = x000F

NOT R0, R1

; After:
; R0 = xFFF0
```

```text
R0 ← NOT R1
```

---

# Shift and Rotate Instructions

Shift amounts use a 4-bit unsigned field, allowing shift amounts from `0` through `15`.

## `SHL`

Performs a logical left shift.

```assembly
; Before:
; R1 = x0005

SHL R0, R1, #2

; After:
; R0 = x0014
```

---

## `SHR`

Performs a logical right shift. Zeros are shifted into the most-significant bits.

```assembly
; Before:
; R1 = xFFF8

SHR R0, R1, #2

; After:
; R0 = x3FFE
```

---

## `SHA`

Performs an arithmetic right shift. The sign bit is preserved.

```assembly
; Before:
; R1 = xFFF8

SHA R0, R1, #2

; After:
; R0 = xFFFE
```

Difference between `SHR` and `SHA`:

```text
Original: 1111 1111 1111 1000

SHR #2:  0011 1111 1111 1110
SHA #2:  1111 1111 1111 1110
```

---

## `ROR`

Rotates bits to the right rather than discarding them.

```assembly
; Before:
; R1 = x0005

ROR R0, R1, #2

; After:
; R0 = x4001
```

---

# Memory Instructions

The CPU supports PC-relative, indirect, base-register, and immediate addressing modes.

---

## `LI`

Loads an 8-bit immediate value into a register.

```assembly
; Before:
; R0 = x0000

LI R0, #10

; After:
; R0 = x000A
```

```text
R0 ← 10
```

---

## `LD`

Loads a value from a PC-relative memory location.

```assembly
; DATA is located at x3010
; MEM[x3010] = x1234
; R0 = x0000

LD R0, DATA

; After:
; R0 = x1234
```

Conceptually:

```text
R0 ← MEM[DATA]
```

The assembler automatically calculates the required signed PC-relative offset to `DATA`.

---

## `ST`

Stores a register value into a PC-relative memory location.

```assembly
; DATA is located at x3010
; R0 = x1234
; MEM[x3010] = x0000

ST R0, DATA

; After:
; MEM[x3010] = x1234
; R0 = x1234
```

Conceptually:

```text
MEM[DATA] ← R0
```

---

## `LDI`

Performs an indirect PC-relative load.

The PC-relative memory location contains another memory address. The CPU follows this address and loads the value stored there.

```assembly
; POINTER is located at x3010
;
; MEM[x3010] = x4000
; MEM[x4000] = x1234
; R0 = x0000

LDI R0, POINTER

; After:
; R0 = x1234
```

Conceptually:

```text
R0 ← MEM[MEM[POINTER]]
```

---

## `STI`

Performs an indirect PC-relative store.

The PC-relative location contains the address where the register value will be stored.

```assembly
; POINTER is located at x3010
;
; R0 = x1234
; MEM[x3010] = x4000
; MEM[x4000] = x0000

STI R0, POINTER

; After:
; MEM[x4000] = x1234
; R0 = x1234
```

Conceptually:

```text
MEM[MEM[POINTER]] ← R0
```

---

## `LDR`

Loads from memory using a base register and signed 5-bit offset.

```assembly
; Before:
; R1 = x3000
; MEM[x3004] = x1234
; R0 = x0000

LDR R0, R1, #4

; Effective Address:
; x3000 + 4 = x3004

; After:
; R0 = x1234
```

```text
R0 ← MEM[R1 + 4]
```

---

## `STR`

Stores into memory using a base register and signed 5-bit offset.

```assembly
; Before:
; R0 = x1234
; R1 = x3000
; MEM[x3004] = x0000

STR R0, R1, #4

; Effective Address:
; x3000 + 4 = x3004

; After:
; MEM[x3004] = x1234
```

```text
MEM[R1 + 4] ← R0
```

---

## `LEA`

Loads the PC-relative address of a label into a register.

Unlike `LD`, `LEA` loads the **address itself** rather than accessing the value stored at that address.

```assembly
; DATA is located at x3010
; MEM[x3010] = x1234

LEA R0, DATA

; After:
; R0 = x3010
```

Compare:

```text
LD  R0, DATA  → R0 = x1234
LEA R0, DATA  → R0 = x3010
```

---

# Comparison Instructions

Comparison instructions update the processor's condition flags without storing an arithmetic result in a destination register.

## `CMP`

Compares two registers.

```assembly
; Before:
; R0 = #5
; R1 = #10

CMP R0, R1

; After:
; R0 = #5
; R1 = #10
; Condition flags indicate R0 < R1
```

---

## `CMPI`

Compares a register against an 8-bit immediate value.

```assembly
; Before:
; R0 = #10

CMPI R0, #10

; After:
; R0 = #10
; Condition flags indicate equality
```

---

# Branch Instructions

Branch instructions use the processor's condition flags to determine whether execution should continue at a specified label.

The branch encoding contains condition bits and a signed 9-bit PC-relative offset. The assembler calculates the offset automatically.

## `BR`

Unconditionally branches to a label.

```assembly
BR LOOP

; Execution continues at LOOP
```

---

## `BEQ`

Branches when the comparison indicates equality.

```assembly
; R0 = #5
; R1 = #5

CMP R0, R1
BEQ EQUAL

; 5 == 5
; Branch is taken
; Execution continues at EQUAL
```

---

## `BNE`

Branches when the compared values are not equal.

```assembly
; R0 = #5
; R1 = #10

CMP R0, R1
BNE DIFFERENT

; 5 != 10
; Branch is taken
```

---

## `BLT`

Branches when the first compared value is less than the second.

```assembly
; R0 = #5
; R1 = #10

CMP R0, R1
BLT SMALLER

; 5 < 10
; Branch is taken
```

---

## `BLE`

Branches when the first compared value is less than or equal to the second.

```assembly
; R0 = #5
; R1 = #5

CMP R0, R1
BLE SMALLER_OR_EQUAL

; 5 <= 5
; Branch is taken
```

---

## `BGT`

Branches when the first compared value is greater than the second.

```assembly
; R0 = #10
; R1 = #5

CMP R0, R1
BGT GREATER

; 10 > 5
; Branch is taken
```

---

## `BGE`

Branches when the first compared value is greater than or equal to the second.

```assembly
; R0 = #10
; R1 = #10

CMP R0, R1
BGE GREATER_OR_EQUAL

; 10 >= 10
; Branch is taken
```

---

# Jump and Subroutine Instructions

The CPU uses **R7 as the link register**.

When `JAL` or `JALR` performs a subroutine call, the return address is saved in `R7`. This allows execution to return to the instruction following the call.

---

## `JMP`

Jumps to an address calculated from a base register and signed 7-bit offset.

Unlike `JAL` and `JALR`, `JMP` does **not** save a return address.

```assembly
; Before:
; R1 = x3000

JMP R1, #4

; Target:
; x3000 + 4 = x3004

; After:
; PC = x3004
; R7 is unchanged
```

Conceptually:

```text
PC ← R1 + 4
```

---

## `JAL`

Performs a PC-relative subroutine call using a signed 10-bit PC-relative offset.

Before jumping, the CPU stores the return address in `R7`.

```assembly
; Suppose this JAL is located at x3000
; The next instruction is at x3001
; FUNCTION is located at x3010

JAL FUNCTION

; After:
; R7 = x3001
; PC = x3010
```

Conceptually:

```text
R7 ← return address
PC ← FUNCTION
```

The assembler automatically calculates the PC-relative offset required to reach `FUNCTION`.

This allows a subroutine to later return using the saved address in `R7`.

---

## `JALR`

Performs a register-relative subroutine call using a base register and signed 7-bit offset.

Like `JAL`, the return address is saved in `R7`.

```assembly
; Suppose JALR is located at x3000
;
; Before:
; R1 = x4000
; Next instruction = x3001

JALR R1, #4

; Target:
; x4000 + 4 = x4004

; After:
; R7 = x3001
; PC = x4004
```

Conceptually:

```text
R7 ← return address
PC ← R1 + 4
```

---

## Returning From a Subroutine

Because `JAL` and `JALR` save the return address in `R7`, a register-based jump can be used to return to the caller.

Example:

```assembly
       JAL FUNCTION
       HALT

FUNCTION
       ADDI R0, R0, #1

       ; Return using the address saved in R7
       JMP R7, #0
```

Execution flow:

```text
JAL FUNCTION
     ↓
R7 receives return address
     ↓
FUNCTION executes
     ↓
JMP R7, #0
     ↓
Execution resumes after JAL
```

---

# System Instructions

## `NOP`

Performs no operation.

```assembly
; Before:
; R0 = x1234

NOP

; After:
; R0 = x1234
; Execution continues normally
```

---

## `HALT`

Stops processor execution.

```assembly
HALT

; CPU execution stops
```

---

# Two-Pass Assembler

The custom Python assembler translates assembly source code into the 16-bit machine instructions executed by the processor.

---

## Pass 1

The first pass:

- Processes comments
- Parses labels
- Validates instructions
- Validates assembler directives
- Tracks the program counter
- Builds the symbol table
- Detects duplicate labels

For example:

```assembly
LOOP ADDI R0, R0, #1
```

may generate:

```text
LOOP → x3004
```

---

## Pass 2

The second pass:

- Encodes instructions into binary
- Resolves labels
- Calculates PC-relative offsets
- Encodes signed and unsigned immediate values
- Processes memory directives
- Generates the final program image

This allows forward label references:

```assembly
BR DONE

ADDI R0, R0, #1

DONE HALT
```

The assembler can resolve `DONE` even though the label is defined later in the source program.

---

# Assembler Directives

## `.ORIG`

Sets the starting memory address of the program.

```assembly
.ORIG x3000
```

---

## `.FILL`

Places a 16-bit value directly into memory.

```assembly
DATA .FILL x1234
```

---

## `.WORD`

Alternative syntax for placing a 16-bit value directly into memory.

```assembly
DATA .WORD x1234
```

---

## `.BLKW`

Reserves a block of memory words.

```assembly
BUFFER .BLKW #16
```

---

## `.SPACE`

Alternative syntax for reserving memory.

```assembly
BUFFER .SPACE #16
```

---

## `.END`

Marks the end of the assembly program.

```assembly
.END
```

---

# Numeric Literals

The assembler supports decimal, hexadecimal, and binary literals.

| Format | Example |
|---|---|
| Decimal | `#10` |
| Hexadecimal | `x000A` |
| Hexadecimal | `0x000A` |
| Binary | `b1010` |
| Binary | `0b1010` |

Signed values are supported for instruction fields that accept signed immediate values.

---

# Labels

Labels can be written with or without a colon.

```assembly
LOOP:
    ADDI R0, R0, #1
```

or:

```assembly
LOOP ADDI R0, R0, #1
```

For PC-relative instructions, the programmer supplies a label instead of manually calculating an offset.

For example:

```assembly
BLT LOOP
```

The assembler determines the address of `LOOP`, calculates the required PC-relative offset, validates that it fits in the instruction field, and encodes it into the final machine instruction.

---

# Comments

The assembler supports several comment styles.

## Semicolon Comments

```assembly
ADD R0, R1, R2      ; comment
```

## C-Style Line Comments

```assembly
ADD R0, R1, R2      // comment
```

## Block Comments

```assembly
/*
This is a
multiline comment.
*/
```

## Inline Block Comments

```assembly
ADD R0, /* source register */ R1, R2
```

---

# Error Detection

The assembler performs validation before generating machine code.

Detected errors include:

- Unknown instructions
- Invalid operand formats
- Invalid register names
- Invalid label syntax
- Duplicate labels
- Undefined labels
- Unknown assembler directives
- Signed immediate overflow
- Unsigned immediate overflow
- Invalid directive operands
- Missing `.ORIG`
- Missing `.END`
- Program counter/address-space overflow
- Unterminated block comments

Example:

```text
Error on line 12:
    ADD R0, R1, #100

Immediate out of signed 5 bit range
    Allowed Range: -16 to +15
```

---

# Example Assembly Program

```assembly
.ORIG x0000

       LI   R0, #0
       LI   R1, #10

LOOP   ADDI R0, R0, #1
       CMP  R0, R1
       BLT  LOOP

       HALT

.END
```

The assembler resolves `LOOP`, calculates the required PC-relative branch offset, and converts each instruction into a 16-bit machine instruction.

---

# Example Subroutine

`JAL` can be used to call a subroutine while automatically saving the return address in `R7`.

```assembly
.ORIG x0000

       LI   R0, #5
       JAL  INCREMENT
       HALT

INCREMENT
       ADDI R0, R0, #1
       JMP  R7, #0

.END
```

Execution:

```text
R0 = 5

JAL INCREMENT
    R7 ← return address
    PC ← INCREMENT

ADDI R0, R0, #1
    R0 = 6

JMP R7, #0
    PC ← saved return address

HALT
```

Final value:

```text
R0 = 6
```

---

# Example Simulation Output

After assembling and compiling the program, run:

```bash
vvp cpu
```

The testbench displays the final CPU state.

```text
################################
#        FINAL CPU STATE       #
################################

Instructions executed = 9
Cycles executed       = 58
Total memory writes   = 3

PC    = 0009
IR    = fc00
MAR   = 0008
MDR   = fc00
Flags = 000

Registers
--------------------------------
R0:000a  R1:000f  R2:000f  R3:000a
R4:fc00  R5:0000  R6:0000  R7:0000

Memory Updated
--------------------------------
MEM[000a] = 000f
MEM[000f] = 000a
MEM[0014] = fc00

################################
# TEST COMPLETED SUCCESSFULLY  #
################################
```

---

# Hardware Implementation

<!-- Add CPU datapath / architecture image here -->

![CPU Architecture](images/cpu-architecture.png)

The processor is implemented in SystemVerilog and contains the datapath and control hardware required to fetch, decode, and execute the custom instruction set.

Major components include:

- ALU
- Register file
- Program counter
- Instruction register
- Memory address register
- Memory data register
- Memory interface
- Instruction decoder
- Control unit
- Condition flags
- Datapath multiplexers

---

# Project Development

The processor was developed incrementally from fundamental digital logic to a complete 16-bit architecture.

## Stage 1 — Digital Logic and 4-Bit CPU

The first stage focused on constructing the fundamental components used by a processor:

- Logic gates
- Multiplexers
- Decoders
- Half adder
- Full adder
- Ripple-carry adder
- D flip-flops
- Registers
- Register file
- ALU
- Initial 4-bit processor

## Stage 2 — 16-Bit CPU

The second stage expanded the design into the complete processor:

- 16-bit datapath
- 8 general-purpose registers
- Custom ISA
- Custom instruction encodings
- Instruction decoder
- Control unit
- Memory addressing
- Condition flags
- Branch logic
- Jump and subroutine support
- Complete processor integration
- Two-pass Python assembler

---

# Repository Structure

```text
cpu-design-project/
│
├── stage1-fourBitCPU/
│   ├── week1-digital-logic/
│   ├── week2-sequential-logic/
│   └── week3-alu-control/
│
├── stage2-sixteenBitCPU/
│   └── ...
│
├── runnable-cpu-simulator/
│   ├── assembler.py
│   ├── design.sv
│   ├── testbench.sv
│   ├── program.asm
│   └── program.svh
│
├── images/
│   ├── isa-encoding-1.png
│   ├── isa-encoding-2.png
│   └── cpu-architecture.png
│
└── README.md
```

The `runnable-cpu-simulator` folder provides a standalone version of the completed processor and assembler so that programs can be written, assembled, and executed without navigating through the development files.

---

# Current Progress

## CPU

- [x] Fundamental digital logic
- [x] Registers and register file
- [x] ALU
- [x] Custom ISA
- [x] Instruction decoder
- [x] Datapath
- [x] Control unit
- [x] Memory operations
- [x] Comparison and condition flags
- [x] Conditional branches
- [x] Jump and subroutine support
- [x] Complete 16-bit processor
- [ ] FPGA implementation

## Assembler

- [x] Source parsing
- [x] Comment handling
- [x] Label parsing
- [x] Instruction validation
- [x] Operand format detection
- [x] Immediate validation
- [x] Immediate encoding
- [x] Symbol table generation
- [x] First pass
- [x] Second pass
- [x] Forward label resolution
- [x] PC-relative offset generation
- [x] Machine-code generation
- [x] Verilog memory-image generation

---

# Motivation

This project was created to develop a deeper understanding of computer architecture by building both the hardware and software layers of a processor from the ground up.

Rather than implementing an existing ISA, the processor uses a custom instruction set designed alongside its datapath and control logic. Building the assembler required defining how human-readable assembly syntax maps to instruction formats, registers, immediate fields, labels, addressing modes, and ultimately the individual bits of each 16-bit machine instruction.

The project connects multiple levels of computer engineering:

```text
Assembly Source
      ↓
Assembler
      ↓
16-Bit Machine Code
      ↓
Instruction Decoder
      ↓
Control Signals
      ↓
Datapath
      ↓
Hardware Execution
```

This makes it possible to follow an instruction from an assembly program all the way down to the digital hardware responsible for executing it.

---

# Technologies

- **SystemVerilog / Verilog** — processor hardware design
- **Python** — custom two-pass assembler
- **Icarus Verilog** — CPU compilation and simulation
- **VS Code** — development environment
- **Git / GitHub** — version control and documentation
- **Digital Logic Design**
- **Computer Architecture**
- **Assembly Language**
- **Instruction Set Architecture Design**
