module instructionRegister(
    output [15:0] instruction,
    input [15:0] memory_data,
    input clk, reset, load_enable
);

register16bit ir(
    .q(instruction),
    .d(memory_data),
    .clk(clk),
    .reset(reset),
    .enable(load_enable)
);

endmodule //instructionRegister
