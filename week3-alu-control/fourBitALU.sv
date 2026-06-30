// Code your design here


/* 	00 = ADD
	  01 = AND
    10 = XOR
    11 = OR
*/

module fourBitALU(
  output reg [3:0] result,
  input [3:0] a, b,
  input [1:0] opcode
);
  
  wire [3:0] sum;
  wire cout;
  
  fourBitAdder fbALU(
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(b)
  );
  
  always @ (*) begin
    case (opcode)
      2'b00 : result = sum;
      2'b01 : result = a & b;
      2'b10 : result = a ^ b;
      2'b11 : result = a | b;
    endcase
  end
  
endmodule //fourBitALU
