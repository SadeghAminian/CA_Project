`timescale 1ns/1ps

module t14_tb_demo;

    localparam int DATA_WIDTH     = 24;
    localparam int STACK_DEPTH    = 15;
    localparam int TIMEOUT_CYCLES = 3000;

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

    logic signed [DATA_WIDTH-1:0] demo_a;
    logic signed [DATA_WIDTH-1:0] demo_b;
    logic signed [DATA_WIDTH-1:0] expected_value;
    logic signed [DATA_WIDTH-1:0] actual_value;

    logic a_accepted;
    logic b_accepted;
    logic result_seen;
    logic test_pass;
    logic test_fail;

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

    task automatic send_a_once;
        begin
            @(negedge clk);
            in_a_data  = demo_a;
            in_a_valid = 1'b1;

            do begin
                @(posedge clk);
            end while (!in_a_ready);

            a_accepted = 1'b1;
            $display("[%0t] A accepted = %0d", $time, $signed(demo_a));

            @(negedge clk);
            in_a_valid = 1'b0;
        end
    endtask

    task automatic send_b_once;
        begin
            @(negedge clk);
            in_b_data  = demo_b;
            in_b_valid = 1'b1;

            do begin
                @(posedge clk);
            end while (!in_b_ready);

            b_accepted = 1'b1;
            $display("[%0t] B accepted = %0d", $time, $signed(demo_b));

            @(negedge clk);
            in_b_valid = 1'b0;
        end
    endtask

    initial begin : main_test
        demo_a         = 7;
        demo_b         = 8;
        expected_value = demo_a * demo_b;
        actual_value   = '0;

        rst        = 1'b1;
        in_a_data  = '0;
        in_a_valid = 1'b0;
        in_b_data  = '0;
        in_b_valid = 1'b0;
        out_ready  = 1'b1;

        a_accepted = 1'b0;
        b_accepted = 1'b0;
        result_seen = 1'b0;
        test_pass = 1'b0;
        test_fail = 1'b0;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("========================================");
        $display("Stage 14 Demo Test");
        $display("A = %0d, B = %0d, Expected = %0d", demo_a, demo_b, expected_value);
        $display("========================================");

        fork
            send_a_once();
            send_b_once();
        join

        wait (out_valid && out_ready);

        @(posedge clk);
        actual_value = out_data;
        result_seen  = 1'b1;

        if ($signed(out_data) === $signed(expected_value)) begin
            test_pass = 1'b1;
            $display("[%0t] PASS: expected=%0d actual=%0d", $time, expected_value, out_data);
        end
        else begin
            test_fail = 1'b1;
            $display("[%0t] FAIL: expected=%0d actual=%0d", $time, expected_value, out_data);
        end

        repeat (50) @(posedge clk);

        $display("========================================");
        if (test_pass)
            $display("FINAL RESULT: PASS");
        else
            $display("FINAL RESULT: FAIL");
        $display("========================================");

        $finish;
    end

    initial begin : timeout_block
        repeat (TIMEOUT_CYCLES) @(posedge clk);

        if (!result_seen) begin
            test_fail = 1'b1;

            $display("========================================");
            $display("FINAL RESULT: FAIL");
            $display("Reason: timeout");
            $display("========================================");

            $finish;
        end
    end

endmodule
