`timescale 1ns/1ps

module testbench;

    reg clk;
    reg write_enable;

    reg [15:0] address;
    reg [15:0] write_data;

    wire [15:0] read_data;

    integer errors;

    unifiedMemory #(
        .MEMORY_DEPTH(16),
        .MEMORY_FILE("")
    ) dut (
        .read_data(read_data),
        .write_data(write_data),
        .address(address),
        .clk(clk),
        .write_enable(write_enable)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task write_memory;
        input [15:0] input_address;
        input [15:0] input_data;

        begin
            address = input_address;
            write_data = input_data;
            write_enable = 1;

            @(posedge clk);
            #1;

            write_enable = 0;
        end
    endtask

    task read_and_check;
        input [15:0] input_address;
        input [15:0] expected;
        input [127:0] test_name;

        begin
            address = input_address;
            write_enable = 0;

            @(posedge clk);
            #1;

            if (read_data !== expected) begin
                $display(
                    "FAIL: %s | address=%0d expected=%h got=%h",
                    test_name,
                    input_address,
                    expected,
                    read_data
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %s | address=%0d data=%h",
                    test_name,
                    input_address,
                    read_data
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        address = 16'h0000;
        write_data = 16'h0000;
        write_enable = 0;

        // ---------------------------------
        // Test 1: Write values
        // ---------------------------------

        write_memory(16'd0, 16'h1234);
        write_memory(16'd1, 16'hABCD);
        write_memory(16'd2, 16'hFFFF);
        write_memory(16'd15, 16'h0055);

        // ---------------------------------
        // Test 2: Read values
        // ---------------------------------

        read_and_check(
            16'd0,
            16'h1234,
            "Read address 0"
        );

        read_and_check(
            16'd1,
            16'hABCD,
            "Read address 1"
        );

        read_and_check(
            16'd2,
            16'hFFFF,
            "Read address 2"
        );

        read_and_check(
            16'd15,
            16'h0055,
            "Read address 15"
        );

        // ---------------------------------
        // Test 3: Overwrite a location
        // ---------------------------------

        write_memory(16'd1, 16'h7777);

        read_and_check(
            16'd1,
            16'h7777,
            "Overwrite address 1"
        );

        // ---------------------------------
        // Test 4: read_data holds during write
        // ---------------------------------

        address = 16'd0;
        write_enable = 0;

        @(posedge clk);
        #1;

        if (read_data !== 16'h1234) begin
            $display(
                "FAIL: Initial hold setup expected 1234, got %h",
                read_data
            );
            errors = errors + 1;
        end

        address = 16'd3;
        write_data = 16'hBEEF;
        write_enable = 1;

        @(posedge clk);
        #1;

        if (read_data !== 16'h1234) begin
            $display(
                "FAIL: read_data changed during write, got %h",
                read_data
            );
            errors = errors + 1;
        end
        else begin
            $display(
                "PASS: read_data held previous value during write"
            );
        end

        write_enable = 0;

        read_and_check(
            16'd3,
            16'hBEEF,
            "Read newly written address 3"
        );

        // ---------------------------------
        // Final result
        // ---------------------------------

        $display("");

        if (errors == 0)
            $display("ALL UNIFIED MEMORY TESTS PASSED");
        else
            $display("%0d UNIFIED MEMORY TESTS FAILED", errors);

        $finish;
    end

endmodule
