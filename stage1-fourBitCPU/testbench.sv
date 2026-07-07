module cpu4bit_tb;

  reg clk;
  reg reset;

  reg preload_enable;
  reg [1:0] preload_address;
  reg [3:0] preload_data;

  cpu4bit uut(
    .clk(clk),
    .reset(reset),
    .preload_enable(preload_enable),
    .preload_address(preload_address),
    .preload_data(preload_data)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, cpu4bit_tb);

     $monitor(
    "t=%0t pc=%b instr=%b result=%b | R0=%b R1=%b R2=%b R3=%b enable=%b",
    $time,
    uut.pc,
    uut.instruction,
    uut.result,
    uut.cpu3.rf1.r0,
    uut.cpu3.rf1.r1,
    uut.cpu3.rf1.r2,
    uut.cpu3.rf1.r3,
    uut.enable
  );

    reset = 1;
    preload_enable = 0;
    preload_address = 2'b00;
    preload_data = 4'b0000;
    #12;

    reset = 0;

    `include "preloadRegisters.svh"

    #120;

    $finish;
  end

endmodule
