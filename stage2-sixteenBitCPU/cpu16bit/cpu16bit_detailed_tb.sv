`timescale 1ns/1ps

module cpu16bit_tb;

    localparam integer CLOCK_PERIOD_NS = 10;
    localparam integer MAX_CYCLES      = 200;
    localparam integer MAX_MEM_WRITES  = 256;

    localparam [4:0] FETCH_MAR = 5'h00;
    localparam [4:0] HALT      = 5'h1F;

    reg clk;
    reg reset;

    integer cycle_count;
    integer i;
    integer search_index;
    integer existing_index;

    reg [4:0] executed_state;

    reg [15:0] modified_address [0:MAX_MEM_WRITES-1];
    reg [15:0] modified_value   [0:MAX_MEM_WRITES-1];
    integer modified_count;

    cpu16bit #(
        .MEMORY_DEPTH(65536),
        .RESET_PC(16'h0000)
    ) uut (
        .clk(clk),
        .reset(reset)
    );

    initial clk = 1'b0;

    always #(CLOCK_PERIOD_NS / 2)
        clk = ~clk;

    function automatic [8*18-1:0] state_name;
        input [4:0] state;
        begin
            case (state)
                5'h00: state_name = "FETCH_MAR";
                5'h01: state_name = "FETCH_MDR";
                5'h02: state_name = "FETCH_IR";
                5'h03: state_name = "DECODE";
                5'h04: state_name = "EXEC_ALU";
                5'h05: state_name = "EXEC_MEM_ADDR";
                5'h06: state_name = "EXEC_MEM_READ";
                5'h07: state_name = "EXEC_INDR_MAR";
                5'h08: state_name = "EXEC_INDR_READ";
                5'h09: state_name = "EXEC_FINAL_LOAD";
                5'h0A: state_name = "EXEC_FINAL_STORE";
                5'h0B: state_name = "EXEC_LI";
                5'h0C: state_name = "EXEC_LEA";
                5'h0D: state_name = "EXEC_JUMP";
                5'h0E: state_name = "EXEC_RESERVED";
                5'h0F: state_name = "EXEC_CMP";
                5'h10: state_name = "EXEC_BR";
                5'h11: state_name = "EXEC_SYSTEM";
                5'h1F: state_name = "HALT";
                default: state_name = "UNKNOWN";
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            cycle_count    = 0;
            executed_state = FETCH_MAR;
        end
        else begin
            cycle_count    = cycle_count + 1;
            executed_state = uut.cpuControlUnit.current_state;

            if (uut.writeback_enable) begin
                $display(
                    "[Cycle %0d] REGISTER WRITE: R%0d <= %04h",
                    cycle_count,
                    uut.writeback_address,
                    uut.writeback_data
                );
            end

            if (uut.memory_write_enable) begin
                $display(
                    "[Cycle %0d] MEMORY WRITE: MEM[%04h] <= %04h",
                    cycle_count,
                    uut.mar,
                    uut.mdr_data
                );

                existing_index = -1;

                for (
                    search_index = 0;
                    search_index < modified_count;
                    search_index = search_index + 1
                ) begin
                    if (modified_address[search_index] == uut.mar)
                        existing_index = search_index;
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
                    $display("WARNING: Increase MAX_MEM_WRITES.");
                end
            end
        end
    end

    task automatic display_registers;
        begin
            $display("Registers");
            $display("------------------------------------------------------------");
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

    task automatic display_cycle_state;
        begin
            $display("");
            $display("============================================================");
            $display(
                "Cycle %0d | Executed state: %0s (0x%02h)",
                cycle_count,
                state_name(executed_state),
                executed_state
            );
            $display("------------------------------------------------------------");
            $display(
                "PC:%04h  IR:%04h  MAR:%04h  MDR:%04h",
                uut.pc,
                uut.instruction,
                uut.mar,
                uut.mdr_data
            );
            $display(
                "ALU:%04h  A:%04h  B:%04h  LEG:%03b",
                uut.alu_result,
                uut.alu_a_data,
                uut.alu_b_data,
                uut.leg_flags
            );
            $display(
                "Next controller state: %0s (0x%02h)",
                state_name(uut.cpuControlUnit.current_state),
                uut.cpuControlUnit.current_state
            );
            $display("");
            display_registers();
            $display("============================================================");
        end
    endtask

    task automatic display_modified_memory;
        begin
            $display("");
            $display("Modified Memory Locations");
            $display("------------------------------------------------------------");

            if (modified_count == 0) begin
                $display("No memory locations were modified.");
            end
            else begin
                for (i = 0; i < modified_count; i = i + 1) begin
                    $display(
                        "MEM[%04h] = %04h",
                        modified_address[i],
                        uut.cpuUM.memory[modified_address[i]]
                    );
                end
            end
        end
    endtask

    task automatic display_final_summary;
        begin
            $display("");
            $display("############################################################");
            $display("#                    FINAL CPU STATE                       #");
            $display("############################################################");
            $display("Total executed cycles: %0d", cycle_count);
            $display("PC    = %04h", uut.pc);
            $display("IR    = %04h", uut.instruction);
            $display("MAR   = %04h", uut.mar);
            $display("MDR   = %04h", uut.mdr_data);
            $display("Flags = %03b", uut.leg_flags);
            $display("");
            display_registers();
            display_modified_memory();
            $display("############################################################");
            $display("");
        end
    endtask

    always @(negedge clk) begin
        if (!reset) begin
            display_cycle_state();

            if (uut.cpuControlUnit.current_state == HALT) begin
                display_final_summary();
                $display("HALT reached. Test completed successfully.");
                $finish;
            end

            if (cycle_count >= MAX_CYCLES) begin
                display_final_summary();
                $display(
                    "ERROR: CPU did not reach HALT within %0d cycles.",
                    MAX_CYCLES
                );
                $fatal;
            end
        end
    end

    initial begin
        cycle_count    = 0;
        modified_count = 0;
        executed_state = FETCH_MAR;
        reset          = 1'b1;

        $dumpfile("cpu16bit_tb.vcd");
        $dumpvars(0, cpu16bit_tb);

        $display("");
        $display("############################################################");
        $display("#              STARTING CPU PROGRAM TEST                   #");
        $display("############################################################");
        $display("");
        $display("The testbench will run until HALT or %0d cycles.", MAX_CYCLES);
        $display("");

        /*
         * Example program to initialize inside unifiedMemory:
         *
         * initial begin
         *     memory[16'h0000] = 16'hA005; // LI R0, #5
         *     memory[16'h0001] = 16'hF400; // HALT
         * end
         */

        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 1'b0;
    end

endmodule
