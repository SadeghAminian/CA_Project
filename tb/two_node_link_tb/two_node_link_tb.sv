`timescale 1ns/1ps

module two_node_link_tb;

    logic clk;
    logic rst;

    logic [23:0] acc_a_out;
    logic [23:0] acc_b_out;

    logic signed [23:0] a_to_b_data;
    logic a_to_b_valid;
    logic a_to_b_ready;

    logic signed [23:0] b_to_a_data;
    logic b_to_a_valid;
    logic b_to_a_ready;

    integer pass_count;
    integer fail_count;
    integer cycle_count;
    integer handshake_count;
    integer reverse_handshake_count;
    integer pre_handshake_cycles;
    integer post_handshake_cycles;
    integer data_unstable_count;

    logic receiver_wait_seen;
    logic sender_wait_seen;
    logic handshake_seen;
    logic data_hold_active;

    logic signed [23:0] held_data;
    logic signed [23:0] transferred_data;

    two_node_link_top #(
        .NODE_A_FILE("node_a.hex"),
        .NODE_B_FILE("node_b.hex")
    ) dut (
        .clk(clk),
        .rst(rst),

        .acc_a_out(acc_a_out),
        .acc_b_out(acc_b_out),

        .a_to_b_data(a_to_b_data),
        .a_to_b_valid(a_to_b_valid),
        .a_to_b_ready(a_to_b_ready),

        .b_to_a_data(b_to_a_data),
        .b_to_a_valid(b_to_a_valid),
        .b_to_a_ready(b_to_a_ready)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("two_node_link_final.vcd");
        $dumpvars(0, two_node_link_tb);
    end

    task automatic check_logic;
        input string name;
        input logic actual;
        input logic expected;
        begin
            if (actual === expected) begin
                $display("PASS: %s = %0b", name, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s = %0b, expected %0b", name, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task automatic check_integer;
        input string name;
        input integer actual;
        input integer expected;
        begin
            if (actual == expected) begin
                $display("PASS: %s = %0d", name, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s = %0d, expected %0d", name, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task automatic check_data;
        input string name;
        input logic signed [23:0] actual;
        input logic signed [23:0] expected;
        begin
            if (actual === expected) begin
                $display("PASS: %s = %0d", name, $signed(actual));
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s = %0d, expected %0d", name, $signed(actual), $signed(expected));
                fail_count = fail_count + 1;
            end
        end
    endtask

    task automatic print_monitor;
        begin
            $display("MONITOR: cycle=%0d time=%0t | A_ACC=%0d B_ACC=%0d | A_TO_B_DATA=%0d VALID=%0b READY=%0b | B_TO_A_DATA=%0d VALID=%0b READY=%0b | A_TO_B_HS=%0b B_TO_A_HS=%0b",
                cycle_count,
                $time,
                $signed(acc_a_out),
                $signed(acc_b_out),
                $signed(a_to_b_data),
                a_to_b_valid,
                a_to_b_ready,
                $signed(b_to_a_data),
                b_to_a_valid,
                b_to_a_ready,
                a_to_b_valid && a_to_b_ready,
                b_to_a_valid && b_to_a_ready
            );
        end
    endtask

    task automatic sample_and_monitor;
        begin
            cycle_count = cycle_count + 1;

            print_monitor();

            if (a_to_b_ready && !a_to_b_valid) begin
                receiver_wait_seen = 1'b1;
            end

            if (a_to_b_valid && !a_to_b_ready) begin
                sender_wait_seen = 1'b1;

                if (!data_hold_active) begin
                    data_hold_active = 1'b1;
                    held_data = a_to_b_data;
                end else begin
                    if (a_to_b_data !== held_data) begin
                        $display("FAIL: A.RIGHT data changed while VALID=1 and READY=0, old=%0d new=%0d", $signed(held_data), $signed(a_to_b_data));
                        data_unstable_count = data_unstable_count + 1;
                        fail_count = fail_count + 1;
                        held_data = a_to_b_data;
                    end
                end
            end else begin
                data_hold_active = 1'b0;
            end

            if (a_to_b_valid && a_to_b_ready) begin
                handshake_count = handshake_count + 1;
                transferred_data = a_to_b_data;

                if (!handshake_seen) begin
                    handshake_seen = 1'b1;
                    $display("MONITOR: A.RIGHT to B.LEFT handshake detected, data=%0d", $signed(a_to_b_data));
                end else begin
                    $display("MONITOR: Additional A.RIGHT to B.LEFT handshake detected, data=%0d", $signed(a_to_b_data));
                end
            end

            if (b_to_a_valid && b_to_a_ready) begin
                reverse_handshake_count = reverse_handshake_count + 1;
                $display("MONITOR: Reverse B.LEFT to A.RIGHT handshake detected, data=%0d", $signed(b_to_a_data));
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        cycle_count = 0;
        handshake_count = 0;
        reverse_handshake_count = 0;
        pre_handshake_cycles = 0;
        post_handshake_cycles = 0;
        data_unstable_count = 0;

        receiver_wait_seen = 1'b0;
        sender_wait_seen = 1'b0;
        handshake_seen = 1'b0;
        data_hold_active = 1'b0;

        held_data = 24'sd0;
        transferred_data = 24'sd0;

        rst = 1'b1;

        repeat (3) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("----------------------------------------");
        $display("Two-node link test started");
        $display("----------------------------------------");

        while (!handshake_seen && pre_handshake_cycles < 40) begin
            @(negedge clk);
            #1;
            pre_handshake_cycles = pre_handshake_cycles + 1;
            sample_and_monitor();
        end

        check_logic("Receiver ready observed before first handshake", receiver_wait_seen, 1'b1);
        check_integer("A.RIGHT to B.LEFT handshake count before post-run", handshake_count, 1);
        check_data("Transferred data", transferred_data, 24'sd55);
        check_integer("Data unstable count while VALID=1 and READY=0", data_unstable_count, 0);

        if (sender_wait_seen) begin
            $display("INFO: Sender had at least one VALID=1 READY=0 waiting cycle");
        end else begin
            $display("INFO: Sender did not have a visible VALID=1 READY=0 waiting cycle");
        end

        while (post_handshake_cycles < 12) begin
            @(negedge clk);
            #1;
            post_handshake_cycles = post_handshake_cycles + 1;
            sample_and_monitor();
        end

        check_data("Node A ACC", acc_a_out, 24'sd55);
        check_data("Node B ACC", acc_b_out, 24'sd55);
        check_integer("Final A.RIGHT to B.LEFT handshake count", handshake_count, 1);
        check_integer("Reverse B.LEFT to A.RIGHT handshake count", reverse_handshake_count, 0);

        $display("----------------------------------------");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
