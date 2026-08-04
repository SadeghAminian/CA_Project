`timescale 1ns/1ps

module t13_tb_debug;

    localparam int DATA_WIDTH = 24;
    localparam int STACK_DEPTH = 15;

    logic clk;
    logic rst;

    logic signed [DATA_WIDTH-1:0] in_data;
    logic in_valid;
    logic in_ready;

    logic signed [DATA_WIDTH-1:0] out_data;
    logic out_valid;
    logic out_ready;

    t13_top #(
        .N01_HEX("n01.hex"),
        .N11_HEX("n11.hex"),
        .N12_HEX("n12.hex"),
        .N22_HEX("n22.hex"),
        .STACK_DEPTH(STACK_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic send_word(input integer value);
    begin
        @(negedge clk);
        in_data  <= value;
        in_valid <= 1'b1;

        while (in_ready !== 1'b1) begin
            @(negedge clk);
        end

        @(negedge clk);
        in_valid <= 1'b0;
        in_data  <= '0;

        $display("[%0t] INPUT SENT: %0d", $time, value);
    end
    endtask

    integer cycle_count;

    initial begin
        rst      = 1'b1;
        in_data  = '0;
        in_valid = 1'b0;
        out_ready = 1'b1;
        cycle_count = 0;

        repeat (5) @(posedge clk);
        rst = 1'b0;

        $display("========================================");
        $display("T13 DEBUG TEST START");
        $display("========================================");

        send_word(1);
        send_word(2);
        send_word(3);
        send_word(4);
        send_word(0);

        repeat (200) @(posedge clk);

        $display("========================================");
        $display("TIMEOUT");
        $display("========================================");
        $stop;
    end

    always @(posedge clk) begin
        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    always @(posedge clk) begin
        if (!rst) begin
            if (in_valid && in_ready)
                $display("[%0t][C%0d] [IN->N01] data=%0d", $time, cycle_count, in_data);

            if (dut.n01_right_valid_out && dut.n02_ready_out_l)
                $display("[%0t][C%0d] [N01->N02] data=%0d", $time, cycle_count, dut.data_out_n01);

            if (dut.n01_down_valid_out && dut.n11_up_ready_out)
                $display("[%0t][C%0d] [N01->N11] data=%0d", $time, cycle_count, dut.data_out_n01);

            if (dut.n02_valid_out_d && dut.n12_up_ready_out)
                $display("[%0t][C%0d] [N02->N12] data=%0d", $time, cycle_count, dut.n02_data_out_d);

            if (dut.n11_right_valid_out && dut.n12_left_ready_out)
                $display("[%0t][C%0d] [N11->N12] data=%0d", $time, cycle_count, dut.data_out_n11);

            if (dut.n12_down_valid_out && dut.n22_up_ready_out)
                $display("[%0t][C%0d] [N12->N22] data=%0d", $time, cycle_count, dut.data_out_n12);

            if (dut.n22_down_valid_out && out_ready)
                $display("[%0t][C%0d] [N22->OUT] data=%0d", $time, cycle_count, dut.data_out_n22);

            if (out_valid && out_ready) begin
                $display("[%0t][C%0d] [OUTPUT] data=%0d", $time, cycle_count, out_data);
                if (out_data == 1) begin
                    $display("========================================");
                    $display("TEST COMPLETED");
                    $display("========================================");
                    $stop;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (!rst) begin
            $display("[%0t][C%0d] STATE | in_v=%b in_r=%b | out_v=%b out_r=%b",
                $time, cycle_count,
                in_valid, in_ready,
                out_valid, out_ready);

            $display("               N01: R(v=%b r=%b) D(v=%b r=%b)",
                dut.n01_right_valid_out, dut.n02_ready_out_l,
                dut.n01_down_valid_out, dut.n11_up_ready_out);

            $display("               N02: D(v=%b r=%b data=%0d)",
                dut.n02_valid_out_d, dut.n12_up_ready_out, dut.n02_data_out_d);

            $display("               N11: R(v=%b r=%b data=%0d)",
                dut.n11_right_valid_out, dut.n12_left_ready_out, dut.data_out_n11);

            $display("               N12: L(v=%b r=%b) U(v=%b r=%b) D(v=%b r=%b data=%0d)",
                dut.n11_right_valid_out, dut.n12_left_ready_out,
                dut.n02_valid_out_d, dut.n12_up_ready_out,
                dut.n12_down_valid_out, dut.n22_up_ready_out, dut.data_out_n12);

            $display("               N22: U(v=%b r=%b data=%0d) D(v=%b r=%b data=%0d)",
                dut.n12_down_valid_out, dut.n22_up_ready_out, dut.data_out_n12,
                dut.n22_down_valid_out, out_ready, dut.data_out_n22);

            $display("----------------------------------------------------------------");
        end
    end

endmodule
