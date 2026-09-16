module dFlipFlop(
  output reg q,
  input d,
  input clk
);
  
  always @(posedge clk)
    q <= d;
  
endmodule //dFlipFlop
