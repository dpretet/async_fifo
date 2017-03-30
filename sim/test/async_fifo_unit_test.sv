`timescale 1 ns / 1 ps
`include "svut_h.sv"
`include "../../src/vlog/async_fifo.v"

module async_fifo_unit_test;

    `SVUT_SETUP

    parameter WIDTH  = 8;
    parameter POINTER = 4;

    reg              wr_clk;
    reg              awresetn;
    reg              wren;
    reg  [WIDTH-1:0] data_in;
    wire             wr_full;
    reg              rd_clk;
    reg              arresetn;
    reg              rden;
    wire [WIDTH-1:0] data_out;
    wire             rd_empty;

    async_fifo 
    #(
    ,
    POINTER
    )
    dut 
    (
    wr_clk,
    awresetn,
    wren,
    data_in,
    wr_full,
    rd_clk,
    arresetn,
    rden,
    data_out,
    rd_empty
    );

    // An example to create a clock
    // initial aclk = 0;
    // always #2 aclk <= ~aclk;

    // An example to dump data for visualization
    // initial $dumpvars(0,async_fifo_unit_test);

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

