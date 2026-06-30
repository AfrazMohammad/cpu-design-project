/* Creating Hardcided 8 bit Instruction Memory by hardcoding the following instructions:
Instructions take the format: OP DR SR1 SR2, 2 bits each
HALT is 8'b11111111, which is otherwise a useless instruction
*/

module instructionMemory(
  output reg [7:0] instruction,
  input [3:0] address
);
  
  always @ (*) begin
    
    case (address)
      4'b0000 : instruction = 8'b00000110; //ADD R0, R1, R2
      4'b0001 : instruction = 8'b01110010; //SUB R3, R0, R2
      4'b0010 : instruction = 8'b10010011; //AND R1, R0, R3
      4'b0011 : instruction = 8'b11100111; //OR  R2, R1, R3
      4'b0100 : instruction = 8'b00111101; //ADD R3, R3, R1
      4'b0101 : instruction = 8'b01001001; //SUB R0, R2, R1
      4'b0110 : instruction = 8'b10101000; //AND R2, R2, R0
      4'b0111 : instruction = 8'b11010010; //OR  R1, R0, R2
      4'b1000 : instruction = 8'b11111111; //HALT (Intended)
      default : instruction = 8'b11111111; //HALT (Safety)
    endcase
    
  end
  
endmodule //instructionMemory
