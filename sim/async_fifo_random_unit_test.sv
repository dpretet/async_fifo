`include "svut_h.sv"
`timescale 1 ns / 1 ps

module async_fifo_random_unit_test;

    `SVUT_SETUP

    `ifndef FALLTHROUGH
    `define FALLTHROUGH "TRUE"
    `endif

    `ifndef CLK_I
    `define CLK_I 3
    `endif

    `ifndef CLK_O
    `define CLK_O 3
    `endif

    parameter DSIZE = 32;
    parameter ASIZE = 4;
    parameter FALLTHROUGH = `FALLTHROUGH;
    parameter MAX_TRAFFIC = 1000;
    parameter MAX_TIMEOUT = MAX_TRAFFIC * 10;

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
    reg  [DSIZE-1:0] rdata_expected;
    wire             rempty;
    wire             arempty;

    logic en_i, en_o, run_traffic;
    logic [31:0] lfsr_i, lfsr_o;
    logic [31:0] cnt_i, cnt_o, xfer_cnt;
    logic [31:0] w_lfsr, r_lfsr;

    ////////////////////////////////////////
    // Design Under Test
    ////////////////////////////////////////

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

    ////////////////////////////////////////
    // LFSR Instances
    ////////////////////////////////////////

    lfsr32
    #(
    .KEY (32'hAAAAAAAA)
    )
    lfsr_driver
    (
    .aclk    (wclk),
    .aresetn (wrst_n),
    .srst    ('0),
    .en      (en_i),
    .lfsr    (lfsr_i)
    );

    lfsr32
    #(
    .KEY (32'h55555555)
    )
    lfsr_monitor
    (
    .aclk    (rclk),
    .aresetn (rrst_n),
    .srst    ('0),
    .en      (en_o),
    .lfsr    (lfsr_o)
    );

    ////////////////////////////////////////
    // Initialization
    ////////////////////////////////////////

    initial wclk = 1'b0;
    always #`CLK_I wclk <= !wclk;
    initial rclk = 1'b0;
    always #`CLK_O rclk <= !rclk;

    initial begin
        $dumpfile("async_fifo_random_unit_test.vcd");
        $dumpvars(0, async_fifo_random_unit_test);
    end

    task setup(msg="Setup testcase");
    begin
        run_traffic = 1'b0;
        wrst_n = 1'b1;
        rrst_n = 1'b1;
        #0;
        wrst_n = 1'b0;
        rrst_n = 1'b0;
        #50;
        @(posedge wclk);

    end
    endtask

    task teardown(msg="Tearing down");
    begin
        #50;
    end
    endtask



    ////////////////////////////////////////
    // Traffic Randomness Injection
    ////////////////////////////////////////

    always @ (posedge wclk or negedge wrst_n) begin

        if (!wrst_n) begin
            w_lfsr <= 32'b0;
        end else begin

            // At startup init with LFSR default value
            if (w_lfsr==32'b0) begin
                w_lfsr <= lfsr_i;
            // Use to randomly assert awvalid/wvalid
            end else if (!winc) begin
                w_lfsr <= w_lfsr >> 1;
            end else if (!wfull) begin
                w_lfsr <= lfsr_i;
            end
        end

        if (!wrst_n) begin
            wdata <= 32'b0;
        end begin
            if (winc & !wfull)
                wdata <= wdata + 1;
        end

    end

    assign en_i = winc & !wfull;
    assign winc = w_lfsr[0] & wrst_n & run_traffic;

    always @ (posedge rclk or negedge rrst_n) begin

        if (!rrst_n) begin
            r_lfsr <= 32'b0;
        end else begin

            // At startup init with LFSR default value
            if (r_lfsr==32'b0) begin
                r_lfsr <= lfsr_o;
            // Use to randomly assert awvalid/wvalid
            end else if (!rinc) begin
                r_lfsr <= r_lfsr >> 1;
            end else if (!rempty) begin
                r_lfsr <= lfsr_o;
            end
        end

        if (!rrst_n) begin
            rdata_expected <= 32'b0;
        end begin
            if (rinc & !rempty) begin
                rdata_expected <= rdata_expected + 1;
                if (rdata != rdata_expected)
                    `ERROR("Wrong data read from FIFO!");
            end
        end

    end

    assign en_o = rinc & !rempty;
    assign rinc = r_lfsr[0] & rrst_n & run_traffic;


    ////////////////////////////////////////
    // SVUT TESTSUITE FLOW
    ////////////////////////////////////////
    `TEST_SUITE("RANDOM")

    `UNIT_TEST("RANDOMNESS")
        timeout = 0;
        xfer_cnt = 0;
        #100;
        wrst_n = 1;
        rrst_n = 1;
        run_traffic = 1'b1;

        while ((xfer_cnt < MAX_TRAFFIC) && (timeout < MAX_TIMEOUT)) begin
            @(posedge rclk);
            if ((rempty == 1'b0) && (rinc == 1'b1))
                xfer_cnt = xfer_cnt + 1;
            timeout = timeout + 1;
        end

        run_traffic = 1'b0;
        if (xfer_cnt < MAX_TRAFFIC)
            `ERROR("Simulation reached timeout!");
    `UNIT_TEST_END

    `TEST_SUITE_END
endmodule
