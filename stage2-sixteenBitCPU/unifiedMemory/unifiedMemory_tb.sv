`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;
    reg [15:0] store_data;
    reg [15:0] address;
    reg mdr_enable;
    reg mdr_select;
    reg memory_write_enable;

    wire [15:0] mdr_data;

    integer errors;

    unifiedMemory #(
        .MEMORY_DEPTH(256),
        .MEMORY_FILE("")
    ) dut (
        .mdr_data(mdr_data),
        .store_data(store_data),
        .address(address),
        .mdr_enable(mdr_enable),
        .mdr_select(mdr_select),
        .mdr_reset(reset),
        .clk(clk),
        .memory_write_enable(memory_write_enable)
    );

    always #5 clk = ~clk;

    task clock_cycle;
    begin
        @(posedge clk);
        #1;
    end
    endtask

    task check_mdr;
        input [15:0] expected;
        input [127:0] name;
    begin
        if (mdr_data !== expected) begin
            $display("FAIL: %s Expected=%h Got=%h",
                     name, expected, mdr_data);
            errors = errors + 1;
        end
        else
            $display("PASS: %s", name);
    end
    endtask

    task check_memory;
        input [15:0] addr;
        input [15:0] expected;
        input [127:0] name;
    begin
        if (dut.memory[addr] !== expected) begin
            $display("FAIL: %s Expected=%h Got=%h",
                     name, expected, dut.memory[addr]);
            errors = errors + 1;
        end
        else
            $display("PASS: %s", name);
    end
    endtask

    initial begin

        clk = 0;
        reset = 0;
        store_data = 0;
        address = 0;
        mdr_enable = 0;
        mdr_select = 0;
        memory_write_enable = 0;
        errors = 0;

        dut.memory[16'h0010] = 16'h1234;
        dut.memory[16'h0020] = 16'hABCD;
        dut.memory[16'h0030] = 16'h5678;

        //---------------------------------
        // Reset
        //---------------------------------

        reset = 1;
        clock_cycle();

        check_mdr(16'h0000, "Reset clears MDR");
        check_memory(16'h0010, 16'h1234,
                     "Reset preserves memory");

        reset = 0;

        //---------------------------------
        // Load MDR from memory
        //---------------------------------

        address = 16'h0010;
        mdr_select = 0;
        mdr_enable = 1;

        clock_cycle();

        check_mdr(16'h1234,
                  "Load MDR from memory");

        mdr_enable = 0;

        //---------------------------------
        // Load MDR from store_data
        //---------------------------------

        store_data = 16'hBEEF;
        mdr_select = 1;
        mdr_enable = 1;

        clock_cycle();

        check_mdr(16'hBEEF,
                  "Load MDR from store_data");

        mdr_enable = 0;

        //---------------------------------
        // Write MDR into memory
        //---------------------------------

        address = 16'h0040;
        memory_write_enable = 1;

        clock_cycle();

        check_memory(16'h0040,
                     16'hBEEF,
                     "Write MDR into memory");

        check_mdr(16'hBEEF,
                  "MDR unchanged after write");

        memory_write_enable = 0;

        //---------------------------------
        // Read it back
        //---------------------------------

        address = 16'h0040;
        mdr_select = 0;
        mdr_enable = 1;

        clock_cycle();

        check_mdr(16'hBEEF,
                  "Read back stored value");

        mdr_enable = 0;

        //---------------------------------
        // Write has priority
        //---------------------------------

        store_data = 16'hCAFE;
        mdr_select = 1;
        mdr_enable = 1;

        clock_cycle();

        check_mdr(16'hCAFE,
                  "Prepare priority test");

        address = 16'h0050;
        store_data = 16'h1111;
        memory_write_enable = 1;
        mdr_enable = 1;
        mdr_select = 1;

        clock_cycle();

        check_memory(16'h0050,
                     16'hCAFE,
                     "Write priority");

        check_mdr(16'hCAFE,
                  "MDR unchanged during write");

        memory_write_enable = 0;
        mdr_enable = 0;

        //---------------------------------
        // Hold state
        //---------------------------------

        clock_cycle();

        check_mdr(16'hCAFE,
                  "Hold MDR");

        check_memory(16'h0030,
                     16'h5678,
                     "Hold memory");

        //---------------------------------
        // Final reset
        //---------------------------------

        reset = 1;
        clock_cycle();

        check_mdr(16'h0000,
                  "Reset again");

        check_memory(16'h0040,
                     16'hBEEF,
                     "Memory still intact");

        if (errors == 0)
            $display("\nALL TESTS PASSED");
        else
            $display("\n%d TESTS FAILED", errors);

        $finish;

    end

endmodule
