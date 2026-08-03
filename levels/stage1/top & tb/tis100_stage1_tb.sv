`timescale 1ns/1ps

module tis100_stage1_tb;

    localparam integer STREAM_LENGTH = 39;
    localparam integer TIMEOUT_CYCLES = 20000;

    logic clk;
    logic rst;

    logic signed [23:0] in_x_data;
    logic               in_x_valid;
    logic               in_x_ready;

    logic signed [23:0] in_a_data;
    logic               in_a_valid;
    logic               in_a_ready;

    logic signed [23:0] out_x_data;
    logic               out_x_valid;
    logic               out_x_ready;

    logic signed [23:0] out_a_data;
    logic               out_a_valid;
    logic               out_a_ready;

    logic signed [23:0] expected_x [0:STREAM_LENGTH-1];
    logic signed [23:0] expected_a [0:STREAM_LENGTH-1];

    logic signed [23:0] held_out_x_data;
    logic signed [23:0] held_out_a_data;

    logic out_x_waiting;
    logic out_a_waiting;

    logic x_driver_done;
    logic a_driver_done;
    logic test_finished;

    logic in_x_ready_unknown_seen;
    logic in_a_ready_unknown_seen;
    logic out_x_valid_unknown_seen;
    logic out_a_valid_unknown_seen;
    logic out_x_data_unknown_seen;
    logic out_a_data_unknown_seen;

    integer x_sent_count;
    integer a_sent_count;
    integer x_received_count;
    integer a_received_count;

    integer x_ready_cycle;
    integer a_ready_cycle;
    integer timeout_counter;

    integer passed;
    integer failed;

    tis100_stage1_top #(
        .N00_HEX("n00.hex"),
        .N10_HEX("n10.hex"),
        .N20_HEX("n20.hex"),
        .N03_HEX("n03.hex"),
        .N02_HEX("n02.hex"),
        .N12_HEX("n12.hex"),
        .N22_HEX("n22.hex"),
        .N23_HEX("n23.hex")
    ) dut (
        .clk         (clk),
        .rst         (rst),

        .in_x_data   (in_x_data),
        .in_x_valid  (in_x_valid),
        .in_x_ready  (in_x_ready),

        .in_a_data   (in_a_data),
        .in_a_valid  (in_a_valid),
        .in_a_ready  (in_a_ready),

        .out_x_data  (out_x_data),
        .out_x_valid (out_x_valid),
        .out_x_ready (out_x_ready),

        .out_a_data  (out_a_data),
        .out_a_valid (out_a_valid),
        .out_a_ready (out_a_ready)
    );

    initial begin
        expected_x[0]  = 24'sd51;
        expected_x[1]  = 24'sd62;
        expected_x[2]  = 24'sd16;
        expected_x[3]  = 24'sd83;
        expected_x[4]  = 24'sd61;
        expected_x[5]  = 24'sd14;
        expected_x[6]  = 24'sd35;
        expected_x[7]  = 24'sd17;
        expected_x[8]  = 24'sd63;
        expected_x[9]  = 24'sd48;
        expected_x[10] = 24'sd22;
        expected_x[11] = 24'sd40;
        expected_x[12] = 24'sd29;
        expected_x[13] = 24'sd50;
        expected_x[14] = 24'sd77;
        expected_x[15] = 24'sd32;
        expected_x[16] = 24'sd31;
        expected_x[17] = 24'sd49;
        expected_x[18] = 24'sd89;
        expected_x[19] = 24'sd89;
        expected_x[20] = 24'sd12;
        expected_x[21] = 24'sd59;
        expected_x[22] = 24'sd53;
        expected_x[23] = 24'sd75;
        expected_x[24] = 24'sd37;
        expected_x[25] = 24'sd78;
        expected_x[26] = 24'sd57;
        expected_x[27] = 24'sd38;
        expected_x[28] = 24'sd44;
        expected_x[29] = 24'sd98;
        expected_x[30] = 24'sd85;
        expected_x[31] = 24'sd25;
        expected_x[32] = 24'sd80;
        expected_x[33] = 24'sd39;
        expected_x[34] = 24'sd20;
        expected_x[35] = 24'sd16;
        expected_x[36] = 24'sd91;
        expected_x[37] = 24'sd81;
        expected_x[38] = 24'sd84;

        expected_a[0]  = 24'sd68;
        expected_a[1]  = 24'sd59;
        expected_a[2]  = 24'sd59;
        expected_a[3]  = 24'sd49;
        expected_a[4]  = 24'sd82;
        expected_a[5]  = 24'sd16;
        expected_a[6]  = 24'sd45;
        expected_a[7]  = 24'sd88;
        expected_a[8]  = 24'sd31;
        expected_a[9]  = 24'sd74;
        expected_a[10] = 24'sd77;
        expected_a[11] = 24'sd71;
        expected_a[12] = 24'sd18;
        expected_a[13] = 24'sd70;
        expected_a[14] = 24'sd48;
        expected_a[15] = 24'sd35;
        expected_a[16] = 24'sd73;
        expected_a[17] = 24'sd85;
        expected_a[18] = 24'sd91;
        expected_a[19] = 24'sd53;
        expected_a[20] = 24'sd30;
        expected_a[21] = 24'sd41;
        expected_a[22] = 24'sd19;
        expected_a[23] = 24'sd61;
        expected_a[24] = 24'sd62;
        expected_a[25] = 24'sd18;
        expected_a[26] = 24'sd26;
        expected_a[27] = 24'sd13;
        expected_a[28] = 24'sd59;
        expected_a[29] = 24'sd83;
        expected_a[30] = 24'sd95;
        expected_a[31] = 24'sd55;
        expected_a[32] = 24'sd73;
        expected_a[33] = 24'sd84;
        expected_a[34] = 24'sd40;
        expected_a[35] = 24'sd22;
        expected_a[36] = 24'sd14;
        expected_a[37] = 24'sd28;
        expected_a[38] = 24'sd90;
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;

        in_x_data = 24'sd0;
        in_x_valid = 1'b0;

        in_a_data = 24'sd0;
        in_a_valid = 1'b0;

        out_x_ready = 1'b0;
        out_a_ready = 1'b0;

        x_driver_done = 1'b0;
        a_driver_done = 1'b0;
        test_finished = 1'b0;

        x_sent_count = 0;
        a_sent_count = 0;
        x_received_count = 0;
        a_received_count = 0;

        x_ready_cycle = 0;
        a_ready_cycle = 0;
        timeout_counter = 0;

        passed = 0;
        failed = 0;

        out_x_waiting = 1'b0;
        out_a_waiting = 1'b0;

        held_out_x_data = 24'sd0;
        held_out_a_data = 24'sd0;

        in_x_ready_unknown_seen = 1'b0;
        in_a_ready_unknown_seen = 1'b0;
        out_x_valid_unknown_seen = 1'b0;
        out_a_valid_unknown_seen = 1'b0;
        out_x_data_unknown_seen = 1'b0;
        out_a_data_unknown_seen = 1'b0;

        repeat (5) @(posedge clk);
        #1;
        rst = 1'b0;
    end

    initial begin
        wait (rst === 1'b0);

        while (x_sent_count < STREAM_LENGTH) begin
            @(negedge clk);
            in_x_data = expected_x[x_sent_count];
            in_x_valid = 1'b1;

            do begin
                @(posedge clk);
            end while (in_x_ready !== 1'b1);

            x_sent_count = x_sent_count + 1;

            @(negedge clk);
            in_x_valid = 1'b0;
            in_x_data = 24'sd0;
        end

        x_driver_done = 1'b1;
    end

    initial begin
        wait (rst === 1'b0);

        while (a_sent_count < STREAM_LENGTH) begin
            @(negedge clk);
            in_a_data = expected_a[a_sent_count];
            in_a_valid = 1'b1;

            do begin
                @(posedge clk);
            end while (in_a_ready !== 1'b1);

            a_sent_count = a_sent_count + 1;

            @(negedge clk);
            in_a_valid = 1'b0;
            in_a_data = 24'sd0;
        end

        a_driver_done = 1'b1;
    end

    always @(negedge clk) begin
        if (rst) begin
            x_ready_cycle = 0;
            a_ready_cycle = 0;
            out_x_ready = 1'b0;
            out_a_ready = 1'b0;
        end
        else begin
            x_ready_cycle = x_ready_cycle + 1;
            a_ready_cycle = a_ready_cycle + 1;

            if ((x_ready_cycle % 5) == 0)
                out_x_ready = 1'b0;
            else
                out_x_ready = 1'b1;

            if (((a_ready_cycle % 7) == 0) ||
                ((a_ready_cycle % 7) == 1))
                out_a_ready = 1'b0;
            else
                out_a_ready = 1'b1;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            x_received_count = 0;
            a_received_count = 0;
            out_x_waiting = 1'b0;
            out_a_waiting = 1'b0;
        end
        else begin
            if ((in_x_ready !== 1'b0) &&
                (in_x_ready !== 1'b1) &&
                !in_x_ready_unknown_seen) begin
                failed = failed + 1;
                in_x_ready_unknown_seen = 1'b1;
                $display("FAIL: X/Z detected on IN.X READY at time=%0t", $time);
            end

            if ((in_a_ready !== 1'b0) &&
                (in_a_ready !== 1'b1) &&
                !in_a_ready_unknown_seen) begin
                failed = failed + 1;
                in_a_ready_unknown_seen = 1'b1;
                $display("FAIL: X/Z detected on IN.A READY at time=%0t", $time);
            end

            if ((out_x_valid !== 1'b0) &&
                (out_x_valid !== 1'b1) &&
                !out_x_valid_unknown_seen) begin
                failed = failed + 1;
                out_x_valid_unknown_seen = 1'b1;
                $display("FAIL: X/Z detected on OUT.X VALID at time=%0t", $time);
            end

            if ((out_a_valid !== 1'b0) &&
                (out_a_valid !== 1'b1) &&
                !out_a_valid_unknown_seen) begin
                failed = failed + 1;
                out_a_valid_unknown_seen = 1'b1;
                $display("FAIL: X/Z detected on OUT.A VALID at time=%0t", $time);
            end

            if ((out_x_valid === 1'b1) &&
                ((^out_x_data) === 1'bx) &&
                !out_x_data_unknown_seen) begin
                failed = failed + 1;
                out_x_data_unknown_seen = 1'b1;
                $display("FAIL: X/Z detected on OUT.X DATA at time=%0t", $time);
            end

            if ((out_a_valid === 1'b1) &&
                ((^out_a_data) === 1'bx) &&
                !out_a_data_unknown_seen) begin
                failed = failed + 1;
                out_a_data_unknown_seen = 1'b1;
                $display("FAIL: X/Z detected on OUT.A DATA at time=%0t", $time);
            end

            if (out_x_waiting) begin
                if (out_x_valid !== 1'b1) begin
                    failed = failed + 1;
                    $display("FAIL: OUT.X VALID dropped before handshake at time=%0t", $time);
                end
                else if (out_x_data !== held_out_x_data) begin
                    failed = failed + 1;
                    $display("FAIL: OUT.X DATA changed while waiting at time=%0t old=%0d new=%0d", $time, held_out_x_data, out_x_data);
                end
            end

            if (out_a_waiting) begin
                if (out_a_valid !== 1'b1) begin
                    failed = failed + 1;
                    $display("FAIL: OUT.A VALID dropped before handshake at time=%0t", $time);
                end
                else if (out_a_data !== held_out_a_data) begin
                    failed = failed + 1;
                    $display("FAIL: OUT.A DATA changed while waiting at time=%0t old=%0d new=%0d", $time, held_out_a_data, out_a_data);
                end
            end

            if ((out_x_valid === 1'b1) &&
                (out_x_ready === 1'b0)) begin
                out_x_waiting = 1'b1;
                held_out_x_data = out_x_data;
            end
            else begin
                out_x_waiting = 1'b0;
            end

            if ((out_a_valid === 1'b1) &&
                (out_a_ready === 1'b0)) begin
                out_a_waiting = 1'b1;
                held_out_a_data = out_a_data;
            end
            else begin
                out_a_waiting = 1'b0;
            end

            if ((out_x_valid === 1'b1) &&
                (out_x_ready === 1'b1)) begin
                if (x_received_count >= STREAM_LENGTH) begin
                    failed = failed + 1;
                    $display("FAIL: Unexpected extra OUT.X value=%0d at time=%0t", out_x_data, $time);
                end
                else if (out_x_data !== expected_x[x_received_count]) begin
                    failed = failed + 1;
                    $display("FAIL: OUT.X index=%0d expected=%0d actual=%0d time=%0t", x_received_count, expected_x[x_received_count], out_x_data, $time);
                end
                else begin
                    passed = passed + 1;
                    $display("PASS: OUT.X index=%0d value=%0d time=%0t", x_received_count, out_x_data, $time);
                end

                x_received_count = x_received_count + 1;
            end

            if ((out_a_valid === 1'b1) &&
                (out_a_ready === 1'b1)) begin
                if (a_received_count >= STREAM_LENGTH) begin
                    failed = failed + 1;
                    $display("FAIL: Unexpected extra OUT.A value=%0d at time=%0t", out_a_data, $time);
                end
                else if (out_a_data !== expected_a[a_received_count]) begin
                    failed = failed + 1;
                    $display("FAIL: OUT.A index=%0d expected=%0d actual=%0d time=%0t", a_received_count, expected_a[a_received_count], out_a_data, $time);
                end
                else begin
                    passed = passed + 1;
                    $display("PASS: OUT.A index=%0d value=%0d time=%0t", a_received_count, out_a_data, $time);
                end

                a_received_count = a_received_count + 1;
            end
        end
    end

    initial begin
        wait (rst === 1'b0);

        wait ((x_driver_done === 1'b1) &&
              (a_driver_done === 1'b1) &&
              (x_received_count >= STREAM_LENGTH) &&
              (a_received_count >= STREAM_LENGTH));

        repeat (8) @(posedge clk);
        #1;

        if (x_sent_count == STREAM_LENGTH) begin
            passed = passed + 1;
            $display("PASS: IN.X accepted count = %0d", x_sent_count);
        end
        else begin
            failed = failed + 1;
            $display("FAIL: IN.X accepted count expected=%0d actual=%0d", STREAM_LENGTH, x_sent_count);
        end

        if (a_sent_count == STREAM_LENGTH) begin
            passed = passed + 1;
            $display("PASS: IN.A accepted count = %0d", a_sent_count);
        end
        else begin
            failed = failed + 1;
            $display("FAIL: IN.A accepted count expected=%0d actual=%0d", STREAM_LENGTH, a_sent_count);
        end

        if (x_received_count == STREAM_LENGTH) begin
            passed = passed + 1;
            $display("PASS: OUT.X produced count = %0d", x_received_count);
        end
        else begin
            failed = failed + 1;
            $display("FAIL: OUT.X produced count expected=%0d actual=%0d", STREAM_LENGTH, x_received_count);
        end

        if (a_received_count == STREAM_LENGTH) begin
            passed = passed + 1;
            $display("PASS: OUT.A produced count = %0d", a_received_count);
        end
        else begin
            failed = failed + 1;
            $display("FAIL: OUT.A produced count expected=%0d actual=%0d", STREAM_LENGTH, a_received_count);
        end

        test_finished = 1'b1;

        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

    initial begin
        wait (rst === 1'b0);

        while ((timeout_counter < TIMEOUT_CYCLES) &&
               (test_finished !== 1'b1)) begin
            @(posedge clk);
            timeout_counter = timeout_counter + 1;
        end

        if (test_finished !== 1'b1) begin
            failed = failed + 1;
            $display("FAIL: Simulation timeout after %0d cycles", TIMEOUT_CYCLES);
            $display("IN.X accepted=%0d OUT.X produced=%0d", x_sent_count, x_received_count);
            $display("IN.A accepted=%0d OUT.A produced=%0d", a_sent_count, a_received_count);
            $display("Passed: %0d", passed);
            $display("Failed: %0d", failed);
            $display("TEST FAILED");
            $finish;
        end
    end

endmodule
