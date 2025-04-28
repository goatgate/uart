module piso #(
  parameter DATA_WIDTH = 8 
) (
  input logic clk,          
  input logic reset,        
  input logic en,       
  input logic [DATA_WIDTH-1:0] din, 
  output logic ser_out  
);

  logic [DATA_WIDTH-1:0] shift_reg; 

  always @(posedge clk) begin
    if (reset) begin
      shift_reg <= 0;
      ser_out <= 1'b1; 
    end else if (en) begin
      shift_reg <= din; // Load data when enable is asserted
      ser_out <= din[0]; // Output the first bit
    end else begin
      ser_out <= shift_reg[0]; // Output the least significant bit
      shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0}; // Shift to the right, padding with 0
    end
  end

endmodule