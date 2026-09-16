`timescale 1ns/1ps

module register16bit(
    output reg [15:0] q,
    input [15:0] d,
    input clk, reset, enable
);

always @(posedge clk) begin
    if (reset)
        q <= 16'h0000;

    else if (enable)
        q <= d;
end

endmodule //register16bit




module decoder3to8(
    output [7:0] d,
    input [2:0] a
);

assign d[0] = ~a[2] & ~a[1] & ~a[0];
assign d[1] = ~a[2] & ~a[1] & a[0];
assign d[2] = ~a[2] & a[1] & ~a[0];
assign d[3] = ~a[2] & a[1] & a[0];
assign d[4] = a[2] & ~a[1] & ~a[0];
assign d[5] = a[2] & ~a[1] & a[0];
assign d[6] = a[2] & a[1] & ~a[0];
assign d[7] = a[2] & a[1] & a[0];

endmodule




module registerFile(
    output reg [15:0] read_data1, read_data2,
    input [2:0] read_address1, read_address2,

    input [2:0] write_address,
    input [15:0] write_data,
    
    input clk, reset, write_enable
);

wire [7:0] register_select;
wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

decoder3to8 rf1(
    .d(register_select),
    .a(write_address)
);

register16bit rfR0(
    .q(r0),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[0])
);

register16bit rfR1(
    .q(r1),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[1])
);

register16bit rfR2(
    .q(r2),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[2])
);

register16bit rfR3(
    .q(r3),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[3])
);

register16bit rfR4(
    .q(r4),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[4])
);

register16bit rfR5(
    .q(r5),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[5])
);

register16bit rfR6(
    .q(r6),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[6])
);

register16bit rfR7(
    .q(r7),
    .d(write_data),
    .clk(clk),
    .reset(reset),
    .enable(write_enable & register_select[7])
);

always @ (*) begin
    case (read_address1)
        3'b000 : read_data1 = r0;
        3'b001 : read_data1 = r1;
        3'b010 : read_data1 = r2;
        3'b011 : read_data1 = r3;
        3'b100 : read_data1 = r4;
        3'b101 : read_data1 = r5;
        3'b110 : read_data1 = r6;
        3'b111 : read_data1 = r7;
        default: read_data1 = 16'h0000;
    endcase

    case (read_address2)
        3'b000 : read_data2 = r0;
        3'b001 : read_data2 = r1;
        3'b010 : read_data2 = r2;
        3'b011 : read_data2 = r3;
        3'b100 : read_data2 = r4;
        3'b101 : read_data2 = r5;
        3'b110 : read_data2 = r6;
        3'b111 : read_data2 = r7;
        default: read_data2 = 16'h0000;
    endcase
end

endmodule //registerFile




module alu16bit(
    output reg [15:0] result,
    output reg carry_flag, overflow_flag,

    input [15:0] a, b,
    input [3:0] alu_control
);

    //ALU Control Codes
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam MUL = 4'b0010;
    localparam AND = 4'b0011;
    localparam OR = 4'b0100;
    localparam XOR = 4'b0101;
    localparam NOT = 4'b0110;
    localparam SHL = 4'b0111;
    localparam SHR = 4'b1000;
    localparam SHRA = 4'b1001;
    localparam ROR = 4'b1010;

    //Internal Regs
    reg signed [31:0] product;
    reg [16:0] sum;

always @ (*) begin
    //Default Initalizations
    carry_flag = 1'b0;
    overflow_flag = 1'b0;
    sum = 17'h00000;
    product = 32'sh00000000;
    result = 16'h0000;

    case (alu_control)
        // Arithmetic Cases
        ADD : begin
            sum = {1'b0, a} + {1'b0, b};
            result = sum[15:0];
            carry_flag = sum[16];
            overflow_flag = ~(a[15] ^ b[15]) & (a[15] ^ result[15]);
        end //ADD
        SUB : begin
            result = a - b;
            carry_flag = (a >= b);
            overflow_flag = (a[15] ^ b[15]) & (a[15] ^ result[15]);
        end //SUB
        MUL : begin
            product = $signed(a) * $signed(b);
            result = product[15:0];
            overflow_flag = product[31:16] != {16{product[15]}};
        end

        // Logic Cases
        AND : result = a & b; 
        OR : result = a | b; 
        XOR : result = a ^ b; 
        NOT : result = ~a;    

        // Shift Cases
        SHL : result = a << b[3:0]; 
        SHR : result = a >> b[3:0]; 
        SHRA : result = $signed(a) >>> b[3:0]; 
        ROR : begin
            if (b[3:0] == 4'b0000)
                result = a;
            else
                result = (a >> b[3:0]) | (a << (16-b[3:0]));
        end
        default : result = 16'h0000;
    endcase

end
endmodule //alu16bit




module programCounter(
    output reg [15:0] pc,
    input [15:0] next_pc,
    input [15:0] reset_pc_value,
    input clk, reset, enable
);

always @ (posedge clk) begin
    if (reset)
        pc <= reset_pc_value;
    else if (enable)
        pc <= next_pc;
end

endmodule //programCounter




module instructionRegister(
    output [15:0] instruction,
    input [15:0] memory_data,
    input clk, reset, enable
);

register16bit ir(
    .q(instruction),
    .d(memory_data),
    .clk(clk),
    .reset(reset),
    .enable(enable)
);

endmodule //instructionRegister




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




module flagsRegister(
    output reg [2:0] leg_flags,
    input [2:0] next_leg_flags,
    input clk, reset, enable
);

always @ (posedge clk) begin
    if (reset)
        leg_flags <= 3'b000;

    else if (enable)
        leg_flags <= next_leg_flags;
end

endmodule //flagsRegister




module compareUnit(
    output reg [2:0] next_leg_flags,
    input [15:0] a, b
);

always @ (*) begin
    next_leg_flags = 3'b000;

    if ($signed(a) < $signed(b))
        next_leg_flags[2] = 1'b1; //L
    else if (a == b)
        next_leg_flags[1] = 1'b1; //E
    else
        next_leg_flags[0] = 1'b1; //G
end

endmodule //compareUnit




module unifiedMemory #(
    parameter MEMORY_DEPTH = 65536      // 16 Bit Representation
    )(
    output reg [15:0] mdr_data,

    input [15:0] store_data, 
    input [15:0] address,

    input mdr_enable, 
    input mdr_select, 
    input mdr_reset,

    input clk, 
    input memory_write_enable
);

    `include "program.svh"

    reg [15:0] memory [0:MEMORY_DEPTH-1];

    always @ (posedge clk) begin
        if (mdr_reset)
            mdr_data <= 16'h0000;
        else begin
            if (memory_write_enable)
                memory[address] <= mdr_data;
            if (mdr_enable) begin
                case (mdr_select)
                    1'b0 : mdr_data <= memory[address];
                    1'b1 : mdr_data <= store_data;
                endcase
            end
        end
    end

endmodule //unifiedMemory




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




module memoryAddressRegister(
    output [15:0] address,
    input [15:0] next_address,
    input clk, reset, enable
);

register16bit mar(
    .q(address),
    .d(next_address),
    .clk(clk),
    .reset(reset),
    .enable(enable)
);

endmodule //memoryAddressRegister




module controlUnitSkeleton(
    output reg pc_enable,
    output reg mar_enable,
    output reg mdr_enable,
    output reg ir_enable,
    output reg writeback_enable,
    output reg memory_write_enable,
    output reg flags_enable,

    output reg [1:0] mar_select,
    output reg mdr_select,
    output reg alu_a_select,
    output reg alu_b_select,
    output reg [1:0] writeback_select,
    output reg write_address_select,
    output reg pc_select,
    output reg [2:0] extend_mode,
    output reg [3:0] alu_control_code,
    output reg read_address1_select,
    output reg read_address2_select,

    input clk, reset,
    input [3:0] opcode,
    input [2:0] subcode,
    input [2:0] leg_flags
);

//STATES: FETCH --> DECODE --> EXECUTE
localparam FETCH_MAR        = 5'h00;
localparam FETCH_MDR        = 5'h01;
localparam FETCH_IR         = 5'h02;
localparam DECODE           = 5'h03;
localparam EXEC_ALU         = 5'h04;

//For Loads and Stores
localparam EXEC_MEM_ADDR    = 5'h05;
localparam EXEC_MEM_READ    = 5'h06;
localparam EXEC_INDR_MAR    = 5'h07;
localparam EXEC_INDR_READ   = 5'h08;
localparam EXEC_FINAL_LOAD  = 5'h09;
localparam EXEC_FINAL_STORE = 5'h0a;

localparam EXEC_LI          = 5'h0b;
localparam EXEC_LEA         = 5'h0c;

localparam EXEC_JUMP        = 5'h0d;

localparam EXEC_RESERVED    = 5'h0e;

localparam EXEC_CMP         = 5'h0f;

localparam EXEC_BR          = 5'h10;

localparam EXEC_SYSTEM      = 5'h11;

localparam HALT             = 5'h1f;

//OPCODES
localparam ADD              = 4'h0;
localparam SUB              = 4'h1;
localparam MUL              = 4'h2;
localparam AND              = 4'h3;
localparam OR               = 4'h4;
localparam XOR              = 4'h5;
localparam NOT              = 4'h6;
localparam SHIFT            = 4'h7;
localparam LD_ST            = 4'h8; // LD, ST, LDI, STI
localparam LDR_STR          = 4'h9; // LDR, STR
localparam LI_LEA           = 4'hA; // LI, LEA
localparam JUMP             = 4'hB; // JAL, JMP, JALR
localparam RESERVED         = 4'hC;
localparam CMP              = 4'hD; // CMP, CMPI
localparam BR               = 4'hE;
localparam SYSTEM           = 4'hF; // NOP, HALT

reg [4:0] current_state, next_state;

always @ (posedge clk) begin
    if (reset)
        current_state <= FETCH_MAR;
    else
        current_state <= next_state;
end

always @ (*) begin

    pc_enable = 1'b0;
    mar_enable = 1'b0;
    mdr_enable = 1'b0;
    ir_enable = 1'b0;
    writeback_enable = 1'b0;
    memory_write_enable = 1'b0;
    flags_enable = 1'b0;

    next_state = current_state;

    mar_select = 2'b00;
    mdr_select = 1'b0;
    alu_a_select = 1'b0;
    alu_b_select = 1'b0;
    writeback_select = 2'b00;
    write_address_select = 1'b0;
    pc_select = 1'b0;
    extend_mode = 3'b000;
    alu_control_code = 4'b0000;
    read_address1_select = 1'b0;
    read_address2_select = 1'b0;

    case (current_state)
        FETCH_MAR : begin
            //MAR
            mar_select = 2'b10; // PC Mode
            mar_enable = 1'b1;

            //PC
            pc_select = 1'b0; // PC + 1 Mode
            pc_enable = 1'b1;

            //FSM
            next_state = FETCH_MDR;
        end

        FETCH_MDR : begin
            //MDR
            mdr_select = 1'b0; // Memory Read Data
            mdr_enable = 1'b1;

            //FSM
            next_state = FETCH_IR;
        end

        FETCH_IR : begin
            //IR
            ir_enable = 1'b1;

            //FSM
            next_state = DECODE;
        end

        DECODE : begin
            case (opcode)
                ADD, SUB, MUL, AND, OR, XOR, NOT, SHIFT :
                    next_state = EXEC_ALU;

                LD_ST, LDR_STR :
                    next_state = EXEC_MEM_ADDR;

                LI_LEA :
                    next_state = (subcode[0]) ? EXEC_LEA : EXEC_LI;

                JUMP :
                    next_state = EXEC_JUMP;

                RESERVED :
                    next_state = EXEC_RESERVED;

                CMP :
                    next_state = EXEC_CMP;

                BR :
                    next_state = EXEC_BR;

                SYSTEM :
                    next_state = EXEC_SYSTEM;

                default:
                    next_state = FETCH_MAR;
            endcase
        end

        // For Arithmetic/Logic Instructions ADD to SHIFT
        EXEC_ALU : begin
            //ALU
            alu_a_select = 1'b0;        //Source Register Data
            alu_b_select = 
                (opcode == SHIFT) ? 1'b1 : subcode[0];  //0 = SR2, 1 = Imm Ext Unit Output
            alu_control_code = 
                (opcode == SHIFT) ? (opcode + {1'b0, subcode}) : opcode;
                // SHL, SHR, SHRA, ROR

            //Writeback
            writeback_select = 2'b00;    // ALU Result
            write_address_select = 1'b0; // Destination Register
            writeback_enable = 1'b1;

            //Registers
            read_address1_select = 1'b0; // SR1
            read_address2_select = 1'b0; // SR2 (or ignored if imm5)

            //Immediate Extension
            if (opcode == SHIFT)
                extend_mode = 3'b000;
            else if (opcode == ADD || opcode == SUB || opcode == MUL)
                extend_mode = 3'b010;        // signed 5 bit
            else
                extend_mode = 3'b001;        // unsigned 5 bit

            //FSM
            next_state = FETCH_MAR;
        end

        //For Loads and Stores
        EXEC_MEM_ADDR: begin
            //MAR <= ALU Result
            mar_enable = 1'b1;
            mar_select = 2'b00;             // ALU Result

            //MDR <= Source Data for ST and STR
            mdr_enable = (subcode == 3'b001);        
            // Only enabled for ST and STR
            mdr_select = 1'b1;              // SR Data for Stores

            //ALU Add Operation
            alu_a_select = !(opcode == LDR_STR);
            // 0 = Base Register (LDR/STR), 1 = PC (LD/ST/LDI/STI)
            alu_b_select = 1'b1;            // Extended Immediate
            alu_control_code = 4'b0000; //ADD
            extend_mode = (opcode == LDR_STR) ? 3'b010 : 3'b011;
            // Signed 5 bit for LDR/STR, 7 bit for LD/ST/LDI/STI
            
            //Register Reads
            read_address1_select = 1'b1; //
            read_address2_select = 1'b1; //For ST/STR

            //FSM
            next_state = (subcode == 3'b001) ?    // Checks if ST/STR
                EXEC_FINAL_STORE : EXEC_MEM_READ;
        end

        //For LD, LDR, LDI, STI
        EXEC_MEM_READ : begin
            mdr_enable = 1'b1;
            mdr_select = 1'b0;          // MDR <- MEM[MAR]

            //FSM
            next_state = (subcode[1]) ?         // Checks if LDI/STI
                EXEC_INDR_MAR : EXEC_FINAL_LOAD;
        end

        //For LDI, STI
        EXEC_INDR_MAR : begin
            //MAR
            mar_enable = 1'b1;
            mar_select = 2'b01;         // MAR <= MDR

            //MDR
            mdr_enable = subcode[0];    // MDR enabled for STI
            mdr_select = 1'b1;          // Register Source Data

            //Register
            read_address2_select = 1'b1; // Source Data for STI

            //FSM
            next_state = (subcode[0]) ?     //Checks if STI
                EXEC_FINAL_STORE : EXEC_INDR_READ;
        end

        //For LDI
        EXEC_INDR_READ : begin
            mdr_enable = 1'b1;
            mdr_select = 0;             // MDR <= MEM[MAR]

            //FSM
            next_state = EXEC_FINAL_LOAD;
        end

        //For LD/LDI/LDR
        EXEC_FINAL_LOAD : begin
            //Writeback into Destination Register
            writeback_select = 2'b01;    // MDR Data
            write_address_select = 1'b0; // Destination Register
            writeback_enable = 1'b1;

            //FSM
            next_state = FETCH_MAR;
        end

        //For ST/STI/STR
        EXEC_FINAL_STORE : begin
            memory_write_enable = 1'b1; // MEM[MAR] <- MDR
            next_state = FETCH_MAR;
        end

        //For LI
        EXEC_LI : begin
            //Writeback
            writeback_enable = 1'b1;
            writeback_select = 2'b10;    // Immediate Extension Unit Output
            write_address_select = 1'b0;

            //Immediate Extension
            extend_mode = 3'b100;       // Signed 8 Bit

            //FSM
            next_state = FETCH_MAR;
        end

        //For LEA
        EXEC_LEA : begin
            //ALU
            alu_a_select = 1'b1;        // PC
            alu_b_select = 1'b1;        // Extended Immediate
            alu_control_code = 4'b0000; // ADD

            //Writeback
            writeback_select = 2'b00;    // ALU Result
            write_address_select = 1'b0; // Destination Register
            writeback_enable = 1'b1;

            //Immediate Extension
            extend_mode = 3'b100;       // Signed 8 Bit

            //FSM
            next_state = FETCH_MAR;
        end

        //For JAL(subcode 000), JMP(001), JALR(010)
        EXEC_JUMP : begin
            //ALU to calculate target address
            alu_a_select = !subcode;    // PC for JAL, BaseR for JMP/JALR
            alu_b_select = 1'b1;        // Extended Immediate
            alu_control_code = 4'b0000; // ADD

            //Writeback: R7 <= PC for JAL/JALR
            writeback_select = 2'b11;   // Current PC
            write_address_select = 1'b1; // R7
            writeback_enable = ~subcode[0];
                //JAL and JALR will write to R7, JMP will not.

            //Update PC
            pc_select = 1'b1;           // ALU Result
            pc_enable = 1'b1;

            //Immediate Extension
            extend_mode = (subcode) ? 3'b011 : 3'b110;
                // Signed 7 bit for JMP, JALR, Signed 10 bit for JAL

            //Register
            read_address1_select = 1'b1;

            //FSM
            next_state = FETCH_MAR;
        end

        //For RESERVED Opcode
        EXEC_RESERVED : begin
            next_state = FETCH_MAR;
        end

        //For CMP
        EXEC_CMP : begin
            //ALU
            alu_a_select = 1'b0;        // SR1
            alu_b_select = subcode[0];  // Immediate for CMPI, Register for CMP

            //Immediate Extension
            extend_mode = 3'b100;

            //Flags
            flags_enable = 1'b1;

            //FSM
            next_state = FETCH_MAR;
        end

        //For BEQ, BNE, BLT, BGT, BLE, BGE, BR
        EXEC_BR : begin
            //ALU for Target PC
            alu_a_select = 1'b1;        // Current PC
            alu_b_select = 1'b1;        // Extended Immediate
            alu_control_code = 4'b0000; // ADD

            //Immediate Extension
            extend_mode = 3'b101;       // Signed 9 Bit

            //Update PC
            pc_select = 1'b1;           // ALU Result
            pc_enable = (subcode & leg_flags) || (subcode == 3'b111);
                // Branch Taken when subcode matches leg_flags or during unconditional branch
            
            //FSM
            next_state = FETCH_MAR;
        end

        //For HALT/NOP
        EXEC_SYSTEM : begin
            next_state = (subcode) ? HALT : FETCH_MAR;
        end

        HALT :
            next_state = HALT;

        default :
            next_state = FETCH_MAR;

    endcase

end

endmodule //controlUnitSkeleton




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
