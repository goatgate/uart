module tb_uart_rx;
    parameter DATA_WIDTH = 8;
    
    logic din;
    logic clk = 0;
    logic reset;
    logic [DATA_WIDTH-1:0] par_out;

    uart_rx #(DATA_WIDTH) DUT (
        .din(din),
        .clk(clk),
        .reset(reset),
        .par_out(par_out)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("tb_uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);
        
        reset = 0;
        #20 reset = 1;
        
        // Send a byte (LSB first)
        din = 1; // idle
        #100;
        
        // Start bit
        din = 0;
        #160;
        
        // Data bits (0x55 - 01010101)
        din = 1; #160; // bit 0
        din = 0; #160; // bit 1
        din = 1; #160; // bit 2
        din = 0; #160; // bit 3
        din = 1; #160; // bit 4
        din = 0; #160; // bit 5
        din = 1; #160; // bit 6
        din = 0; #160; // bit 7
        
        // Stop bit
        din = 1;
        #160;
        
        $display("Received data: %h", par_out);
        $finish;
    end
endmodule