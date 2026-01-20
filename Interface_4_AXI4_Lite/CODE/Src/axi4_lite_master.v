`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// AXI4-Lite Master
// - Supports single read OR single write at a time
// - FSM-based sequencing for AW/W/B and AR/R channels
// - Designed for clarity and educational correctness
//////////////////////////////////////////////////////////////////////////////////
module master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  clk,
    input  reset,

    // User-side control
    input  wr_en,
    input  rd_en,
    input  [ADDR_WIDTH-1:0] addr,
    input  [DATA_WIDTH-1:0] wdata_in,

    // User-side status
    output reg [DATA_WIDTH-1:0] rdata_out,
    output reg read_done,
    output reg write_done,
    output reg busy,
    output reg error,        // Set on SLVERR response

    // AXI Write Address Channel
    output reg awvalid,
    output reg [ADDR_WIDTH-1:0] awaddr,
    input  awready,

    // AXI Write Data Channel
    output reg wvalid,
    output reg [DATA_WIDTH-1:0] wdata,
    input  wready,

    // AXI Write Response Channel
    input  bvalid,
    input  [1:0] bresp,
    output reg bready,

    // AXI Read Address Channel
    output reg arvalid,
    output reg [ADDR_WIDTH-1:0] araddr,
    input  arready,

    // AXI Read Data Channel
    output reg rready,
    input  [DATA_WIDTH-1:0] rdata,
    input  rvalid,
    input  [1:0] rresp
);

    // ---------------- WRITE FSM STATES ----------------
    localparam W_IDLE = 3'b000;  // Idle / waiting for write request
    localparam W_AW   = 3'b001;  // Send write address
    localparam W_W    = 3'b010;  // Send write data
    localparam W_B    = 3'b011;  // Wait for write response
    localparam W_DONE = 3'b100;  // Write complete

    reg [2:0] w_state;

    // ---------------- READ FSM STATES -----------------
    localparam R_IDLE = 2'b00;   // Idle / waiting for read request
    localparam R_AR   = 2'b01;   // Send read address
    localparam R_R    = 2'b10;   // Receive read data
    localparam R_DONE = 2'b11;   // Read complete

    reg [1:0] r_state;

    // Latches to hold address/data during transactions
    reg [ADDR_WIDTH-1:0] waddr_latch, raddr_latch;
    reg [DATA_WIDTH-1:0] wdata_latch;

    // Edge detection for wr_en / rd_en
    reg wr_d, rd_d;

    always @(posedge clk) begin
        if(reset) begin
            // Reset all FSMs and outputs
            w_state <= W_IDLE;
            r_state <= R_IDLE;

            awvalid <= 0; wvalid <= 0; bready <= 0;
            arvalid <= 0; rready <= 0;

            write_done <= 0;
            read_done  <= 0;
            busy       <= 0;
            error      <= 0;

            wr_d <= 0;
            rd_d <= 0;
        end else begin
            // Edge detect
            wr_d <= wr_en;
            rd_d <= rd_en;

            // Detect illegal simultaneous read & write request
            if(wr_en && rd_en && !wr_d && !rd_d)
                error <= 1;

            // Busy whenever any FSM is active
            busy <= (w_state != W_IDLE) || (r_state != R_IDLE);

            // ---------------- WRITE FSM ----------------
            case(w_state)
                W_IDLE: begin
                    write_done <= 0;
                    if(wr_en && !wr_d && !busy) begin
                        waddr_latch <= addr;
                        wdata_latch <= wdata_in;
                        error <= 0;
                        w_state <= W_AW;
                    end
                end

                W_AW: begin
                    awvalid <= 1;
                    awaddr  <= waddr_latch;
                    if(awready) begin
                        awvalid <= 0;
                        w_state <= W_W;
                    end
                end

                W_W: begin
                    wvalid <= 1;
                    wdata  <= wdata_latch;
                    if(wready) begin
                        wvalid <= 0;
                        bready <= 1;
                        w_state <= W_B;
                    end
                end

                W_B: begin
                    if(bvalid) begin
                        error  <= (bresp == 2'b10); // SLVERR
                        bready <= 0;
                        w_state <= W_DONE;
                    end
                end

                W_DONE: begin
                    write_done <= 1;
                    w_state <= W_IDLE;
                end
            endcase

            // ---------------- READ FSM -----------------
            case(r_state)
                R_IDLE: begin
                    read_done <= 0;
                    if(rd_en && !rd_d && !busy) begin
                        raddr_latch <= addr;
                        error <= 0;
                        r_state <= R_AR;
                    end
                end

                R_AR: begin
                    arvalid <= 1;
                    araddr  <= raddr_latch;
                    if(arready) begin
                        arvalid <= 0;
                        rready  <= 1;
                        r_state <= R_R;
                    end
                end

                R_R: begin
                    if(rvalid) begin
                        rdata_out <= rdata;
                        error <= (rresp == 2'b10); // SLVERR
                        rready <= 0;
                        r_state <= R_DONE;
                    end
                end

                R_DONE: begin
                    read_done <= 1;
                    r_state <= R_IDLE;
                end
            endcase
        end
    end
endmodule
  
