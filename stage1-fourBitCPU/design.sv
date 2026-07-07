/* Two to One Multiplexer (Mux)
   If Select = 0, Output = a
   If Select = 1, Output = b
*/

module twoToOneMux(
  output o,
  input a,
  input b,
  input select
);
  
  assign o = select ? b : a;
  
endmodule //twoToOneMux




// a = MSB
// b = LSB

module twoToFourDecoder(
  
  output [3:0] d,
  input [1:0] a
  
);
  
  assign d[0] = ~a[1] & ~a[0];
  assign d[1] = ~a[1] & a[0];
  assign d[2] = a[1] & ~a[0];
  assign d[3] = a[1] & a[0];
  
endmodule //twoToFourDecoder




module halfAdder(
  output sum,
  output cout,
  input a,
  input b
);
  
  assign sum = a ^ b;
  assign cout = a & b;
  
endmodule //halfAdder




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




module fourBitAdder(
  output [3:0] sum,
  output cout,
  input [3:0] a,
  input [3:0] b,
  input cin
);
  
  wire c1, c2, c3;
  
  fullAdder bit0(
    .sum(sum[0]),
    .cout(c1),
    .a(a[0]),
    .b(b[0]),
    .cin(cin)
  );
  
  fullAdder bit1(
    .sum(sum[1]),
    .cout(c2),
    .a(a[1]),
    .b(b[1]),
    .cin(c1)
  );
  
  fullAdder bit2(
    .sum(sum[2]),
    .cout(c3),
    .a(a[2]),
    .b(b[2]),
    .cin(c2)
  );
  
  fullAdder bit3(
    .sum(sum[3]),
    .cout(cout),
    .a(a[3]),
    .b(b[3]),
    .cin(c3)
  );
  
endmodule //fourBitAdder




module dFlipFlop(
  output reg q,
  input d,
  input clk
);
  
  always @(posedge clk)
    q <= d;
  
endmodule //dFlipFlop




module fourBitRegister(
  output [3:0] q,
  input [3:0] d,
  input clk
);
  
  dFlipFlop bit0(
    .q(q[0]),
    .d(d[0]),
    .clk(clk)
  );
  
  dFlipFlop bit1(
    .q(q[1]),
    .d(d[1]),
    .clk(clk)
  );
  
  dFlipFlop bit2(
    .q(q[2]),
    .d(d[2]),
    .clk(clk)
  );
  
  dFlipFlop bit3(
    .q(q[3]),
    .d(d[3]),
    .clk(clk)
  );
  
endmodule //fourBitRegister




module fourBitRegisterEnable(
  output [3:0] q,
  input [3:0] d,
  input clk,
  input enable
);
  
  wire [3:0] next_d;
  
  assign next_d = enable ? d : q;
  
  fourBitRegister fbre(
    .q(q),
    .d(next_d),
    .clk(clk)
  );
  
endmodule //fourBitRegisterEnable




module fourBitRegisterFile(
  output [3:0] r0, r1, r2, r3,
  input [3:0] d,
  input clk,
  input write_enable,
  input [1:0] write_address
);
  
  wire [3:0] register_select;
  
  twoToFourDecoder fbrf(
    .d(register_select),
    .a(write_address)
  );
  
  fourBitRegisterEnable register0(
    .q(r0),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[0]))
  );
  
  fourBitRegisterEnable register1(
    .q(r1),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[1]))
  );
  
  fourBitRegisterEnable register2(
    .q(r2),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[2]))
  );
  
  fourBitRegisterEnable register3(
    .q(r3),
    .d(d),
    .clk(clk),
    .enable((write_enable & register_select[3]))
  );
  
endmodule //fourBitRegisterFile




module registerFile4x4(
  output reg [3:0] read_data1,
  output reg [3:0] read_data2,
  
  input [1:0] read_address1,
  input [1:0] read_address2,
  
  input [3:0] write_data,
  input [1:0] write_address,
  
  input clk, write_enable
);
  
  wire [3:0] r0, r1, r2, r3;
  
  fourBitRegisterFile rf1(
    .r0(r0),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .d(write_data),
    .clk(clk),
    .write_enable(write_enable),
    .write_address(write_address)
  );
  
  always @ (*) begin
    case (read_address1)
      2'b00 : read_data1 = r0;
      2'b01 : read_data1 = r1;
      2'b10 : read_data1 = r2;
      2'b11 : read_data1 = r3;
      default: read_data1 = 4'b0000;
    endcase
    
    case (read_address2)
      2'b00 : read_data2 = r0;
      2'b01 : read_data2 = r1;
      2'b10 : read_data2 = r2;
      2'b11 : read_data2 = r3;
      default: read_data2 = 4'b0000;
    endcase
  end
  
endmodule //registerFile4x4




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




module programCounter(
  output [3:0] pc,
  input clk, reset, enable
);
  
  wire [3:0] pcIncrement, nextPC;
  
  fourBitAdder pc1(
    .sum(pcIncrement),
    .a(pc),
    .b(4'b0001),
    .cin(1'b0)
  );
  
  assign nextPC = (reset) ? 4'b0000 : pcIncrement;
  
  fourBitRegisterEnable pc2(
    .q(pc),
    .d(nextPC),
    .clk(clk),
    .enable(enable | reset)
  );
  
endmodule //programCounter




/* Creating Hardcoded 8 bit Instruction Memory by hardcoding the following instructions:
Instructions take the format: OP DR SR1 SR2, 2 bits each
HALT is 8'b11111111, which is otherwise a useless instruction
*/

module instructionMemory(
  output reg [7:0] instruction,
  input [3:0] address
);
  
  always @ (*) begin
    
    `include "program.svh"
    
  end
  
endmodule //instructionMemory




module fetchUnit(
  output [7:0] instruction,
  output [3:0] pc,
  input clk, reset, enable
);
  
  programCounter fu1(
    .pc(pc),
    .clk(clk),
    .reset(reset),
    .enable(enable)
  );
  
  instructionMemory fu2(
    .instruction(instruction),
    .address(pc)
  );
  
endmodule //fetchUnit




module instructionDecoder(
  output [1:0] opcode, dr, sr1, sr2,
  input [7:0] instruction
);
  
  assign opcode = instruction[7:6];
  assign dr = instruction[5:4];
  assign sr1 = instruction[3:2];
  assign sr2 = instruction[1:0];
  
endmodule //instructionDecoder




module cpu4bit(
  input clk, reset,
  input preload_enable,
  input [1:0] preload_address,
  input [3:0] preload_data
);
  
  wire [3:0] pc;
  wire [7:0] instruction;
  wire enable;
  
  wire [1:0] opcode, dr, sr1, sr2;
  wire [3:0] sr1data, sr2data, result;
  wire carry_out, zero_flag, negative_flag, positive_flag, overflow;
  
  wire rf_write_enable;
  wire [1:0] rf_write_address;
  wire [3:0] rf_write_data;
  
  assign enable = ~(instruction == 8'b11111111);
  
  assign rf_write_enable = preload_enable ? 1'b1 : enable;
  assign rf_write_address = preload_enable ? preload_address : dr;
  assign rf_write_data = preload_enable ? preload_data : result;

  fetchUnit cpu1(
    .instruction(instruction),
    .pc(pc),
    .clk(clk),
    .reset(reset),
    .enable(enable & ~preload_enable)
  );

  instructionDecoder cpu2(
    .instruction(instruction),
    .opcode(opcode),
    .dr(dr),
    .sr1(sr1),
    .sr2(sr2)
  );

  registerFile4x4 cpu3(
    .read_data1(sr1data),
    .read_data2(sr2data),

    .read_address1(sr1),
    .read_address2(sr2),

    .write_data(rf_write_data),
    .write_address(rf_write_address),
    .clk(clk),
    .write_enable(rf_write_enable)
  );

  fourBitALU cpu4(
    .result(result),
    .a(sr1data),
    .b(sr2data),
    .opcode(opcode),
    .carry_out(carry_out),
    .negative_flag(negative_flag),
    .zero_flag(zero_flag),
    .positive_flag(positive_flag),
    .overflow(overflow)
  );
  
endmodule //fourBitCPU
