`timescale 1ns/1ps

module t12_t30_integration_tb;

    logic clk;
    logic rst;
    logic rst_pop_node;

    logic signed [23:0] in_data;
    logic in_valid;
    logic in_ready;

    logic signed [23:0] out_data;
    logic out_valid;
    logic out_ready;

    int passed;
    int failed;

    always #5 clk = ~clk;

    t12_t30_integration_top #(
        .PUSH_HEX("t12_t30_push.hex"),
        .POP_HEX("t12_t30_pop.hex"),
        .STACK_DEPTH(15),
        .DATA_WIDTH(24)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rst_pop_node(rst_pop_node),
        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    task automatic check_data(
        input string name,
        input logic signed [23:0] actual,
        input logic signed [23:0] expected
    );
        begin
            if (actual === expected) begin
                passed++;
                $display("PASS %-24s actual=%0d expected=%0d time=%0t", name, actual, expected, $time);
            end else begin
                failed++;
                $display("FAIL %-24s actual=%0d expected=%0d time=%0t", name, actual, expected, $time);
            end
        end
    endtask

    task automatic drive_input(input logic signed [23:0] value);
        begin
            @(negedge clk);
            in_data  = value;
            in_valid = 1'b1;

            while (in_ready !== 1'b1) begin
                @(negedge clk);
            end

            @(posedge clk);
            @(negedge clk);
            in_valid = 1'b0;
            in_data  = 24'sd0;

            repeat (2) @(posedge clk);
        end
    endtask

    task automatic expect_output(input logic signed [23:0] expected);
        begin
            @(negedge clk);
            out_ready = 1'b1;

            while (out_valid !== 1'b1) begin
                @(negedge clk);
            end

            #1;
            check_data("output", out_data, expected);

            @(posedge clk);
            @(negedge clk);
            out_ready = 1'b0;

            repeat (2) @(posedge clk);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        rst_pop_node = 1'b1;

        in_data = 24'sd0;
        in_valid = 1'b0;
        out_ready = 1'b0;

        passed = 0;
        failed = 0;

        repeat (5) @(posedge clk);
        rst = 1'b0;

        repeat (5) @(posedge clk);

        drive_input(24'sd10);
        drive_input(24'sd20);
        drive_input(24'sd30);

        repeat (10) @(posedge clk);

        @(negedge clk);
        rst_pop_node = 1'b0;

        repeat (5) @(posedge clk);

        expect_output(24'sd30);
        expect_output(24'sd20);
        expect_output(24'sd10);

        repeat (10) @(posedge clk);

        $display("========================================");
        $display("T12 <-> T30 integration finished");
        $display("passed = %0d", passed);
        $display("failed = %0d", failed);

        if (failed == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TESTS FAILED");
        end
        $display("========================================");

        $finish;
    end

    initial begin
        repeat (3000) @(posedge clk);
        $display("TIMEOUT");
        $display("passed = %0d", passed);
        $display("failed = %0d", failed + 1);
        $finish;
    end

endmodule
