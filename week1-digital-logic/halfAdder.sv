module halfAdder(
  output sum,
  output cout,
  input a,
  input b
);
  
  assign sum = a ^ b;
  assign cout = a & b;
  
endmodule //halfAdder
