`timescale 1 ns / 1 ps
`include "svut_h.sv"
`include "../../src/vlog/async_fifo.v"

module async_fifo_unit_test;

    `SVUT_SETUP

    parameter WIDTH		= 8;
    parameter POINTER	= 4;

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
    .WIDTH      (WIDTH),
    .POINTER    (POINTER)
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

    initial wr_clk = 0;
    initial rd_clk = 0;
    always #2 wr_clk <= ~wr_clk;
    always #2 rd_clk <= ~rd_clk;

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

