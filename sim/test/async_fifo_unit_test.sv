`include "svut_h.sv"
`timescale 1 ns / 1 ps

module async_fifo_unit_test;

    `SVUT_SETUP

    integer i;

    parameter DSIZE = 32;
    parameter ASIZE = 4;

    reg              wclk;
    reg              wrst_n;
    reg              winc;
    reg  [DSIZE-1:0] wdata;
    wire             wfull;
    reg              rclk;
    reg              rrst_n;
    reg              rinc;
    wire [DSIZE-1:0] rdata;
    wire             rempty;

    async_fifo 
    #(
    DSIZE,
    ASIZE
    )
    dut 
    (
    wclk,
    wrst_n,
    winc,
    wdata,
    wfull,
    rclk,
    rrst_n,
    rinc,
    rdata,
    rempty
    );

    // An example to create a clock
    initial wclk = 1'b0;
    always #2 wclk <= ~wclk;
    initial rclk = 1'b0;
    always #3 rclk <= ~rclk;

    // An example to dump data for visualization
    initial $dumpvars(0,async_fifo_unit_test);

    task setup();
    begin
        wrst_n = 1'b0;
        winc = 1'b0;
        wdata = 0;
        rrst_n = 1'b0;
        rinc = 1'b0;
        #100;
        wrst_n = 1;
        rrst_n = 1;
        #200;
        @(posedge wclk);
    end
    endtask

    task teardown();
    begin
        // teardown() runs when a test ends
    end
    endtask

    `UNIT_TESTS

    `UNIT_TEST(IDLE)
        `INFO("Start IDLE test");
        `FAIL_IF(wfull);
        `FAIL_IF(!rempty);
    `UNIT_TEST_END

    `UNIT_TEST(SIMPLE_WRITE_AND_READ)
        `INFO("Simple write then read");
        @(posedge wclk)
        winc = 1;
        wdata = 32'hA;
        @(posedge wclk)
        winc = 0;

        @(posedge rclk)
        wait (rempty == 0);
        `FAIL_IF_NOT_EQUAL(rdata, 32'hA);

    `UNIT_TEST_END

    `UNIT_TEST(MULTIPLE_WRITE_AND_READ)
        `INFO("Multiple write then read");
        for (i=0; i<20; i = i+1) begin
            @(posedge wclk)
            winc = 1;
            wdata = i;
            @(posedge wclk)
            winc = 0;
            @(posedge rclk)
            wait (rempty == 0);
            `FAIL_IF_NOT_EQUAL(rdata, i);
        end
    `UNIT_TEST_END

    `UNIT_TEST(TEST_FULL_FLAG)
        `INFO("Test full flag test");
        @(posedge wclk)
        for (i=0; i<2**ASIZE; i = i+1) begin
            @(posedge wclk)
            winc = 1;
            wdata = i;
            `FAIL_IF_NOT_EQUAL(wfull, 1);
        end
        @(posedge wclk)
        #50;
    `UNIT_TEST_END

    `UNIT_TEST(TEST_EMPTY_FLAG)
        `INFO("Test empty flag test");
        @(posedge wclk)
        for (i=0; i<2**ASIZE; i = i+1) begin
            @(posedge wclk)
            winc = 1;
            wdata = i;
            `FAIL_IF_NOT_EQUAL(wfull, 1);
        end
        @(posedge wclk)
        #50;
    `UNIT_TEST_END

    `UNIT_TESTS_END

endmodule

