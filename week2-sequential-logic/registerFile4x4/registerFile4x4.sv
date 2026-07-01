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
