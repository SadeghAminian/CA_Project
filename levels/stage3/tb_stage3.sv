`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 3 (Registered-Sender, Race-Free)
//=============================================================================
module tb_stage3;

    localparam int  NUM_VALUES = 10;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    logic signed [23:0] in_a_data, in_b_data;
    logic               in_a_valid, in_b_valid;
    logic               in_a_ready, in_b_ready;
    logic signed [23:0] out_p_data, out_n_data;
    logic               out_p_valid, out_n_valid;
    logic               out_p_ready, out_n_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage3 dut (
        .clk(clk), .rst(rst),
        .in_a_data(in_a_data), .in_a_valid(in_a_valid), .in_a_ready(in_a_ready),
        .in_b_data(in_b_data), .in_b_valid(in_b_valid), .in_b_ready(in_b_ready),
        .out_p_data(out_p_data), .out_p_valid(out_p_valid), .out_p_ready(out_p_ready),
        .out_n_data(out_n_data), .out_n_valid(out_n_valid), .out_n_ready(out_n_ready)
    );

    logic signed [23:0] in_a_vals [0:NUM_VALUES-1];
    logic signed [23:0] in_b_vals [0:NUM_VALUES-1];
    logic signed [23:0] exp_p [0:NUM_VALUES-1];
    logic signed [23:0] exp_n [0:NUM_VALUES-1];
    logic signed [23:0] cap_p [0:NUM_VALUES-1];
    logic signed [23:0] cap_n [0:NUM_VALUES-1];

    integer recv_p, recv_n, i, errors;
    logic timed_out;

    initial begin
        recv_p = 0; recv_n = 0; errors = 0; timed_out = 0;

        in_a_vals[0]=44;  in_a_vals[1]=78;  in_a_vals[2]=88;  in_a_vals[3]=95;  in_a_vals[4]=65;
        in_a_vals[5]=63;  in_a_vals[6]=41;  in_a_vals[7]=26;  in_a_vals[8]=87;  in_a_vals[9]=75;

        in_b_vals[0]=93;  in_b_vals[1]=60;  in_b_vals[2]=92;  in_b_vals[3]=68;  in_b_vals[4]=56;
        in_b_vals[5]=30;  in_b_vals[6]=90;  in_b_vals[7]=65;  in_b_vals[8]=94;  in_b_vals[9]=92;

        exp_p[0]=-49; exp_p[1]=18;  exp_p[2]=-4;  exp_p[3]=27;  exp_p[4]=9;
        exp_p[5]=33;  exp_p[6]=-49; exp_p[7]=-39; exp_p[8]=-7;  exp_p[9]=-17;

        exp_n[0]=49;  exp_n[1]=-18; exp_n[2]=4;   exp_n[3]=-27; exp_n[4]=-9;
        exp_n[5]=-33; exp_n[6]=49;  exp_n[7]=39;  exp_n[8]=7;   exp_n[9]=17;
    end

    // Sink
    assign out_p_ready = 1'b1;
    assign out_n_ready = 1'b1;

    //=================================================
    // Output Monitoring
    //=================================================
    always @(posedge clk) begin
        if (!rst && out_p_valid && out_p_ready) begin
            if (recv_p < NUM_VALUES) begin
                cap_p[recv_p] = out_p_data;
                $display("Time=%0t : OUT.P[%0d] <= %0d", $time, recv_p, out_p_data);
            end
            recv_p = recv_p + 1;
        end
    end

    always @(posedge clk) begin
        if (!rst && out_n_valid && out_n_ready) begin
            if (recv_n < NUM_VALUES) begin
                cap_n[recv_n] = out_n_data;
                $display("Time=%0t : OUT.N[%0d] <= %0d", $time, recv_n, out_n_data);
            end
            recv_n = recv_n + 1;
        end
    end

    //=================================================
    // Reset
    //=================================================
    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    //=================================================
    // Sanchron Transmision: IN.A
    //=================================================
    logic signed [23:0] a_data_q; logic a_valid_q; integer a_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_valid_q <= 1'b0; a_data_q <= 24'sd0; a_idx <= 0;
        end else begin
            if (a_valid_q && in_a_ready) begin
                a_valid_q <= 1'b0;
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
    // Sanchron Transmision: IN.B
    //=================================================
    logic signed [23:0] b_data_q; logic b_valid_q; integer b_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            b_valid_q <= 1'b0; b_data_q <= 24'sd0; b_idx <= 0;
        end else begin
            if (b_valid_q && in_b_ready) begin
                b_valid_q <= 1'b0;
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
    // Checker with TimeOut
    //=================================================
    initial begin
        fork
            wait (recv_p >= NUM_VALUES && recv_n >= NUM_VALUES);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. P:%0d / N:%0d of %0d", recv_p, recv_n, NUM_VALUES);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 3 RESULT CHECK (P=A-B , N=B-A)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            if (cap_p[i] === exp_p[i] && cap_n[i] === exp_n[i])
                $display("  PASS: [%0d] P=%0d , N=%0d", i, cap_p[i], cap_n[i]);
            else begin
                $display("  FAIL: [%0d] P=%0d (exp %0d) , N=%0d (exp %0d)",
                         i, cap_p[i], exp_p[i], cap_n[i], exp_n[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 3: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 3: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule