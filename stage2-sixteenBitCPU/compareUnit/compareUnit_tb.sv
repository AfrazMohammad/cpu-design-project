`timescale 1ns/1ps

module testbench;

    reg [15:0] a;
    reg [15:0] b;

    reg clk;
    reg reset;
    reg enable;

    wire [2:0] next_leg_flags;
    wire [2:0] leg_flags;

    integer errors;

    compareUnit comparator(
        .next_leg_flags(next_leg_flags),
        .a(a),
        .b(b)
    );

    flagsRegister flags_reg(
        .leg_flags(leg_flags),
        .next_leg_flags(next_leg_flags),
        .clk(clk),
        .reset(reset),
        .enable(enable)
    );

    // 10 ns clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check_next_flags;
        input [15:0] input_a;
        input [15:0] input_b;
        input [2:0] expected;
        input [127:0] test_name;

        begin
            a = input_a;
            b = input_b;

            #1;

            if (next_leg_flags !== expected) begin
                $display(
                    "FAIL: %s | a=%h b=%h expected_next=%b got=%b",
                    test_name,
                    a,
                    b,
                    expected,
                    next_leg_flags
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %s | next_flags=%b",
                    test_name,
                    next_leg_flags
                );
            end
        end
    endtask

    task load_and_check_flags;
        input [15:0] input_a;
        input [15:0] input_b;
        input [2:0] expected;
        input [127:0] test_name;

        begin
            a = input_a;
            b = input_b;
            enable = 1;

            @(posedge clk);
            #1;

            enable = 0;

            if (leg_flags !== expected) begin
                $display(
                    "FAIL: %s | a=%h b=%h expected_stored=%b got=%b",
                    test_name,
                    a,
                    b,
                    expected,
                    leg_flags
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %s | stored_flags=%b",
                    test_name,
                    leg_flags
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        a = 16'h0000;
        b = 16'h0000;
        reset = 0;
        enable = 0;

        // ---------------------------------
        // Test 1: Reset flags register
        // ---------------------------------
        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        if (leg_flags !== 3'b000) begin
            $display(
                "FAIL: Reset expected 000, got %b",
                leg_flags
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Reset");
        end

        // ---------------------------------
        // Test 2: Combinational comparator
        // ---------------------------------

        check_next_flags(
            16'd3,
            16'd7,
            3'b100,
            "Positive less-than"
        );

        check_next_flags(
            16'd9,
            16'd9,
            3'b010,
            "Positive equal"
        );

        check_next_flags(
            16'd12,
            16'd4,
            3'b001,
            "Positive greater-than"
        );

        // ---------------------------------
        // Test 3: Signed comparisons
        // ---------------------------------

        check_next_flags(
            16'hFFFF,       // -1
            16'h0001,       // +1
            3'b100,
            "Negative less-than positive"
        );

        check_next_flags(
            16'hFFFB,       // -5
            16'hFFFB,       // -5
            3'b010,
            "Negative equal"
        );

        check_next_flags(
            16'hFFFE,       // -2
            16'hFFF8,       // -8
            3'b001,
            "Negative greater-than"
        );

        // ---------------------------------
        // Test 4: Store comparison flags
        // ---------------------------------

        load_and_check_flags(
            16'd2,
            16'd8,
            3'b100,
            "Store less-than"
        );

        load_and_check_flags(
            16'd15,
            16'd15,
            3'b010,
            "Store equal"
        );

        load_and_check_flags(
            16'd20,
            16'd5,
            3'b001,
            "Store greater-than"
        );

        // ---------------------------------
        // Test 5: Disabled register holds
        // ---------------------------------

        a = 16'd1;
        b = 16'd10;
        enable = 0;

        #1;

        // Comparator should now show L
        if (next_leg_flags !== 3'b100) begin
            $display(
                "FAIL: Comparator expected 100 while disabled, got %b",
                next_leg_flags
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Comparator still updates while register disabled");
        end

        @(posedge clk);
        #1;

        // Stored flags should still contain previous G result
        if (leg_flags !== 3'b001) begin
            $display(
                "FAIL: Hold expected 001, got %b",
                leg_flags
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Flags register hold");
        end

        // ---------------------------------
        // Test 6: Reset overrides enable
        // ---------------------------------

        a = 16'd100;
        b = 16'd1;
        enable = 1;
        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;
        enable = 0;

        if (leg_flags !== 3'b000) begin
            $display(
                "FAIL: Reset priority expected 000, got %b",
                leg_flags
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Reset priority");
        end

        // ---------------------------------
        // Final result
        // ---------------------------------

        $display("");

        if (errors == 0)
            $display("ALL COMPARE AND FLAGS TESTS PASSED");
        else
            $display("%0d COMPARE/FLAGS TESTS FAILED", errors);

        $finish;
    end

endmodule
