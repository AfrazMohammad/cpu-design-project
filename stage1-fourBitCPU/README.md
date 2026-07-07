# 4-Bit CPU in SystemVerilog

A custom 4-bit CPU designed from the ground up in **SystemVerilog**, featuring a complete fetch-decode-execute datapath, register file, ALU, program counter, assembler, and automated instruction memory generation.

This project was built as a personal exploration of computer architecture after learning digital logic and sequential circuits.

---

# CPU Architecture

<img width="646" height="657" alt="image" src="https://github.com/user-attachments/assets/1c1bb489-f14a-46f8-bbef-6c3831e0ad5f" />


*Overall datapath of the 4-bit CPU.*

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
- Fetch → Decode → Execute datapath
- Python assembler
- Human-readable assembly language
- Automatic Verilog instruction memory generation
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

## HALT Instruction

The HALT instruction is encoded as

```verilog
8'b11111111
```

This value was chosen because it is otherwise a useless instruction. It corresponds to

```text
OR R3, R3, R3
```

which simply computes `R3 OR R3` and writes the result back to `R3`, leaving the register unchanged. Instead of performing this redundant operation, the CPU interprets `8'b11111111` as a HALT instruction and stops execution.

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

The Python assembler automatically converts this program into:

- Verilog instruction memory (`program.svh`)
- Register preload code (`preloadRegisters.svh`)

No manual binary encoding is required.

---

## Project Structure

```text
design.sv
testbench.sv
assembler.py

program.asm
program.svh
preloadRegisters.svh
```

---

## Running

Generate the instruction memory and register preload files:

```bash
python assembler.py
```

Compile the CPU:

```bash
iverilog -g2012 -o cpu design.sv testbench.sv
```

Run the simulation:

```bash
vvp cpu
```

(Optional)

View the waveform:

```bash
gtkwave dump.vcd
```

---

## Future Improvements

- 16-bit RISC-inspired CPU
- Expanded instruction set
- Immediate instructions
- Data memory
- Branch instructions
- Labels in the assembler
- More capable Python assembler

---

## Motivation

This project was created to understand how processors work beyond individual digital logic components.

Instead of implementing an existing ISA, I designed my own instruction format, built the processor entirely in SystemVerilog, and wrote a Python assembler that translates human-readable assembly into machine code and automatically generates the Verilog include files used during simulation.

The long-term goal is to evolve this project into a **16-bit RISC-inspired processor** featuring memory, branching, a richer instruction set, and a more sophisticated assembler.
