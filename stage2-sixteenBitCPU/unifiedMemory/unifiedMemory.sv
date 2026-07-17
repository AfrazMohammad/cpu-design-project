module unifiedMemory #(
    parameter MEMORY_DEPTH = 65536,
    parameter MEMORY_FILE = "program.mem"
    )(
    output reg [15:0] mdr_data,
    input [15:0] store_data, address,
    input mdr_enable, mdr_select, mdr_reset,
    input clk, memory_write_enable
);

reg [15:0] memory [0:MEMORY_DEPTH-1];

initial begin
    if (MEMORY_FILE != "")
        $readmemh(MEMORY_FILE, memory);
end

always @ (posedge clk) begin
    if (mdr_reset)
        mdr_data <= 16'h0000;
    else if (memory_write_enable)
        memory[address] <= mdr_data;
    else if (mdr_enable) begin
        if (!mdr_select)
            mdr_data <= memory[address];
        else
            mdr_data <= store_data;
    end
end

endmodule //unifiedMemory




module memoryAddressRegister(
    output [15:0] address,
    input [15:0] next_address,
    input clk, reset, enable
);

register16bit mar(
    .q(address),
    .d(next_address),
    .clk(clk),
    .reset(reset),
    .enable(enable)
);

endmodule //memoryAddressRegister
