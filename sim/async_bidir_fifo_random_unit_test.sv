`include "svut_h.sv"
`timescale 1 ns / 1 ps

`ifndef BIDIR_TEST_MODULE
`define BIDIR_TEST_MODULE async_bidir_fifo_random_unit_test
`endif

module `BIDIR_TEST_MODULE;

    `SVUT_SETUP

    `ifndef CLK_A
    `define CLK_A 3
    `endif

    `ifndef CLK_B
    `define CLK_B 3
    `endif

    parameter DSIZE = 32;
    parameter ASIZE = 4;
    parameter MAX_TRAFFIC = 1000;
    parameter MAX_TIMEOUT = MAX_TRAFFIC * 20;

    reg a_clk;
    reg a_rst_n;
    reg a_dir;
    reg b_clk;
    reg b_rst_n;
    reg b_dir;

    reg source_enable;
    reg sink_enable;
    wire traffic_active = source_enable | sink_enable;

    reg  [DSIZE-1:0] a_wdata;
    reg  [DSIZE-1:0] b_wdata;
    wire [DSIZE-1:0] a_rdata;
    wire [DSIZE-1:0] b_rdata;
    wire             a_winc;
    wire             a_rinc;
    wire             b_winc;
    wire             b_rinc;
    wire             a_full;
    wire             a_afull;
    wire             a_empty;
    wire             a_aempty;
    wire             b_full;
    wire             b_afull;
    wire             b_empty;
    wire             b_aempty;

    logic [31:0] a_w_random;
    logic [31:0] a_r_random;
    logic [31:0] b_w_random;
    logic [31:0] b_r_random;

    integer a_write_count;
    integer a_read_count;
    integer b_write_count;
    integer b_read_count;
    integer timeout;
    reg [DSIZE-1:0] a_expected;
    reg [DSIZE-1:0] b_expected;
    reg a_read_error;
    reg b_read_error;

    assign a_winc = source_enable && a_dir &&
                    (a_write_count < MAX_TRAFFIC) && a_w_random[0];
    assign a_rinc = sink_enable && !a_dir &&
                    (a_read_count < MAX_TRAFFIC) && a_r_random[0];
    assign b_winc = source_enable && b_dir &&
                    (b_write_count < MAX_TRAFFIC) && b_w_random[0];
    assign b_rinc = sink_enable && !b_dir &&
                    (b_read_count < MAX_TRAFFIC) && b_r_random[0];

`ifdef EXTERNAL_RAM
    localparam RAM_DEPTH = 1 << ASIZE;
    reg [DSIZE-1:0] ext_ram [0:RAM_DEPTH-1];
    wire             ram_a_clk;
    wire [DSIZE-1:0] ram_a_wdata;
    wire [DSIZE-1:0] ram_a_rdata;
    wire [ASIZE-1:0] ram_a_addr;
    wire             ram_a_rinc;
    wire             ram_a_winc;
    wire             ram_b_clk;
    wire [DSIZE-1:0] ram_b_wdata;
    wire [DSIZE-1:0] ram_b_rdata;
    wire [ASIZE-1:0] ram_b_addr;
    wire             ram_b_rinc;
    wire             ram_b_winc;

    async_bidir_ramif_fifo
    #(
        .DSIZE (DSIZE),
        .ASIZE (ASIZE)
    ) dut (
        .a_clk   (a_clk),
        .a_rst_n (a_rst_n),
        .a_winc  (a_winc),
        .a_wdata (a_wdata),
        .a_rinc  (a_rinc),
        .a_rdata (a_rdata),
        .a_full  (a_full),
        .a_afull (a_afull),
        .a_empty (a_empty),
        .a_aempty(a_aempty),
        .a_dir   (a_dir),
        .o_ram_a_clk  (ram_a_clk),
        .o_ram_a_wdata(ram_a_wdata),
        .i_ram_a_rdata(ram_a_rdata),
        .o_ram_a_addr (ram_a_addr),
        .o_ram_a_rinc (ram_a_rinc),
        .o_ram_a_winc (ram_a_winc),
        .b_clk   (b_clk),
        .b_rst_n (b_rst_n),
        .b_winc  (b_winc),
        .b_wdata (b_wdata),
        .b_rinc  (b_rinc),
        .b_rdata (b_rdata),
        .b_full  (b_full),
        .b_afull (b_afull),
        .b_empty (b_empty),
        .b_aempty(b_aempty),
        .b_dir   (b_dir),
        .o_ram_b_clk  (ram_b_clk),
        .o_ram_b_wdata(ram_b_wdata),
        .i_ram_b_rdata(ram_b_rdata),
        .o_ram_b_addr (ram_b_addr),
        .o_ram_b_rinc (ram_b_rinc),
        .o_ram_b_winc (ram_b_winc)
    );

    // Combinational reads provide the FIFO's first-word-fall-through contract.
    assign ram_a_rdata = ext_ram[ram_a_addr];
    assign ram_b_rdata = ext_ram[ram_b_addr];

    always @(posedge ram_a_clk)
        if (ram_a_winc)
            ext_ram[ram_a_addr] <= ram_a_wdata;

    always @(posedge ram_b_clk)
        if (ram_b_winc)
            ext_ram[ram_b_addr] <= ram_b_wdata;
`else
    async_bidir_fifo
    #(
        .DSIZE (DSIZE),
        .ASIZE (ASIZE)
    ) dut (
        .a_clk   (a_clk),
        .a_rst_n (a_rst_n),
        .a_winc  (a_winc),
        .a_wdata (a_wdata),
        .a_rinc  (a_rinc),
        .a_rdata (a_rdata),
        .a_full  (a_full),
        .a_afull (a_afull),
        .a_empty (a_empty),
        .a_aempty(a_aempty),
        .a_dir   (a_dir),
        .b_clk   (b_clk),
        .b_rst_n (b_rst_n),
        .b_winc  (b_winc),
        .b_wdata (b_wdata),
        .b_rinc  (b_rinc),
        .b_rdata (b_rdata),
        .b_full  (b_full),
        .b_afull (b_afull),
        .b_empty (b_empty),
        .b_aempty(b_aempty),
        .b_dir   (b_dir)
    );
`endif

    lfsr32 #(.KEY(32'hAAAAAAAA)) a_write_randomizer (
        .aclk(a_clk), .aresetn(a_rst_n), .srst('0),
        .en(traffic_active), .lfsr(a_w_random)
    );
    lfsr32 #(.KEY(32'h55555555)) a_read_randomizer (
        .aclk(a_clk), .aresetn(a_rst_n), .srst('0),
        .en(traffic_active), .lfsr(a_r_random)
    );
    lfsr32 #(.KEY(32'hCCCCCCCC)) b_write_randomizer (
        .aclk(b_clk), .aresetn(b_rst_n), .srst('0),
        .en(traffic_active), .lfsr(b_w_random)
    );
    lfsr32 #(.KEY(32'h33333333)) b_read_randomizer (
        .aclk(b_clk), .aresetn(b_rst_n), .srst('0),
        .en(traffic_active), .lfsr(b_r_random)
    );

    initial a_clk = 1'b0;
    always #`CLK_A a_clk <= ~a_clk;
    initial b_clk = 1'b0;
    always #`CLK_B b_clk <= ~b_clk;

    initial begin
`ifdef EXTERNAL_RAM
        $dumpfile("async_bidir_ramif_fifo_random_unit_test.vcd");
`else
        $dumpfile("async_bidir_fifo_random_unit_test.vcd");
`endif
`ifdef EXTERNAL_RAM
        $dumpvars(0, async_bidir_ramif_fifo_random_unit_test);
`else
        $dumpvars(0, async_bidir_fifo_random_unit_test);
`endif
    end

    task setup(msg="Setup testcase");
    begin
        source_enable = 1'b0;
        sink_enable = 1'b0;
        a_dir = 1'b1;
        b_dir = 1'b0;
        a_rst_n = 1'b0;
        b_rst_n = 1'b0;
        #50;
        a_rst_n = 1'b1;
        b_rst_n = 1'b1;
        #50;
    end
    endtask

    task teardown(msg="Tearing down");
    begin
        #50;
    end
    endtask

    always @(posedge a_clk or negedge a_rst_n) begin
        if (!a_rst_n) begin
            a_wdata       <= '0;
            a_write_count <= 0;
            a_read_count  <= 0;
            a_expected    <= '0;
            a_read_error  <= 1'b0;
        end else begin
            if (a_winc && !a_full) begin
                a_wdata       <= a_wdata + 1'b1;
                a_write_count <= a_write_count + 1;
            end

            if (a_rinc && !a_empty) begin
                if (a_rdata !== a_expected) begin
                    $display("A-side read mismatch: got %h, expected %h", a_rdata, a_expected);
                    `ERROR("B-to-A data mismatch");
                    a_read_error <= 1'b1;
                end
                a_expected   <= a_expected + 1'b1;
                a_read_count <= a_read_count + 1;
            end
        end
    end

    always @(posedge b_clk or negedge b_rst_n) begin
        if (!b_rst_n) begin
            b_wdata       <= '0;
            b_write_count <= 0;
            b_read_count  <= 0;
            b_expected    <= '0;
            b_read_error  <= 1'b0;
        end else begin
            if (b_winc && !b_full) begin
                b_wdata       <= b_wdata + 1'b1;
                b_write_count <= b_write_count + 1;
            end

            if (b_rinc && !b_empty) begin
                if (b_rdata !== b_expected) begin
                    $display("B-side read mismatch: got %h, expected %h", b_rdata, b_expected);
                    `ERROR("A-to-B data mismatch");
                    b_read_error <= 1'b1;
                end
                b_expected   <= b_expected + 1'b1;
                b_read_count <= b_read_count + 1;
            end
        end
    end

    task run_a_to_b;
    begin
        a_dir = 1'b1;
        b_dir = 1'b0;
        @(negedge a_clk);
        @(negedge b_clk);
        timeout = 0;
        source_enable = 1'b1;
        sink_enable = 1'b1;

        while ((a_write_count < MAX_TRAFFIC || b_read_count < MAX_TRAFFIC) &&
               (timeout < MAX_TIMEOUT) && !b_read_error) begin
            @(posedge b_clk);
            timeout = timeout + 1;
        end

        source_enable = 1'b0;
        sink_enable = 1'b0;

        if (!b_read_error) begin
            `FAIL_IF_NOT_EQUAL(a_write_count, MAX_TRAFFIC);
            `FAIL_IF_NOT_EQUAL(b_read_count, MAX_TRAFFIC);
            `FAIL_IF_NOT_EQUAL(b_empty, 1'b1);
        end
    end
    endtask

    task run_b_to_a;
    begin
        a_dir = 1'b0;
        b_dir = 1'b1;
        @(negedge a_clk);
        @(negedge b_clk);
        timeout = 0;
        source_enable = 1'b1;
        sink_enable = 1'b1;

        while ((b_write_count < MAX_TRAFFIC || a_read_count < MAX_TRAFFIC) &&
               (timeout < MAX_TIMEOUT) && !a_read_error) begin
            @(posedge a_clk);
            timeout = timeout + 1;
        end

        source_enable = 1'b0;
        sink_enable = 1'b0;

        if (!a_read_error) begin
            `FAIL_IF_NOT_EQUAL(b_write_count, MAX_TRAFFIC);
            `FAIL_IF_NOT_EQUAL(a_read_count, MAX_TRAFFIC);
            `FAIL_IF_NOT_EQUAL(a_empty, 1'b1);
        end
    end
    endtask

    `TEST_SUITE("BIDIRECTIONAL_RANDOM")

    `UNIT_TEST("RANDOM_A_TO_B_THEN_B_TO_A")
        run_a_to_b();
        if (!b_read_error &&
            (a_write_count == MAX_TRAFFIC) &&
            (b_read_count == MAX_TRAFFIC))
            run_b_to_a();
    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
