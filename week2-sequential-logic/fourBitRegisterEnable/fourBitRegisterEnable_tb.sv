module fourBitRegisterEnable_tb;

  reg [3:0] d;
  reg clk;
  reg enable;
  wire [3:0] q;

  fourBitRegisterEnable uut(
    .q(q),
    .d(d),
    .clk(clk),
    .enable(enable)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fourBitRegisterEnable_tb);

    $monitor("time=%0t clk=%b enable=%b d=%b q=%b",
             $time, clk, enable, d, q);

    // Initial conditions
    clk = 0;
    enable = 1;
    d = 4'b0000;
    #10;

    // Store 1010
    d = 4'b1010;
    #10;

    clk = 1;        // q should become 1010
    #10;

    clk = 0;
    #10;

    // Disable writing
    enable = 0;
    d = 4'b0101;
    #10;

    clk = 1;        // q should stay 1010
    #10;

    clk = 0;
    #10;

    // Re-enable writing
    enable = 1;
    d = 4'b0101;
    #10;

    clk = 1;        // q should become 0101
    #10;

    $finish;
  end

endmodule
