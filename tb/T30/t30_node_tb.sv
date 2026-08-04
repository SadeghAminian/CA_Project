`timescale 1ns/1ps

module t30_node_tb;

    localparam int DATA_WIDTH  = 24;
    localparam int STACK_DEPTH = 4;

    logic clk;
    logic rst;

    logic valid_in_u;
    logic ready_in_u;
    logic signed [DATA_WIDTH-1:0] data_in_u;
    logic valid_out_u;
    logic ready_out_u;
    logic signed [DATA_WIDTH-1:0] data_out_u;

    logic valid_in_d;
    logic ready_in_d;
    logic signed [DATA_WIDTH-1:0] data_in_d;
    logic valid_out_d;
    logic ready_out_d;
    logic signed [DATA_WIDTH-1:0] data_out_d;

    logic valid_in_l;
    logic ready_in_l;
    logic signed [DATA_WIDTH-1:0] data_in_l;
    logic valid_out_l;
    logic ready_out_l;
    logic signed [DATA_WIDTH-1:0] data_out_l;

    logic valid_in_r;
    logic ready_in_r;
    logic signed [DATA_WIDTH-1:0] data_in_r;
    logic valid_out_r;
    logic ready_out_r;
    logic signed [DATA_WIDTH-1:0] data_out_r;

    int passed;
    int failed;

    t30_node #(
        .DATA_WIDTH(DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),

        .valid_in_u(valid_in_u),
        .ready_in_u(ready_in_u),
        .data_in_u(data_in_u),
        .valid_out_u(valid_out_u),
        .ready_out_u(ready_out_u),
        .data_out_u(data_out_u),

        .valid_in_d(valid_in_d),
        .ready_in_d(ready_in_d),
        .data_in_d(data_in_d),
        .valid_out_d(valid_out_d),
        .ready_out_d(ready_out_d),
        .data_out_d(data_out_d),

        .valid_in_l(valid_in_l),
        .ready_in_l(ready_in_l),
        .data_in_l(data_in_l),
        .valid_out_l(valid_out_l),
        .ready_out_l(ready_out_l),
        .data_out_l(data_out_l),

        .valid_in_r(valid_in_r),
        .ready_in_r(ready_in_r),
        .data_in_r(data_in_r),
        .valid_out_r(valid_out_r),
        .ready_out_r(ready_out_r),
        .data_out_r(data_out_r)
    );

    always #5 clk = ~clk;

    task automatic clear_ports;
        begin
            valid_in_u = 1'b0;
            valid_in_d = 1'b0;
            valid_in_l = 1'b0;
            valid_in_r = 1'b0;

            ready_in_u = 1'b0;
            ready_in_d = 1'b0;
            ready_in_l = 1'b0;
            ready_in_r = 1'b0;

            data_in_u = '0;
            data_in_d = '0;
            data_in_l = '0;
            data_in_r = '0;
        end
    endtask

    task automatic check_bit(input string name, input logic actual, input logic expected);
        begin
            if (actual === expected) begin
                passed++;
            end else begin
                failed++;
                $display("FAIL %-35s actual=%0b expected=%0b time=%0t", name, actual, expected, $time);
            end
        end
    endtask

    task automatic check_data(
        input string name,
        input logic signed [DATA_WIDTH-1:0] actual,
        input logic signed [DATA_WIDTH-1:0] expected
    );
        begin
            if (actual === expected) begin
                passed++;
            end else begin
                failed++;
                $display("FAIL %-35s actual=%0d expected=%0d time=%0t", name, actual, expected, $time);
            end
        end
    endtask

    task automatic push_u(input logic signed [DATA_WIDTH-1:0] value);
        begin
            @(negedge clk);
            clear_ports();
            valid_in_u = 1'b1;
            data_in_u  = value;
            #1;
            check_bit("push_u ready_out_u", ready_out_u, 1'b1);

            @(posedge clk);
            @(negedge clk);
            clear_ports();
        end
    endtask

    task automatic push_d(input logic signed [DATA_WIDTH-1:0] value);
        begin
            @(negedge clk);
            clear_ports();
            valid_in_d = 1'b1;
            data_in_d  = value;
            #1;
            check_bit("push_d ready_out_d", ready_out_d, 1'b1);

            @(posedge clk);
            @(negedge clk);
            clear_ports();
        end
    endtask

    task automatic pop_u(input logic signed [DATA_WIDTH-1:0] expected);
        begin
            @(negedge clk);
            clear_ports();
            ready_in_u = 1'b1;
            #1;
            check_bit("pop_u valid_out_u", valid_out_u, 1'b1);
            check_data("pop_u data_out_u", data_out_u, expected);

            @(posedge clk);
            @(negedge clk);
            clear_ports();
        end
    endtask

    task automatic pop_d(input logic signed [DATA_WIDTH-1:0] expected);
        begin
            @(negedge clk);
            clear_ports();
            ready_in_d = 1'b1;
            #1;
            check_bit("pop_d valid_out_d", valid_out_d, 1'b1);
            check_data("pop_d data_out_d", data_out_d, expected);

            @(posedge clk);
            @(negedge clk);
            clear_ports();
        end
    endtask

    task automatic check_no_unknowns(input string name);
        begin
            if (
                $isunknown(valid_out_u) || $isunknown(valid_out_d) ||
                $isunknown(valid_out_l) || $isunknown(valid_out_r) ||
                $isunknown(ready_out_u) || $isunknown(ready_out_d) ||
                $isunknown(ready_out_l) || $isunknown(ready_out_r) ||
                $isunknown(data_out_u)  || $isunknown(data_out_d)  ||
                $isunknown(data_out_l)  || $isunknown(data_out_r)
            ) begin
                failed++;
                $display("FAIL %-35s unknown X/Z detected time=%0t", name, $time);
            end else begin
                passed++;
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        passed = 0;
        failed = 0;
        clear_ports();

        repeat (3) @(posedge clk);
        rst = 1'b0;
        @(negedge clk);
        #1;

        check_bit("empty pop blocked valid_out_u", valid_out_u, 1'b0);
        check_data("empty stack data_out_u", data_out_u, 'sd0);
        check_no_unknowns("after reset");

        push_u(24'sd10);
        pop_u(24'sd10);

        push_u(24'sd11);
        push_u(24'sd22);
        push_u(24'sd33);
        pop_u(24'sd33);
        pop_u(24'sd22);
        pop_u(24'sd11);

        push_u(-24'sd5);
        push_d(24'sd100);
        pop_d(24'sd100);
        pop_u(-24'sd5);

        push_u(24'sd1);
        push_u(24'sd2);
        push_u(24'sd3);
        push_u(24'sd4);

        @(negedge clk);
        clear_ports();
        valid_in_u = 1'b1;
        data_in_u  = 24'sd99;
        #1;
        check_bit("full push blocked ready_out_u", ready_out_u, 1'b0);

        @(posedge clk);
        @(negedge clk);
        clear_ports();

        pop_u(24'sd4);
        push_u(24'sd99);
        pop_u(24'sd99);
        pop_u(24'sd3);
        pop_u(24'sd2);
        pop_u(24'sd1);

        @(negedge clk);
        clear_ports();
        ready_in_u = 1'b1;
        #1;
        check_bit("empty pop blocked valid_out_u", valid_out_u, 1'b0);

        @(posedge clk);
        @(negedge clk);
        clear_ports();

        push_u(24'sd7);

        @(negedge clk);
        clear_ports();
        valid_in_u = 1'b1;
        valid_in_d = 1'b1;
        valid_in_l = 1'b1;
        valid_in_r = 1'b1;
        data_in_u  = 24'sd10;
        data_in_d  = 24'sd20;
        data_in_l  = 24'sd30;
        data_in_r  = 24'sd40;
        #1;
        check_bit("arb push u wins ready_u", ready_out_u, 1'b1);
        check_bit("arb push d loses ready_d", ready_out_d, 1'b0);
        check_bit("arb push l loses ready_l", ready_out_l, 1'b0);
        check_bit("arb push r loses ready_r", ready_out_r, 1'b0);

        @(posedge clk);
        @(negedge clk);
        clear_ports();
        pop_u(24'sd10);
        pop_u(24'sd7);

        push_u(24'sd55);

        @(negedge clk);
        clear_ports();
        ready_in_u = 1'b1;
        ready_in_d = 1'b1;
        ready_in_l = 1'b1;
        ready_in_r = 1'b1;
        #1;
        check_bit("arb pop u wins valid_u", valid_out_u, 1'b1);
        check_bit("arb pop d loses valid_d", valid_out_d, 1'b0);
        check_bit("arb pop l loses valid_l", valid_out_l, 1'b0);
        check_bit("arb pop r loses valid_r", valid_out_r, 1'b0);
        check_data("arb pop u data", data_out_u, 24'sd55);

        @(posedge clk);
        @(negedge clk);
        clear_ports();

        push_d(24'sd66);

        @(negedge clk);
        clear_ports();
        valid_in_u = 1'b1;
        ready_in_u = 1'b1;
        data_in_u  = 24'sd77;
        #1;
        check_bit("same port push wins ready_u", ready_out_u, 1'b1);
        check_bit("same port pop loses valid_u", valid_out_u, 1'b0);

        @(posedge clk);
        @(negedge clk);
        clear_ports();

        pop_u(24'sd77);
        pop_u(24'sd66);

        check_no_unknowns("final signals");

        $display("========================================");
        $display("T30 NODE TB FINISHED");
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

endmodule
