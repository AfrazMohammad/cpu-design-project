`timescale 1ns/1ps

module testbench;

    // ============================================================
    // DUT inputs
    // ============================================================

    logic clk;
    logic reset;
    logic [3:0] opcode;
    logic [2:0] subcode;
    logic [2:0] leg_flags;

    // ============================================================
    // DUT outputs
    // ============================================================

    wire pc_enable;
    wire mar_enable;
    wire mdr_enable;
    wire ir_enable;
    wire writeback_enable;
    wire memory_write_enable;
    wire flags_enable;

    wire [1:0] mar_select;
    wire       mdr_select;
    wire       alu_a_select;
    wire       alu_b_select;
    wire [1:0] writeback_select;
    wire       write_address_select;
    wire       pc_select;
    wire [2:0] extend_mode;
    wire [3:0] alu_control_code;
    wire       read_address1_select;
    wire       read_address2_select;

    // ============================================================
    // State encodings
    // ============================================================

    localparam logic [4:0]
        FETCH_MAR        = 5'h00,
        FETCH_MDR        = 5'h01,
        FETCH_IR         = 5'h02,
        DECODE           = 5'h03,
        EXEC_ALU         = 5'h04,
        EXEC_MEM_ADDR    = 5'h05,
        EXEC_MEM_READ    = 5'h06,
        EXEC_INDR_MAR    = 5'h07,
        EXEC_INDR_READ   = 5'h08,
        EXEC_FINAL_LOAD  = 5'h09,
        EXEC_FINAL_STORE = 5'h0A,
        EXEC_LI          = 5'h0B,
        EXEC_LEA         = 5'h0C,
        EXEC_JUMP        = 5'h0D,
        EXEC_RESERVED    = 5'h0E,
        EXEC_CMP         = 5'h0F,
        EXEC_BR          = 5'h10,
        EXEC_SYSTEM      = 5'h11,
        HALT_STATE       = 5'h1F;

    // ============================================================
    // Opcode encodings
    // ============================================================

    localparam logic [3:0]
        OP_ADD    = 4'h0,
        OP_AND    = 4'h3,
        OP_SHIFT  = 4'h7,
        OP_LD_ST  = 4'h8,
        OP_LDRSTR = 4'h9,
        OP_LI_LEA = 4'hA,
        OP_JUMP   = 4'hB,
        OP_RESERVED = 4'hC,
        OP_CMP    = 4'hD,
        OP_BR     = 4'hE,
        OP_SYSTEM = 4'hF;

    // ============================================================
    // DUT
    // ============================================================

    controlUnitSkeleton dut (
        .clk                  (clk),
        .reset                (reset),
        .opcode               (opcode),
        .subcode              (subcode),
        .leg_flags            (leg_flags),

        .pc_enable            (pc_enable),
        .mar_enable           (mar_enable),
        .mdr_enable           (mdr_enable),
        .ir_enable            (ir_enable),
        .writeback_enable     (writeback_enable),
        .memory_write_enable  (memory_write_enable),
        .flags_enable         (flags_enable),

        .mar_select           (mar_select),
        .mdr_select           (mdr_select),
        .alu_a_select         (alu_a_select),
        .alu_b_select         (alu_b_select),
        .writeback_select     (writeback_select),
        .write_address_select (write_address_select),
        .pc_select            (pc_select),
        .extend_mode          (extend_mode),
        .alu_control_code     (alu_control_code),
        .read_address1_select (read_address1_select),
        .read_address2_select (read_address2_select)
    );

    // ============================================================
    // Clock
    // ============================================================

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer passed = 0;
    integer failed = 0;

    // ============================================================
    // Helper tasks
    // ============================================================

    task automatic tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task automatic check(
        input logic condition,
        input string message
    );
        begin
            if (condition === 1'b1) begin
                passed++;
                $display("[PASS] %s", message);
            end
            else begin
                failed++;
                $display("[FAIL] %s", message);
            end
        end
    endtask

    task automatic expect_state(
        input logic [4:0] expected,
        input string name
    );
        begin
            check(
                dut.current_state === expected,
                $sformatf(
                    "%s: expected %02h, got %02h",
                    name,
                    expected,
                    dut.current_state
                )
            );
        end
    endtask

    task automatic reset_dut;
        begin
            reset   = 1'b1;
            opcode  = OP_ADD;
            subcode = 3'b000;
            leg_flags = 3'b000;

            tick();

            expect_state(FETCH_MAR, "Reset");

            // Deassert immediately after the reset edge.
            reset = 1'b0;
            #1;
        end
    endtask

    /*
     * Runs the common fetch/decode sequence and stops in the
     * instruction's first execute state.
     */
    task automatic fetch_decode(
        input logic [3:0] instruction_opcode,
        input logic [2:0] instruction_subcode,
        input logic [4:0] execute_state,
        input string instruction_name
    );
        begin
            @(negedge clk);

            opcode  = instruction_opcode;
            subcode = instruction_subcode;
            #1;

            expect_state(FETCH_MAR,
                         $sformatf("%s FETCH_MAR", instruction_name));

            check(pc_enable && mar_enable,
                  $sformatf("%s fetches PC into MAR", instruction_name));

            tick();
            expect_state(FETCH_MDR,
                         $sformatf("%s FETCH_MDR", instruction_name));

            check(mdr_enable,
                  $sformatf("%s loads MDR", instruction_name));

            tick();
            expect_state(FETCH_IR,
                         $sformatf("%s FETCH_IR", instruction_name));

            check(ir_enable,
                  $sformatf("%s loads IR", instruction_name));

            tick();
            expect_state(DECODE,
                         $sformatf("%s DECODE", instruction_name));

            tick();
            expect_state(
                execute_state,
                $sformatf("%s execute state", instruction_name)
            );
        end
    endtask

    // ============================================================
    // ALU tests
    // ============================================================

    task automatic test_add_register;
        begin
            $display("\n========== ADD REGISTER ==========");

            fetch_decode(OP_ADD, 3'b000, EXEC_ALU, "ADD");

            check(writeback_enable,
                  "ADD enables register writeback");

            check(!alu_b_select,
                  "ADD register form selects register operand B");

            tick();
            expect_state(FETCH_MAR, "ADD returns to fetch");
        end
    endtask

    task automatic test_add_immediate;
        begin
            $display("\n========== ADD IMMEDIATE ==========");

            fetch_decode(OP_ADD, 3'b001, EXEC_ALU, "ADDI");

            check(writeback_enable,
                  "ADDI enables register writeback");

            check(alu_b_select,
                  "ADDI selects immediate operand B");

            tick();
            expect_state(FETCH_MAR, "ADDI returns to fetch");
        end
    endtask

    task automatic test_and;
        begin
            $display("\n========== AND ==========");

            fetch_decode(OP_AND, 3'b000, EXEC_ALU, "AND");

            check(writeback_enable,
                  "AND enables register writeback");

            tick();
            expect_state(FETCH_MAR, "AND returns to fetch");
        end
    endtask

    task automatic test_shift;
        begin
            $display("\n========== SHIFT ==========");

            fetch_decode(OP_SHIFT, 3'b000, EXEC_ALU, "SHIFT");

            check(writeback_enable,
                  "SHIFT enables register writeback");

            check(alu_b_select,
                  "SHIFT selects immediate shift amount");

            tick();
            expect_state(FETCH_MAR, "SHIFT returns to fetch");
        end
    endtask

    // ============================================================
    // Compare tests
    // ============================================================

    task automatic test_cmp;
        begin
            $display("\n========== CMP ==========");

            fetch_decode(OP_CMP, 3'b000, EXEC_CMP, "CMP");

            check(flags_enable,
                  "CMP enables condition flags");

            check(!writeback_enable,
                  "CMP does not write a register");

            tick();
            expect_state(FETCH_MAR, "CMP returns to fetch");
        end
    endtask

    task automatic test_cmpi;
        begin
            $display("\n========== CMPI ==========");

            fetch_decode(OP_CMP, 3'b001, EXEC_CMP, "CMPI");

            check(flags_enable,
                  "CMPI enables condition flags");

            check(alu_b_select,
                  "CMPI selects immediate operand");

            tick();
            expect_state(FETCH_MAR, "CMPI returns to fetch");
        end
    endtask

    // ============================================================
    // Memory tests
    // ============================================================

    task automatic test_ld;
        begin
            $display("\n========== LD ==========");

            fetch_decode(OP_LD_ST, 3'b000, EXEC_MEM_ADDR, "LD");

            check(mar_enable,
                  "LD address state enables MAR");

            tick();
            expect_state(EXEC_MEM_READ, "LD memory read");

            check(mdr_enable,
                  "LD memory read enables MDR");

            tick();
            expect_state(EXEC_FINAL_LOAD, "LD final load");

            check(writeback_enable,
                  "LD writes MDR value to register");

            tick();
            expect_state(FETCH_MAR, "LD returns to fetch");
        end
    endtask

    task automatic test_st;
        begin
            $display("\n========== ST ==========");

            fetch_decode(OP_LD_ST, 3'b001, EXEC_MEM_ADDR, "ST");

            check(mar_enable,
                  "ST address state enables MAR");

            check(mdr_enable,
                  "ST address state loads source data into MDR");

            tick();
            expect_state(EXEC_FINAL_STORE, "ST final store");

            check(memory_write_enable,
                  "ST enables memory write");

            tick();
            expect_state(FETCH_MAR, "ST returns to fetch");
        end
    endtask

    task automatic test_ldr;
        begin
            $display("\n========== LDR ==========");

            fetch_decode(OP_LDRSTR, 3'b000, EXEC_MEM_ADDR, "LDR");

            check(mar_enable,
                  "LDR address state enables MAR");

            tick();
            expect_state(EXEC_MEM_READ, "LDR memory read");

            check(mdr_enable,
                  "LDR reads memory into MDR");

            tick();
            expect_state(EXEC_FINAL_LOAD, "LDR final load");

            check(writeback_enable,
                  "LDR writes result to register");

            tick();
            expect_state(FETCH_MAR, "LDR returns to fetch");
        end
    endtask

    task automatic test_str;
        begin
            $display("\n========== STR ==========");

            fetch_decode(OP_LDRSTR, 3'b001, EXEC_MEM_ADDR, "STR");

            check(mar_enable,
                  "STR address state enables MAR");

            check(mdr_enable,
                  "STR address state loads MDR");

            tick();
            expect_state(EXEC_FINAL_STORE, "STR final store");

            check(memory_write_enable,
                  "STR enables memory write");

            tick();
            expect_state(FETCH_MAR, "STR returns to fetch");
        end
    endtask

    task automatic test_ldi;
        begin
            $display("\n========== LDI ==========");

            fetch_decode(OP_LD_ST, 3'b010, EXEC_MEM_ADDR, "LDI");

            tick();
            expect_state(EXEC_MEM_READ, "LDI pointer read");

            check(mdr_enable,
                  "LDI reads pointer into MDR");

            tick();
            expect_state(EXEC_INDR_MAR, "LDI indirect MAR");

            check(mar_enable,
                  "LDI loads pointer into MAR");

            tick();
            expect_state(EXEC_INDR_READ, "LDI indirect read");

            check(mdr_enable,
                  "LDI reads final value into MDR");

            tick();
            expect_state(EXEC_FINAL_LOAD, "LDI final load");

            check(writeback_enable,
                  "LDI writes final value to register");

            tick();
            expect_state(FETCH_MAR, "LDI returns to fetch");
        end
    endtask

    task automatic test_sti;
        begin
            $display("\n========== STI ==========");

            fetch_decode(OP_LD_ST, 3'b011, EXEC_MEM_ADDR, "STI");

            tick();
            expect_state(EXEC_MEM_READ, "STI pointer read");

            check(mdr_enable,
                  "STI reads pointer into MDR");

            tick();
            expect_state(EXEC_INDR_MAR, "STI indirect MAR");

            check(mar_enable,
                  "STI loads destination pointer into MAR");

            check(mdr_enable,
                  "STI loads source register value into MDR");

            tick();
            expect_state(EXEC_FINAL_STORE, "STI final store");

            check(memory_write_enable,
                  "STI enables memory write");

            tick();
            expect_state(FETCH_MAR, "STI returns to fetch");
        end
    endtask

    // ============================================================
    // LI/LEA tests
    // ============================================================

    task automatic test_li;
        begin
            $display("\n========== LI ==========");

            fetch_decode(OP_LI_LEA, 3'b000, EXEC_LI, "LI");

            check(writeback_enable,
                "LI enables register writeback");

            check(writeback_select == 2'b10,
                "LI writes immediate extension");

            check(write_address_select == 1'b0,
                "LI writes destination register");

            check(extend_mode == 3'b100,
                "LI uses signed 8-bit immediate");

            tick();
            expect_state(FETCH_MAR, "LI returns to fetch");
        end
    endtask

    task automatic test_lea;
        begin
            $display("\n========== LEA ==========");

            fetch_decode(OP_LI_LEA, 3'b001, EXEC_LEA, "LEA");

            check(alu_a_select,
                "LEA selects PC");

            check(alu_b_select,
                "LEA selects extended immediate");

            check(alu_control_code == 4'b0000,
                "LEA performs ADD");

            check(writeback_enable,
                "LEA enables register writeback");

            check(writeback_select == 2'b00,
                "LEA writes ALU result");

            check(extend_mode == 3'b100,
                "LEA uses signed 8-bit immediate");

            tick();
            expect_state(FETCH_MAR, "LEA returns to fetch");
        end
    endtask

    // ============================================================
    // JUMP tests
    // ============================================================

    task automatic test_jal;
        begin
            $display("\n========== JAL ==========");

            fetch_decode(OP_JUMP, 3'b000, EXEC_JUMP, "JAL");

            check(alu_a_select,
                "JAL selects PC");

            check(alu_b_select,
                "JAL selects extended immediate");

            check(writeback_enable,
                "JAL enables link register write");

            check(writeback_select == 2'b11,
                "JAL writes current PC");

            check(write_address_select,
                "JAL writes R7");

            check(pc_enable,
                "JAL updates PC");

            check(pc_select,
                "JAL loads PC from ALU");

            check(extend_mode == 3'b110,
                "JAL uses signed 10-bit immediate");

            tick();
            expect_state(FETCH_MAR, "JAL returns to fetch");
        end
    endtask

    task automatic test_jmp;
        begin
            $display("\n========== JMP ==========");

            fetch_decode(OP_JUMP, 3'b001, EXEC_JUMP, "JMP");

            check(!alu_a_select,
                "JMP selects BaseR");

            check(alu_b_select,
                "JMP selects extended immediate");

            check(!writeback_enable,
                "JMP does not write R7");

            check(pc_enable,
                "JMP updates PC");

            check(pc_select,
                "JMP loads PC from ALU");

            check(extend_mode == 3'b011,
                "JMP uses signed 7-bit immediate");

            check(read_address1_select,
                "JMP selects BaseR field");

            tick();
            expect_state(FETCH_MAR, "JMP returns to fetch");
        end
    endtask

    task automatic test_jalr;
        begin
            $display("\n========== JALR ==========");

            fetch_decode(OP_JUMP, 3'b010, EXEC_JUMP, "JALR");

            check(!alu_a_select,
                "JALR selects BaseR");

            check(alu_b_select,
                "JALR selects extended immediate");

            check(writeback_enable,
                "JALR enables link register write");

            check(writeback_select == 2'b11,
                "JALR writes current PC");

            check(write_address_select,
                "JALR writes R7");

            check(pc_enable,
                "JALR updates PC");

            check(pc_select,
                "JALR loads PC from ALU");

            check(extend_mode == 3'b011,
                "JALR uses signed 7-bit immediate");

            check(read_address1_select,
                "JALR selects BaseR field");

            tick();
            expect_state(FETCH_MAR, "JALR returns to fetch");
        end
    endtask

    // ============================================================
    // Reserved opcode test
    // ============================================================

    task automatic test_reserved;
        begin
            $display("\n========== RESERVED OPCODE ==========");

            fetch_decode(
                OP_RESERVED,
                3'b000,
                EXEC_RESERVED,
                "RESERVED"
            );

            check(
                !pc_enable &&
                !mar_enable &&
                !mdr_enable &&
                !ir_enable &&
                !writeback_enable &&
                !memory_write_enable &&
                !flags_enable,
                "Reserved opcode does not enable datapath writes"
            );

            check(mar_select == 2'b00,
                "Reserved opcode leaves MAR select at default");

            check(mdr_select == 1'b0,
                "Reserved opcode leaves MDR select at default");

            check(writeback_select == 2'b00,
                "Reserved opcode leaves writeback select at default");

            tick();
            expect_state(
                FETCH_MAR,
                "Reserved opcode returns to fetch"
            );
        end
    endtask

    // ============================================================
    // BRANCH tests
    // ============================================================

    // ============================================================
    // Branch tests
    // LEG encoding:
    //   100 = Less
    //   010 = Equal
    //   001 = Greater
    // ============================================================

    task automatic test_branch_case(
        input logic [2:0] branch_mask,
        input logic [2:0] test_leg_flags,
        input logic       expected_taken,
        input string      test_name
    );
        begin
            leg_flags = test_leg_flags;

            fetch_decode(
                OP_BR,
                branch_mask,
                EXEC_BR,
                test_name
            );

            check(alu_a_select,
                $sformatf("%s selects PC as ALU operand A",
                            test_name));

            check(alu_b_select,
                $sformatf("%s selects immediate as ALU operand B",
                            test_name));

            check(alu_control_code == 4'b0000,
                $sformatf("%s performs ADD for target address",
                            test_name));

            check(extend_mode == 3'b101,
                $sformatf("%s uses signed 9-bit immediate",
                            test_name));

            check(pc_select,
                $sformatf("%s selects ALU result for PC",
                            test_name));

            check(pc_enable === expected_taken,
                $sformatf(
                    "%s decision: expected pc_enable=%b, got %b",
                    test_name,
                    expected_taken,
                    pc_enable
                ));

            check(!writeback_enable,
                $sformatf("%s does not write a register",
                            test_name));

            check(!memory_write_enable,
                $sformatf("%s does not write memory",
                            test_name));

            check(!flags_enable,
                $sformatf("%s does not modify LEG flags",
                            test_name));

            tick();
            expect_state(
                FETCH_MAR,
                $sformatf("%s returns to fetch", test_name)
            );
        end
    endtask

    task automatic test_branches;
        begin
            $display("\n========== BRANCH TESTS ==========");

            // ----------------------------------------------------
            // BEQ: Equal
            // Mask = 010
            // ----------------------------------------------------
            test_branch_case(
                3'b010,
                3'b010,
                1'b1,
                "BEQ taken when equal"
            );

            test_branch_case(
                3'b010,
                3'b100,
                1'b0,
                "BEQ not taken when less"
            );

            test_branch_case(
                3'b010,
                3'b001,
                1'b0,
                "BEQ not taken when greater"
            );

            // ----------------------------------------------------
            // BNE: Less or Greater
            // Mask = 101
            // ----------------------------------------------------
            test_branch_case(
                3'b101,
                3'b100,
                1'b1,
                "BNE taken when less"
            );

            test_branch_case(
                3'b101,
                3'b001,
                1'b1,
                "BNE taken when greater"
            );

            test_branch_case(
                3'b101,
                3'b010,
                1'b0,
                "BNE not taken when equal"
            );

            // ----------------------------------------------------
            // BLT: Less
            // Mask = 100
            // ----------------------------------------------------
            test_branch_case(
                3'b100,
                3'b100,
                1'b1,
                "BLT taken when less"
            );

            test_branch_case(
                3'b100,
                3'b010,
                1'b0,
                "BLT not taken when equal"
            );

            test_branch_case(
                3'b100,
                3'b001,
                1'b0,
                "BLT not taken when greater"
            );

            // ----------------------------------------------------
            // BGT: Greater
            // Mask = 001
            // ----------------------------------------------------
            test_branch_case(
                3'b001,
                3'b001,
                1'b1,
                "BGT taken when greater"
            );

            test_branch_case(
                3'b001,
                3'b010,
                1'b0,
                "BGT not taken when equal"
            );

            test_branch_case(
                3'b001,
                3'b100,
                1'b0,
                "BGT not taken when less"
            );

            // ----------------------------------------------------
            // BLE: Less or Equal
            // Mask = 110
            // ----------------------------------------------------
            test_branch_case(
                3'b110,
                3'b100,
                1'b1,
                "BLE taken when less"
            );

            test_branch_case(
                3'b110,
                3'b010,
                1'b1,
                "BLE taken when equal"
            );

            test_branch_case(
                3'b110,
                3'b001,
                1'b0,
                "BLE not taken when greater"
            );

            // ----------------------------------------------------
            // BGE: Equal or Greater
            // Mask = 011
            // ----------------------------------------------------
            test_branch_case(
                3'b011,
                3'b010,
                1'b1,
                "BGE taken when equal"
            );

            test_branch_case(
                3'b011,
                3'b001,
                1'b1,
                "BGE taken when greater"
            );

            test_branch_case(
                3'b011,
                3'b100,
                1'b0,
                "BGE not taken when less"
            );

            // ----------------------------------------------------
            // BR: unconditional
            // Mask = 111
            // It must work even when LEG flags are cleared.
            // ----------------------------------------------------
            test_branch_case(
                3'b111,
                3'b000,
                1'b1,
                "BR unconditional with cleared flags"
            );

            // Also verify unconditional BR with normal flags.
            test_branch_case(
                3'b111,
                3'b010,
                1'b1,
                "BR unconditional with equal flag"
            );

            // ----------------------------------------------------
            // Empty condition mask
            // Mask = 000 should never branch.
            // ----------------------------------------------------
            test_branch_case(
                3'b000,
                3'b100,
                1'b0,
                "BR mask 000 not taken"
            );
        end
    endtask

    // ============================================================
    // System tests
    // ============================================================

    task automatic test_nop;
        begin
            $display("\n========== NOP ==========");

            fetch_decode(OP_SYSTEM, 3'b000, EXEC_SYSTEM, "NOP");

            check(
                !pc_enable &&
                !mar_enable &&
                !mdr_enable &&
                !ir_enable &&
                !writeback_enable &&
                !memory_write_enable &&
                !flags_enable,
                "NOP does not enable datapath writes"
            );

            tick();
            expect_state(FETCH_MAR, "NOP returns to fetch");
        end
    endtask

    task automatic test_halt;
        begin
            $display("\n========== HALT ==========");

            fetch_decode(OP_SYSTEM, 3'b011, EXEC_SYSTEM, "HALT");

            tick();
            expect_state(HALT_STATE, "HALT state");

            check(
                !pc_enable &&
                !mar_enable &&
                !mdr_enable &&
                !ir_enable &&
                !writeback_enable &&
                !memory_write_enable &&
                !flags_enable,
                "HALT disables datapath writes"
            );

            tick();
            expect_state(HALT_STATE, "HALT remains halted");
        end
    endtask

    // ============================================================
    // Main test sequence
    // ============================================================

    initial begin
        reset   = 1'b0;
        opcode  = OP_ADD;
        subcode = 3'b000;
        leg_flags = 3'b000;

        $dumpfile("cpu.vcd");
        $dumpvars(0, testbench);

        $display("========================================");
        $display("SHORT CONTROL UNIT TESTBENCH");
        $display("========================================");

        reset_dut();

        test_add_register();
        test_add_immediate();
        test_and();
        test_shift();

        test_cmp();
        test_cmpi();

        test_ld();
        test_st();
        test_ldr();
        test_str();
        test_ldi();
        test_sti();

        test_li();
        test_lea();

        test_jal();
        test_jmp();
        test_jalr();

        test_reserved();
        test_branches();

        test_nop();

        // HALT must be last because it stays in HALT until reset.
        test_halt();

        $display("\n========================================");
        $display("TEST RESULTS");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("========================================");

        if (failed == 0)
            $display("ALL TESTS PASSED");
        else
            $fatal(1, "%0d tests failed", failed);

        $finish;
    end

endmodule
