module uart_rx #(
    parameter DATA_WIDTH = 8
) (
    input logic din,            // Serial input
    input logic clk,
    input logic reset,
    output logic [DATA_WIDTH-1:0] par_out  // Parallel output
);
    logic en_shift; 
    logic [2:0] state;  
    logic flag;
    logic [DATA_WIDTH-1:0] shift_reg;
    logic [3:0] bit_counter;
    
    // Define states
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            state <= IDLE;
            shift_reg <= 0;
            bit_counter <= 0;
            par_out <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if(!din) begin  // Start bit detection (low)
                        state <= START;
                        bit_counter <= 0;
                    end
                end
                
                START: begin
                    // Wait 1.5 bit times (middle of first data bit)
                    state <= DATA;
                end
                
                DATA: begin
                    shift_reg <= {din, shift_reg[DATA_WIDTH-1:1]};
                    bit_counter <= bit_counter + 1;
                    if(bit_counter == DATA_WIDTH-1)
                        state <= STOP;
                end
                
                STOP: begin
                    par_out <= shift_reg;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule