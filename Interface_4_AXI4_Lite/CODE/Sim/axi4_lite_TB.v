
//////////////////////////////////////////////////////////////////////////////////
// Top Testbench
// - Drives user-level read/write requests
// - Logs transaction timing and results
// - Generates waveform for debugging
//////////////////////////////////////////////////////////////////////////////////
module top_tb;

    // Clock and reset
    reg clk = 0;
    reg reset = 1;

    // User-side control signals
    reg wr_en = 0;
    reg rd_en = 0;
    reg [31:0] addr = 0;
    reg [31:0] wdata_in = 0;

    // User-side outputs
    wire [31:0] rdata_out;
    wire read_done;
    wire write_done;
    wire busy;
    wire error;

    // Transaction tracking (for console logs)
    integer txn_count = 0;
    integer start_time;

    // DUT instance
    top DUT(
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
        .error(error)
    );

    // 100 MHz clock generation
    always #5 clk = ~clk;

    initial begin
        // Enable waveform dumping
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_tb);

        // Apply reset
        reset = 1;
        #20;
        reset = 0;

        // ---------------- WRITE TRANSACTION ----------------
        @(posedge clk);
        txn_count = txn_count + 1;

        addr      <= 32'h10;
        wdata_in  <= 32'hAABBCCDD;
        wr_en     <= 1;

        start_time = $time;
        $display("---------------------------------------------------");
        $display("[%0t] TXN %0d START WRITE  Addr: 0x%h  Data: 0x%h", $time, txn_count, addr, wdata_in);

        @(posedge clk);
        wr_en <= 0;

        // Wait for write completion
        wait(write_done);

        $display("[%0t] TXN %0d END WRITE    Addr: 0x%h  Done: %b  Error: %b  BRESP: 00 (OKAY=0, SLVERR=2)", $time, txn_count, addr, write_done, error);
        $display("WRITE completed in %0t ns", $time - start_time);

        // ---------------- READ TRANSACTION ----------------
        @(posedge clk);
        addr  <= 32'h10;
        rd_en <= 1;

        start_time = $time;
        $display("[%0t] TXN %0d START READ   Addr: 0x%h", $time, txn_count, addr);

        @(posedge clk);
        rd_en <= 0;

        // Wait for read completion
        wait(read_done);

        $display("[%0t] TXN %0d END READ     Addr: 0x%h  Data: 0x%h  Error: %b  RRESP: 00 (OKAY=0, SLVERR=2)",  $time, txn_count, addr, rdata_out, error);
        $display("READ completed in %0t ns", $time - start_time);
        $display("---------------------------------------------------");

        // End simulation
        #50 $finish;
    end
endmodule

 
