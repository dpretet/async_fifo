`include "svut_h.sv"
`timescale 1 ns / 1 ps

module fifo_unit_test;

    `SVUT_SETUP

    parameter DSIZE = 8;
    parameter ASIZE = 4;

    wire [DSIZE-1:0] wdata;
    wire winc;
    wire wclk;
    wire wrst_n;
    wire rinc;
    wire rclk;
    wire rrst_n;
    wire [DSIZE-1:0] rdata;
    wire wfull;
    wire rempty;

    fifo 
    #(
    DSIZE,
    ASIZE
    )
    dut 
    (
    wdata,
    winc,
    wclk,
    wrst_n,
    rinc,
    rclk,
    rrst_n,
    rdata,
    wfull,
    rempty
    );

    // An example to create a clock
    // initial aclk = 0;
    // always #2 aclk <= ~aclk;

    // An example to dump data for visualization
    // initial $dumpvars(0,fifo_unit_test);

    task setup();
    begin
        // setup() runs when a test begins
    end
    endtask

    task teardown();
    begin
        // teardown() runs when a test ends
    end
    endtask

    `UNIT_TESTS

    `UNIT_TEST(TESTNAME)
        // Describe here your testcase
    `UNIT_TEST_END

    `UNIT_TESTS_END

endmodule

