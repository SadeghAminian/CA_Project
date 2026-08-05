// window filter solution tb
`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 18 (Moving Sum of Last 3 & 5)
//=============================================================================
module tb_stage18;

    localparam int  NUM_VALUES = 11;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    // Input Stream
    logic signed [23:0] in_data;
    logic               in_valid;
    logic               in_ready;

    // Output Streams
    logic signed [23:0] out3_data, out5_data;
    logic               out3_valid, out5_valid;
    logic               out3_ready, out5_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage18 dut (
        .clk(clk), .rst(rst),
        .in_data(in_data), .in_valid(in_valid), .in_ready(in_ready),
        .out3_data(out3_data), .out3_valid(out3_valid), .out3_ready(out3_ready),
        .out5_data(out5_data), .out5_valid(out5_valid), .out5_ready(out5_ready)
    );

    // Test Data Arrays
    logic signed [23:0] in_vals  [0:NUM_VALUES-1];
    logic signed [23:0] exp_out3 [0:NUM_VALUES-1];
    logic signed [23:0] exp_out5 [0:NUM_VALUES-1];
    logic signed [23:0] cap_out3 [0:NUM_VALUES-1];
    logic signed [23:0] cap_out5 [0:NUM_VALUES-1];

    integer cnt3, cnt5, i, errors;
    logic timed_out;

    initial begin
        cnt3 = 0; cnt5 = 0; errors = 0; timed_out = 0;

        in_vals  = '{11, 77, 17, 67, 30, 84, 17, 23, 96, 82, 90};
        exp_out3 = '{11, 88, 105, 161, 114, 181, 131, 124, 136, 201, 268};
        exp_out5 = '{11, 88, 105, 172, 202, 275, 215, 221, 250, 302, 308};
    end

    assign out3_ready = 1'b1;
    assign out5_ready = 1'b1;

    // Monitor Output 3
    always @(posedge clk) begin
        if (!rst && out3_valid && out3_ready) begin
            if (cnt3 < NUM_VALUES) begin
                cap_out3[cnt3] = out3_data;
                $display("Time=%0t : OUT.3[%0d] <= %0d", $time, cnt3, out3_data);
            end
            cnt3++;
        end
    end

    // Monitor Output 5
    always @(posedge clk) begin
        if (!rst && out5_valid && out5_ready) begin
            if (cnt5 < NUM_VALUES) begin
                cap_out5[cnt5] = out5_data;
                $display("Time=%0t : OUT.5[%0d] <= %0d", $time, cnt5, out5_data);
            end
            cnt5++;
        end
    end

    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    //=================================================
    // IN Driver (Registered Handshake)
    //=================================================
    logic signed [23:0] data_q; logic valid_q; integer idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin valid_q <= 0; data_q <= 0; idx <= 0; end
        else begin
            if (valid_q && in_ready) begin
                valid_q <= 0;
                $display("Time=%0t : IN[%0d]=%0d accepted", $time, idx, data_q);
                idx <= idx + 1;
            end else if (!valid_q && idx < NUM_VALUES) begin
                data_q  <= in_vals[idx];
                valid_q <= 1'b1;
            end
        end
    end
    assign in_data  = data_q;
    assign in_valid = valid_q;

    //=================================================
    // Checker with Timeout
    //=================================================
    initial begin
        fork
            wait (cnt3 >= NUM_VALUES && cnt5 >= NUM_VALUES);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. OUT3=%0d/%0d, OUT5=%0d/%0d", cnt3, NUM_VALUES, cnt5, NUM_VALUES);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 18 RESULT CHECK (Moving Sums)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            automatic logic ok3 = (cap_out3[i] === exp_out3[i]);
            automatic logic ok5 = (cap_out5[i] === exp_out5[i]);
            
            if (ok3 && ok5)
                $display("  PASS: [%0d] OUT3=%0d OUT5=%0d (IN=%0d)", 
                         i, cap_out3[i], cap_out5[i], in_vals[i]);
            else begin
                if (!ok3) begin
                    $display("  FAIL: [%0d] OUT3=%0d (expected %0d) (IN=%0d)",
                             i, cap_out3[i], exp_out3[i], in_vals[i]);
                    errors++;
                end
                if (!ok5) begin
                    $display("  FAIL: [%0d] OUT5=%0d (expected %0d) (IN=%0d)",
                             i, cap_out5[i], exp_out5[i], in_vals[i]);
                    errors++;
                end
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 18: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 18: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule