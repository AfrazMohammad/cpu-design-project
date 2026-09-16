/* 	000 = ADD
    001 = SUB
    010 = AND
    011 = XOR
    100 = OR
*/

module fourBitALU(
  output reg [3:0] result,
  output reg carry_out,
  output zero_flag, negative_flag, positive_flag, overflow,
  input [3:0] a, b,
  input [2:0] opcode
);
  
  wire [3:0] sum;
  wire cout;
  
  wire [3:0] bForAdder;
  assign bForAdder = (opcode == 3'b001) ? ~b : b;
  

  fourBitAdder fbALU(
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(bForAdder),
    .cin(opcode == 3'b001)
  );
  
  always @ (*) begin
    
    result = 4'b0000;
    carry_out = 1'b0;
    
    case (opcode)
      3'b000 : begin
        result = sum;
        carry_out = cout;
      end
      3'b001 : begin
        result = sum;
        carry_out = cout;
      end
      3'b010 : result = a & b;
      3'b011 : result = a ^ b;
      3'b100 : result = a | b;
    endcase
    
  end
  
  assign zero_flag = (result == 4'b0000);
  assign negative_flag = result[3];
  assign positive_flag = ~zero_flag & ~negative_flag;
  assign overflow = ~(a[3] ^ bForAdder[3]) & (a[3] ^ result[3]);
  
endmodule //fourBitALU
