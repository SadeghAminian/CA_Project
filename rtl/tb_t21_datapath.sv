`timescale 1ns/1ps

module tb_simple;
    // سیگنال‌های پایه
    logic clk, rst;
    
    // سیگنال‌های پورت (فعلاً صفر)
    logic [10:0] dummy_data = 0;
    logic dummy_valid = 0;
    logic dummy_ready = 1;

    // کلاک و ریست
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #20 rst = 0;
    end

    // لود کردن فایل HEX (بدون دستکاری کدهای قبلی)
    // نکته: dut.u_mem.mem را بر اساس نام ماژول در کد خودت تنظیم کن
    initial begin
        #10; // صبر کن تا ساختار ساخته شود
        $readmemh("test1.hex", dut.u_mem.mem); 
        $display("--- HEX File Loaded ---");
    end

    // مانیتور برای اینکه در Transcript ببینیم چه خبر است
    initial begin
        $monitor("Time=%0t | PC=%d | ACC=%d", $time, dut.datapath_inst.pc, dut.datapath_inst.acc_out);
    end

    // نمونه‌سازی DUT
    // (اینجا پورت‌ها را وصل می‌کنیم. اگر نام پورت‌های تو فرق دارد فقط همان‌ها را اصلاح کن)
    t21_node dut (
        .clk(clk),
        .rst(rst),
        .left_rx_valid(dummy_valid),
        .left_rx_ready(dummy_ready),
        .left_rx_data(dummy_data),
        .right_rx_valid(dummy_valid),
        .right_rx_ready(dummy_ready),
        .right_rx_data(dummy_data),
        .up_rx_valid(dummy_valid),
        .up_rx_ready(dummy_ready),
        .up_rx_data(dummy_data),
        .down_rx_valid(dummy_valid),
        .down_rx_ready(dummy_ready),
        .down_rx_data(dummy_data)
        // ... بقیه پورت‌های خروجی tx را اگر لازم نیست رها کن یا به سیگنال dummy وصل کن
    );

endmodule
