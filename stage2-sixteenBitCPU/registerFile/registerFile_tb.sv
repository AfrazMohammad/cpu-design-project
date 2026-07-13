`timescale 1ns/1ps

module testbench;

    reg  [2:0]  read_address1;
    reg  [2:0]  read_address2;
    reg  [2:0]  write_address;
    reg  [15:0] write_data;

    reg clk;
    reg reset;
    reg write_enable;

    wire [15:0] read_data1;
    wire [15:0] read_data2;

    integer errors;

    registerFile dut(
        .read_data1(read_data1),
        .read_data2(read_data2),

        .read_address1(read_address1),
        .read_address2(read_address2),

        .write_address(write_address),
        .write_data(write_data),

        .clk(clk),
        .reset(reset),
        .write_enable(write_enable)
    );

    // 10 ns clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Helpful waveform output
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
    end

    // Write one register and wait for the clock edge
    task write_register;
        input [2:0] address;
        input [15:0] value;

        begin
            write_address = address;
            write_data = value;
            write_enable = 1;

            @(posedge clk);
            #1;

            write_enable = 0;
        end
    endtask

    // Check both read ports
    task check_reads;
        input [2:0] address1;
        input [15:0] expected1;

        input [2:0] address2;
        input [15:0] expected2;

        begin
            read_address1 = address1;
            read_address2 = address2;

            // Reads are combinational, so no clock is needed
            #1;

            if (read_data1 !== expected1) begin
                $display(
                    "FAIL: Port 1 R%0d expected %h, got %h",
                    address1, expected1, read_data1
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: Port 1 R%0d = %h",
                    address1, read_data1
                );
            end

            if (read_data2 !== expected2) begin
                $display(
                    "FAIL: Port 2 R%0d expected %h, got %h",
                    address2, expected2, read_data2
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: Port 2 R%0d = %h",
                    address2, read_data2
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        read_address1 = 3'b000;
        read_address2 = 3'b000;
        write_address = 3'b000;
        write_data = 16'h0000;

        reset = 0;
        write_enable = 0;

        // ---------------------------------
        // Test 1: Reset all registers
        // ---------------------------------
        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        check_reads(3'b000, 16'h0000, 3'b001, 16'h0000);
        check_reads(3'b010, 16'h0000, 3'b011, 16'h0000);
        check_reads(3'b100, 16'h0000, 3'b101, 16'h0000);
        check_reads(3'b110, 16'h0000, 3'b111, 16'h0000);

        // ---------------------------------
        // Test 2: Write all eight registers
        // ---------------------------------
        write_register(3'b000, 16'h0001);
        write_register(3'b001, 16'h0011);
        write_register(3'b010, 16'h0022);
        write_register(3'b011, 16'h0033);
        write_register(3'b100, 16'h0044);
        write_register(3'b101, 16'h0055);
        write_register(3'b110, 16'h0066);
        write_register(3'b111, 16'h0077);

        // ---------------------------------
        // Test 3: Read two registers at once
        // ---------------------------------
        check_reads(3'b000, 16'h0001, 3'b111, 16'h0077);
        check_reads(3'b001, 16'h0011, 3'b110, 16'h0066);
        check_reads(3'b010, 16'h0022, 3'b101, 16'h0055);
        check_reads(3'b011, 16'h0033, 3'b100, 16'h0044);

        // ---------------------------------
        // Test 4: Read same register twice
        // ---------------------------------
        check_reads(3'b101, 16'h0055, 3'b101, 16'h0055);

        // ---------------------------------
        // Test 5: Disabled write must not change data
        // ---------------------------------
        write_address = 3'b011;
        write_data = 16'hFFFF;
        write_enable = 0;

        @(posedge clk);
        #1;

        check_reads(3'b011, 16'h0033, 3'b000, 16'h0001);

        // ---------------------------------
        // Test 6: Reset overrides write
        // ---------------------------------
        write_address = 3'b100;
        write_data = 16'hABCD;
        write_enable = 1;
        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;
        write_enable = 0;

        check_reads(3'b000, 16'h0000, 3'b001, 16'h0000);
        check_reads(3'b010, 16'h0000, 3'b011, 16'h0000);
        check_reads(3'b100, 16'h0000, 3'b101, 16'h0000);
        check_reads(3'b110, 16'h0000, 3'b111, 16'h0000);

        // ---------------------------------
        // Final result
        // ---------------------------------
        $display("");

        if (errors == 0)
            $display("ALL REGISTER FILE TESTS PASSED");
        else
            $display("%0d REGISTER FILE TESTS FAILED", errors);

        $finish;
    end

endmodule
