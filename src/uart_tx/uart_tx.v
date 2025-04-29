`include "piso.v"
module uart_tx #(
    parameter DATA_WIDTH = 8
    ) (
    input logic [DATA_WIDTH -1:0] din,
    input logic clk,
    input logic reset,
    input logic en,
    output logic ser_out
);
    logic en_shift; 
    logic [2:0] state;  
    logic flag;
    // Define states
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    piso piso_DUT(
        .clk(clk),
        .reset(reset),
        .din(din),
        .en(en),
        .flag(flag),
        .ser_out(ser_out)
    );
always @(posedge clk )
begin
    if(!reset)
    begin
        state <= IDLE;
        en_shift <= '0;
    end    
    else 
        begin
            case(state)
                IDLE:begin
                    if(en)
                    begin
                        state <= START;
                        en_shift <= '1;
                    end
                    else
                        begin
                            state <= IDLE;
                            en_shift <= '0;
                        end
                end
                START:begin
                    state <= DATA;
                    en_shift <= '0;
                end
                DATA:begin
                    if(flag)
                    begin
                        state <= STOP; 
                    end
                    else
                        begin
                            state <= DATA;
                        end
                    en_shift <= '0;     
                end
                STOP:begin
                    state <= IDLE;
                    en_shift <= '0;
                end
                default:state <= IDLE;
            
            endcase
        end
end

endmodule