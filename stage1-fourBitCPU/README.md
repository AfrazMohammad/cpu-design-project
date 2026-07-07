# 4-Bit CPU in SystemVerilog

A custom 4-bit CPU designed from the ground up in **SystemVerilog**, featuring a complete fetch-decode-execute datapath, register file, ALU, program counter, assembler, and automated instruction memory generation.

This project was built as a personal exploration of computer architecture after learning digital logic and sequential circuits.

---

## Features

- 4-bit ALU
  - ADD
  - SUB
  - AND
  - OR
- 4 general-purpose 4-bit registers (R0–R3)
- 4-bit Program Counter
- Instruction Decoder
- Hardwired Control Logic
- Fetch → Decode → Execute architecture
- HALT instruction
- Python assembler
- Human-readable assembly language
- Automatic generation of Verilog instruction memory
- Automatic register initialization

---

## Instruction Format

Each instruction is 8 bits wide.

| Bits | Purpose |
|------|---------|
| 7:6 | Opcode |
| 5:4 | Destination Register |
| 3:2 | Source Register 1 |
| 1:0 | Source Register 2 |

### Opcodes

| Opcode | Instruction |
|--------|-------------|
| 00 | ADD |
| 01 | SUB |
| 10 | AND |
| 11 | OR |

---

## Assembly Language

Programs are written in a custom assembly language.

Example:

```asm
INIT R0, 5
INIT R1, 2
INIT R2, 6
INIT R3, 1

ADD R0, R1, R2
SUB R3, R0, R2
AND R1, R0, R3
OR R2, R1, R3
HALT
```

The Python assembler automatically converts this into:

- machine code
- Verilog instruction memory
- register preload code

No manual binary encoding is required.

---

## Project Structure

```
design.sv
testbench.sv
assembler.py

program.asm
program.svh
preloadRegisters.svh
```

---

## Running

Generate instruction memory and register preload:

```bash
python assembler.py
```

Compile:

```bash
iverilog -g2012 -o cpu design.sv testbench.sv
```

Run:

```bash
vvp cpu
```

(Optional)

```bash
gtkwave dump.vcd
```

---

## Future Improvements

- 16-bit datapath
- Expanded instruction set
- Immediate instructions
- Data memory
- Branch instructions
- Labels in the assembler
- RISC-inspired ISA
- 16-bit educational CPU

---

## Motivation

This project was created to understand how processors work beyond individual digital logic components.

Instead of using an existing ISA, I designed a complete instruction format, built the processor in SystemVerilog, and wrote a Python assembler that translates custom assembly into machine code and Verilog include files.

The long-term goal is to evolve this project into a 16-bit RISC-inspired processor with a richer instruction set, memory support, and a more capable assembler.
