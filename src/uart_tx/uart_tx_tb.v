`timescale 1ns/1ps
`include "uart_tx.v"

module uart_tx_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10; // 100 MHz clock
    
    // Signals
    logic [DATA_WIDTH-1:0] din;
    logic clk;
    logic reset;
    logic en;
    logic ser_out;
    
    // Instantiate DUT
    uart_tx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .din(din),
        .clk(clk),
        .reset(reset),
        .en(en),
        .ser_out(ser_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Reset generation
    task automatic reset_dut;
        begin
            reset = 0;
            repeat(2) @(posedge clk);
            reset = 1;
            @(posedge clk);
        end
    endtask
    
    // Test tasks
    task automatic send_byte(input [DATA_WIDTH-1:0] data);
        begin
            // Wait for IDLE state
            while (dut.state != dut.IDLE) @(posedge clk);
            
            // Apply data and enable
            din = data;
            en = 1;
            @(posedge clk);
            en = 0;
            
            // Wait for transmission to complete
            while (dut.state != dut.IDLE) @(posedge clk);
            
            // Add some idle time
            repeat(5) @(posedge clk);
        end
    endtask
    
    // Monitor task
    task automatic monitor_uart;
        begin
            // Wait for start bit
            wait (ser_out === 0);
            $display("[%0t] Start bit detected", $time);
            
            // Sample data bits in the middle of each bit period
            #(CLK_PERIOD * 1.5); // Middle of start bit
            if (ser_out !== 0) $error("Start bit not low");
            
            // Sample data bits
            for (int i = 0; i < DATA_WIDTH; i++) begin
                #(CLK_PERIOD);
                $display("[%0t] Bit %0d: %b", $time, i, ser_out);
            end
            
            // Check stop bit
            #(CLK_PERIOD);
            if (ser_out !== 1) $error("Stop bit not high");
            
            $display("[%0t] Stop bit detected", $time);
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        din = 0;
        en = 0;
        
        // Apply reset
        reset_dut();
        
        // Test 1: Single byte transmission
        fork
            send_byte(8'h55); // 01010101
            monitor_uart();
        join
        
        // Test 2: All zeros
        fork
            send_byte(8'h00);
            monitor_uart();
        join
        
        // Test 3: All ones
        fork
            send_byte(8'hFF);
            monitor_uart();
        join
        
        // Test 4: Random data
        for (int i = 0; i < 5; i++) begin
            fork
                send_byte($random);
                monitor_uart();
            join
        end
        
        // Test 5: Back-to-back transmissions
        fork
            begin
                send_byte(8'hAA);
                send_byte(8'h55);
                send_byte(8'hA5);
            end
            begin
                monitor_uart();
                monitor_uart();
                monitor_uart();
            end
        join
        
        // End simulation
        $display("UART TX test completed");
        $finish;
    end
    
    // Simulation timeout
    initial begin
        #100000;
        $display("Simulation timeout");
        $finish;
    end
    
endmodule
