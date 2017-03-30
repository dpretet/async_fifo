`include "svut_h.sv"
`include "../../src/vlog/async_fifo.v"
`timescale 1 ns / 1 ps

module async_fifo_unit_test;

    `SVUT_SETUP

    parameter WIDTH  = 8;
    parameter POINTER = 4;

    reg              wr_clk;
    reg              wr_arstn;
    reg              wr_en;
    reg  [WIDTH-1:0] wr_data;
    wire             wr_full;
    reg              rd_clk;
    reg              rd_arstn;
    reg              rd_en;
    wire [WIDTH-1:0] rd_data;
    wire             rd_empty;

    async_fifo 
    #(
    .WIDTH (WIDTH),
    .POINTER (POINTER)
    )
    dut 
    (
    wr_clk,
    wr_arstn,
    wr_en,
    wr_data,
    wr_full,
    rd_clk,
    rd_arstn,
    rd_en,
    rd_data,
    rd_empty
    );

    // An example to create a clock
    initial wr_clk = 0;
    initial rd_clk = 0;
    always #2 wr_clk = ~wr_clk;
    always #2 rd_clk = ~rd_clk;

    // An example to dump data for visualization
    initial $dumpvars(0,async_fifo_unit_test);

    task setup();
    begin
        wr_arstn = 1;
        rd_arstn = 1;
        init_write();
        init_read();
        #50;
        wr_arstn = 1;
        rd_arstn = 1;
    end
    endtask

    task teardown();
    begin
        // teardown() runs when a test ends
    end
    endtask

    task init_write();
    begin
        wr_arstn = 0;
        wr_en = 1'b0;
        wr_data = 0;
    end
    endtask

    task init_read();
    begin
        rd_arstn = 0;
        rd_en = 1'b0;
    end
    endtask

    `UNIT_TESTS

    `UNIT_TEST(INIT_FIFO)
        wait (wr_full == 1'b0);
        wait (rd_empty == 1'b0);
    `UNIT_TEST_END

    `UNIT_TESTS_END

endmodule

