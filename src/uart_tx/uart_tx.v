`include "piso.v"
module uart_tx #(
    parameter DATA_WIDTH = 8
    ) (
    input logic [DATA_WIDTH -1:0] DIN,
    input logic clk,
    input logic reset,
    input logic en,
    output logic ser_out
);
    
endmodule