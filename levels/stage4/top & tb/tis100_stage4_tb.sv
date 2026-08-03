`timescale 1ns/1ps

module tis100_stage4_tb;

    localparam int N = 39;
    localparam int TIMEOUT_CYCLES = 20000;

    logic clk;
    logic rst;

    logic signed [23:0] in_data;
    logic in_valid;
    logic in_ready;

    logic signed [23:0] out_g_data;
    logic out_g_valid;
    logic out_g_ready;

    logic signed [23:0] out_e_data;
    logic out_e_valid;
    logic out_e_ready;

    logic signed [23:0] out_l_data;
    logic out_l_valid;
    logic out_l_ready;

    logic signed [23:0] acc_n00;
    logic signed [23:0] acc_n10;
    logic signed [23:0] acc_n20;
    logic signed [23:0] acc_n21;
    logic signed [23:0] acc_n22;
    logic signed [23:0] acc_n23;

    logic zero_n00;
    logic zero_n10;
    logic zero_n20;
    logic zero_n21;
    logic zero_n22;
    logic zero_n23;

    logic sign_n00;
    logic sign_n10;
    logic sign_n20;
    logic sign_n21;
    logic sign_n22;
    logic sign_n23;

    logic signed [23:0] input_vec [0:N-1];
    logic signed [23:0] expected_g [0:N-1];
    logic signed [23:0] expected_e [0:N-1];
    logic signed [23:0] expected_l [0:N-1];

    int sent_count;
    int g_received_count;
    int e_received_count;
    int l_received_count;

    int passed;
    int failed;
    int timeout_counter;

    logic test_finished;

    logic in_ready_unknown_seen;
    logic out_g_valid_unknown_seen;
    logic out_e_valid_unknown_seen;
    logic out_l_valid_unknown_seen;
    logic out_g_data_unknown_seen;
    logic out_e_data_unknown_seen;
    logic out_l_data_unknown_seen;

    tis100_stage4_top #(
        .N00_HEX("n00.hex"),
        .N10_HEX("n10.hex"),
        .N20_HEX("n20.hex"),
        .N21_HEX("n21.hex"),
        .N22_HEX("n22.hex"),
        .N23_HEX("n23.hex")
    ) dut (
        .clk(clk),
        .rst(rst),

        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out_g_data(out_g_data),
        .out_g_valid(out_g_valid),
        .out_g_ready(out_g_ready),

        .out_e_data(out_e_data),
        .out_e_valid(out_e_valid),
        .out_e_ready(out_e_ready),

        .out_l_data(out_l_data),
        .out_l_valid(out_l_valid),
        .out_l_ready(out_l_ready),

        .acc_n00(acc_n00),
        .acc_n10(acc_n10),
        .acc_n20(acc_n20),
        .acc_n21(acc_n21),
        .acc_n22(acc_n22),
        .acc_n23(acc_n23),

        .zero_n00(zero_n00),
        .zero_n10(zero_n10),
        .zero_n20(zero_n20),
        .zero_n21(zero_n21),
        .zero_n22(zero_n22),
        .zero_n23(zero_n23),

        .sign_n00(sign_n00),
        .sign_n10(sign_n10),
        .sign_n20(sign_n20),
        .sign_n21(sign_n21),
        .sign_n22(sign_n22),
        .sign_n23(sign_n23)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        input_vec[0]  = 24'sd2;
        input_vec[1]  = 24'sd1;
        input_vec[2]  = 24'sd2;
        input_vec[3]  = 24'sd0;
        input_vec[4]  = -24'sd2;
        input_vec[5]  = 24'sd1;
        input_vec[6]  = 24'sd2;
        input_vec[7]  = -24'sd2;
        input_vec[8]  = -24'sd1;
        input_vec[9]  = -24'sd2;
        input_vec[10] = 24'sd1;
        input_vec[11] = -24'sd2;
        input_vec[12] = 24'sd0;
        input_vec[13] = 24'sd2;
        input_vec[14] = 24'sd0;
        input_vec[15] = 24'sd1;
        input_vec[16] = 24'sd0;
        input_vec[17] = 24'sd2;
        input_vec[18] = -24'sd1;
        input_vec[19] = 24'sd0;
        input_vec[20] = -24'sd1;
        input_vec[21] = -24'sd1;
        input_vec[22] = -24'sd1;
        input_vec[23] = 24'sd0;
        input_vec[24] = 24'sd1;
        input_vec[25] = 24'sd1;
        input_vec[26] = -24'sd2;
        input_vec[27] = -24'sd2;
        input_vec[28] = -24'sd2;
        input_vec[29] = 24'sd2;
        input_vec[30] = -24'sd2;
        input_vec[31] = 24'sd0;
        input_vec[32] = 24'sd2;
        input_vec[33] = -24'sd1;
        input_vec[34] = 24'sd1;
        input_vec[35] = 24'sd2;
        input_vec[36] = 24'sd0;
        input_vec[37] = -24'sd1;
        input_vec[38] = -24'sd1;
    end

    initial begin
        for (int i = 0; i < N; i++) begin
            expected_g[i] = (input_vec[i] > 0) ? 24'sd1 : 24'sd0;
            expected_e[i] = (input_vec[i] == 0) ? 24'sd1 : 24'sd0;
            expected_l[i] = (input_vec[i] < 0) ? 24'sd1 : 24'sd0;
        end
    end

    initial begin
        rst = 1'b1;

        in_data = 24'sd0;
        in_valid = 1'b0;

        out_g_ready = 1'b0;
        out_e_ready = 1'b0;
        out_l_ready = 1'b0;

        sent_count = 0;
        g_received_count = 0;
        e_received_count = 0;
        l_received_count = 0;

        passed = 0;
        failed = 0;
        timeout_counter = 0;
        test_finished = 1'b0;

        in_ready_unknown_seen = 1'b0;
        out_g_valid_unknown_seen = 1'b0;
        out_e_valid_unknown_seen = 1'b0;
        out_l_valid_unknown_seen = 1'b0;
        out_g_data_unknown_seen = 1'b0;
        out_e_data_unknown_seen = 1'b0;
        out_l_data_unknown_seen = 1'b0;

        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        wait (rst == 1'b0);
        @(negedge clk);

        while (sent_count < N) begin
            in_valid <= 1'b1;
            in_data <= input_vec[sent_count];

            do begin
                @(posedge clk);
            end while (!(in_valid && in_ready));

            $display("IN accepted[%0d] = %0d", sent_count, input_vec[sent_count]);
            sent_count++;

            @(negedge clk);
        end

        in_valid <= 1'b0;
        in_data <= 24'sd0;
    end

    initial begin
        out_g_ready = 1'b1;
        out_e_ready = 1'b1;
        out_l_ready = 1'b1;
    
        wait (rst == 1'b0);
    end


    always @(posedge clk) begin
        if (!rst && !test_finished) begin
            if ($isunknown(in_ready)) begin
                in_ready_unknown_seen <= 1'b1;
            end

            if ($isunknown(out_g_valid)) begin
                out_g_valid_unknown_seen <= 1'b1;
            end

            if ($isunknown(out_e_valid)) begin
                out_e_valid_unknown_seen <= 1'b1;
            end

            if ($isunknown(out_l_valid)) begin
                out_l_valid_unknown_seen <= 1'b1;
            end

            if (out_g_valid && $isunknown(out_g_data)) begin
                out_g_data_unknown_seen <= 1'b1;
            end

            if (out_e_valid && $isunknown(out_e_data)) begin
                out_e_data_unknown_seen <= 1'b1;
            end

            if (out_l_valid && $isunknown(out_l_data)) begin
                out_l_data_unknown_seen <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst && !test_finished) begin
            if (out_g_valid && out_g_ready) begin
                if (g_received_count >= N) begin
                    failed++;
                    $display("ERROR: extra OUT.G value = %0d", out_g_data);
                end else if (out_g_data !== expected_g[g_received_count]) begin
                    failed++;
                    $display(
                        "ERROR OUT.G[%0d]: got %0d expected %0d input %0d",
                        g_received_count,
                        out_g_data,
                        expected_g[g_received_count],
                        input_vec[g_received_count]
                    );
                end else begin
                    passed++;
                    $display("OUT.G[%0d] = %0d OK", g_received_count, out_g_data);
                end

                g_received_count++;
            end

            if (out_e_valid && out_e_ready) begin
                if (e_received_count >= N) begin
                    failed++;
                    $display("ERROR: extra OUT.E value = %0d", out_e_data);
                end else if (out_e_data !== expected_e[e_received_count]) begin
                    failed++;
                    $display(
                        "ERROR OUT.E[%0d]: got %0d expected %0d input %0d",
                        e_received_count,
                        out_e_data,
                        expected_e[e_received_count],
                        input_vec[e_received_count]
                    );
                end else begin
                    passed++;
                    $display("OUT.E[%0d] = %0d OK", e_received_count, out_e_data);
                end

                e_received_count++;
            end

            if (out_l_valid && out_l_ready) begin
                if (l_received_count >= N) begin
                    failed++;
                    $display("ERROR: extra OUT.L value = %0d", out_l_data);
                end else if (out_l_data !== expected_l[l_received_count]) begin
                    failed++;
                    $display(
                        "ERROR OUT.L[%0d]: got %0d expected %0d input %0d",
                        l_received_count,
                        out_l_data,
                        expected_l[l_received_count],
                        input_vec[l_received_count]
                    );
                end else begin
                    passed++;
                    $display("OUT.L[%0d] = %0d OK", l_received_count, out_l_data);
                end

                l_received_count++;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst && !test_finished) begin
            timeout_counter++;

            if (timeout_counter >= TIMEOUT_CYCLES) begin
                failed++;

                $display("TIMEOUT");
                $display("sent_count       = %0d", sent_count);
                $display("g_received_count = %0d", g_received_count);
                $display("e_received_count = %0d", e_received_count);
                $display("l_received_count = %0d", l_received_count);
                $display("Passed: %0d", passed);
                $display("Failed: %0d", failed);

                test_finished <= 1'b1;
                $finish;
            end

            if (
                sent_count == N &&
                g_received_count == N &&
                e_received_count == N &&
                l_received_count == N
            ) begin
                test_finished <= 1'b1;

                if (sent_count == N) begin
                    passed++;
                end else begin
                    failed++;
                end

                if (g_received_count == N) begin
                    passed++;
                end else begin
                    failed++;
                end

                if (e_received_count == N) begin
                    passed++;
                end else begin
                    failed++;
                end

                if (l_received_count == N) begin
                    passed++;
                end else begin
                    failed++;
                end

                if (in_ready_unknown_seen) failed++;
                else passed++;

                if (out_g_valid_unknown_seen) failed++;
                else passed++;

                if (out_e_valid_unknown_seen) failed++;
                else passed++;

                if (out_l_valid_unknown_seen) failed++;
                else passed++;

                if (out_g_data_unknown_seen) failed++;
                else passed++;

                if (out_e_data_unknown_seen) failed++;
                else passed++;

                if (out_l_data_unknown_seen) failed++;
                else passed++;

                $display("");
                $display("IN accepted count   = %0d", sent_count);
                $display("OUT.G produced count = %0d", g_received_count);
                $display("OUT.E produced count = %0d", e_received_count);
                $display("OUT.L produced count = %0d", l_received_count);

                $display("");
                $display("in_ready_unknown_seen     = %0d", in_ready_unknown_seen);
                $display("out_g_valid_unknown_seen  = %0d", out_g_valid_unknown_seen);
                $display("out_e_valid_unknown_seen  = %0d", out_e_valid_unknown_seen);
                $display("out_l_valid_unknown_seen  = %0d", out_l_valid_unknown_seen);
                $display("out_g_data_unknown_seen   = %0d", out_g_data_unknown_seen);
                $display("out_e_data_unknown_seen   = %0d", out_e_data_unknown_seen);
                $display("out_l_data_unknown_seen   = %0d", out_l_data_unknown_seen);

                $display("");
                $display("Passed: %0d", passed);
                $display("Failed: %0d", failed);

                if (failed == 0) begin
                    $display("ALL TESTS PASSED");
                end else begin
                    $display("TESTS FAILED");
                end

                $finish;
            end
        end
    end

endmodule
