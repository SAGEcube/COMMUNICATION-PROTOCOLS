// ============================================================================
// UART Top Module (Corrected)
// ============================================================================
module uart_top(
    input  clk,
    input  rst,
    input  wr_en,
    input  rdy_clr,
    input  [7:0] data_in,
    output tx_out,      // Added external TX output
    output rdy,
    output busy,
    output [7:0] data_out
);
    wire tx_enb;
    wire rx_enb;
    wire tx;
    
    // Baud generator
    Baud_Generator bg (
        .clk(clk),
        .rst(rst),
        .tx_enb(tx_enb),
        .rx_enb(rx_enb)
    );
    
    // UART Transmitter
    uart_transmitter ut (
        .clk(clk),
        .rst(rst),
        .wr_enb(wr_en),
        .enb(tx_enb),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );
    
    // UART Receiver (TX looped back to RX for testing)
    uart_receiver ur (
        .clk(clk),
        .rst(rst),
        .rx(tx),        // Loopback for testing
        .clk_en(rx_enb),
        .rdy_clr(rdy_clr),
        .rdy(rdy),
        .data_out(data_out)
    );
    
    assign tx_out = tx;  // Output for external connection
endmodule





