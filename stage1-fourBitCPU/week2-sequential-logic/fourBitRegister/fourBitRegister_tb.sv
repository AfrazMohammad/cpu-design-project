module fourBitRegister_tb;

  reg [3:0] d;
  reg clk;
  wire [3:0] q;

  fourBitRegister uut(
    .q(q),
    .d(d),
    .clk(clk)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fourBitRegister_tb);

    $monitor("time=%0t clk=%b d=%b q=%b",
             $time, clk, d, q);

    clk = 0;
    d = 4'b0000;
    #10;

    d = 4'b1010;    // q should NOT change yet
    #10;

    clk = 1;  // rising edge: q should become 1010
    #10;
    
    d = 4'b0101;
    #10;

    clk = 0;   // q should NOT change yet
    #20;

    clk = 1;  // rising edge: q should become 0101
    #10;

    $finish;
  end

endmodule
