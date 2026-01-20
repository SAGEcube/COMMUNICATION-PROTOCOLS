
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// AXI4-Lite Slave
// - 32 x 32-bit register file
// - Independent read/write handling
//////////////////////////////////////////////////////////////////////////////////

module axi4 (
    input  wire        clk,
    input  wire        reset,

    // Write Address
    input  wire        awvalid,
    input  wire [31:0] awaddr,
    output reg         awready,

    // Write Data
    input  wire        wvalid,
    input  wire [31:0] wdata,
  	input  [3:0] wstrb,
    output reg         wready,

    // Write Response
    output reg         bvalid,
    output reg [1:0]   bresp,
    input  wire        bready,

    // Read Address
    input  wire        arvalid,
    input  wire [31:0] araddr,
    output reg         arready,

    // Read Data
    output reg [31:0]  rdata,
    output reg         rvalid,
    output reg [1:0]   rresp,
    input  wire        rready
);

    reg [31:0] my_reg [0:31];
    reg        aw_hs, w_hs, ar_hs;
    reg [4:0]  aw_index, ar_index;

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            awready <= 0; wready <= 0; bvalid <= 0;
            arready <= 0; rvalid <= 0;
            bresp <= 0; rresp <= 0;
            aw_hs <= 0; w_hs <= 0; ar_hs <= 0;

            for (i = 0; i < 32; i = i + 1)
                my_reg[i] <= 0;
        end else begin
            // Write handshake
            awready <= awvalid && !aw_hs;
            wready  <= wvalid  && !w_hs;

            if (awvalid && awready) begin
                aw_hs <= 1;
                aw_index <= awaddr[6:2];
            end

            if (wvalid && wready)
                w_hs <= 1;

            if (aw_hs && w_hs)
                my_reg[aw_index] <= wdata;

            if (!bvalid && aw_hs && w_hs) begin
                bvalid <= 1;
                bresp  <= 2'b00;
            end

            if (bvalid && bready) begin
                bvalid <= 0;
                aw_hs  <= 0;
                w_hs   <= 0;
            end

            // Read handshake
            arready <= arvalid && !ar_hs;

            if (arvalid && arready) begin
                ar_hs <= 1;
                ar_index <= araddr[6:2];
            end

            if (ar_hs && !rvalid) begin
                rdata  <= my_reg[ar_index];
                rvalid <= 1;
                rresp  <= 2'b00;
            end

            if (rvalid && rready) begin
                rvalid <= 0;
                ar_hs  <= 0;
            end
        end
    end
endmodule
 
