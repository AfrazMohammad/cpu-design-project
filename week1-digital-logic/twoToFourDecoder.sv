// a = MSB
// b = LSB

module twoToFourDecoder(
  
  output d0, d1, d2, d3,
  input a,
  input b
  
);
  
  assign d0 = ~a & ~b;
  assign d1 = ~a & b;
  assign d2 = a & ~b;
  assign d3 = a & b;
  
endmodule //twoToFourDecoder
