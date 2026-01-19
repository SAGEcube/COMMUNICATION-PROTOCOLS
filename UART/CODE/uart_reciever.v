// ============================================================================
// UART Receiver Module (Corrected)
// ============================================================================
module uart_receiver(
    input clk,
    input rst,
    input rx,
    input clk_en,
    input rdy_clr,
    output reg rdy,
    output reg [7:0] data_out
);
    parameter IDLE  = 2'b00,
              START = 2'b01,
              DATA  = 2'b10,
              STOP  = 2'b11;
    
    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] index;
    reg [7:0] shift_reg;
    reg rx_sync;
    
    // Single stage synchronizer (sufficient for most cases)
    always @(posedge clk) begin
        if (rst) begin
            rx_sync <= 1'b1;
        end else begin
            rx_sync <= rx;
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            sample <= 4'd0;
            index <= 3'd0;
            shift_reg <= 8'd0;
            data_out <= 8'd0;
            rdy <= 1'b0;
        end else begin
            // Clear ready flag if requested
            if (rdy_clr) begin
                rdy <= 1'b0;
            end
            
            if (clk_en) begin
                case (state)
                    IDLE: begin
                        sample <= 4'd0;
                        if (rx_sync == 1'b0) begin
                            state <= START;
                        end
                    end
                    
                    START: begin
                        if (sample == 4'd7) begin
                            if (rx_sync == 1'b0) begin
                                state <= DATA;
                            end else begin
                                state <= IDLE;
                            end
                            sample <= 4'd0;
                            index <= 3'd0;
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end
                    
                    DATA: begin
                        if (sample == 4'd15) begin
                            shift_reg[index] <= rx_sync;
                            sample <= 4'd0;
                            if (index == 3'd7) begin
                                state <= STOP;
                            end else begin
                                index <= index + 1'b1;
                            end
                        end else if (sample == 4'd7) begin
                            // Sample in the middle
                            shift_reg[index] <= rx_sync;
                            sample <= sample + 1'b1;
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end
                    
                    STOP: begin
                        if (sample == 4'd15) begin
                            state <= IDLE;
                            if (rx_sync == 1'b1) begin
                                data_out <= shift_reg;
                                if (!rdy_clr) begin
                                    rdy <= 1'b1;
                                end
                            end
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end
                endcase
            end
        end
    end
endmodule