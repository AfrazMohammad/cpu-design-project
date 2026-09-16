module fourBitRegisterFile(
  output reg [3:0] r0, r1, r2, r3,
  input [3:0] d,
  input clk,
  input write_enable,
  input [1:0] write_address
);

  always @(posedge clk) begin
    if (write_enable) begin
      case (write_address)
        2'b00: r0 <= d;
        2'b01: r1 <= d;
        2'b10: r2 <= d;
        2'b11: r3 <= d;
      endcase
    end
  end

endmodule //fourBitRegisterFile
