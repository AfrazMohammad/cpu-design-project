module cpu16bit #(
    parameter MEMORY_DEPTH = 65536,
    parameter RESET_PC = 16'h0000
)(
    input clk,
    input reset
);


    // Signal Declarations //


    // Program Counter
    wire [15:0] pc;
    wire [15:0] next_pc;
    wire pc_select;
    wire pc_enable;

    // MAR
    wire [15:0] mar;
    reg [15:0] next_mar;
    wire [1:0] mar_select;
    wire mar_enable;

    // Memory and MDR
    wire [15:0] mdr_data;
    wire mdr_enable;
    wire mdr_select;
    wire memory_write_enable;

    // Instruction Register
    wire [15:0] instruction;
    wire ir_enable;

    // Instruction Decoder
    wire [3:0] opcode;
    wire [2:0] dr;
    wire [2:0] sr1;
    wire [2:0] sr2;
    wire [2:0] base_r;
    wire [9:0] raw_imm;
    wire [2:0] subcode;
    
    // ALU
    wire [15:0] alu_result;
    wire [15:0] alu_a_data;
    wire [15:0] alu_b_data;
    wire alu_a_select;
    wire alu_b_select;
    wire carry_flag;
    wire overflow_flag;
    wire [3:0] alu_control_code;

    // Register Reads
    wire [15:0] read_data1;
    wire [15:0] read_data2;
    wire [2:0] read_address1;
    wire [2:0] read_address2;
    wire read_address1_select;
    wire read_address2_select;

    // Writeback
    reg [15:0] writeback_data;
    wire [2:0] writeback_address;
    wire [1:0] writeback_select;
    wire write_address_select;
    wire writeback_enable;

    // Immediate Extension
    wire [15:0] imm16;
    wire [2:0] extend_mode;

    // Compare Flags
    wire [2:0] leg_flags;
    wire [2:0] next_leg_flags;
    wire flags_enable;
    

    // Combinational Logic //


    // Program Counter
    assign next_pc = pc_select ? alu_result : (pc + 1);

    programCounter cpuPC(
        .pc(pc),
        .next_pc(next_pc),
        .reset_pc_value(RESET_PC),
        .clk(clk),
        .reset(reset),
        .enable(pc_enable)
    );

    // Memory Address Register
    always @ (*) begin
        case (mar_select)
            2'b00 : next_mar = alu_result;
            2'b01 : next_mar = mdr_data;
            2'b10 : next_mar = pc;
            default : next_mar = pc;
        endcase
    end
    
    memoryAddressRegister cpuMAR(
        .address(mar),
        .next_address(next_mar),
        .clk(clk),
        .reset(reset),
        .enable(mar_enable)
    );

    // Instruction Register
    instructionRegister cpuIR(
        .instruction(instruction),
        .memory_data(mdr_data),
        .clk(clk),
        .reset(reset),
        .enable(ir_enable)
    );

    // Instruction Decoder
    instructionDecoder cpuID(
        .opcode(opcode),
        .dr(dr),
        .sr1(sr1),
        .sr2(sr2),
        .base_r(base_r),
        .raw_imm(raw_imm),
        .subcode(subcode),
        .instruction(instruction)
    );

    // Immediate Extension Unit
    immediateExtensionUnit cpuIEU(
        .imm16(imm16),
        .imm(raw_imm),
        .extend_mode(extend_mode)
    );

    // Read Register Data
    assign read_address1 = read_address1_select ? base_r : sr1;
    assign read_address2 = read_address2_select ? sr1 : sr2;

    always @ (*) begin
        case (writeback_select)
            2'b00: writeback_data = alu_result;
            2'b01 : writeback_data = mdr_data;
            2'b10 : writeback_data = imm16;
            2'b11 : writeback_data = pc;
            default : writeback_data = 16'h0000;
        endcase
    end

    assign writeback_address = write_address_select ? 3'b111 : dr;

    registerFile cpuRF(
        .read_data1(read_data1),
        .read_data2(read_data2),
        .read_address1(read_address1),
        .read_address2(read_address2),
        .write_address(writeback_address),
        .write_data(writeback_data),
        .clk(clk),
        .reset(reset),
        .write_enable(writeback_enable)
    );

    // Memory
    unifiedMemory #(
        .MEMORY_DEPTH(MEMORY_DEPTH)
    ) cpuUM(
        .mdr_data(mdr_data),
        .store_data(read_data2),
        .address(mar),
        .mdr_enable(mdr_enable),
        .mdr_select(mdr_select),
        .mdr_reset(reset),
        .clk(clk),
        .memory_write_enable(memory_write_enable)
    );

    // Compare Unit + Flags Register
    compareUnit cpuCU(
        .next_leg_flags(next_leg_flags),
        .a(alu_a_data),
        .b(alu_b_data)
    );

    flagsRegister cpuFR(
        .leg_flags(leg_flags),
        .next_leg_flags(next_leg_flags),
        .clk(clk),
        .reset(reset),
        .enable(flags_enable)
    );

    // Arithmetic Logic Unit
    assign alu_a_data = alu_a_select ? pc : read_data1;
    assign alu_b_data = alu_b_select ? imm16 : read_data2;

    alu16bit cpuALU(
        .result(alu_result),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .a(alu_a_data),
        .b(alu_b_data),
        .alu_control(alu_control_code)
    );

    // Final Control Unit
    controlUnitSkeleton cpuControlUnit(
        .pc_enable(pc_enable),
        .mar_enable(mar_enable),
        .mdr_enable(mdr_enable),
        .ir_enable(ir_enable),
        .writeback_enable(writeback_enable),
        .memory_write_enable(memory_write_enable),
        .flags_enable(flags_enable),

        .mar_select(mar_select),
        .mdr_select(mdr_select),
        .alu_a_select(alu_a_select),
        .alu_b_select(alu_b_select),
        .writeback_select(writeback_select),
        .write_address_select(write_address_select),
        .pc_select(pc_select),
        .extend_mode(extend_mode),
        .alu_control_code(alu_control_code),
        .read_address1_select(read_address1_select),
        .read_address2_select(read_address2_select),

        .clk(clk), 
        .reset(reset),
        .opcode(opcode),
        .subcode(subcode),
        .leg_flags(leg_flags)
    );

endmodule //cpu16bit
