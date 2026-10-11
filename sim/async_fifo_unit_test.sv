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

    parameter DSIZE = 32;
    parameter ASIZE = 4;
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

    // Registered read instance for 100% architectural coverage of fifomem
    reg              winc_reg;
    reg  [DSIZE-1:0] wdata_reg;
    wire             wfull_reg;
    wire             awfull_reg;
    reg              rinc_reg;
    wire [DSIZE-1:0] rdata_reg;
    wire             rempty_reg;
    wire             arempty_reg;

    async_fifo
    #(
        .DSIZE        (DSIZE),
        .ASIZE        (ASIZE),
        .FALLTHROUGH  ("FALSE")
    )
    dut_reg
    (
        wclk,
        wrst_n,
        winc_reg,
        wdata_reg,
        wfull_reg,
        awfull_reg,
        rclk,
        rrst_n,
        rinc_reg,
        rdata_reg,
        rempty_reg,
        arempty_reg
    );

`ifdef VERILATOR
    // Functional coverage properties
    cov_wfull_assert: cover property (@(posedge wclk) disable iff (!wrst_n) wfull == 1'b1);
    cov_wfull_deassert: cover property (@(posedge wclk) disable iff (!wrst_n) wfull == 1'b0);
    cov_awfull_assert: cover property (@(posedge wclk) disable iff (!wrst_n) awfull == 1'b1);
    cov_rempty_assert: cover property (@(posedge rclk) disable iff (!rrst_n) rempty == 1'b1);
    cov_rempty_deassert: cover property (@(posedge rclk) disable iff (!rrst_n) rempty == 1'b0);
    cov_arempty_assert: cover property (@(posedge rclk) disable iff (!rrst_n) arempty == 1'b1);
    cov_winc_active: cover property (@(posedge wclk) disable iff (!wrst_n) (winc && !wfull));
    cov_winc_on_full: cover property (@(posedge wclk) disable iff (!wrst_n) (winc && wfull));
    cov_rinc_active: cover property (@(posedge rclk) disable iff (!rrst_n) (rinc && !rempty));
    cov_rinc_on_empty: cover property (@(posedge rclk) disable iff (!rrst_n) (rinc && rempty));
    cov_simultaneous_rw: cover property (@(posedge wclk) disable iff (!wrst_n) (winc && rinc));
`endif

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
        winc_reg = 1'b0;
        wdata_reg = 0;
        rinc_reg = 1'b0;
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

    `UNIT_TEST("TEST_SINGLE_WRITE_THEN_READ")

        @(posedge wclk)

        winc = 1;
        wdata = 32'hA;

        @(posedge wclk)

        winc = 0;

        @(posedge rclk)

        wait (rempty == 1'b0);

        rinc = 1;
        @(negedge rclk)

        `FAIL_IF_NOT_EQUAL(rdata, 32'hA);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_MULTIPLE_WRITE_THEN_READ")

        for (int i=0; i<10; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = i;
        end
        @(negedge wclk);
        winc = 0;

        #100;

        @(negedge rclk);
        rinc = 1;
        for (int i=0; i<10; i=i+1) begin
            `FAIL_IF_NOT_EQUAL(rdata, i);
            if (i == 9)
                rinc = 0;
            @(negedge rclk);
        end

    `UNIT_TEST_END

    `UNIT_TEST("TEST_FULL_FLAG")

        winc = 1;

        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk)
            wdata = i;
        end

        @(negedge wclk);
        winc = 0;

        @(posedge wclk)
        `FAIL_IF_NOT_EQUAL(wfull, 1);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_EMPTY_FLAG")

        `FAIL_IF_NOT_EQUAL(rempty, 1);

        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(posedge wclk)
            winc = 1;
            wdata = i;
        end

        `FAIL_IF_NOT_EQUAL(rempty, 0);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_ALMOST_EMPTY_FLAG")

        `FAIL_IF_NOT_EQUAL(arempty, 0);

        @(negedge wclk);
        winc = 1;
        wdata = 32'h1;
        @(negedge wclk);
        winc = 0;

        #100;
        `FAIL_IF_NOT_EQUAL(arempty, 1);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_ALMOST_FULL_FLAG")

        for (int i=0; i<2**ASIZE-1; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = i;
        end
        @(negedge wclk);
        winc = 0;

        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(awfull, 1);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_CONCURRENT_WRITE_READ")

        fork
        // Concurrent accesses
        begin
            fork
            // Write source
            begin
                for (int i=0; i<MAX_TRAFFIC; i=i+1) begin
                    while (wfull)
                        @(negedge wclk);
                    @(negedge wclk);
                    winc = 1;
                    wdata = i;
                end
                @(negedge wclk);
                winc = 0;
            end
            // Read sink
            begin
                rinc = 0;
                for (int i=0; i<MAX_TRAFFIC; i=i+1) begin
                    while (rempty)
                        @(negedge rclk);
                    `FAIL_IF_NOT_EQUAL(rdata, i);
                    rinc = 1;
                    @(negedge rclk);
                    rinc = 0;
                end
            end
            join
        end
        // Timeout management
        begin
            while (timeout<10000) begin
                timeout = timeout + 1;
                @(posedge rclk);
            end
            `ERROR("Reached timeout!");
        end
        join_any

    `UNIT_TEST_END

    `UNIT_TEST("TEST_FULL_TO_EMPTY_WRAPAROUND")

        // First pass: fill 16 words, empty 16 words
        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = i;
        end
        @(negedge wclk);
        winc = 0;
        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(wfull, 1);

        #100;

        @(negedge rclk);
        rinc = 1;
        for (int i=0; i<2**ASIZE; i=i+1) begin
            `FAIL_IF_NOT_EQUAL(rdata, i);
            @(negedge rclk);
        end
        rinc = 0;
        #100;
        `FAIL_IF_NOT_EQUAL(rempty, 1);

        // Second pass: fill 16 words, empty 16 words to wrap Gray pointers across full range
        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = i + 16;
        end
        @(negedge wclk);
        winc = 0;
        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(wfull, 1);

        #100;

        @(negedge rclk);
        rinc = 1;
        for (int i=0; i<2**ASIZE; i=i+1) begin
            `FAIL_IF_NOT_EQUAL(rdata, i + 16);
            @(negedge rclk);
        end
        rinc = 0;
        #100;
        `FAIL_IF_NOT_EQUAL(rempty, 1);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_DATA_BUS_TOGGLE")

        @(negedge wclk); winc = 1; wdata = 32'hFFFF_FFFF;
        @(negedge wclk); wdata = 32'h0000_0000;
        @(negedge wclk); wdata = 32'hAAAA_AAAA;
        @(negedge wclk); wdata = 32'h5555_5555;
        @(negedge wclk); wdata = 32'h1234_5678;
        @(negedge wclk); wdata = 32'hEDCB_A987;
        @(negedge wclk); winc = 0;

        #100;

        @(negedge rclk); rinc = 1;
        `FAIL_IF_NOT_EQUAL(rdata, 32'hFFFF_FFFF); @(negedge rclk);
        `FAIL_IF_NOT_EQUAL(rdata, 32'h0000_0000); @(negedge rclk);
        `FAIL_IF_NOT_EQUAL(rdata, 32'hAAAA_AAAA); @(negedge rclk);
        `FAIL_IF_NOT_EQUAL(rdata, 32'h5555_5555); @(negedge rclk);
        `FAIL_IF_NOT_EQUAL(rdata, 32'h1234_5678); @(negedge rclk);
        `FAIL_IF_NOT_EQUAL(rdata, 32'hEDCB_A987); @(negedge rclk);
        rinc = 0;

    `UNIT_TEST_END

    `UNIT_TEST("TEST_OVERFLOW_PROTECTION")

        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = 32'h100 + i;
        end
        @(negedge wclk);
        winc = 0;
        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(wfull, 1);

        // Attempt illegal writes while full
        for (int i=0; i<4; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = 32'hDEAD_BEEF;
        end
        @(negedge wclk);
        winc = 0;
        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(wfull, 1);

        #100;

        // Verify original data intact
        @(negedge rclk);
        rinc = 1;
        for (int i=0; i<2**ASIZE; i=i+1) begin
            `FAIL_IF_NOT_EQUAL(rdata, 32'h100 + i);
            if (i == 2**ASIZE - 1)
                rinc = 0;
            @(negedge rclk);
        end

    `UNIT_TEST_END

    `UNIT_TEST("TEST_UNDERFLOW_PROTECTION")

        `FAIL_IF_NOT_EQUAL(rempty, 1);

        // Attempt illegal reads while empty
        for (int i=0; i<4; i=i+1) begin
            @(negedge rclk);
            rinc = 1;
        end
        @(negedge rclk);
        rinc = 0;
        `FAIL_IF_NOT_EQUAL(rempty, 1);

        // Write a valid item and read it back
        @(negedge wclk);
        winc = 1;
        wdata = 32'hBEEF_CAFE;
        @(negedge wclk);
        winc = 0;

        #100;

        @(negedge rclk);
        `FAIL_IF_NOT_EQUAL(rempty, 0);
        `FAIL_IF_NOT_EQUAL(rdata, 32'hBEEF_CAFE);
        rinc = 1;
        @(negedge rclk);
        rinc = 0;
        #100;
        `FAIL_IF_NOT_EQUAL(rempty, 1);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_SIMULTANEOUS_FULL_READ_WRITE")

        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk);
            winc = 1;
            wdata = 32'hA0 + i;
        end
        @(negedge wclk);
        winc = 0;
        #100;
        `FAIL_IF_NOT_EQUAL(wfull, 1);

        fork
            begin
                @(negedge wclk);
                winc = 1;
                wdata = 32'hFF;
                @(negedge wclk);
                winc = 0;
            end
            begin
                @(negedge rclk);
                rinc = 1;
                @(negedge rclk);
                rinc = 0;
            end
        join

        #100;

    `UNIT_TEST_END

    `UNIT_TEST("TEST_CONSECUTIVE_RESETS")

        @(negedge wclk);
        winc = 1;
        wdata = 32'h55;
        @(negedge wclk);
        wdata = 32'hAA;

        wrst_n = 0;
        rrst_n = 0;
        #100;
        wrst_n = 1;
        rrst_n = 1;
        winc = 0;
        rinc = 0;
        #50;

        `FAIL_IF_NOT_EQUAL(rempty, 1);
        `FAIL_IF_NOT_EQUAL(wfull, 0);

    `UNIT_TEST_END

    `UNIT_TEST("TEST_REGISTERED_READ_MODE")

        // First pass: fill 16 words, check wfull_reg
        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk);
            winc_reg = 1;
            wdata_reg = 32'h200 + i;
        end
        @(negedge wclk);
        winc_reg = 0;
        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(wfull_reg, 1);

        #100;

        // In registered read mode, pulse rinc_reg to read each word
        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge rclk);
            rinc_reg = 1;
            @(negedge rclk);
            `FAIL_IF_NOT_EQUAL(rdata_reg, 32'h200 + i);
            rinc_reg = 0;
        end
        #100;
        `FAIL_IF_NOT_EQUAL(rempty_reg, 1);

        // Second pass: wrap Gray pointers in dut_reg
        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge wclk);
            winc_reg = 1;
            wdata_reg = 32'h300 + i;
        end
        @(negedge wclk);
        winc_reg = 0;
        @(posedge wclk);
        `FAIL_IF_NOT_EQUAL(wfull_reg, 1);

        #100;

        for (int i=0; i<2**ASIZE; i=i+1) begin
            @(negedge rclk);
            rinc_reg = 1;
            @(negedge rclk);
            `FAIL_IF_NOT_EQUAL(rdata_reg, 32'h300 + i);
            rinc_reg = 0;
        end
        #100;
        `FAIL_IF_NOT_EQUAL(rempty_reg, 1);

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule

