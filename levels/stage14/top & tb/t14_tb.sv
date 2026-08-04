`timescale 1ns/1ps

module t14_tb;

    localparam int DATA_WIDTH    = 24;
    localparam int STACK_DEPTH   = 15;
    localparam int TEST_COUNT    = 40;
    localparam int TIMEOUT_CYCLES = 10000;
    localparam bit TRACE         = 1'b1;

    logic clk;
    logic rst;

    logic signed [DATA_WIDTH-1:0] in_a_data;
    logic                         in_a_valid;
    logic                         in_a_ready;

    logic signed [DATA_WIDTH-1:0] in_b_data;
    logic                         in_b_valid;
    logic                         in_b_ready;

    logic signed [DATA_WIDTH-1:0] out_data;
    logic                         out_valid;
    logic                         out_ready;

    logic signed [DATA_WIDTH-1:0] input_a [0:TEST_COUNT-1];
    logic signed [DATA_WIDTH-1:0] input_b [0:TEST_COUNT-1];
    logic signed [DATA_WIDTH-1:0] expected [0:TEST_COUNT-1];

    integer cycle_count;
    integer input_a_count;
    integer input_b_count;
    integer output_count;
    integer pass_count;
    integer fail_count;

    event output_done;

    t14_top #(
        .N01_HEX("t14_n01.hex"),
        .N02_HEX("t14_n02.hex"),
        .N11_HEX("t14_n11.hex"),
        .N12_HEX("t14_n12.hex"),
        .N22_HEX("t14_n22.hex"),
        .STACK_DEPTH(STACK_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),

        .in_a_data(in_a_data),
        .in_a_valid(in_a_valid),
        .in_a_ready(in_a_ready),

        .in_b_data(in_b_data),
        .in_b_valid(in_b_valid),
        .in_b_ready(in_b_ready),

        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        input_a[0]  = 1; input_b[0]  = 8;
        input_a[1]  = 4; input_b[1]  = 1;
        input_a[2]  = 0; input_b[2]  = 4;
        input_a[3]  = 8; input_b[3]  = 4;
        input_a[4]  = 6; input_b[4]  = 5;
        input_a[5]  = 5; input_b[5]  = 1;
        input_a[6]  = 1; input_b[6]  = 4;
        input_a[7]  = 4; input_b[7]  = 7;
        input_a[8]  = 7; input_b[8]  = 5;
        input_a[9]  = 6; input_b[9]  = 7;
        input_a[10] = 8; input_b[10] = 5;
        input_a[11] = 7; input_b[11] = 0;
        input_a[12] = 3; input_b[12] = 3;
        input_a[13] = 0; input_b[13] = 4;
        input_a[14] = 5; input_b[14] = 8;
        input_a[15] = 4; input_b[15] = 5;
        input_a[16] = 7; input_b[16] = 6;
        input_a[17] = 8; input_b[17] = 4;
        input_a[18] = 8; input_b[18] = 9;
        input_a[19] = 8; input_b[19] = 8;
        input_a[20] = 8; input_b[20] = 7;
        input_a[21] = 1; input_b[21] = 7;
        input_a[22] = 7; input_b[22] = 1;
        input_a[23] = 0; input_b[23] = 5;
        input_a[24] = 4; input_b[24] = 3;
        input_a[25] = 6; input_b[25] = 1;
        input_a[26] = 4; input_b[26] = 0;
        input_a[27] = 8; input_b[27] = 3;
        input_a[28] = 3; input_b[28] = 8;
        input_a[29] = 7; input_b[29] = 3;
        input_a[30] = 7; input_b[30] = 8;
        input_a[31] = 3; input_b[31] = 8;
        input_a[32] = 8; input_b[32] = 0;
        input_a[33] = 2; input_b[33] = 7;
        input_a[34] = 7; input_b[34] = 9;
        input_a[35] = 0; input_b[35] = 2;
        input_a[36] = 6; input_b[36] = 0;
        input_a[37] = 0; input_b[37] = 1;
        input_a[38] = 0; input_b[38] = 0;
        input_a[39] = 5; input_b[39] = 8;

        for (int index = 0; index < TEST_COUNT; index = index + 1)
            expected[index] = input_a[index] * input_b[index];
    end

    task automatic drive_input_a;
        integer index;
        begin
            for (index = 0; index < TEST_COUNT; index = index + 1) begin
                @(negedge clk);
                in_a_data  = input_a[index];
                in_a_valid = 1'b1;

                do begin
                    @(posedge clk);
                end while (!in_a_ready);

                @(negedge clk);
                in_a_valid = 1'b0;
            end
        end
    endtask

    task automatic drive_input_b;
        integer index;
        begin
            for (index = 0; index < TEST_COUNT; index = index + 1) begin
                @(negedge clk);
                in_b_data  = input_b[index];
                in_b_valid = 1'b1;

                do begin
                    @(posedge clk);
                end while (!in_b_ready);

                @(negedge clk);
                in_b_valid = 1'b0;
            end
        end
    endtask

    task automatic print_state;
        begin
            $display(
                "[%0t][C%0d] STATE | A(v=%0b r=%0b data=%0d) | B(v=%0b r=%0b data=%0d) | OUT(v=%0b r=%0b data=%0d)",
                $time,
                cycle_count,
                in_a_valid,
                in_a_ready,
                $signed(in_a_data),
                in_b_valid,
                in_b_ready,
                $signed(in_b_data),
                out_valid,
                out_ready,
                $signed(out_data)
            );

            $display(
                "    N01 D(v=%0b r=%0b data=%0d) | N02 D(v=%0b r=%0b data=%0d)",
                dut.n01_down_valid_out,
                dut.n11_up_ready_out,
                $signed(dut.data_out_n01),
                dut.n02_down_valid_out,
                dut.n12_up_ready_out,
                $signed(dut.data_out_n02)
            );

            $display(
                "    N11 R(v=%0b r=%0b data=%0d) | N12 L(v=%0b r=%0b) U(v=%0b r=%0b)",
                dut.n11_right_valid_out,
                dut.n12_left_ready_out,
                $signed(dut.data_out_n11),
                dut.n11_right_valid_out,
                dut.n12_left_ready_out,
                dut.n02_down_valid_out,
                dut.n12_up_ready_out
            );

            $display(
                "    N12 R(v=%0b r=%0b data=%0d) | N13 L(v=%0b r=%0b data=%0d)",
                dut.n12_right_valid_out,
                dut.n13_ready_out_l,
                $signed(dut.data_out_n12),
                dut.n13_valid_out_l,
                dut.n12_right_ready_out,
                $signed(dut.n13_data_out_l)
            );

            $display(
                "    N12 D(v=%0b r=%0b data=%0d) | N22 D(v=%0b r=%0b data=%0d)",
                dut.n12_down_valid_out,
                dut.n22_up_ready_out,
                $signed(dut.data_out_n12),
                dut.n22_down_valid_out,
                out_ready,
                $signed(dut.data_out_n22)
            );
        end
    endtask

    always @(posedge clk) begin
        if (rst) begin
            cycle_count  = 0;
            input_a_count = 0;
            input_b_count = 0;
            output_count = 0;
            pass_count   = 0;
            fail_count   = 0;
        end
        else begin
            cycle_count = cycle_count + 1;

            if (in_a_valid && in_a_ready) begin
                $display(
                    "[%0t][C%0d][IN.A] index=%0d data=%0d",
                    $time,
                    cycle_count,
                    input_a_count,
                    $signed(in_a_data)
                );

                input_a_count = input_a_count + 1;
            end

            if (in_b_valid && in_b_ready) begin
                $display(
                    "[%0t][C%0d][IN.B] index=%0d data=%0d",
                    $time,
                    cycle_count,
                    input_b_count,
                    $signed(in_b_data)
                );

                input_b_count = input_b_count + 1;
            end

            if (out_valid && out_ready) begin
                if (output_count >= TEST_COUNT) begin
                    fail_count = fail_count + 1;

                    $display(
                        "[%0t][C%0d][FAIL] unexpected extra output=%0d",
                        $time,
                        cycle_count,
                        $signed(out_data)
                    );
                end
                else if ($signed(out_data) === $signed(expected[output_count])) begin
                    pass_count = pass_count + 1;

                    $display(
                        "[%0t][C%0d][PASS] index=%0d A=%0d B=%0d expected=%0d actual=%0d",
                        $time,
                        cycle_count,
                        output_count,
                        $signed(input_a[output_count]),
                        $signed(input_b[output_count]),
                        $signed(expected[output_count]),
                        $signed(out_data)
                    );
                end
                else begin
                    fail_count = fail_count + 1;

                    $display(
                        "[%0t][C%0d][FAIL] index=%0d A=%0d B=%0d expected=%0d actual=%0d",
                        $time,
                        cycle_count,
                        output_count,
                        $signed(input_a[output_count]),
                        $signed(input_b[output_count]),
                        $signed(expected[output_count]),
                        $signed(out_data)
                    );
                end

                output_count = output_count + 1;

                if (output_count == TEST_COUNT)
                    -> output_done;
            end

            if (
                TRACE &&
                (
                    in_a_valid ||
                    in_b_valid ||
                    out_valid ||
                    dut.n01_down_valid_out ||
                    dut.n02_down_valid_out ||
                    dut.n11_right_valid_out ||
                    dut.n12_right_valid_out ||
                    dut.n13_valid_out_l ||
                    dut.n12_down_valid_out
                )
            )
                print_state();
        end
    end

    initial begin
        rst        = 1'b1;
        in_a_data  = '0;
        in_a_valid = 1'b0;
        in_b_data  = '0;
        in_b_valid = 1'b0;
        out_ready  = 1'b1;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("============================================================");
        $display("STAGE 14: SIGNAL MULTIPLIER TEST");
        $display("TEST COUNT = %0d", TEST_COUNT);
        $display("============================================================");

        fork
            drive_input_a();
            drive_input_b();
        join_none

        fork : test_control
            begin
                @output_done;
                repeat (3) @(posedge clk);

                $display("============================================================");
                $display("STAGE 14 TEST COMPLETED");
                $display("INPUT A TRANSFERS = %0d", input_a_count);
                $display("INPUT B TRANSFERS = %0d", input_b_count);
                $display("OUTPUT TRANSFERS  = %0d", output_count);
                $display("PASS              = %0d", pass_count);
                $display("FAIL              = %0d", fail_count);
                $display("TOTAL CYCLES      = %0d", cycle_count);

                if (
                    fail_count == 0 &&
                    pass_count == TEST_COUNT &&
                    input_a_count == TEST_COUNT &&
                    input_b_count == TEST_COUNT &&
                    output_count == TEST_COUNT
                )
                    $display("FINAL RESULT: PASS");
                else
                    $display("FINAL RESULT: FAIL");

                $display("============================================================");
                $finish;
            end

            begin
                repeat (TIMEOUT_CYCLES) @(posedge clk);

                $display("============================================================");
                $display("FINAL RESULT: FAIL");
                $display("REASON: SIMULATION TIMEOUT");
                $display("INPUT A TRANSFERS = %0d/%0d", input_a_count, TEST_COUNT);
                $display("INPUT B TRANSFERS = %0d/%0d", input_b_count, TEST_COUNT);
                $display("OUTPUT TRANSFERS  = %0d/%0d", output_count, TEST_COUNT);
                $display("PASS              = %0d", pass_count);
                $display("FAIL              = %0d", fail_count);
                $display("TOTAL CYCLES      = %0d", cycle_count);
                $display("============================================================");

                $finish;
            end
        join_any

        disable test_control;
    end

endmodule
