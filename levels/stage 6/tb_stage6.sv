`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 6 (Registered-Sender, Race-Free)
// Output count (39) != Input count (13) -> checker keys on OUTPUT count
//=============================================================================
module tb_stage6;

    localparam int  NUM_IN     = 13;
    localparam int  NUM_OUT    = 39;
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 8ms;   // بزرگ‌تر، چون ۳۹ خروجی تولید می‌شود

    logic clk = 1'b0;
    logic rst;

    logic signed [23:0] in_a_data, in_b_data;
    logic               in_a_valid, in_b_valid;
    logic               in_a_ready, in_b_ready;
    logic signed [23:0] out_data;
    logic               out_valid;
    logic               out_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage6 dut (
        .clk(clk), .rst(rst),
        .in_a_data(in_a_data), .in_a_valid(in_a_valid), .in_a_ready(in_a_ready),
        .in_b_data(in_b_data), .in_b_valid(in_b_valid), .in_b_ready(in_b_ready),
        .out_data(out_data), .out_valid(out_valid), .out_ready(out_ready)
    );

    logic signed [23:0] in_a_vals [0:NUM_IN-1];
    logic signed [23:0] in_b_vals [0:NUM_IN-1];
    logic signed [23:0] expected  [0:NUM_OUT-1];
    logic signed [23:0] captured  [0:NUM_OUT-1];

    integer recv_count, i, errors;
    logic timed_out;

    initial begin
        recv_count = 0; errors = 0; timed_out = 0;

        in_a_vals[0]=46;  in_a_vals[1]=71;  in_a_vals[2]=66;  in_a_vals[3]=21;  in_a_vals[4]=79;
        in_a_vals[5]=23;  in_a_vals[6]=62;  in_a_vals[7]=23;  in_a_vals[8]=36;  in_a_vals[9]=96;
        in_a_vals[10]=12; in_a_vals[11]=97; in_a_vals[12]=47;

        in_b_vals[0]=71;  in_b_vals[1]=29;  in_b_vals[2]=90;  in_b_vals[3]=67;  in_b_vals[4]=79;
        in_b_vals[5]=84;  in_b_vals[6]=78;  in_b_vals[7]=27;  in_b_vals[8]=60;  in_b_vals[9]=45;
        in_b_vals[10]=67; in_b_vals[11]=42; in_b_vals[12]=64;

        expected[0]=46;  expected[1]=71;  expected[2]=0;   expected[3]=29;  expected[4]=71;
        expected[5]=0;   expected[6]=66;  expected[7]=90;  expected[8]=0;   expected[9]=21;
        expected[10]=67; expected[11]=0;  expected[12]=79; expected[13]=79; expected[14]=0;
        expected[15]=23; expected[16]=84; expected[17]=0;  expected[18]=62; expected[19]=78;
        expected[20]=0;  expected[21]=23; expected[22]=27; expected[23]=0;  expected[24]=36;
        expected[25]=60; expected[26]=0;  expected[27]=45; expected[28]=96; expected[29]=0;
        expected[30]=12; expected[31]=67; expected[32]=0;  expected[33]=42; expected[34]=97;
        expected[35]=0;  expected[36]=47; expected[37]=64; expected[38]=0;
    
    end

    assign out_ready = 1'b1;

    // Monitor Output
    always @(posedge clk) begin
        if (!rst && out_valid && out_ready) begin
            if (recv_count < NUM_OUT) begin
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
            end else if (!a_valid_q && a_idx < NUM_IN) begin
                a_data_q  <= in_a_vals[a_idx];
                a_valid_q <= 1'b1;
            end
        end
    end
    assign in_a_data  = a_data_q;
    assign in_a_valid = a_valid_q;

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
            end else if (!b_valid_q && b_idx < NUM_IN) begin
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
            wait (recv_count >= NUM_OUT);
            begin #TIMEOUT; timed_out = 1'b1; end
        join_any
        disable fork;

        if (timed_out) begin
            $display("!! ERROR: TIMEOUT. received %0d / %0d", recv_count, NUM_OUT);
            $finish;
        end

        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("  STAGE 6 RESULT CHECK (min, max, 0 per pair)");
        $display("==================================================");
        for (i = 0; i < NUM_OUT; i++) begin
            if (captured[i] === expected[i])
                $display("  PASS: [%0d] OUT=%0d", i, captured[i]);
            else begin
                $display("  FAIL: [%0d] OUT=%0d (expected %0d)", i, captured[i], expected[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 6: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 6: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule