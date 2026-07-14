module unifiedMemory #(
    parameter MEMORY_DEPTH = 65536,
    parameter MEMORY_FILE = "program.mem"
    )(
    output reg [15:0] read_data,
    input [15:0] write_data, address,
    input clk, write_enable
);

reg [15:0] memory [0:MEMORY_DEPTH-1];

initial begin
    if (MEMORY_FILE != "")
        $readmemh(MEMORY_FILE, memory);
end

always @ (posedge clk) begin
    if (!write_enable)
        read_data <= memory[address];
    else
        memory[address] <= write_data;
end

endmodule //unifiedMemory
