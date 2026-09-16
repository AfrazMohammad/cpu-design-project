/*	00 = ADD
	01 = SUB
    10 = AND
    11 = OR
*/
module fourBitALU(
  output reg [3:0] result,
  output reg carry_out,
  output zero_flag, negative_flag, positive_flag, overflow,
  input [3:0] a, b,
  input [1:0] opcode
);
  
  wire [3:0] sum;
  wire cout;
  
  wire [3:0] bForAdder;
  assign bForAdder = (opcode == 2'b01) ? ~b : b;
  
  fourBitAdder fbALU(
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(bForAdder),
    .cin(opcode == 2'b01)
  );
  
  always @ (*) begin
    
    result = 4'b0000;
    carry_out = 1'b0;
    
    case (opcode)
      2'b00 : begin
        result = sum;
        carry_out = cout;
      end
      2'b01 : begin
        result = sum;
        carry_out = cout;
      end
      2'b10 : result = a & b;
      2'b11 : result = a | b;
    endcase
    
  end
  
  assign zero_flag = (result == 4'b0000);
  assign negative_flag = result[3];
  assign positive_flag = ~zero_flag & ~negative_flag;
  assign overflow =
  ((opcode == 2'b00) || (opcode == 2'b01)) &&
  (~(a[3] ^ bForAdder[3]) & (a[3] ^ result[3]));
  
endmodule //fourBitALU
  
  
