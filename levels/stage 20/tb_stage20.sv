//Sequence Indexer tb
`timescale 1ns/1ps
//=============================================================================
// Testbench for TIS-100 Stage 20 (Stack Lookup Sequence)
//=============================================================================
module tb_stage20;

    localparam int  NUM_V   = 11;  // 10 values + zero terminator
    localparam int  NUM_X   = 12;  // 12 index queries
    localparam int  NUM_OUT = 12;  // 12 expected outputs
    localparam time CLK_PERIOD = 10ns;
    localparam time TIMEOUT    = 4ms;

    logic clk = 1'b0;
    logic rst;

    // Input V Stream
    logic signed [23:0] in_v_data;
    logic               in_v_valid;
    logic               in_v_ready;

    // Input X Stream
    logic signed [23:0] in_x_data;
    logic               in_x_valid;
    logic               in_x_ready;

    // Output Stream
    logic signed [23:0] out_data;
    logic               out_valid;
    logic               out_ready;

    always #(CLK_PERIOD/2) clk = ~clk;

    Top_stage20 dut (
        .clk(clk), .rst(rst),
        .in_v_data(in_v_data), .in_v_valid(in_v_valid), .in_v_ready(in_v_ready),
        .in_x_data(in_x_data), .in_x_valid(in_x_valid), .in_x_ready(in_x_ready),
        .out_data(out_data), .out_valid(out_valid), .out_ready(out_ready)
    );

    logic signed [23:0] in_v_vals [0:NUM_V-1];
    logic signed [23:0] in_x_vals [0:NUM_X-1];
    logic signed [23:0] expected  [0:NUM_OUT-1];
    logic signed [23:0] captured  [0:NUM_OUT-1];

    integer recv_count, i, errors;
    logic timed_out;

    initial begin
        recv_count = 0; errors = 0; timed_out = 0;

        // IN.V Sequence (Zero-terminated): 10 values + 0
        in_v_vals[0]=860;  in_v_vals[1]=215; in_v_vals[2]=230; in_v_vals[3]=784;
        in_v_vals[4]=900;  in_v_vals[5]=978; in_v_vals[6]=945; in_v_vals[7]=124;
        in_v_vals[8]=432;  in_v_vals[9]=679; in_v_vals[10]=0;

        // IN.X Indices: 12 queries
        in_x_vals[0]=0;  in_x_vals[1]=5;  in_x_vals[2]=0;  in_x_vals[3]=4;
        in_x_vals[4]=0;  in_x_vals[5]=8;  in_x_vals[6]=5;  in_x_vals[7]=4;
        in_x_vals[8]=2;  in_x_vals[9]=7;  in_x_vals[10]=3; in_x_vals[11]=0;

        // Expected Outputs
        expected[0]=860;  expected[1]=978; expected[2]=860; expected[3]=900;
        expected[4]=860;  expected[5]=432; expected[6]=978; expected[7]=900;
        expected[8]=230;  expected[9]=124; expected[10]=784; expected[11]=860;
    end

    assign out_ready = 1'b1;

    // Monitor output
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
    // IN.V Driver (Registered Handshake) - NUM_V items
    //=================================================
    logic signed [23:0] v_data_q; logic v_valid_q; integer v_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin v_valid_q <= 0; v_data_q <= 0; v_idx <= 0; end
        else begin
            if (v_valid_q && in_v_ready) begin
                v_valid_q <= 0;
                $display("Time=%0t : IN.V[%0d]=%0d accepted", $time, v_idx, v_data_q);
                v_idx <= v_idx + 1;
            end else if (!v_valid_q && v_idx < NUM_V) begin
                v_data_q  <= in_v_vals[v_idx];
                v_valid_q <= 1'b1;
            end
        end
    end
    assign in_v_data  = v_data_q;
    assign in_v_valid = v_valid_q;

    //=================================================
    // IN.X Driver (Registered Handshake) - NUM_X items
    //=================================================
    logic signed [23:0] x_data_q; logic x_valid_q; integer x_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin x_valid_q <= 0; x_data_q <= 0; x_idx <= 0; end
        else begin
            if (x_valid_q && in_x_ready) begin
                x_valid_q <= 0;
                $display("Time=%0t : IN.X[%0d]=%0d accepted", $time, x_idx, x_data_q);
                x_idx <= x_idx + 1;
            end else if (!x_valid_q && x_idx < NUM_X) begin
                x_data_q  <= in_x_vals[x_idx];
                x_valid_q <= 1'b1;
            end
        end
    end
    assign in_x_data  = x_data_q;
    assign in_x_valid = x_valid_q;

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
        $display("  STAGE 20 RESULT CHECK (Stack Lookup)");
        $display("==================================================");
        for (i = 0; i < NUM_OUT; i++) begin
            if (captured[i] === expected[i])
                $display("  PASS: [%0d] OUT=%0d (IDX=%0d)", i, captured[i], in_x_vals[i]);
            else begin
                $display("  FAIL: [%0d] OUT=%0d (expected %0d) (IDX=%0d)",
                         i, captured[i], expected[i], in_x_vals[i]);
                errors = errors + 1;
            end
        end
        $display("==================================================");
        if (errors == 0) $display("  *** STAGE 20: ALL TESTS PASSED! ***");
        else             $display("  *** STAGE 20: %0d ERRORS! ***", errors);
        $display("==================================================");
        $finish;
    end

endmodule