module fetchUnit_tb;

  reg clk;
  reg reset;
  reg enable;

  wire [3:0] pc;
  wire [7:0] instruction;

  fetchUnit uut(
    .instruction(instruction),
    .pc(pc),
    .clk(clk),
    .reset(reset),
    .enable(enable)
  );

  // Automatic clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fetchUnit_tb);

    $monitor("t=%0t clk=%b reset=%b enable=%b pc=%b instruction=%b",
             $time, clk, reset, enable, pc, instruction);

    reset = 1; enable = 0;
    #12;

    reset = 0; enable = 1;
    #80;

    enable = 0;   // hold PC
    #20;

    enable = 1;   // resume
    #40;

    $finish;
  end

endmodule
