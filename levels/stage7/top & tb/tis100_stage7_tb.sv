`timescale 1ns/1ps

module tis100_stage7_tb;

    localparam int INPUT_COUNT  = 39;
    localparam int OUTPUT_COUNT = 11;

    logic clk;
    logic rst;

    logic signed [23:0] in_data;
    logic in_valid;
    logic in_ready;

    logic signed [23:0] out_s_data;
    logic out_s_valid;
    logic out_s_ready;

    logic signed [23:0] out_l_data;
    logic out_l_valid;
    logic out_l_ready;

    logic signed [23:0] acc_n10;
    logic signed [23:0] acc_n20;
    logic signed [23:0] acc_n11;
    logic signed [23:0] acc_n21;
    logic signed [23:0] acc_n12;
    logic signed [23:0] acc_n22;

    logic zero_n10;
    logic zero_n20;
    logic zero_n11;
    logic zero_n21;
    logic zero_n12;
    logic zero_n22;

    logic sign_n10;
    logic sign_n20;
    logic sign_n11;
    logic sign_n21;
    logic sign_n12;
    logic sign_n22;

    logic signed [23:0] input_values [0:INPUT_COUNT-1];
    logic signed [23:0] expected_s   [0:OUTPUT_COUNT-1];
    logic signed [23:0] expected_l   [0:OUTPUT_COUNT-1];

    int sent_count;
    int s_received_count;
    int l_received_count;
    int passed;
    int failed;

    bit test_finished;

    bit in_ready_unknown_seen;
    bit out_s_valid_unknown_seen;
    bit out_l_valid_unknown_seen;
    bit out_s_data_unknown_seen;
    bit out_l_data_unknown_seen;

    tis100_stage7_top #(
        .N10_HEX("n10.hex"),
        .N20_HEX("n20.hex"),
        .N11_HEX("n11.hex"),
        .N21_HEX("n21.hex"),
        .N12_HEX("n12.hex"),
        .N22_HEX("n22.hex")
    ) dut (
        .clk(clk),
        .rst(rst),

        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out_s_data(out_s_data),
        .out_s_valid(out_s_valid),
        .out_s_ready(out_s_ready),

        .out_l_data(out_l_data),
        .out_l_valid(out_l_valid),
        .out_l_ready(out_l_ready),

        .acc_n10(acc_n10),
        .acc_n20(acc_n20),
        .acc_n11(acc_n11),
        .acc_n21(acc_n21),
        .acc_n12(acc_n12),
        .acc_n22(acc_n22),

        .zero_n10(zero_n10),
        .zero_n20(zero_n20),
        .zero_n11(zero_n11),
        .zero_n21(zero_n21),
        .zero_n12(zero_n12),
        .zero_n22(zero_n22),

        .sign_n10(sign_n10),
        .sign_n20(sign_n20),
        .sign_n11(sign_n11),
        .sign_n21(sign_n21),
        .sign_n12(sign_n12),
        .sign_n22(sign_n22)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        input_values[0]  = 24'sd35;
        input_values[1]  = 24'sd0;
        input_values[2]  = 24'sd62;
        input_values[3]  = 24'sd51;
        input_values[4]  = 24'sd81;
        input_values[5]  = 24'sd54;
        input_values[6]  = 24'sd12;
        input_values[7]  = 24'sd0;
        input_values[8]  = 24'sd51;
        input_values[9]  = 24'sd63;
        input_values[10] = 24'sd50;
        input_values[11] = 24'sd67;
        input_values[12] = 24'sd48;
        input_values[13] = 24'sd0;
        input_values[14] = 24'sd49;
        input_values[15] = 24'sd23;
        input_values[16] = 24'sd26;
        input_values[17] = 24'sd0;
        input_values[18] = 24'sd33;
        input_values[19] = 24'sd79;
        input_values[20] = 24'sd76;
        input_values[21] = 24'sd0;
        input_values[22] = 24'sd0;
        input_values[23] = 24'sd94;
        input_values[24] = 24'sd0;
        input_values[25] = 24'sd79;
        input_values[26] = 24'sd0;
        input_values[27] = 24'sd98;
        input_values[28] = 24'sd15;
        input_values[29] = 24'sd0;
        input_values[30] = 24'sd53;
        input_values[31] = 24'sd35;
        input_values[32] = 24'sd45;
        input_values[33] = 24'sd12;
        input_values[34] = 24'sd79;
        input_values[35] = 24'sd0;
        input_values[36] = 24'sd19;
        input_values[37] = 24'sd71;
        input_values[38] = 24'sd0;

        expected_s[0]  = 24'sd35;
        expected_s[1]  = 24'sd260;
        expected_s[2]  = 24'sd279;
        expected_s[3]  = 24'sd98;
        expected_s[4]  = 24'sd188;
        expected_s[5]  = 24'sd0;
        expected_s[6]  = 24'sd94;
        expected_s[7]  = 24'sd79;
        expected_s[8]  = 24'sd113;
        expected_s[9]  = 24'sd224;
        expected_s[10] = 24'sd90;

        expected_l[0]  = 24'sd1;
        expected_l[1]  = 24'sd5;
        expected_l[2]  = 24'sd5;
        expected_l[3]  = 24'sd3;
        expected_l[4]  = 24'sd3;
        expected_l[5]  = 24'sd0;
        expected_l[6]  = 24'sd1;
        expected_l[7]  = 24'sd1;
        expected_l[8]  = 24'sd2;
        expected_l[9]  = 24'sd5;
        expected_l[10] = 24'sd2;
    end

    task automatic reset_dut;
        begin
            rst = 1'b1;
            in_data = 24'sd0;
            in_valid = 1'b0;
            out_s_ready = 1'b0;
            out_l_ready = 1'b0;
            sent_count = 0;
            s_received_count = 0;
            l_received_count = 0;
            passed = 0;
            failed = 0;
            test_finished = 1'b0;
            in_ready_unknown_seen = 1'b0;
            out_s_valid_unknown_seen = 1'b0;
            out_l_valid_unknown_seen = 1'b0;
            out_s_data_unknown_seen = 1'b0;
            out_l_data_unknown_seen = 1'b0;
            repeat (8) @(posedge clk);
            rst = 1'b0;
            repeat (3) @(posedge clk);
        end
    endtask

    task automatic drive_input;
        int i;
        int gap;
        begin
            for (i = 0; i < INPUT_COUNT; i++) begin
                @(negedge clk);
                in_data = input_values[i];
                in_valid = 1'b1;

                do begin
                    @(posedge clk);
                end while (!in_ready);

                sent_count++;
                $display("[%0t] IN accepted index=%0d data=%0d", $time, i, input_values[i]);

                @(negedge clk);
                in_valid = 1'b0;
                in_data = 24'sd0;

                gap = $urandom_range(0, 2);
                repeat (gap) @(negedge clk);
            end
        end
    endtask

    task automatic drive_output_ready;
        begin
            forever begin
                @(negedge clk);
                if (rst) begin
                    out_s_ready = 1'b0;
                    out_l_ready = 1'b0;
                end else begin
                    out_s_ready = ($urandom_range(0, 3) != 0);
                    out_l_ready = ($urandom_range(0, 3) != 0);
                end
            end
        end
    endtask

    task automatic monitor_out_s;
        begin
            while (s_received_count < OUTPUT_COUNT) begin
                @(posedge clk);
                if (!rst && out_s_valid && out_s_ready) begin
                    if (out_s_data === expected_s[s_received_count]) begin
                        passed++;
                        $display("[%0t] OUT.S OK index=%0d data=%0d", $time, s_received_count, out_s_data);
                    end else begin
                        failed++;
                        $display("[%0t] OUT.S FAIL index=%0d expected=%0d got=%0d", $time, s_received_count, expected_s[s_received_count], out_s_data);
                    end
                    s_received_count++;
                end
            end
        end
    endtask

    task automatic monitor_out_l;
        begin
            while (l_received_count < OUTPUT_COUNT) begin
                @(posedge clk);
                if (!rst && out_l_valid && out_l_ready) begin
                    if (out_l_data === expected_l[l_received_count]) begin
                        passed++;
                        $display("[%0t] OUT.L OK index=%0d data=%0d", $time, l_received_count, out_l_data);
                    end else begin
                        failed++;
                        $display("[%0t] OUT.L FAIL index=%0d expected=%0d got=%0d", $time, l_received_count, expected_l[l_received_count], out_l_data);
                    end
                    l_received_count++;
                end
            end
        end
    endtask

    task automatic monitor_unknowns;
        begin
            forever begin
                @(posedge clk);
                if (!rst) begin
                    if ($isunknown(in_ready)) begin
                        in_ready_unknown_seen = 1'b1;
                    end

                    if ($isunknown(out_s_valid)) begin
                        out_s_valid_unknown_seen = 1'b1;
                    end

                    if ($isunknown(out_l_valid)) begin
                        out_l_valid_unknown_seen = 1'b1;
                    end

                    if (out_s_valid && $isunknown(out_s_data)) begin
                        out_s_data_unknown_seen = 1'b1;
                    end

                    if (out_l_valid && $isunknown(out_l_data)) begin
                        out_l_data_unknown_seen = 1'b1;
                    end
                end
            end
        end
    endtask

    task automatic check_final_counts;
        begin
            if (sent_count == INPUT_COUNT) begin
                passed++;
            end else begin
                failed++;
                $display("IN count FAIL expected=%0d got=%0d", INPUT_COUNT, sent_count);
            end

            if (s_received_count == OUTPUT_COUNT) begin
                passed++;
            end else begin
                failed++;
                $display("OUT.S count FAIL expected=%0d got=%0d", OUTPUT_COUNT, s_received_count);
            end

            if (l_received_count == OUTPUT_COUNT) begin
                passed++;
            end else begin
                failed++;
                $display("OUT.L count FAIL expected=%0d got=%0d", OUTPUT_COUNT, l_received_count);
            end
        end
    endtask

    task automatic check_unknown_flags;
        begin
            if (!in_ready_unknown_seen) passed++; else failed++;
            if (!out_s_valid_unknown_seen) passed++; else failed++;
            if (!out_l_valid_unknown_seen) passed++; else failed++;
            if (!out_s_data_unknown_seen) passed++; else failed++;
            if (!out_l_data_unknown_seen) passed++; else failed++;

            $display("");
            $display("in_ready_unknown_seen    = %0d", in_ready_unknown_seen);
            $display("out_s_valid_unknown_seen = %0d", out_s_valid_unknown_seen);
            $display("out_l_valid_unknown_seen = %0d", out_l_valid_unknown_seen);
            $display("out_s_data_unknown_seen  = %0d", out_s_data_unknown_seen);
            $display("out_l_data_unknown_seen  = %0d", out_l_data_unknown_seen);
        end
    endtask

    task automatic print_report;
        begin
            $display("");
            $display("IN accepted count    = %0d", sent_count);
            $display("OUT.S produced count = %0d", s_received_count);
            $display("OUT.L produced count = %0d", l_received_count);
            $display("");
            $display("Passed: %0d", passed);
            $display("Failed: %0d", failed);

            if (failed == 0) begin
                $display("ALL TESTS PASSED");
            end else begin
                $display("TESTS FAILED");
            end
        end
    endtask

    initial begin
        reset_dut();

        fork
            drive_output_ready();
            monitor_unknowns();

            begin
                fork
                    drive_input();
                    monitor_out_s();
                    monitor_out_l();
                join

                test_finished = 1'b1;
                repeat (20) @(posedge clk);

                check_final_counts();
                check_unknown_flags();
                print_report();

                $finish;
            end

            begin
                #300000;
                failed++;
                $display("TIMEOUT");
                print_report();
                $finish;
            end
        join
    end

endmodule
