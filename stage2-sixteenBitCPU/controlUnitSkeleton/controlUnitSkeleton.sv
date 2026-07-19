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
