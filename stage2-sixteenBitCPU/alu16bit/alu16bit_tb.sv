`timescale 1ns/1ps

module testbench;

    reg signed [15:0] a;
    reg signed [15:0] b;
    reg [3:0] alu_control;

    wire signed [15:0] result;
    wire carry_flag;
    wire overflow_flag;

    integer errors;

    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam MUL = 4'b0010;
    localparam AND = 4'b0011;
    localparam OR  = 4'b0100;
    localparam XOR = 4'b0101;
    localparam NOT = 4'b0110;
    localparam SHL = 4'b0111;
    localparam SHR = 4'b1000;
    localparam SHA = 4'b1001;
    localparam ROR = 4'b1010;

    alu16bit dut(
        .result(result),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .a(a),
        .b(b),
        .alu_control(alu_control)
    );

    task check_result;
        input [3:0] control;
        input signed [15:0] input_a;
        input signed [15:0] input_b;
        input signed [15:0] expected_result;
        input expected_carry;
        input expected_overflow;
        input [127:0] test_name;

        begin
            alu_control = control;
            a = input_a;
            b = input_b;

            #1;

            if (
                result !== expected_result ||
                carry_flag !== expected_carry ||
                overflow_flag !== expected_overflow
            ) begin
                $display(
                    "FAIL: %s | a=%h b=%h result=%h expected=%h carry=%b expected_carry=%b overflow=%b expected_overflow=%b",
                    test_name,
                    a,
                    b,
                    result,
                    expected_result,
                    carry_flag,
                    expected_carry,
                    overflow_flag,
                    expected_overflow
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %s | result=%h carry=%b overflow=%b",
                    test_name,
                    result,
                    carry_flag,
                    overflow_flag
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        a = 16'sh0000;
        b = 16'sh0000;
        alu_control = 4'b0000;

        // -------------------------
        // ADD tests
        // -------------------------

        check_result(
            ADD,
            16'sd7,
            16'sd4,
            16'sd11,
            1'b0,
            1'b0,
            "ADD normal"
        );

        check_result(
            ADD,
            16'hFFFF,
            16'h0001,
            16'h0000,
            1'b1,
            1'b0,
            "ADD unsigned carry"
        );

        check_result(
            ADD,
            16'h7FFF,
            16'h0001,
            16'h8000,
            1'b0,
            1'b1,
            "ADD positive overflow"
        );

        check_result(
            ADD,
            16'h8000,
            16'hFFFF,
            16'h7FFF,
            1'b1,
            1'b1,
            "ADD negative overflow"
        );

        // -------------------------
        // SUB tests
        // -------------------------

        check_result(
            SUB,
            16'sd12,
            16'sd5,
            16'sd7,
            1'b1,
            1'b0,
            "SUB normal no borrow"
        );

        check_result(
            SUB,
            16'sd3,
            16'sd5,
            -16'sd2,
            1'b0,
            1'b0,
            "SUB with borrow"
        );

        check_result(
            SUB,
            16'h7FFF,
            16'hFFFF,
            16'h8000,
            1'b0,
            1'b1,
            "SUB positive overflow"
        );

        check_result(
            SUB,
            16'h8000,
            16'h0001,
            16'h7FFF,
            1'b1,
            1'b1,
            "SUB negative overflow"
        );

        // -------------------------
        // MUL tests
        // -------------------------

        check_result(
            MUL,
            16'sd6,
            16'sd4,
            16'sd24,
            1'b0,
            1'b0,
            "MUL positive"
        );

        check_result(
            MUL,
            -16'sd3,
            16'sd5,
            -16'sd15,
            1'b0,
            1'b0,
            "MUL negative"
        );

        check_result(
            MUL,
            16'sd300,
            16'sd300,
            16'h5F90,
            1'b0,
            1'b1,
            "MUL overflow"
        );

        // -------------------------
        // Logic tests
        // -------------------------

        check_result(
            AND,
            16'h00CC,
            16'h00AA,
            16'h0088,
            1'b0,
            1'b0,
            "AND"
        );

        check_result(
            OR,
            16'h00CC,
            16'h00AA,
            16'h00EE,
            1'b0,
            1'b0,
            "OR"
        );

        check_result(
            XOR,
            16'h00CC,
            16'h00AA,
            16'h0066,
            1'b0,
            1'b0,
            "XOR"
        );

        check_result(
            NOT,
            16'h000F,
            16'h0000,
            16'hFFF0,
            1'b0,
            1'b0,
            "NOT"
        );

        // -------------------------
        // Shift tests
        // -------------------------

        check_result(
            SHL,
            16'h0005,
            16'h0003,
            16'h0028,
            1'b0,
            1'b0,
            "SHL"
        );

        check_result(
            SHR,
            16'h0014,
            16'h0002,
            16'h0005,
            1'b0,
            1'b0,
            "SHR"
        );

        check_result(
            SHA,
            16'hFFF8,
            16'h0001,
            16'hFFFC,
            1'b0,
            1'b0,
            "SHA negative"
        );

        // -------------------------
        // Rotate tests
        // -------------------------

        check_result(
            ROR,
            16'h8001,
            16'h0001,
            16'hC000,
            1'b0,
            1'b0,
            "ROR by 1"
        );

        check_result(
            ROR,
            16'h1234,
            16'h0000,
            16'h1234,
            1'b0,
            1'b0,
            "ROR by 0"
        );

        // -------------------------
        // Invalid control test
        // -------------------------

        check_result(
            4'b1111,
            16'hFFFF,
            16'hFFFF,
            16'h0000,
            1'b0,
            1'b0,
            "Invalid ALU control"
        );

        $display("");

        if (errors == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("%0d ALU TESTS FAILED", errors);

        $finish;
    end

endmodule
