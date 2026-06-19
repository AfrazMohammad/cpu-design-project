module fullAdder(
  output sum,
  output cout,
  input a,
  input b,
  input cin
);
  
  assign sum = (a ^ b) ^ cin;
  assign cout = (a) ? (b | cin) : (b & cin);
  
endmodule //fullAdder
