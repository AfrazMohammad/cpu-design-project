module fourBitRegisterFile_tb;

  reg [3:0] d;
  reg clk;
  reg write_enable;
  reg [1:0] write_address;

  wire [3:0] r0, r1, r2, r3;

  fourBitRegisterFile uut(
    .r0(r0),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .d(d),
    .clk(clk),
    .write_enable(write_enable),
    .write_address(write_address)
  );

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, fourBitRegisterFile_tb);

    $monitor(
      "t=%0t clk=%b we=%b addr=%b d=%b | R0=%b R1=%b R2=%b R3=%b",
      $time, clk, write_enable, write_address,
      d, r0, r1, r2, r3
    );

    // Initial values
    clk = 0;
    write_enable = 0;
    d = 4'b0000;
    write_address = 2'b00;

    #10;

    // Write 1010 to R0
    write_enable = 1;
    d = 4'b1010;
    write_address = 2'b00;

    #10 clk = 1;   // Rising edge -> R0 should become 1010
    #10 clk = 0;

    // Write 0101 to R2
    d = 4'b0101;
    write_address = 2'b10;

    #10 clk = 1;   // Rising edge -> R2 should become 0101
    #10 clk = 0;

    // Disable writing and attempt to overwrite R0
    write_enable = 0;
    d = 4'b1111;
    write_address = 2'b00;

    #10 clk = 1;   // Nothing should change
    #10 clk = 0;

    // Write 0011 to R3
    write_enable = 1;
    d = 4'b0011;
    write_address = 2'b11;

    #10 clk = 1;   // R3 should become 0011
    #10 clk = 0;

    #20 $finish;

  end

endmodule
