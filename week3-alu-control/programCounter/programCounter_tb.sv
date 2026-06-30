module programCounter_tb;

  reg clk, reset, enable;
  wire [3:0] pc;

  programCounter uut(
    .pc(pc),
    .clk(clk),
    .reset(reset),
    .enable(enable)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, programCounter_tb);

    $monitor("t=%0t clk=%b reset=%b enable=%b pc=%b",
         $time, clk, reset, enable, pc);

    // Initial conditions
    clk = 0;
    reset = 0;
    enable = 0;
    #10;

    // Reset PC to 0000
    reset = 1;
    #10;

    clk = 1;    // PC should become 0000
    #10;
    clk = 0;
    #10;

    reset = 0;

    // Count normally
    enable = 1;
    #10;

    clk = 1;    // PC = 0001
    #10;
    clk = 0;
    #10;

    clk = 1;    // PC = 0010
    #10;
    clk = 0;
    #10;

    clk = 1;    // PC = 0011
    #10;
    clk = 0;
    #10;

    // Hold PC
    enable = 0;
    #10;

    clk = 1;    // PC should remain 0011
    #10;
    clk = 0;
    #10;

    // Resume counting
    enable = 1;
    #10;

    clk = 1;    // PC = 0100
    #10;
    clk = 0;
    #10;

    // Reset again while enable is 0
    enable = 0;
    reset = 1;
    #10;

    clk = 1;    // PC should become 0000
    #10;
    clk = 0;
    #10;

    $finish;
  end

endmodule
