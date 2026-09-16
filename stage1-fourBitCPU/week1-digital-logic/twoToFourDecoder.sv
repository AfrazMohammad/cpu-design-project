module twoToFourDecoder(
  
  output [3:0] d,
  input [1:0] a
  
);
  
  assign d[0] = ~a[1] & ~a[0];
  assign d[1] = ~a[1] & a[0];
  assign d[2] = a[1] & ~a[0];
  assign d[3] = a[1] & a[0];
  
endmodule //twoToFourDecoder
