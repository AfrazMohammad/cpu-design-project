# 16-Bit CPU Documentation (Draft)

> **A custom 16-bit CPU designed in SystemVerilog with a Python
> assembler**

------------------------------------------------------------------------

# Table of Contents

1.  Introduction
2.  CPU Architecture Overview
3.  Assembly Language Basics
4.  Arithmetic Instructions
5.  Shift Instructions
6.  Memory Instructions
7.  Control Flow
8.  System Instructions
9.  Machine Code Reference
10. CPU Implementation
11. Future Improvements
12. Appendix A -- Opcode Table
13. Appendix B -- Assembler Directives
14. Appendix C -- Pseudo Instructions

------------------------------------------------------------------------

# 1. Introduction

Welcome! This document describes the architecture of my custom 16-bit
CPU.

Unlike a traditional ISA reference manual, this document is written as a
**mini textbook**. It explains not only *what* each instruction does,
but also *why* it exists and how it fits into the processor.

This CPU began as a 4-bit educational processor and evolved into a much
more capable 16-bit architecture inspired by ideas from LC-3, RISC-V,
and original design decisions.

## Design Goals

-   Easy to learn
-   Consistent instruction formats
-   Small but practical ISA
-   Unified instruction/data memory
-   Multi-cycle implementation in SystemVerilog
-   Custom Python assembler
-   Designed for future expansion

------------------------------------------------------------------------

# 2. CPU Architecture Overview

This chapter introduces the hardware before discussing any instructions.

## Register File

The processor contains eight 16-bit general-purpose registers.

  Register   Purpose
  ---------- ----------------------------------
  R0--R6     General-purpose
  R7         Link register (used by JAL/JALR)

All registers are writable.

------------------------------------------------------------------------

## Program Counter (PC)

The Program Counter stores the address of the next instruction to
execute.

Normally:

    PC = PC + 1

Branches and jumps modify the PC instead of allowing it to increment
normally.

------------------------------------------------------------------------

## Unified Memory

This CPU uses **one memory** for both instructions and data.

That means:

-   instructions are fetched from memory,
-   variables are also stored in memory,
-   the control unit performs multiple cycles when memory accesses are
    required.

------------------------------------------------------------------------

## Instruction Format

Every instruction is 16 bits wide.

Although different instruction families have different layouts, they all
begin with a 4-bit opcode.

Later chapters explain each format individually.

------------------------------------------------------------------------

# 3. Assembly Language Basics

Before learning the ISA, it's useful to understand how assembly programs
are written.

## Registers

    R0
    R1
    ...
    R7

## Labels

Labels provide names for memory addresses.

``` asm
LOOP:
    DEC R1
    BGT LOOP
```

## Comments

``` asm
; subtract one from R1
```

## Assembler Directives

-   `.ORIG`
-   `.WORD`
-   `.SPACE`
-   `.END`

These are processed by the assembler and are **not CPU instructions**.

## Pseudo Instructions

Examples include:

-   CLR
-   INC
-   DEC
-   NEG
-   RET
-   CMPZ

These are translated into one or more real instructions.

------------------------------------------------------------------------

# 4. Arithmetic Instructions

Introduce the arithmetic instruction family.

Each instruction section will follow the same format:

1.  Purpose
2.  Syntax
3.  Example
4.  Machine Encoding
5.  Notes

Example:

## ADD

### Purpose

Adds two values together.

### Syntax

``` asm
ADD  DR, SR1, SR2
ADDI DR, SR, imm5
```

### Example

``` asm
LI R1, 5
LI R2, 7
ADD R3, R1, R2
```

Result:

    R3 = 12

Only after understanding the instruction should the reader learn its
binary encoding.

Repeat this format for:

-   ADD
-   SUB
-   MUL
-   AND
-   OR
-   XOR
-   NOT

------------------------------------------------------------------------

# 5. Shift Instructions

Begin by explaining what shifting means before introducing:

-   SHL
-   SHR
-   SHA
-   ROR

Include diagrams showing how bits move.

------------------------------------------------------------------------

# 6. Memory Instructions

Explain the difference between:

-   LI
-   LEA
-   LD
-   LDI
-   LDR
-   ST
-   STI
-   STR

Use diagrams to illustrate:

-   PC-relative addressing
-   Base-relative addressing
-   Indirect addressing

This chapter should focus on understanding memory rather than binary
encodings.

------------------------------------------------------------------------

# 7. Control Flow

Explain why CPUs need to change execution order.

Topics:

-   CMP / CMPI
-   Branches
-   JAL
-   JMP
-   JALR

Use function-call and loop examples.

------------------------------------------------------------------------

# 8. System Instructions

Explain:

-   NOP
-   HALT

Reserve space for future system instructions.

------------------------------------------------------------------------

# 9. Machine Code Reference

This chapter contains the exact binary encodings for every instruction
family.

Readers implementing the assembler or CPU decoder should primarily use
this chapter.

------------------------------------------------------------------------

# 10. CPU Implementation

Connect the ISA to the hardware implementation.

Discuss:

-   Program Counter
-   Register File
-   ALU
-   Immediate Generator
-   Memory
-   Control Unit
-   FSM
-   Instruction Decoder

Reference the corresponding SystemVerilog modules.

------------------------------------------------------------------------

# 11. Future Improvements

Ideas for Version 2:

-   Pipeline
-   Interrupts
-   Multiply-high
-   Division
-   Stack pointer
-   Byte addressing
-   Cache
-   Memory-mapped I/O

------------------------------------------------------------------------

# Appendix A --- Opcode Table

Complete opcode reference.

# Appendix B --- Assembler Directives

Detailed documentation for:

-   .ORIG
-   .WORD
-   .SPACE
-   .END

# Appendix C --- Pseudo Instructions

Explain:

-   CLR
-   INC
-   DEC
-   NEG
-   RET
-   CMPZ

Include the real instructions each expands into.
