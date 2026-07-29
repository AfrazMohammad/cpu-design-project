# Custom 16-Bit CPU & Two-Pass Assembler

A custom 16-bit processor architecture implemented in Verilog with a Python-based two-pass assembler. This project explores computer architecture from the ground up by designing an instruction set, implementing hardware modules, and building the software toolchain required to translate assembly language into machine code.

> **Status:** 🚧 Work in Progress

---

## Overview

This project consists of two major components:

- **16-bit CPU (Verilog)** – A custom processor implementing a custom instruction set architecture.
- **Python Assembler** – A two-pass assembler that converts assembly programs into 16-bit machine code and Verilog-compatible memory initialization.

The goal of this project is to understand how high-level assembly instructions are translated into binary and executed by hardware.

---

## Features

### CPU

- Custom 16-bit instruction set architecture
- 8 general-purpose registers (`R0`–`R7`)
- Register-register and register-immediate arithmetic
- Logical operations
- Shift and rotate instructions
- Memory load/store instructions
- Comparison instructions
- Branches and jumps
- Function call support
- Hardware written entirely in Verilog

### Assembler

- Two-pass assembly process
- Symbol table generation
- Forward label resolution
- Program counter management
- Automatic instruction format detection
- Decimal, hexadecimal, and binary literals
- Signed and unsigned immediate validation
- Verilog memory initialization output
- Helpful compiler-style error messages with line numbers

---

## Supported Instructions

### Arithmetic

```
ADD   ADDI
SUB   SUBI
MUL   MULI
```

### Logical

```
AND   ANDI
OR    ORI
XOR   XORI
NOT
```

### Comparison

```
CMP
CMPI
```

### Shift / Rotate

```
SHL
SHR
SHA
ROR
```

### Memory

```
LDR
STR
LI
```

### Control Flow

```
BR
BEQ
BNE
BLT
BLE
BGT
BGE

JMP
JAL
JALR
```

### System

```
NOP
HALT
```

---

## Assembler Directives

```
.ORIG
.FILL
.WORD
.BLKW
.SPACE
.END
```

---

## Example Assembly Program

```assembly
.ORIG x3000

START  LI   R0, #5
       LI   R1, #10

LOOP   ADD  R0, R0, #1
       CMP  R0, R1
       BLT  LOOP

       HALT

.END
```

---

## Example Output

```
PC: x3000    Instruction: xA005
PC: x3001    Instruction: xA10A
PC: x3002    Instruction: x00A1
PC: x3003    Instruction: x9...
...
```

---

## Assembler Features

The assembler performs extensive validation before machine code generation.

### Syntax Checking

- Unknown instructions
- Invalid operand formats
- Invalid register names
- Invalid labels
- Duplicate labels
- Unknown assembler directives

### Immediate Validation

- Signed immediate range checking
- Unsigned immediate range checking
- Decimal
- Hexadecimal
- Binary

### Source Processing

- Case insensitive
- Labels with or without `:`
- Single-line comments

```
;
//
```

- Block comments

```
/*
...
*/
```

- Inline block comments

```
ADD R0, /* comment */ R1, R2
```

### Assembly Directives

- Validates `.ORIG`
- Requires `.END`
- Builds symbol table
- Tracks program counter
- Detects address-space overflow

---

## Repository Structure

```
.
├── assembler/
│   ├── assembler.py
│   ├── instruction_formats.py
│   ├── encoder.py
│   └── parser.py
│
├── cpu/
│   ├── alu.v
│   ├── register_file.v
│   ├── control_unit.v
│   ├── cpu.v
│   └── ...
│
├── examples/
│   ├── hello.asm
│   ├── loops.asm
│   └── fibonacci.asm
│
└── README.md
```

---

## Current Progress

### CPU

- [x] Digital logic components
- [x] Registers
- [x] ALU
- [ ] Instruction decoder
- [ ] Datapath
- [ ] Control unit
- [ ] Complete processor
- [ ] FPGA implementation

### Assembler

- [x] File parsing
- [x] Comment handling
- [x] Label parsing
- [x] Instruction validation
- [x] Immediate encoding
- [x] Machine code generation
- [x] Symbol table generation
- [x] Pass 1
- [ ] Pass 2
- [ ] Label resolution
- [ ] Binary output file
- [ ] Verilog memory image generation

---

## Motivation

This project was created to gain a deeper understanding of computer architecture by building an entire software and hardware stack from scratch. Rather than using an existing ISA such as RISC-V or MIPS, the processor, instruction set, assembler, and hardware are all custom designed.

The objective is to understand every stage of execution—from writing assembly code, to generating machine code, to implementing the digital logic that executes each instruction.

---

## Technologies

- Python
- Verilog
- VS Code
- Git
- Digital Logic Design
- Computer Architecture
