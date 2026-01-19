// ============================================================================
// Testbench (Corrected)
// ============================================================================
module uart_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rdy_clr;
    reg [7:0] data_in;
    wire rdy;
    wire busy;
    wire [7:0] data_out;

    // Instantiate the UART top module
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rdy_clr(rdy_clr),
        .data_in(data_in),
        .rdy(rdy),
        .busy(busy),
        .data_out(data_out)
    );

    // Clock generation: 50 MHz (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("--------------------------------------------------");
        $display("UART TEST STARTED @ time = %0t", $time);
        $display("Clock period = 20ns (50MHz)");
        $display("Expected TX_ENB period = 104.16us (5208 clocks)");
        $display("Expected RX_ENB period = 6.52us (326 clocks)");
        $display("--------------------------------------------------");
        
        // Initialize signals
        rst = 1;
        wr_en = 0;
        rdy_clr = 0;
        data_in = 8'h00;
        
        // Apply reset for 4 clock cycles
        repeat(4) @(posedge clk);
        rst = 0;
        $display("[%0t] Reset deasserted", $time);
        
        // Wait for a few baud periods
        #100000;  // Wait 100us
        
        // Test 1: Send byte 0x41 ('A')
        $display("\n[%0t] Test 1: Sending byte = 0x41", $time);
        @(posedge clk);
        data_in = 8'h41;
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        // Wait for transmission to complete
        wait(busy == 0);
        $display("[%0t] Transmission complete", $time);
        
        // Wait for reception
        #200000;  // Wait for stop bit + margin
        
        if (rdy == 1) begin
            $display("[%0t] Received data = 0x%h", $time, data_out);
            if (data_out == 8'h41) begin
                $display("[%0t] TEST 1 PASSED ✓", $time);
            end else begin
                $display("[%0t] TEST 1 FAILED ✗", $time);
            end
        end else begin
            $display("[%0t] ERROR: Data not received", $time);
        end
        
        // Clear ready flag
        @(posedge clk);
        rdy_clr = 1;
        @(posedge clk);
        rdy_clr = 0;
        
        // Test 2: Send byte 0x55
        #100000;
        $display("\n[%0t] Test 2: Sending byte = 0x55", $time);
        @(posedge clk);
        data_in = 8'h55;
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        wait(busy == 0);
        #200000;
        
        if (data_out == 8'h55) begin
            $display("[%0t] TEST 2 PASSED ✓", $time);
        end else begin
            $display("[%0t] TEST 2 FAILED ✗", $time);
        end
        
        // End simulation
        #10000;
        $display("--------------------------------------------------");
        $display("TEST COMPLETED @ time = %0t", $time);
        $display("--------------------------------------------------");
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $timeformat(-6, 3, "us", 10);
        $monitor("[%0t] TX=%b busy=%b rdy=%b data_out=0x%h", 
                 $realtime, uut.tx, busy, rdy, data_out);
    end

endmodule