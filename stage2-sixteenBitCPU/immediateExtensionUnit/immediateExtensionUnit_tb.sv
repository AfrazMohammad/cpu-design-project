`timescale 1ns/1ps

module testbench;

    reg  [9:0] imm;
    reg  [2:0] extend_mode;
    wire [15:0] imm16;

    integer errors;

    localparam ZERO_EXTEND_4  = 3'b000;
    localparam ZERO_EXTEND_5  = 3'b001;
    localparam SIGN_EXTEND_5  = 3'b010;
    localparam SIGN_EXTEND_7  = 3'b011;
    localparam SIGN_EXTEND_8  = 3'b100;
    localparam SIGN_EXTEND_9  = 3'b101;
    localparam SIGN_EXTEND_10 = 3'b110;

    immediateExtensionUnit dut(
        .imm16(imm16),
        .imm(imm),
        .extend_mode(extend_mode)
    );

    task check_extension;
        input [2:0] mode;
        input [9:0] input_imm;
        input [15:0] expected;
        input [127:0] test_name;

        begin
            extend_mode = mode;
            imm = input_imm;

            #1;

            if (imm16 !== expected) begin
                $display(
                    "FAIL: %s | imm=%b mode=%b expected=%h got=%h",
                    test_name,
                    imm,
                    extend_mode,
                    expected,
                    imm16
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %s | imm=%b result=%h",
                    test_name,
                    imm,
                    imm16
                );
            end
        end
    endtask

    initial begin
        errors = 0;
        imm = 10'b0;
        extend_mode = 3'b0;

        //==========================================
        // Zero Extend 4
        //==========================================

        check_extension(
            ZERO_EXTEND_4,
            10'b0000001010,
            16'h000A,
            "Zero extend 4-bit value 10"
        );

        check_extension(
            ZERO_EXTEND_4,
            10'b0000001111,
            16'h000F,
            "Zero extend maximum 4-bit value"
        );

        //==========================================
        // Zero Extend 5
        //==========================================

        check_extension(
            ZERO_EXTEND_5,
            10'b0000010000,
            16'h0010,
            "Zero extend value 16"
        );

        check_extension(
            ZERO_EXTEND_5,
            10'b0000011111,
            16'h001F,
            "Zero extend maximum 5-bit value"
        );

        //==========================================
        // Sign Extend 5
        //==========================================

        check_extension(
            SIGN_EXTEND_5,
            10'b0000000111,
            16'h0007,
            "Sign extend positive imm5"
        );

        check_extension(
            SIGN_EXTEND_5,
            10'b0000011111,
            16'hFFFF,
            "Sign extend -1"
        );

        check_extension(
            SIGN_EXTEND_5,
            10'b0000010000,
            16'hFFF0,
            "Sign extend -16"
        );

        //==========================================
        // Sign Extend 7
        //==========================================

        check_extension(
            SIGN_EXTEND_7,
            10'b0000111111,
            16'h003F,
            "Sign extend +63"
        );

        check_extension(
            SIGN_EXTEND_7,
            10'b0001000000,
            16'hFFC0,
            "Sign extend -64"
        );

        check_extension(
            SIGN_EXTEND_7,
            10'b0001111111,
            16'hFFFF,
            "Sign extend -1"
        );

        //==========================================
        // Sign Extend 8
        //==========================================

        check_extension(
            SIGN_EXTEND_8,
            10'b0001111111,
            16'h007F,
            "Sign extend +127"
        );

        check_extension(
            SIGN_EXTEND_8,
            10'b0010000000,
            16'hFF80,
            "Sign extend -128"
        );

        check_extension(
            SIGN_EXTEND_8,
            10'b0011111011,
            16'hFFFB,
            "Sign extend -5"
        );

        //==========================================
        // Sign Extend 9
        //==========================================

        check_extension(
            SIGN_EXTEND_9,
            10'b0011111111,
            16'h00FF,
            "Sign extend +255"
        );

        check_extension(
            SIGN_EXTEND_9,
            10'b0100000000,
            16'hFF00,
            "Sign extend -256"
        );

        check_extension(
            SIGN_EXTEND_9,
            10'b0111111111,
            16'hFFFF,
            "Sign extend -1"
        );

        //==========================================
        // Sign Extend 10
        //==========================================

        check_extension(
            SIGN_EXTEND_10,
            10'b0111111111,
            16'h01FF,
            "Sign extend +511"
        );

        check_extension(
            SIGN_EXTEND_10,
            10'b1000000000,
            16'hFE00,
            "Sign extend -512"
        );

        check_extension(
            SIGN_EXTEND_10,
            10'b1111111111,
            16'hFFFF,
            "Sign extend -1"
        );

        //==========================================
        // Invalid mode
        //==========================================

        check_extension(
            3'b111,
            10'b1111111111,
            16'h0000,
            "Invalid mode"
        );

        $display("");

        if (errors == 0)
            $display("ALL IMMEDIATE EXTENSION TESTS PASSED");
        else
            $display("%0d IMMEDIATE EXTENSION TESTS FAILED", errors);

        $finish;
    end

endmodule
