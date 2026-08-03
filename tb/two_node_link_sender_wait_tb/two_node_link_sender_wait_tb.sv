`timescale 1ns/1ps

module two_node_link_sender_wait_tb;

    parameter integer VERBOSE = 0;

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
    integer wait_phase_cycles;
    integer post_handshake_cycles;
    integer data_unstable_count;
    integer sender_wait_cycles;
    integer receiver_ready_before_sender_count;

    logic sender_wait_seen;
    logic receiver_ready_seen;
    logic handshake_seen;
    logic data_hold_active;
    logic acc_a_changed_seen;
    logic acc_b_changed_seen;

    logic signed [23:0] held_data;
    logic signed [23:0] transferred_data;

    logic [23:0] prev_acc_a;
    logic [23:0] prev_acc_b;

    logic sampled_a_to_b_valid;
    logic sampled_a_to_b_ready;
    logic signed [23:0] sampled_a_to_b_data;

    logic sampled_b_to_a_valid;
    logic sampled_b_to_a_ready;
    logic signed [23:0] sampled_b_to_a_data;

    time previous_posedge_time;
    logic first_posedge_seen;

    two_node_link_top #(
        .NODE_A_FILE("node_a.hex"),
        .NODE_B_FILE("node_b_delayed.hex")
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
        $dumpfile("two_node_link_sender_wait.vcd");
        $dumpvars(0, two_node_link_sender_wait_tb);
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

    task automatic check_integer_min;
        input string name;
        input integer actual;
        input integer minimum;
        begin
            if (actual >= minimum) begin
                $display("PASS: %s = %0d, minimum %0d", name, actual, minimum);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s = %0d, minimum %0d", name, actual, minimum);
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

    task automatic print_cycle_status;
        begin
            if (VERBOSE != 0) begin
                $display("CYCLE: %0d time=%0t A_ACC=%0d B_ACC=%0d A2B_DATA=%0d A2B_V=%0b A2B_R=%0b B2A_DATA=%0d B2A_V=%0b B2A_R=%0b",
                    cycle_count,
                    $time,
                    $signed(acc_a_out),
                    $signed(acc_b_out),
                    $signed(a_to_b_data),
                    a_to_b_valid,
                    a_to_b_ready,
                    $signed(b_to_a_data),
                    b_to_a_valid,
                    b_to_a_ready
                );
            end
        end
    endtask

    always @(posedge clk) begin
        sampled_a_to_b_valid = a_to_b_valid;
        sampled_a_to_b_ready = a_to_b_ready;
        sampled_a_to_b_data  = a_to_b_data;

        sampled_b_to_a_valid = b_to_a_valid;
        sampled_b_to_a_ready = b_to_a_ready;
        sampled_b_to_a_data  = b_to_a_data;

        if (first_posedge_seen) begin
            if (($time - previous_posedge_time) != 10) begin
                $display("FAIL: Invalid clock period at time=%0t period=%0t", $time, $time - previous_posedge_time);
                fail_count = fail_count + 1;
            end
        end else begin
            first_posedge_seen = 1'b1;
        end

        previous_posedge_time = $time;

        if (!rst) begin
            cycle_count = cycle_count + 1;

            print_cycle_status();

            if ((sampled_a_to_b_valid !== 1'b0) && (sampled_a_to_b_valid !== 1'b1)) begin
                $display("FAIL: A2B VALID is unknown at cycle=%0d time=%0t", cycle_count, $time);
                fail_count = fail_count + 1;
            end

            if ((sampled_a_to_b_ready !== 1'b0) && (sampled_a_to_b_ready !== 1'b1)) begin
                $display("FAIL: A2B READY is unknown at cycle=%0d time=%0t", cycle_count, $time);
                fail_count = fail_count + 1;
            end

            if (!handshake_seen && sampled_a_to_b_ready && !sampled_a_to_b_valid) begin
                receiver_ready_before_sender_count = receiver_ready_before_sender_count + 1;
                if (!receiver_ready_seen) begin
                    receiver_ready_seen = 1'b1;
                    $display("EVENT: cycle=%0d time=%0t Receiver ready before sender valid observed", cycle_count, $time);
                end
            end

            if (sampled_a_to_b_valid) begin
                if (!data_hold_active) begin
                    data_hold_active = 1'b1;
                    held_data = sampled_a_to_b_data;
                end else begin
                    if (!sampled_a_to_b_ready && (sampled_a_to_b_data !== held_data)) begin
                        $display("FAIL: cycle=%0d time=%0t A.RIGHT data changed while VALID=1 READY=0 old=%0d new=%0d",
                            cycle_count, $time, $signed(held_data), $signed(sampled_a_to_b_data));
                        data_unstable_count = data_unstable_count + 1;
                        fail_count = fail_count + 1;
                        held_data = sampled_a_to_b_data;
                    end
                end

                if (!sampled_a_to_b_ready) begin
                    sender_wait_cycles = sender_wait_cycles + 1;

                    if (!sender_wait_seen) begin
                        sender_wait_seen = 1'b1;
                        $display("EVENT: cycle=%0d time=%0t Sender wait observed: A.RIGHT VALID=1 while B.LEFT READY=0 DATA=%0d",
                            cycle_count, $time, $signed(sampled_a_to_b_data));
                    end
                end

                if (sampled_a_to_b_ready) begin
                    handshake_count = handshake_count + 1;
                    transferred_data = sampled_a_to_b_data;

                    if (!handshake_seen) begin
                        handshake_seen = 1'b1;
                        $display("EVENT: cycle=%0d time=%0t A.RIGHT -> B.LEFT handshake, data=%0d",
                            cycle_count, $time, $signed(sampled_a_to_b_data));
                    end else begin
                        $display("EVENT: cycle=%0d time=%0t Extra A.RIGHT -> B.LEFT handshake, data=%0d",
                            cycle_count, $time, $signed(sampled_a_to_b_data));
                    end

                    data_hold_active = 1'b0;
                end
            end else begin
                if (data_hold_active) begin
                    $display("FAIL: cycle=%0d time=%0t A.RIGHT VALID dropped before handshake", cycle_count, $time);
                    data_hold_active = 1'b0;
                    fail_count = fail_count + 1;
                end
            end

            if (sampled_b_to_a_valid && sampled_b_to_a_ready) begin
                reverse_handshake_count = reverse_handshake_count + 1;
                $display("EVENT: cycle=%0d time=%0t Reverse B.LEFT -> A.RIGHT handshake, data=%0d",
                    cycle_count, $time, $signed(sampled_b_to_a_data));
            end

            #1;

            if (acc_a_out !== prev_acc_a) begin
                acc_a_changed_seen = 1'b1;
                $display("EVENT: cycle=%0d time=%0t Node A ACC changed: %0d -> %0d",
                    cycle_count, $time, $signed(prev_acc_a), $signed(acc_a_out));
                prev_acc_a = acc_a_out;
            end

            if (acc_b_out !== prev_acc_b) begin
                acc_b_changed_seen = 1'b1;
                $display("EVENT: cycle=%0d time=%0t Node B ACC changed: %0d -> %0d",
                    cycle_count, $time, $signed(prev_acc_b), $signed(acc_b_out));
                prev_acc_b = acc_b_out;
            end
        end
    end

    initial begin
        pass_count = 0;
        fail_count = 0;
        cycle_count = 0;
        handshake_count = 0;
        reverse_handshake_count = 0;
        wait_phase_cycles = 0;
        post_handshake_cycles = 0;
        data_unstable_count = 0;
        sender_wait_cycles = 0;
        receiver_ready_before_sender_count = 0;

        sender_wait_seen = 1'b0;
        receiver_ready_seen = 1'b0;
        handshake_seen = 1'b0;
        data_hold_active = 1'b0;
        acc_a_changed_seen = 1'b0;
        acc_b_changed_seen = 1'b0;

        held_data = 24'sd0;
        transferred_data = 24'sd0;

        prev_acc_a = 24'd0;
        prev_acc_b = 24'd0;

        sampled_a_to_b_valid = 1'b0;
        sampled_a_to_b_ready = 1'b0;
        sampled_a_to_b_data = 24'sd0;

        sampled_b_to_a_valid = 1'b0;
        sampled_b_to_a_ready = 1'b0;
        sampled_b_to_a_data = 24'sd0;

        previous_posedge_time = 0;
        first_posedge_seen = 1'b0;

        rst = 1'b1;

        repeat (4) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        @(posedge clk);
        #1;

        prev_acc_a = acc_a_out;
        prev_acc_b = acc_b_out;

        $display("----------------------------------------");
        $display("Two-node sender-wait timing test started");
        $display("Reset released. Handshake is sampled at posedge clk.");
        $display("ACC changes are checked after #1 to allow NBA updates.");
        $display("Node B is delayed by NOP instructions before MOV LEFT, ACC.");
        $display("----------------------------------------");

        while (!handshake_seen && wait_phase_cycles < 80) begin
            @(posedge clk);
            if (!rst) begin
                wait_phase_cycles = wait_phase_cycles + 1;
            end
        end

        $display("----------------------------------------");
        $display("Wait phase completed");
        $display("----------------------------------------");

        check_logic("Sender wait observed before first handshake", sender_wait_seen, 1'b1);
        check_integer_min("Sender wait cycles with VALID=1 READY=0", sender_wait_cycles, 1);
        check_integer("Data unstable count while VALID=1 READY=0", data_unstable_count, 0);
        check_integer("A.RIGHT to B.LEFT handshake count before post-run", handshake_count, 1);
        check_data("Transferred data", transferred_data, 24'sd55);

        if (receiver_ready_before_sender_count == 0) begin
            $display("PASS: Receiver was not ready before sender valid in this delayed-receiver scenario");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Receiver became ready before sender valid, count=%0d", receiver_ready_before_sender_count);
            fail_count = fail_count + 1;
        end

        repeat (12) begin
            @(posedge clk);
            if (!rst) begin
                post_handshake_cycles = post_handshake_cycles + 1;
            end
        end

        #1;

        $display("----------------------------------------");
        $display("Post-handshake phase completed");
        $display("----------------------------------------");

        check_data("Node A ACC", acc_a_out, 24'sd55);
        check_data("Node B ACC", acc_b_out, 24'sd55);
        check_integer("Final A.RIGHT to B.LEFT handshake count", handshake_count, 1);
        check_integer("Reverse B.LEFT to A.RIGHT handshake count", reverse_handshake_count, 0);

        $display("----------------------------------------");
        $display("Final state:");
        $display("A_ACC=%0d B_ACC=%0d A2B_HANDSHAKES=%0d B2A_HANDSHAKES=%0d SENDER_WAIT_CYCLES=%0d DATA_UNSTABLE=%0d",
            $signed(acc_a_out), $signed(acc_b_out), handshake_count, reverse_handshake_count, sender_wait_cycles, data_unstable_count);
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
