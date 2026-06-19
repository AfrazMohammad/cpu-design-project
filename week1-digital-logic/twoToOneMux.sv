/* Two to One Multiplexer (Mux)
   If Select = 0, Output = a
   If Select = 1, Output = b
*/

module twoToOneMux(
  output o,
  input a,
  input b,
  input select,
);
  
  assign o = select ? b : a;
  
endmodule //twoToOneMux
