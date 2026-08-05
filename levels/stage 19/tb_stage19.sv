//signal divider solution tb
`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 19 (Division: Quotient & Remainder)
//=============================================================================
module tb_stage19;

    localparam int  NUM_VALUES = 10;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    // Input Streams
    logic signed [23:0] in_a_data, in_b_data;
    logic               in_a_valid, in_b_valid;
    logic               in_a_ready, in_b_ready;

    // Output Streams
    logic signed [23:0] out_q_data, out_r_data;
    logic               out_q_valid, out_r_valid;
    logic               out_q_ready, out_r_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage19 dut (
        .clk(clk), .rst(rst),
        .in_a_data(in_a_data), .in_a_valid(in_a_valid), .in_a_ready(in_a_ready),
        .in_b_data(in_b_data), .in_b_valid(in_b_valid), .in_b_ready(in_b_ready),
        .out_q_data(out_q_data), .out_q_valid(out_q_valid), .out_q_ready(out_q_ready),
        .out_r_data(out_r_data), .out_r_valid(out_r_valid), .out_r_ready(out_r_ready)
    );

    // Test Data Arrays
    logic signed [23:0] in_a_vals [0:NUM_VALUES-1];
    logic signed [23:0] in_b_vals [0:NUM_VALUES-1];
    logic signed [23:0] exp_q     [0:NUM_VALUES-1];
    logic signed [23:0] exp_r     [0:NUM_VALUES-1];
    logic signed [23:0] cap_q     [0:NUM_VALUES-1];
    logic signed [23:0] cap_r     [0:NUM_VALUES-1];

    integer q_count, r_count, i, errors;
    logic timed_out;

    initial begin
        q_count = 0; r_count = 0; errors = 0; timed_out = 0;

        in_a_vals = '{47, 75, 65, 81, 96, 74, 96, 62, 10, 71};
        in_b_vals = '{3,  6,  3,  7,  9,  9,  2,  1,  2,  9};
        exp_q     = '{15, 12, 21, 11, 10, 8,  48, 62, 5,  7};
        exp_r     = '{2,  3,  2,  4,  6,  2,  0,  0,  0,  8};
    end

    assign out_q_ready = 1'b1;
    assign out_r_ready = 1'b1;

    // Monitor Output Q
    always @(posedge clk) begin
        if (!rst && out_q_valid && out_q_ready) begin
            if (q_count < NUM_VALUES) begin
                cap_q[q_count] = out_q_data;
                $display("Time=%0t : OUT.Q[%0d] <= %0d", $time, q_count, out_q_data);
            end
            q_count++;
        end
    end

    // Monitor Output R
    always @(posedge clk) begin
        if (!rst && out_r_valid && out_r_ready) begin
            if (r_count < NUM_VALUES) begin
                cap_r[r_count] = out_r_data;
                $display("Time=%0t : OUT.R[%0d] <= %0d", $time, r_count, out_r_data);
            end
            r_count++;
        end
    end

    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    //=================================================
    // IN.A Driver (Registered Handshake)
    //=================================================
    logic signed [23:0] a_data_q; logic a_valid_q; integer a_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin a_valid_q <= 0; a_data_q <= 0; a_idx <= 0; end
        else begin
            if (a_valid_q && in_a_ready) begin
                a_valid_q <= 0;
                $display("Time=%0t : IN.A[%0d]=%0d accepted", $time, a_idx, a_data_q);
                a_idx <= a_idx + 1;
            end else if (!a_valid_q && a_idx < NUM_VALUES) begin
                a_data_q  <= in_a_vals[a_idx];
                a_valid_q <= 1'b1;
            end
        end
    end
    assign in_a_data  = a_data_q;
    assign in_a_valid = a_valid_q;

    //=================================================
    // IN.B Driver (Registered Handshake)
    //=================================================
    logic signed [23:0] b_data_q; logic b_valid_q; integer b_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin b_valid_q <= 0; b_data_q <= 0; b_idx <= 0; end
        else begin
            if (b_valid_q && in_b_ready) begin
                b_valid_q <= 0;
                $display("Time=%0t : IN.B[%0d]=%0d accepted", $time, b_idx, b_data_q);
                b_idx <= b_idx + 1;
            end else if (!b_valid_q && b_idx < NUM_VALUES) begin
                b_data_q  <= in_b_vals[b_idx];
                b_valid_q <= 1'b1;
            end
        end
    end
    assign in_b_data  = b_data_q;
    assign in_b_valid = b_valid_q;

    //=================================================
    // Checker with Timeout
    //=================================================
    initial begin
        fork
            wait (q_count >= NUM_VALUES && r_count >= NUM_VALUES);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. Q=%0d/%0d, R=%0d/%0d", q_count, NUM_VALUES, r_count, NUM_VALUES);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 19 RESULT CHECK (Division)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            automatic logic q_ok = (cap_q[i] === exp_q[i]);
            automatic logic r_ok = (cap_r[i] === exp_r[i]);
            
            if (q_ok && r_ok)
                $display("  PASS: [%0d] Q=%0d R=%0d (A=%0d B=%0d)", 
                         i, cap_q[i], cap_r[i], in_a_vals[i], in_b_vals[i]);
            else begin
                if (!q_ok) begin
                    $display("  FAIL: [%0d] Q=%0d (expected %0d) (A=%0d B=%0d)",
                             i, cap_q[i], exp_q[i], in_a_vals[i], in_b_vals[i]);
                    errors++;
                end
                if (!r_ok) begin
                    $display("  FAIL: [%0d] R=%0d (expected %0d) (A=%0d B=%0d)",
                             i, cap_r[i], exp_r[i], in_a_vals[i], in_b_vals[i]);
                    errors++;
                end
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 19: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 19: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule