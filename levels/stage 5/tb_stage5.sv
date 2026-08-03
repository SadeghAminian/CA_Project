`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 5 (Registered-Sender, Race-Free)
//=============================================================================
module tb_stage5;

    localparam int  NUM_VALUES = 10;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    logic signed [23:0] in_a_data, in_s_data, in_b_data;
    logic               in_a_valid, in_s_valid, in_b_valid;
    logic               in_a_ready, in_s_ready, in_b_ready;
    logic signed [23:0] out_data;
    logic               out_valid;
    logic               out_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage5 dut (
        .clk(clk), .rst(rst),
        .in_a_data(in_a_data), .in_a_valid(in_a_valid), .in_a_ready(in_a_ready),
        .in_s_data(in_s_data), .in_s_valid(in_s_valid), .in_s_ready(in_s_ready),
        .in_b_data(in_b_data), .in_b_valid(in_b_valid), .in_b_ready(in_b_ready),
        .out_data(out_data), .out_valid(out_valid), .out_ready(out_ready)
    );

    logic signed [23:0] in_a_vals [0:NUM_VALUES-1];
    logic signed [23:0] in_s_vals [0:NUM_VALUES-1];
    logic signed [23:0] in_b_vals [0:NUM_VALUES-1];
    logic signed [23:0] expected  [0:NUM_VALUES-1];
    logic signed [23:0] captured  [0:NUM_VALUES-1];

    integer recv_count, i, errors;
    logic timed_out;

    initial begin
        recv_count = 0; errors = 0; timed_out = 0;

        in_a_vals[0]=-13; in_a_vals[1]=-27; in_a_vals[2]=-29; in_a_vals[3]=-17; in_a_vals[4]=-19;
        in_a_vals[5]=-17; in_a_vals[6]=0;   in_a_vals[7]=-28; in_a_vals[8]=-17; in_a_vals[9]=-28;

        in_s_vals[0]=-1;  in_s_vals[1]=1;   in_s_vals[2]=1;   in_s_vals[3]=-1;  in_s_vals[4]=-1;
        in_s_vals[5]=0;   in_s_vals[6]=1;   in_s_vals[7]=1;   in_s_vals[8]=1;   in_s_vals[9]=0;

        in_b_vals[0]=7;   in_b_vals[1]=7;   in_b_vals[2]=6;   in_b_vals[3]=17;  in_b_vals[4]=11;
        in_b_vals[5]=29;  in_b_vals[6]=25;  in_b_vals[7]=29;  in_b_vals[8]=3;   in_b_vals[9]=7;

        expected[0]=-13; expected[1]=7;  expected[2]=6;   expected[3]=-17; expected[4]=-19;
        expected[5]=12;  expected[6]=25; expected[7]=29;  expected[8]=3;   expected[9]=-21;
    end

    assign out_ready = 1'b1;

    // Output monitor
    always @(posedge clk) begin
        if (!rst && out_valid && out_ready) begin
            if (recv_count < NUM_VALUES) begin
                captured[recv_count] = out_data;
                $display("Time=%0t : OUT[%0d] <= %0d", $time, recv_count, out_data);
            end
            recv_count = recv_count + 1;
        end
    end

    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    //=================================================
    // IN.A
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
    // IN.S
    //=================================================
    logic signed [23:0] s_data_q; logic s_valid_q; integer s_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin s_valid_q <= 0; s_data_q <= 0; s_idx <= 0; end
        else begin
            if (s_valid_q && in_s_ready) begin
                s_valid_q <= 0;
                $display("Time=%0t : IN.S[%0d]=%0d accepted", $time, s_idx, s_data_q);
                s_idx <= s_idx + 1;
            end else if (!s_valid_q && s_idx < NUM_VALUES) begin
                s_data_q  <= in_s_vals[s_idx];
                s_valid_q <= 1'b1;
            end
        end
    end
    assign in_s_data  = s_data_q;
    assign in_s_valid = s_valid_q;

    //=================================================
    // IN.B
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
    // Checker with Tiemout
    //=================================================
    initial begin
        fork
            wait (recv_count >= NUM_VALUES);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. received %0d / %0d", recv_count, NUM_VALUES);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 5 RESULT CHECK (MUX by S)");
        $display("==================================================");
        for (i = 0; i < NUM_VALUES; i++) begin
            if (captured[i] === expected[i])
                $display("  PASS: [%0d] OUT=%0d (S=%0d)", i, captured[i], in_s_vals[i]);
            else begin
                $display("  FAIL: [%0d] OUT=%0d (expected %0d) (S=%0d)",
                         i, captured[i], expected[i], in_s_vals[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 5: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 5: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule