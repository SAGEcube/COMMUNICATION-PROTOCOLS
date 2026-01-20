`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Top Module
// - Integrates AXI4-Lite master and slave
// - Acts as a simple SoC-style wrapper
// - Exposes user-side control/status signals only
//////////////////////////////////////////////////////////////////////////////////
module top(
    input clk,
    input reset,

    // User-side control
    input wr_en,
    input rd_en,
    input [31:0] addr,
    input [31:0] wdata_in,

    // User-side outputs
    output [31:0] rdata_out,
    output read_done,
    output write_done,
    output busy,
    output error
);

    // AXI interconnect signals between master and slave
    wire awvalid, awready;
    wire wvalid,  wready;
    wire bvalid,  bready;
    wire arvalid, arready;
    wire rvalid,  rready;

    wire [31:0] awaddr, wdata, araddr, rdata;
    wire [1:0]  bresp, rresp;

    // ---------------- MASTER INSTANCE ----------------
    // Converts simple wr_en / rd_en requests into AXI4-Lite transactions
    master u_master(
        .clk(clk),
        .reset(reset),

        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wdata_in(wdata_in),

        .rdata_out(rdata_out),
        .read_done(read_done),
        .write_done(write_done),
        .busy(busy),
        .error(error),

        .awvalid(awvalid),
        .awaddr(awaddr),
        .awready(awready),

        .wvalid(wvalid),
        .wdata(wdata),
        .wready(wready),

        .bvalid(bvalid),
        .bresp(bresp),
        .bready(bready),

        .arvalid(arvalid),
        .araddr(araddr),
        .arready(arready),

        .rready(rready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rresp(rresp)
    );

    // ---------------- SLAVE INSTANCE ----------------
    // Simple register-mapped AXI4-Lite slave
    axi4 u_slave(
        .clk(clk),
        .reset(reset),

        .awvalid(awvalid),
        .awaddr(awaddr),
        .awready(awready),

        .wvalid(wvalid),
        .wdata(wdata),
        .wstrb(4'b1111),   // Full-word write
        .wready(wready),

        .bvalid(bvalid),
        .bresp(bresp),
        .bready(bready),

        .arvalid(arvalid),
        .araddr(araddr),
        .arready(arready),

        .rdata(rdata),
        .rvalid(rvalid),
        .rresp(rresp),
        .rready(rready)
    );

endmodule
   
