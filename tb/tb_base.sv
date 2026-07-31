module testbench;

    logic clk = 0;
    logic rst;
    logic [23:0] acc_out;
    logic zero_flag;
    logic sign_flag;

    // تولید کلاک (دوره 10 واحد زمان)
    always #5 clk = ~clk;

    // نمونه‌سازی t12Node
    t12Node #(
        .FILE_NAME("C:/Users/TUF/CA Project/hex/test_alu.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
        .acc_out(acc_out),
        .zero_flag(zero_flag),
        .sign_flag(sign_flag)
    );

    initial begin
        // مقداردهی اولیه
        rst = 1;
        #10;
        rst = 0;
        
        // انتظار برای اجرای دستورات
        // هر دستور 3 سیکل کلاک طول می‌کشد (FETCH, DECODE, EXECUTE)
        // 7 دستور × 3 سیکل = 21 سیکل
        repeat(25) @(posedge clk);
        
        // نمایش نتایج
        $display("========================================");
        $display("Final ACC Value: %d (0x%0h)", acc_out, acc_out);
        $display("Zero Flag: %b", zero_flag);
        $display("Sign Flag: %b", sign_flag);
        $display("========================================");
        
        $stop;
    end

    // مانیتور کردن تغییرات ACC
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time=%0t, ACC=%d (signed) | (0x%0h), Zero=%b, Sign=%b", 
                     $time, acc_out, acc_out, zero_flag, sign_flag);
        end
    end

endmodule