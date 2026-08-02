`timescale 1ns/1ps

import cpu_type_pkg::*;

module testbench_port_interface;

    // سیگنال‌های کلاک و ریست
    logic clk;
    logic rst;
    
    // سیگنال‌های کنترلی
    PortType port_dst;
    PortType port_src;
    logic ready_en;
    logic write_en;
    logic signed [23:0] write_data;
    
    // سیگنال‌های داده ورودی
    logic signed [23:0] left_data_in;
    logic signed [23:0] right_data_in;
    logic signed [23:0] up_data_in;
    logic signed [23:0] down_data_in;
    
    // سیگنال‌های Handshake ورودی
    logic left_valid_in;
    logic right_valid_in;
    logic up_valid_in;
    logic down_valid_in;
    logic left_ready_in;
    logic right_ready_in;
    logic up_ready_in;
    logic down_ready_in;
    
    // خروجی‌های ماژول
    logic signed [23:0] data_out;
    logic signed [23:0] buffered_data_out;
    logic read_done;
    logic write_done;
    logic left_ready_out;
    logic right_ready_out;
    logic up_ready_out;
    logic down_ready_out;
    logic left_valid_out;
    logic right_valid_out;
    logic up_valid_out;
    logic down_valid_out;

    // تولید کلاک
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // نمونه‌سازی ماژول
    port_interface u_port_interface (
        .clk(clk),
        .rst(rst),
        .port_dst(port_dst),
        .port_src(port_src),
        .ready_en(ready_en),
        .write_en(write_en),
        .write_data(write_data),
        .left_data_in(left_data_in),
        .right_data_in(right_data_in),
        .up_data_in(up_data_in),
        .down_data_in(down_data_in),
        .left_valid_in(left_valid_in),
        .right_valid_in(right_valid_in),
        .up_valid_in(up_valid_in),
        .down_valid_in(down_valid_in),
        .left_ready_in(left_ready_in),
        .right_ready_in(right_ready_in),
        .up_ready_in(up_ready_in),
        .down_ready_in(down_ready_in),
        .data_out(data_out),
        .buffered_data_out(buffered_data_out),
        .read_done(read_done),
        .write_done(write_done),
        .left_ready_out(left_ready_out),
        .right_ready_out(right_ready_out),
        .up_ready_out(up_ready_out),
        .down_ready_out(down_ready_out),
        .left_valid_out(left_valid_out),
        .right_valid_out(right_valid_out),
        .up_valid_out(up_valid_out),
        .down_valid_out(down_valid_out)
    );

    // متغیر شمارنده تست
    integer pass_count;
    integer fail_count;

    // مقداردهی اولیه
    initial begin
        pass_count = 0;
        fail_count = 0;
        
        // ریست کردن همه سیگنال‌ها
        rst = 1;
        port_dst = LEFT;
        port_src = LEFT;
        ready_en = 0;
        write_en = 0;
        write_data = 0;
        left_data_in = 0;
        right_data_in = 0;
        up_data_in = 0;
        down_data_in = 0;
        left_valid_in = 0;
        right_valid_in = 0;
        up_valid_in = 0;
        down_valid_in = 0;
        left_ready_in = 0;
        right_ready_in = 0;
        up_ready_in = 0;
        down_ready_in = 0;
        
        #20;
        rst = 0;
        #10;
        
        $display("========================================");
        $display("  Port Interface Testbench");
        $display("========================================");
        
        // ==========================================
        // تست 1: خواندن از LEFT با داده مثبت
        // ==========================================
        $display("TEST 1: Read from LEFT (data=42)");
        
        port_src = LEFT;
        ready_en = 1;
        left_data_in = 42;
        left_valid_in = 1;
        
        @(posedge clk);
        #1;
        
        if (left_ready_out == 1) begin
            $display("  PASS: left_ready_out = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: left_ready_out = %b (expected 1)", left_ready_out);
            fail_count = fail_count + 1;
        end
        
        if (read_done == 1) begin
            $display("  PASS: read_done = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: read_done = %b (expected 1)", read_done);
            fail_count = fail_count + 1;
        end
        
        if (buffered_data_out == 42) begin
            $display("  PASS: buffered_data_out = %0d", buffered_data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: buffered_data_out = %0d (expected 42)", buffered_data_out);
            fail_count = fail_count + 1;
        end
        
        // پاک کردن سیگنال‌ها
        left_valid_in = 0;
        ready_en = 0;
        @(posedge clk);
        #1;
        
        // بررسی Hold
        if (buffered_data_out == 42) begin
            $display("  PASS: buffered_data_out holds value = %0d", buffered_data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: buffered_data_out = %0d (expected 42)", buffered_data_out);
            fail_count = fail_count + 1;
        end
        
        $display("----------------------------------------");
        
        // ==========================================
        // تست 2: خواندن از RIGHT با داده منفی
        // ==========================================
        $display("TEST 2: Read from RIGHT (data=-10)");
        
        port_src = RIGHT;
        ready_en = 1;
        right_data_in = -10;
        right_valid_in = 1;
        
        @(posedge clk);
        #1;
        
        if (right_ready_out == 1) begin
            $display("  PASS: right_ready_out = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: right_ready_out = %b (expected 1)", right_ready_out);
            fail_count = fail_count + 1;
        end
        
        if (left_ready_out == 0) begin
            $display("  PASS: left_ready_out = 0 (not selected)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: left_ready_out = %b (expected 0)", left_ready_out);
            fail_count = fail_count + 1;
        end
        
        if (read_done == 1) begin
            $display("  PASS: read_done = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: read_done = %b (expected 1)", read_done);
            fail_count = fail_count + 1;
        end
        
        if (buffered_data_out == -10) begin
            $display("  PASS: buffered_data_out = %0d", buffered_data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: buffered_data_out = %0d (expected -10)", buffered_data_out);
            fail_count = fail_count + 1;
        end
        
        right_valid_in = 0;
        ready_en = 0;
        @(posedge clk);
        #1;
        
        $display("----------------------------------------");
        
        // ==========================================
        // تست 3: نوشتن به UP (همسایه آماده نیست)
        // ==========================================
        $display("TEST 3: Write to UP (neighbor not ready)");
        
        port_dst = UP;
        write_en = 1;
        write_data = 99;
        up_ready_in = 0;
        
        @(posedge clk);
        #1;
        
        if (up_valid_out == 1) begin
            $display("  PASS: up_valid_out = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: up_valid_out = %b (expected 1)", up_valid_out);
            fail_count = fail_count + 1;
        end
        
        if (left_valid_out == 0) begin
            $display("  PASS: left_valid_out = 0 (not selected)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: left_valid_out = %b (expected 0)", left_valid_out);
            fail_count = fail_count + 1;
        end
        
        if (data_out == 99) begin
            $display("  PASS: data_out = %0d", data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: data_out = %0d (expected 99)", data_out);
            fail_count = fail_count + 1;
        end
        
        if (write_done == 0) begin
            $display("  PASS: write_done = 0 (neighbor not ready)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: write_done = %b (expected 0)", write_done);
            fail_count = fail_count + 1;
        end
        
        // حالا همسایه آماده می‌شود
        up_ready_in = 1;
        @(posedge clk);
        #1;
        
        if (write_done == 1) begin
            $display("  PASS: write_done = 1 (handshake complete)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: write_done = %b (expected 1)", write_done);
            fail_count = fail_count + 1;
        end
        
        write_en = 0;
        up_ready_in = 0;
        @(posedge clk);
        #1;
        
        $display("----------------------------------------");
        
        // ==========================================
        // تست 4: نوشتن به DOWN با داده منفی
        // ==========================================
        $display("TEST 4: Write to DOWN (data=-50, neighbor ready)");
        
        port_dst = DOWN;
        write_en = 1;
        write_data = -50;
        down_ready_in = 1;
        
        @(posedge clk);
        #1;
        
        if (down_valid_out == 1) begin
            $display("  PASS: down_valid_out = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: down_valid_out = %b (expected 1)", down_valid_out);
            fail_count = fail_count + 1;
        end
        
        if (data_out == -50) begin
            $display("  PASS: data_out = %0d", data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: data_out = %0d (expected -50)", data_out);
            fail_count = fail_count + 1;
        end
        
        if (write_done == 1) begin
            $display("  PASS: write_done = 1");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: write_done = %b (expected 1)", write_done);
            fail_count = fail_count + 1;
        end
        
        write_en = 0;
        down_ready_in = 0;
        @(posedge clk);
        #1;
        
        $display("----------------------------------------");
        
        // ==========================================
        // تست 5: عدم فعال‌سازی
        // ==========================================
        $display("TEST 5: No activation (ready_en=0)");
        
        port_src = LEFT;
        ready_en = 0;
        left_valid_in = 1;
        left_data_in = 777;
        
        @(posedge clk);
        #1;
        
        if (left_ready_out == 0) begin
            $display("  PASS: left_ready_out = 0 (not enabled)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: left_ready_out = %b (expected 0)", left_ready_out);
            fail_count = fail_count + 1;
        end
        
        if (read_done == 0) begin
            $display("  PASS: read_done = 0 (not enabled)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: read_done = %b (expected 0)", read_done);
            fail_count = fail_count + 1;
        end
        
        left_valid_in = 0;
        @(posedge clk);
        #1;
        
        $display("----------------------------------------");
        
        // ==========================================
        // نتایج نهایی
        // ==========================================
        $display("========================================");
        $display("  FINAL RESULTS");
        $display("========================================");
        $display("Total Tests: %0d", pass_count + fail_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end
        $display("========================================");
        
        $stop;
    end

endmodule