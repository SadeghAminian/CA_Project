`timescale 1ns/1ps

import cpu_type_pkg::*;

module testbench_t12Node_blocking_write;

    logic clk;
    logic rst;

    logic signed [23:0] left_data_in, right_data_in, up_data_in, down_data_in;
    logic left_valid_in, right_valid_in, up_valid_in, down_valid_in;
    logic left_ready_in, right_ready_in, up_ready_in, down_ready_in;

    logic [23:0] acc_out;
    logic zero_flag;
    logic sign_flag;

    logic signed [23:0] data_out;
    logic left_ready_out, right_ready_out, up_ready_out, down_ready_out;
    logic left_valid_out, right_valid_out, up_valid_out, down_valid_out;

    integer pass_count;
    integer fail_count;

    t12Node #(
        .FILE_NAME("mov_acc_right.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_out),
        .zero_flag(zero_flag),
        .sign_flag(sign_flag),

        .left_data_in(left_data_in),
        .right_data_in(right_data_in),
        .up_data_in(up_data_in),
        .down_data_in(down_data_in),

        .left_valid_in(left_valid_in),
        .right_valid_in(right_valid_in),
        .up_valid_in(up_valid_in),
        .down_valid_in(down_valid_in),

        .left_ready_in(left_ready_in),
        .right_ready_in(right_ready_in),
        .up_ready_in(up_ready_in),
        .down_ready_in(down_ready_in),

        .data_out(data_out),

        .left_ready_out(left_ready_out),
        .right_ready_out(right_ready_out),
        .up_ready_out(up_ready_out),
        .down_ready_out(down_ready_out),

        .left_valid_out(left_valid_out),
        .right_valid_out(right_valid_out),
        .up_valid_out(up_valid_out),
        .down_valid_out(down_valid_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task automatic check_equal_int(
        input string name,
        input integer actual,
        input integer expected
    );
        begin
            if (actual == expected) begin
                $display("PASS: %s = %0d", name, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s = %0d (expected %0d)", name, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task automatic check_equal_logic(
        input string name,
        input logic actual,
        input logic expected
    );
        begin
            if (actual === expected) begin
                $display("PASS: %s = %0b", name, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s = %0b (expected %0b)", name, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task automatic show_status(input string tag);
        begin
            $display("[%0t] %s", $time, tag);
            $display("  state=%0d pc=%0d instr_up=%03h acc=%0d",
                dut.u_Controller.Main_FSM.state,
                dut.u_datapath.pc,
                dut.u_datapath.up_instr,
                $signed(dut.u_datapath.acc_value)
            );
            $display("  ready_en=%0b write_en=%0b read_done=%0b write_done=%0b",
                dut.u_Controller.ready_en,
                dut.u_Controller.write_en,
                dut.read_done,
                dut.write_done
            );
            $display("  right_ready_in=%0b right_valid_out=%0b data_out=%0d",
                right_ready_in,
                right_valid_out,
                $signed(data_out)
            );
        end
    endtask

    initial begin
        $dumpfile("testbench_t12Node_blocking_write.vcd");
        $dumpvars(0, testbench_t12Node_blocking_write);
    end

    initial begin

        logic [2:0] blocked_state;
        logic [3:0] blocked_pc;
        logic signed [23:0] blocked_acc;
        logic found_wait_write;
        integer i;

        pass_count = 0;
        fail_count = 0;

        rst = 1;

        left_data_in = 0;
        right_data_in = 0;
        up_data_in = 0;
        down_data_in = 0;

        left_valid_in = 0;
        right_valid_in = 0;
        up_valid_in = 0;
        down_valid_in = 0;

        left_ready_in = 0;
        right_ready_in = 0;
        up_ready_in = 0;
        down_ready_in = 0;

        repeat(2) @(posedge clk);
        rst = 0;

        $display("========================================");
        $display("t12Node Integration Test: Blocking Write");
        $display("Program: MOV 55, ACC ; MOV ACC, RIGHT ; NOP");
        $display("========================================");

        repeat(8) begin
            @(posedge clk);
            #1;
            show_status("Running until ACC becomes 55");
        end

        check_equal_int("ACC after MOV 55, ACC", $signed(acc_out), 55);

        found_wait_write = 0;

        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            #1;
            show_status("Searching for ST_WAIT_WRITE");

            if (dut.u_Controller.Main_FSM.state == dut.u_Controller.Main_FSM.ST_WAIT_WRITE) begin
                found_wait_write = 1;
                i = 10;
            end
        end

        check_equal_logic("entered ST_WAIT_WRITE", found_wait_write, 1'b1);

        if (found_wait_write) begin
            show_status("Entered ST_WAIT_WRITE");

            check_equal_logic("write_en", dut.u_Controller.write_en, 1'b1);
            check_equal_logic("right_valid_out", right_valid_out, 1'b1);
            check_equal_logic("write_done while neighbor not ready", dut.write_done, 1'b0);
            check_equal_int("data_out during blocking write", $signed(data_out), 55);

            blocked_state = dut.u_Controller.Main_FSM.state;
            blocked_pc = dut.u_datapath.pc;
            blocked_acc = dut.u_datapath.acc_value;

            repeat(3) begin
                @(posedge clk);
                #1;
                show_status("Blocking write cycle");
                check_equal_int("state remains ST_WAIT_WRITE", dut.u_Controller.Main_FSM.state, blocked_state);
                check_equal_int("pc remains ثابت during write block", dut.u_datapath.pc, blocked_pc);
                check_equal_int("acc remains ثابت during write block", $signed(dut.u_datapath.acc_value), $signed(blocked_acc));
                check_equal_logic("right_valid_out during block", right_valid_out, 1'b1);
                check_equal_logic("write_done during block", dut.write_done, 1'b0);
                check_equal_int("data_out remains 55", $signed(data_out), 55);
            end

            $display("----------------------------------------");
            $display("Now making RIGHT neighbor ready");

            right_ready_in = 1;

            @(posedge clk);
            #1;
            show_status("Handshake cycle");

            check_equal_logic("write_done after right_ready_in", dut.write_done, 1'b1);
            check_equal_logic("right_valid_out during handshake", right_valid_out, 1'b1);
            check_equal_int("data_out during handshake", $signed(data_out), 55);

            @(posedge clk);
            #1;
            show_status("After write handshake");

            right_ready_in = 0;

            repeat(3) begin
                @(posedge clk);
                #1;
                show_status("After write completion");
            end

            check_equal_int("ACC after MOV ACC, RIGHT", $signed(acc_out), 55);
        end

        $display("----------------------------------------");
        $display("Final Results");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $stop;
    end

endmodule
