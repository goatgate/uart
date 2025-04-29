module piso #(
  parameter DATA_WIDTH = 8 
) (
  input logic clk,          
  input logic reset,        
  input logic en,       
  input logic [DATA_WIDTH-1:0] din,
  output logic flag, 
  output logic ser_out  
);

    logic [DATA_WIDTH-1:0] shift_reg; 
    logic [2:0] counter;
    always @(posedge clk) begin
        if (reset) begin
        shift_reg <= 0;
        ser_out <= 1'b1;
        counter <= '0;
        flag <= '0;
        end else if (en) begin
        shift_reg <= din; 
        ser_out <= din[0]; 
        end else begin
        ser_out <= shift_reg[0]; 
        shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
        counter <= counter +1;
        end
    end

    always @(posedge clk ) begin
        if(counter == 3'b111)
        begin
            flag <= '1;
        end
    end

endmodule