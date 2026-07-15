`timescale 1ns/1ps

module testbench;

    reg [15:0] instruction;

    wire [3:0] opcode;
    wire [2:0] dr;
    wire [2:0] sr1;
    wire [2:0] sr2;
    wire [2:0] base_r;
    wire [9:0] raw_imm;
    wire [2:0] subcode;

    integer errors;

    instructionDecoder dut(
        .opcode(opcode),
        .dr(dr),
        .sr1(sr1),
        .sr2(sr2),
        .base_r(base_r),
        .raw_imm(raw_imm),
        .subcode(subcode),
        .instruction(instruction)
    );

    task check_decode;
        input [15:0] test_instruction;
        input [3:0] expected_opcode;
        input [2:0] expected_dr;
        input [2:0] expected_sr1;
        input [2:0] expected_sr2;
        input [2:0] expected_base_r;
        input [9:0] expected_raw_imm;
        input [2:0] expected_subcode;
        input [127:0] test_name;

        begin
            instruction = test_instruction;

            #1;

            if (
                opcode   !== expected_opcode  ||
                dr       !== expected_dr      ||
                sr1      !== expected_sr1     ||
                sr2      !== expected_sr2     ||
                base_r   !== expected_base_r  ||
                raw_imm  !== expected_raw_imm ||
                subcode  !== expected_subcode
            ) begin
                $display(
                    "FAIL: %s | instr=%h op=%h dr=%b sr1=%b sr2=%b base=%b imm=%b sub=%b",
                    test_name,
                    instruction,
                    opcode,
                    dr,
                    sr1,
                    sr2,
                    base_r,
                    raw_imm,
                    subcode
                );

                $display(
                    "EXPECTED: op=%h dr=%b sr1=%b sr2=%b base=%b imm=%b sub=%b",
                    expected_opcode,
                    expected_dr,
                    expected_sr1,
                    expected_sr2,
                    expected_base_r,
                    expected_raw_imm,
                    expected_subcode
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %s | instr=%h",
                    test_name,
                    instruction
                );
            end
        end
    endtask

    initial begin
        errors = 0;
        instruction = 16'h0000;

        // ADD R1, R2, R3
        check_decode(
            16'b0000_001_010_0_00_011,
            4'h0,
            3'b001,
            3'b010,
            3'b011,
            3'b000,
            10'b0000000011,
            3'b000,
            "ADD register"
        );

        // ADDI R4, R5, imm5
        check_decode(
            16'b0000_100_101_1_11101,
            4'h0,
            3'b100,
            3'b101,
            3'b101,
            3'b000,
            10'b0000011101,
            3'b001,
            "ADDI"
        );

        // SUB R7, R1, R6
        check_decode(
            16'b0001_111_001_0_00_110,
            4'h1,
            3'b111,
            3'b001,
            3'b110,
            3'b000,
            10'b0000000110,
            3'b000,
            "SUB register"
        );

        // MULI R2, R3, 5
        check_decode(
            16'b0010_010_011_1_00101,
            4'h2,
            3'b010,
            3'b011,
            3'b101,
            3'b000,
            10'b0000000101,
            3'b001,
            "MULI"
        );

        // ANDI
        check_decode(
            16'b0011_001_010_1_11111,
            4'h3,
            3'b001,
            3'b010,
            3'b111,
            3'b000,
            10'b0000011111,
            3'b001,
            "ANDI"
        );

        // OR register
        check_decode(
            16'b0100_011_100_0_00_101,
            4'h4,
            3'b011,
            3'b100,
            3'b101,
            3'b000,
            10'b0000000101,
            3'b000,
            "OR register"
        );

        // XORI
        check_decode(
            16'b0101_110_001_1_01010,
            4'h5,
            3'b110,
            3'b001,
            3'b010,
            3'b000,
            10'b0000001010,
            3'b001,
            "XORI"
        );

        // NOT
        check_decode(
            16'b0110_010_111_000000,
            4'h6,
            3'b010,
            3'b111,
            3'b000,
            3'b000,
            10'b0000000000,
            3'b000,
            "NOT"
        );

        // SHL
        check_decode(
            16'b0111_001_010_00_1010,
            4'h7,
            3'b001,
            3'b010,
            3'b000,
            3'b000,
            10'b0000001010,
            3'b000,
            "SHL"
        );

        // SHRA
        check_decode(
            16'b0111_011_100_10_0011,
            4'h7,
            3'b011,
            3'b100,
            3'b000,
            3'b000,
            10'b0000000011,
            3'b010,
            "SHRA"
        );

        // LD
        check_decode(
            16'b1000_101_00_0101010,
            4'h8,
            3'b101,
            3'b101,
            3'b000,
            3'b000,
            10'b0000101010,
            3'b000,
            "LD"
        );

        // ST
        check_decode(
            16'b1000_011_01_1110001,
            4'h8,
            3'b011,
            3'b011,
            3'b000,
            3'b000,
            10'b0001110001,
            3'b001,
            "ST"
        );

        // LDI
        check_decode(
            16'b1000_110_10_0001111,
            4'h8,
            3'b110,
            3'b110,
            3'b000,
            3'b000,
            10'b0000001111,
            3'b010,
            "LDI"
        );

        // STI
        check_decode(
            16'b1000_001_11_1010101,
            4'h8,
            3'b001,
            3'b001,
            3'b000,
            3'b000,
            10'b0001010101,
            3'b011,
            "STI"
        );

        // LDR
        check_decode(
            16'b1001_010_0_110_10011,
            4'h9,
            3'b010,
            3'b010,
            3'b000,
            3'b110,
            10'b0000010011,
            3'b000,
            "LDR"
        );

        // STR
        check_decode(
            16'b1001_101_1_011_00101,
            4'h9,
            3'b101,
            3'b101,
            3'b000,
            3'b011,
            10'b0000000101,
            3'b001,
            "STR"
        );

        // LI
        check_decode(
            16'b1010_100_0_10101100,
            4'hA,
            3'b100,
            3'b000,
            3'b000,
            3'b000,
            10'b0010101100,
            3'b000,
            "LI"
        );

        // LEA
        check_decode(
            16'b1010_001_1_01110101,
            4'hA,
            3'b001,
            3'b000,
            3'b000,
            3'b000,
            10'b0001110101,
            3'b001,
            "LEA"
        );

        // JAL
        check_decode(
            16'b1011_00_1010101010,
            4'hB,
            3'b000,
            3'b000,
            3'b000,
            3'b101,
            10'b1010101010,
            3'b000,
            "JAL"
        );

        // JMP
        check_decode(
            16'b1011_01_101_0110011,
            4'hB,
            3'b000,
            3'b000,
            3'b000,
            3'b101,
            10'b1010110011,
            3'b001,
            "JMP"
        );

        // JALR
        check_decode(
            16'b1011_10_010_1110001,
            4'hB,
            3'b000,
            3'b000,
            3'b000,
            3'b010,
            10'b0101110001,
            3'b010,
            "JALR"
        );

        // Reserved opcode
        check_decode(
            16'b1100_111111111111,
            4'hC,
            3'b000,
            3'b000,
            3'b000,
            3'b000,
            10'b0000000000,
            3'b000,
            "Reserved"
        );

        // CMP R3, R5
        check_decode(
            16'b1101_011_000_0_00_101,
            4'hD,
            3'b000,
            3'b011,
            3'b101,
            3'b000,
            10'b0000000101,
            3'b000,
            "CMP"
        );

        // CMPI
        check_decode(
            16'b1101_110_000_1_11100,
            4'hD,
            3'b000,
            3'b110,
            3'b100,
            3'b000,
            10'b0000011100,
            3'b001,
            "CMPI"
        );

        // BEQ
        check_decode(
            16'b1110_010_101010101,
            4'hE,
            3'b000,
            3'b000,
            3'b000,
            3'b000,
            10'b0101010101,
            3'b010,
            "BEQ"
        );

        // BR
        check_decode(
            16'b1110_111_000111000,
            4'hE,
            3'b000,
            3'b000,
            3'b000,
            3'b000,
            10'b0000111000,
            3'b111,
            "BR"
        );

        // NOP
        check_decode(
            16'b1111_00_0000000000,
            4'hF,
            3'b000,
            3'b000,
            3'b000,
            3'b000,
            10'b0000000000,
            3'b000,
            "NOP"
        );

        // HALT
        check_decode(
            16'b1111_11_0000000000,
            4'hF,
            3'b000,
            3'b000,
            3'b000,
            3'b000,
            10'b0000000000,
            3'b011,
            "HALT"
        );

        $display("");

        if (errors == 0)
            $display("ALL INSTRUCTION DECODER TESTS PASSED");
        else
            $display("%0d INSTRUCTION DECODER TESTS FAILED", errors);

        $finish;
    end

endmodule
