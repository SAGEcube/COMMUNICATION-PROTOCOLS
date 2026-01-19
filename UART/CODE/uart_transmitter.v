// ============================================================================
// UART Transmitter Module (Corrected)
// ============================================================================
module uart_transmitter(
    input clk,
    input rst,
    input wr_enb,
    input enb,
    input [7:0] data_in,
    output reg tx,
    output reg busy  // Made reg for better control
);
    parameter IDLE  = 2'b00,
              START = 2'b01,
              DATA  = 2'b10,
              STOP  = 2'b11;
    
    reg [7:0] data;
    reg [2:0] index;
    reg [1:0] state;
    reg [1:0] next_state;
    
    // State register
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (wr_enb) next_state = START;
            end
            START: begin
                if (enb) next_state = DATA;
            end
            DATA: begin
                if (enb && (index == 3'd7)) next_state = STOP;
            end
            STOP: begin
                if (enb) next_state = IDLE;
            end
        endcase
    end
    
    // Output logic
    always @(posedge clk) begin
        if (rst) begin
            tx <= 1'b1;
            index <= 3'd0;
            data <= 8'd0;
            busy <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    if (wr_enb) begin
                        data <= data_in;
                        busy <= 1'b1;
                    end
                end
                
                START: begin
                    tx <= 1'b0;
                    index <= 3'd0;
                end
                
                DATA: begin
                    if (enb) begin
                        tx <= data[index];
                        if (index < 3'd7) begin
                            index <= index + 1'b1;
                        end
                    end
                end
                
                STOP: begin
                    if (enb) begin
                        tx <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
