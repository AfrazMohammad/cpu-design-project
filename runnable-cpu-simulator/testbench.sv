`timescale 1ns/1ps

module cpu16bit_tb;

    localparam integer CLOCK_PERIOD_NS      = 10;
    localparam integer MAX_CYCLES           = 1000;
    localparam integer MAX_MEM_WRITES       = 16;
    localparam integer MAX_TOTAL_MEM_WRITES = 256;

    localparam [4:0] FETCH_IR  = 5'h02;
    localparam [4:0] FETCH_MAR = 5'h00;
    localparam [4:0] HALT      = 5'h1F;

    reg clk;
    reg reset;

    integer cycle_count;
    integer instruction_count;
    integer modified_count;
    integer final_count;
    integer total_memory_writes;

    integer i;
    integer search_index;
    integer existing_index;

    reg instruction_started;

    // Memory modified by the current instruction
    reg [15:0] modified_address [0:MAX_MEM_WRITES-1];
    reg [15:0] modified_value   [0:MAX_MEM_WRITES-1];

    // Memory modified during the entire program
    reg [15:0] final_address [0:MAX_TOTAL_MEM_WRITES-1];
    reg [15:0] final_value   [0:MAX_TOTAL_MEM_WRITES-1];


    // ============================================================
    // CPU
    // ============================================================

    cpu16bit #(
        .MEMORY_DEPTH(65536),
        .RESET_PC(16'h0000)
    ) uut (
        .clk(clk),
        .reset(reset)
    );


    // ============================================================
    // Clock
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #(CLOCK_PERIOD_NS / 2)
            clk = ~clk;
    end


    // ============================================================
    // Instruction name
    // ============================================================

    function automatic [8*12-1:0] instruction_name;
        input [15:0] instruction;

        begin
            case (instruction[15:12])

                // Arithmetic and logic:
                // bit 5 selects register or immediate format.
                4'h0: instruction_name = instruction[5] ? "ADDI" : "ADD";
                4'h1: instruction_name = instruction[5] ? "SUBI" : "SUB";
                4'h2: instruction_name = instruction[5] ? "MULI" : "MUL";
                4'h3: instruction_name = instruction[5] ? "ANDI" : "AND";
                4'h4: instruction_name = instruction[5] ? "ORI"  : "OR";
                4'h5: instruction_name = instruction[5] ? "XORI" : "XOR";

                4'h6: instruction_name = "NOT";

                // Shift function is instruction[5:4].
                4'h7: begin
                    case (instruction[5:4])
                        2'b00: instruction_name = "SHL";
                        2'b01: instruction_name = "SHR";
                        2'b10: instruction_name = "SHA";
                        2'b11: instruction_name = "ROR";
                    endcase
                end

                // Memory mode is instruction[8:7].
                4'h8: begin
                    case (instruction[8:7])
                        2'b00: instruction_name = "LD";
                        2'b01: instruction_name = "ST";
                        2'b10: instruction_name = "LDI";
                        2'b11: instruction_name = "STI";
                    endcase
                end

                // Direction bit is instruction[8].
                4'h9: begin
                    case (instruction[8])
                        1'b0: instruction_name = "LDR";
                        1'b1: instruction_name = "STR";
                    endcase
                end

                // Mode bit is instruction[8].
                4'hA: begin
                    case (instruction[8])
                        1'b0: instruction_name = "LI";
                        1'b1: instruction_name = "LEA";
                    endcase
                end

                // Jump mode is instruction[11:10].
                4'hB: begin
                    case (instruction[11:10])
                        2'b00: instruction_name = "JAL";
                        2'b01: instruction_name = "JMP";
                        2'b10: instruction_name = "JALR";
                        2'b11: instruction_name = "RESERVED";
                    endcase
                end

                4'hC: instruction_name = "RESERVED";

                // Compare mode is instruction[8].
                4'hD: begin
                    case (instruction[8])
                        1'b0: instruction_name = "CMP";
                        1'b1: instruction_name = "CMPI";
                    endcase
                end

                // Branch condition is instruction[11:9].
                4'hE: begin
                    case (instruction[11:9])
                        3'b000: instruction_name = "RESERVED";
                        3'b001: instruction_name = "BGT";
                        3'b010: instruction_name = "BEQ";
                        3'b011: instruction_name = "BGE";
                        3'b100: instruction_name = "BLT";
                        3'b101: instruction_name = "BNE";
                        3'b110: instruction_name = "BLE";
                        3'b111: instruction_name = "BR";
                    endcase
                end

                // System mode is instruction[11:10].
                4'hF: begin
                    case (instruction[11:10])
                        2'b00: instruction_name = "NOP";
                        2'b11: instruction_name = "HALT";
                        default: instruction_name = "RESERVED";
                    endcase
                end

                default:
                    instruction_name = "UNKNOWN";

            endcase
        end
    endfunction


    // ============================================================
    // Register display
    // ============================================================

    task automatic display_registers;
        begin
            $display("Registers");
            $display("--------------------------------");

            $display(
                "R0:%04h  R1:%04h  R2:%04h  R3:%04h",
                uut.cpuRF.r0,
                uut.cpuRF.r1,
                uut.cpuRF.r2,
                uut.cpuRF.r3
            );

            $display(
                "R4:%04h  R5:%04h  R6:%04h  R7:%04h",
                uut.cpuRF.r4,
                uut.cpuRF.r5,
                uut.cpuRF.r6,
                uut.cpuRF.r7
            );
        end
    endtask


    // ============================================================
    // Memory updates for the current instruction
    // ============================================================

    task automatic display_instruction_memory;
        begin
            $display("");
            $display("Memory Updated");
            $display("--------------------------------");

            if (modified_count == 0) begin
                $display("None");
            end
            else begin
                for (i = 0; i < modified_count; i = i + 1) begin
                    $display(
                        "MEM[%04h] = %04h",
                        modified_address[i],
                        modified_value[i]
                    );
                end
            end
        end
    endtask


    // ============================================================
    // All memory updated during the program
    // ============================================================

    task automatic display_final_memory;
        begin
            $display("");
            $display("Memory Updated");
            $display("--------------------------------");

            if (final_count == 0) begin
                $display("None");
            end
            else begin
                for (i = 0; i < final_count; i = i + 1) begin
                    $display(
                        "MEM[%04h] = %04h",
                        final_address[i],
                        final_value[i]
                    );
                end
            end
        end
    endtask


    // ============================================================
    // Completed instruction display
    // ============================================================

    task automatic display_instruction;
        begin
            $display("");
            $display("");
            $display("================================");
            $display(
                "Instruction %0d: %0s",
                instruction_count,
                instruction_name(uut.instruction)
            );
            $display("================================");

            $display("IR      = %04h", uut.instruction);
            $display("Next PC = %04h", uut.pc);
            $display("Flags   = %03b", uut.leg_flags);

            $display("");
            display_registers();

            display_instruction_memory();

            $display("================================");
            $display("");
        end
    endtask


    // ============================================================
    // Final summary
    // ============================================================

    task automatic display_final_summary;
        begin
            $display("");
            $display("");
            $display("################################");
            $display("#        FINAL CPU STATE       #");
            $display("################################");

            $display("");
            $display(
                "Instructions executed = %0d",
                instruction_count
            );
            $display(
                "Cycles executed       = %0d",
                cycle_count
            );
            $display(
                "Total memory writes   = %0d",
                total_memory_writes
            );

            $display("");
            $display("PC    = %04h", uut.pc);
            $display("IR    = %04h", uut.instruction);
            $display("MAR   = %04h", uut.mar);
            $display("MDR   = %04h", uut.mdr_data);
            $display("Flags = %03b", uut.leg_flags);

            $display("");
            display_registers();

            display_final_memory();

            $display("");
            $display("################################");
            $display("# TEST COMPLETED SUCCESSFULLY  #");
            $display("################################");
            $display("");
        end
    endtask


    // ============================================================
    // Cycle counting and memory-write tracking
    // ============================================================

    always @(posedge clk) begin
        if (reset) begin
            cycle_count         = 0;
            modified_count      = 0;
            final_count         = 0;
            total_memory_writes = 0;
        end
        else begin
            cycle_count = cycle_count + 1;

            if (uut.memory_write_enable) begin
                total_memory_writes = total_memory_writes + 1;


                // ------------------------------------------------
                // Track memory updated by this instruction
                // ------------------------------------------------

                existing_index = -1;

                for (
                    search_index = 0;
                    search_index < modified_count;
                    search_index = search_index + 1
                ) begin
                    if (
                        modified_address[search_index] == uut.mar
                    ) begin
                        existing_index = search_index;
                    end
                end

                if (existing_index >= 0) begin
                    modified_value[existing_index] = uut.mdr_data;
                end
                else if (modified_count < MAX_MEM_WRITES) begin
                    modified_address[modified_count] = uut.mar;
                    modified_value[modified_count]   = uut.mdr_data;
                    modified_count = modified_count + 1;
                end
                else begin
                    $display(
                        "WARNING: Increase MAX_MEM_WRITES above %0d.",
                        MAX_MEM_WRITES
                    );
                end


                // ------------------------------------------------
                // Track all memory updated by the entire program
                // ------------------------------------------------

                existing_index = -1;

                for (
                    search_index = 0;
                    search_index < final_count;
                    search_index = search_index + 1
                ) begin
                    if (
                        final_address[search_index] == uut.mar
                    ) begin
                        existing_index = search_index;
                    end
                end

                if (existing_index >= 0) begin
                    final_value[existing_index] = uut.mdr_data;
                end
                else if (
                    final_count < MAX_TOTAL_MEM_WRITES
                ) begin
                    final_address[final_count] = uut.mar;
                    final_value[final_count]   = uut.mdr_data;
                    final_count = final_count + 1;
                end
                else begin
                    $display(
                        "WARNING: Increase MAX_TOTAL_MEM_WRITES above %0d.",
                        MAX_TOTAL_MEM_WRITES
                    );
                end
            end
        end
    end


    // ============================================================
    // Print once per completed instruction
    // ============================================================

    always @(negedge clk) begin
        if (!reset) begin

            /*
             * FETCH_IR confirms that an instruction has begun.
             * This prevents the initial FETCH_MAR after reset from
             * being printed as a completed instruction.
             */
            if (
                uut.cpuControlUnit.current_state == FETCH_IR
            ) begin
                instruction_started = 1'b1;
            end


            /*
             * Normal instructions finish by returning to FETCH_MAR.
             * At this point, IR still contains the instruction that
             * just completed.
             */
            if (
                uut.cpuControlUnit.current_state == FETCH_MAR &&
                instruction_started
            ) begin
                instruction_count = instruction_count + 1;

                display_instruction();

                instruction_started = 1'b0;
                modified_count      = 0;
            end


            /*
             * HALT stays in the HALT state instead of returning to
             * FETCH_MAR, so it must be printed separately.
             */
            if (
                uut.cpuControlUnit.current_state == HALT &&
                instruction_started
            ) begin
                instruction_count = instruction_count + 1;

                display_instruction();
                display_final_summary();

                $finish;
            end


            // Prevent runaway simulations.
            if (cycle_count >= MAX_CYCLES) begin
                $display("");
                $display("################################");
                $display("#         TEST FAILED          #");
                $display("################################");
                $display(
                    "CPU did not reach HALT within %0d cycles.",
                    MAX_CYCLES
                );
                $display("");

                $fatal;
            end
        end
    end


    // ============================================================
    // Initialization
    // ============================================================

    initial begin
        reset               = 1'b1;
        cycle_count         = 0;
        instruction_count   = 0;
        modified_count      = 0;
        final_count         = 0;
        total_memory_writes = 0;
        instruction_started = 1'b0;

        $dumpfile("cpu16bit_tb.vcd");
        $dumpvars(0, cpu16bit_tb);

        $display("");
        $display("################################");
        $display("#  STARTING CPU PROGRAM TEST   #");
        $display("################################");
        $display("");

        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 1'b0;
    end

endmodule
