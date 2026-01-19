// ============================================================================
// Baud Generator Module (Corrected)
// ============================================================================
module Baud_Generator(
    input clk,
    input rst,
    output reg tx_enb,
    output reg rx_enb
);
    // Constants for 50MHz clock
    localparam TX_DIVISOR = 5208;      // 50MHz/9600 ≈ 5208.33
    localparam RX_DIVISOR = 326;       // 50MHz/(9600*16) ≈ 325.52
    
    reg [12:0] tx_counter;
    reg [8:0]  rx_counter;  // Changed to 9 bits for clarity
    
    // TX baud pulse generator
    always @(posedge clk) begin
        if (rst) begin
            tx_counter <= 13'd0;
            tx_enb <= 1'b0;
        end else begin
            if (tx_counter == TX_DIVISOR-1) begin
                tx_counter <= 13'd0;
                tx_enb <= 1'b1;
            end else begin
                tx_counter <= tx_counter + 1'b1;
                tx_enb <= 1'b0;
            end
        end
    end
    
    // RX oversampling baud generator (16x)
    always @(posedge clk) begin
        if (rst) begin
            rx_counter <= 9'd0;
            rx_enb <= 1'b0;
        end else begin
            if (rx_counter == RX_DIVISOR-1) begin
                rx_counter <= 9'd0;
                rx_enb <= 1'b1;
            end else begin
                rx_counter <= rx_counter + 1'b1;
                rx_enb <= 1'b0;
            end
        end
    end
endmodule
