module instructionDecoder(
    output [3:0] opcode,
    output reg [2:0] dr,
    output reg [2:0] sr1, sr2,
    output reg [2:0] base_r,
    output reg [9:0] raw_imm,
    output reg [2:0] subcode,
    input [15:0] instruction
);

localparam ADD = 4'h0;
localparam SUB = 4'h1;
localparam MUL = 4'h2;
localparam AND = 4'h3;
localparam OR = 4'h4;
localparam XOR = 4'h5;
localparam NOT = 4'h6;
localparam SHIFT = 4'h7;
localparam LD_ST = 4'h8;
localparam LDR_STR = 4'h9;
localparam LI_LEA = 4'ha;
localparam JUMP = 4'hb;
localparam RESERVED = 4'hc;
localparam CMP = 4'hd;
localparam BR = 4'he;
localparam NOP_HALT = 4'hf;

assign opcode = instruction[15:12];

always @ (*) begin

    dr = 3'b000;
    sr1 = 3'b000;
    sr2 = 3'b000;
    base_r = 3'b000;
    subcode = 3'b000;
    raw_imm = 10'h000;

    case (opcode)

        ADD, SUB, MUL, AND, OR, XOR : begin
            dr = instruction[11:9];
            sr1 = instruction[8:6];
            subcode = {2'b00, instruction[5]};
            sr2 = instruction[2:0];
            raw_imm = {5'b0, instruction[4:0]};
        end

        NOT : begin
            dr = instruction[11:9];
            sr1 = instruction[8:6];
        end

        SHIFT : begin
            dr = instruction[11:9];
            sr1 = instruction[8:6];
            subcode = {1'b0, instruction[5:4]};
            raw_imm = {6'b0, instruction[3:0]};
        end

        LD_ST : begin
            dr = instruction[11:9];
            sr1 = instruction[11:9];
            subcode = {1'b0, instruction[8:7]};
            raw_imm = {3'b0, instruction[6:0]};
        end

        LDR_STR : begin
            dr = instruction[11:9];
            sr1 = instruction[11:9];
            subcode = {2'b0, instruction[8]};
            base_r = instruction[7:5];
            raw_imm = {5'b0, instruction[4:0]};
        end

        LI_LEA : begin
            dr = instruction[11:9];
            subcode = {2'b0, instruction[8]};
            raw_imm = {2'b0, instruction[7:0]};
        end

        JUMP : begin
            subcode = {1'b0, instruction[11:10]};
            raw_imm = instruction[9:0];
            base_r = instruction[9:7];
        end

        RESERVED: begin
            // Outputs remain at default values
        end

        CMP : begin
            sr1 = instruction[11:9];
            subcode = {2'b0, instruction[8]};
            sr2 = instruction[2:0];
            raw_imm = {2'b0, instruction[7:0]};
        end

        BR : begin
            subcode = instruction[11:9];
            raw_imm = {1'b0, instruction[8:0]};
        end

        NOP_HALT : subcode = {1'b0, instruction[11:10]};

        default : begin
            // Defaults remain active
        end
    endcase
end

endmodule //instructionDecoder
