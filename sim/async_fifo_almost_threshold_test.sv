
`include "svut_h.sv"
`timescale 1 ns / 1 ps

module async_fifo_unit_test;

    `SVUT_SETUP

    `ifndef AEMPTY
    `define AEMPTY 1
    `endif

    `ifndef AFULL
    `define AFULL 1
    `endif

    `ifndef FALLTHROUGH
    `define FALLTHROUGH "TRUE"
    `endif

    parameter DSIZE = 16;
    parameter ASIZE = 13;
    parameter AREMPTYSIZE = `AEMPTY;
    parameter AWFULLSIZE = 4096;
    parameter FALLTHROUGH = `FALLTHROUGH;
    parameter MAX_TRAFFIC = 10;

    integer timeout;

    reg              wclk;
    reg              wrst_n;
    reg              winc;
    reg  [DSIZE-1:0] wdata;
    wire             wfull;
    wire             awfull;
    reg              rclk;
    reg              rrst_n;
    reg              rinc;
    wire [DSIZE-1:0] rdata;
    wire             rempty;
    wire             arempty;

    async_fifo
    #(
        .DSIZE        (DSIZE),
        .ASIZE        (ASIZE),
        .AWFULLSIZE   (AWFULLSIZE),
        .AREMPTYSIZE  (AREMPTYSIZE),
        .FALLTHROUGH  (FALLTHROUGH)
    )
    dut
    (
        wclk,
        wrst_n,
        winc,
        wdata,
        wfull,
        awfull,
        rclk,
        rrst_n,
        rinc,
        rdata,
        rempty,
        arempty
    );

    // An example to create a clock
    initial wclk = 1'b0;
    always #2 wclk <= ~wclk;
    initial rclk = 1'b0;
    always #3 rclk <= ~rclk;

    // An example to dump data for visualization
    initial begin
        $dumpfile("async_fifo_unit_test.vcd");
        $dumpvars(0, async_fifo_unit_test);
    end

    task setup(msg="Setup testcase");
    begin

        wrst_n = 1'b0;
        winc = 1'b0;
        wdata = 0;
        rrst_n = 1'b0;
        rinc = 1'b0;
        #100;
        wrst_n = 1;
        rrst_n = 1;
        #50;
        timeout = 0;
        @(posedge wclk);

    end
    endtask

    task teardown(msg="Tearing down");
    begin
        #50;
    end
    endtask

    `TEST_SUITE("ASYNCFIFO")

    `UNIT_TEST("TEST_IDLE")

        `FAIL_IF(wfull);
        `FAIL_IF(!rempty);

    `UNIT_TEST_END


    `UNIT_TEST("TEST_MULTIPLE_WRITE_THEN_READ")


        // repeat for 3 times

        for( int j = 0; j < 3; j= j+1)begin

            // write 4096 data
            winc = 1;
            for (int i=0; i<(2**(ASIZE-1)); i=i+1) begin

                @(negedge wclk)
                wdata = i;

            end

            @(negedge wclk);
            winc = 0;

            @(posedge wclk)
            `FAIL_IF_NOT_EQUAL(awfull, 1);


            // try to read it
            @(posedge rclk);

            rinc = 1;
            for (int i=0;  i<(2**(ASIZE-1)); i=i+1) begin
                @(posedge rclk);
                `FAIL_IF_NOT_EQUAL(rdata, i);
            end
            @(negedge rclk);
            rinc = 0;

            `FAIL_IF(rempty == 0);

        end


    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule