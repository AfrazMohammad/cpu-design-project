module immediateExtensionUnit(
    output reg [15:0] imm16,
    input [9:0] imm,
    input [2:0] extend_mode
);

localparam zero_extend_4 = 3'b000;
localparam zero_extend_5 = 3'b001;
localparam sign_extend_5 = 3'b010;
localparam sign_extend_7 = 3'b011;
localparam sign_extend_8 = 3'b100;
localparam sign_extend_9 = 3'b101;
localparam sign_extend_10 = 3'b110;

always @ (*) begin
    case (extend_mode)
        zero_extend_4 : imm16 = {12'b0, imm[3:0]};
        zero_extend_5 : imm16 = {11'b0, imm[4:0]};
        sign_extend_5 : imm16 = {{11{imm[4]}}, imm[4:0]};
        sign_extend_7 : imm16 = {{9{imm[6]}}, imm[6:0]};
        sign_extend_8 : imm16 = {{8{imm[7]}}, imm[7:0]};
        sign_extend_9 : imm16 = {{7{imm[8]}}, imm[8:0]};
        sign_extend_10 : imm16 = {{6{imm[9]}}, imm[9:0]};
        default : imm16 = 16'h0000;
    endcase
end

endmodule //immediateExtensionUnit
