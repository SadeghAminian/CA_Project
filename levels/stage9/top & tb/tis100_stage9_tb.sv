`timescale 1ns/1ps

module tis100_stage9_tb;

    localparam int CLK_PERIOD = 10;
    localparam int MAX_EXPECTED = 512;

    logic clk;
    logic rst;

    logic signed [23:0] in1_data;
    logic signed [23:0] in2_data;
    logic signed [23:0] in3_data;
    logic signed [23:0] in4_data;

    logic in1_valid;
    logic in2_valid;
    logic in3_valid;
    logic in4_valid;

    logic in1_ready;
    logic in2_ready;
    logic in3_ready;
    logic in4_ready;

    logic signed [23:0] out_data;
    logic out_valid;
    logic out_ready;

    logic signed [23:0] acc_n10;
    logic signed [23:0] acc_n20;
    logic signed [23:0] acc_n30;
    logic signed [23:0] acc_n40;
    logic signed [23:0] acc_n11;
    logic signed [23:0] acc_n21;
    logic signed [23:0] acc_n31;
    logic signed [23:0] acc_n41;
    logic signed [23:0] acc_n32;

    logic zero_n10;
    logic zero_n20;
    logic zero_n30;
    logic zero_n40;
    logic zero_n11;
    logic zero_n21;
    logic zero_n31;
    logic zero_n41;
    logic zero_n32;

    logic sign_n10;
    logic sign_n20;
    logic sign_n30;
    logic sign_n40;
    logic sign_n11;
    logic sign_n21;
    logic sign_n31;
    logic sign_n41;
    logic sign_n32;

    integer passed;
    integer failed;
    integer produced_count;
    integer expected_count;
    integer expected_head;
    integer expected_tail;

    integer in_ready_unknown_seen;
    integer out_valid_unknown_seen;
    integer out_data_unknown_seen;

    logic signed [23:0] expected_queue [0:MAX_EXPECTED-1];

    tis100_stage9_top #(
        .N10_HEX("n10.hex"),
        .N20_HEX("n20.hex"),
        .N30_HEX("n30.hex"),
        .N40_HEX("n40.hex"),
        .N11_HEX("n11.hex"),
        .N21_HEX("n21.hex"),
        .N31_HEX("n31.hex"),
        .N41_HEX("n41.hex"),
        .N32_HEX("n32.hex")
    ) dut (
        .clk(clk),
        .rst(rst),

        .in1_data(in1_data),
        .in1_valid(in1_valid),
        .in1_ready(in1_ready),

        .in2_data(in2_data),
        .in2_valid(in2_valid),
        .in2_ready(in2_ready),

        .in3_data(in3_data),
        .in3_valid(in3_valid),
        .in3_ready(in3_ready),

        .in4_data(in4_data),
        .in4_valid(in4_valid),
        .in4_ready(in4_ready),

        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready),

        .acc_n10(acc_n10),
        .acc_n20(acc_n20),
        .acc_n30(acc_n30),
        .acc_n40(acc_n40),
        .acc_n11(acc_n11),
        .acc_n21(acc_n21),
        .acc_n31(acc_n31),
        .acc_n41(acc_n41),
        .acc_n32(acc_n32),

        .zero_n10(zero_n10),
        .zero_n20(zero_n20),
        .zero_n30(zero_n30),
        .zero_n40(zero_n40),
        .zero_n11(zero_n11),
        .zero_n21(zero_n21),
        .zero_n31(zero_n31),
        .zero_n41(zero_n41),
        .zero_n32(zero_n32),

        .sign_n10(sign_n10),
        .sign_n20(sign_n20),
        .sign_n30(sign_n30),
        .sign_n40(sign_n40),
        .sign_n11(sign_n11),
        .sign_n21(sign_n21),
        .sign_n31(sign_n31),
        .sign_n41(sign_n41),
        .sign_n32(sign_n32)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task push_expected(input logic signed [23:0] value);
        begin
            expected_queue[expected_tail] = value;
            expected_tail = expected_tail + 1;
            expected_count = expected_count + 1;
        end
    endtask

    task drive_cycle(
        input logic signed [23:0] v1,
        input logic signed [23:0] v2,
        input logic signed [23:0] v3,
        input logic signed [23:0] v4,
        input logic signed [23:0] expected_value
    );
        begin
            @(negedge clk);

            while (!(in1_ready && in2_ready && in3_ready && in4_ready)) begin
                @(negedge clk);
            end

            in1_data = v1;
            in2_data = v2;
            in3_data = v3;
            in4_data = v4;

            in1_valid = 1'b1;
            in2_valid = 1'b1;
            in3_valid = 1'b1;
            in4_valid = 1'b1;

            push_expected(expected_value);

            @(negedge clk);

            in1_valid = 1'b0;
            in2_valid = 1'b0;
            in3_valid = 1'b0;
            in4_valid = 1'b0;
        end
    endtask

    always @(posedge clk) begin
        if (!rst) begin
            if (^in1_ready === 1'bx || ^in2_ready === 1'bx || ^in3_ready === 1'bx || ^in4_ready === 1'bx) begin
                in_ready_unknown_seen = 1;
            end

            if (^out_valid === 1'bx) begin
                out_valid_unknown_seen = 1;
            end

            if (out_valid && (^out_data === 1'bx)) begin
                out_data_unknown_seen = 1;
            end

            if (out_valid && out_ready) begin
                produced_count = produced_count + 1;

                if (expected_head < expected_tail) begin
                    if (out_data === expected_queue[expected_head]) begin
                        passed = passed + 1;
                        $display("PASS: out=%0d expected=%0d time=%0t",
                                 out_data, expected_queue[expected_head], $time);
                    end else begin
                        failed = failed + 1;
                        $display("FAIL: out=%0d expected=%0d time=%0t",
                                 out_data, expected_queue[expected_head], $time);
                    end

                    expected_head = expected_head + 1;
                end else begin
                    failed = failed + 1;
                    $display("FAIL: unexpected extra output=%0d time=%0t", out_data, $time);
                end
            end
        end
    end

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        in1_data = 24'sd0;
        in2_data = 24'sd0;
        in3_data = 24'sd0;
        in4_data = 24'sd0;

        in1_valid = 1'b0;
        in2_valid = 1'b0;
        in3_valid = 1'b0;
        in4_valid = 1'b0;

        out_ready = 1'b1;

        passed = 0;
        failed = 0;
        produced_count = 0;
        expected_count = 0;
        expected_head = 0;
        expected_tail = 0;

        in_ready_unknown_seen = 0;
        out_valid_unknown_seen = 0;
        out_data_unknown_seen = 0;

        repeat (8) @(posedge clk);
        rst = 1'b0;
        repeat (5) @(posedge clk);

        drive_cycle(0, 0, 0, 0, 0);

        drive_cycle(1, 0, 0, 0, 1);
        drive_cycle(1, 0, 0, 0, 0);
        drive_cycle(1, 0, 0, 0, 0);
        drive_cycle(0, 0, 0, 0, 0);

        drive_cycle(0, 1, 0, 0, 2);
        drive_cycle(0, 1, 0, 0, 0);
        drive_cycle(0, 0, 0, 0, 0);

        drive_cycle(0, 0, 1, 0, 3);
        drive_cycle(0, 0, 1, 0, 0);
        drive_cycle(0, 0, 0, 0, 0);

        drive_cycle(0, 0, 0, 1, 4);
        drive_cycle(0, 0, 0, 1, 0);
        drive_cycle(0, 0, 0, 0, 0);

        drive_cycle(1, 0, 0, 0, 1);
        drive_cycle(0, 0, 0, 0, 0);
        drive_cycle(1, 0, 0, 0, 1);
        drive_cycle(0, 0, 0, 0, 0);

        drive_cycle(0, 0, 1, 0, 3);
        drive_cycle(0, 0, 0, 0, 0);
        drive_cycle(0, 1, 0, 0, 2);
        drive_cycle(0, 0, 0, 0, 0);
        drive_cycle(0, 0, 0, 1, 4);
        drive_cycle(0, 0, 0, 0, 0);

        repeat (150) @(posedge clk);

        $display("========================================");
        $display("expected_count           = %0d", expected_count);
        $display("produced_count           = %0d", produced_count);
        $display("passed                   = %0d", passed);
        $display("failed                   = %0d", failed);
        $display("in_ready_unknown_seen    = %0d", in_ready_unknown_seen);
        $display("out_valid_unknown_seen   = %0d", out_valid_unknown_seen);
        $display("out_data_unknown_seen    = %0d", out_data_unknown_seen);
        $display("========================================");

        if (
            failed == 0 &&
            produced_count == expected_count &&
            expected_head == expected_tail &&
            in_ready_unknown_seen == 0 &&
            out_valid_unknown_seen == 0 &&
            out_data_unknown_seen == 0
        ) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
