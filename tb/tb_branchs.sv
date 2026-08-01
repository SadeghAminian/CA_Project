module tb_branchs;

    logic clk = 0;
    logic rst;
    logic [23:0] acc_out;
    logic zero_flag;
    logic sign_flag;
    logic [3:0] pc;

    // تولید کلاک (دوره 10 واحد زمان)
    always #5 clk = ~clk;

    // نمونه‌سازی t12Node
    t12Node #(
        .FILE_NAME("C:/Users/TUF/CA Project/hex/branch_hex.hex")
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

        assign pc = dut.u_datapath.pc;
        
        $display("========================================");
        $display("Testing All Branch Instructions");
        $display("========================================");
        
        // انتظار برای اجرای کامل برنامه
        // 12 دستور × 3 سیکل = 36 سیکل (حداقل)
        // با احتساب حلقه‌ها: 60 سیکل کافی است
        repeat(70) @(posedge clk);
        
        // بررسی نتیجه نهایی
        $display("========================================");
        $display("Final Results:");
        $display("========================================");
        $display("ACC = %0d (signed) | 0x%0h", $signed(acc_out), acc_out);
        $display("Zero Flag = %b", zero_flag);
        $display("Sign Flag = %b", sign_flag);
        $display("----------------------------------------");
        
        if (acc_out == 24'd99) begin
            $display("✓ TEST PASSED: ACC = 99 (Expected)");
        end else begin
            $display("✗ TEST FAILED: ACC = %0d (Expected: 99)", $signed(acc_out));
        end
        
        $display("========================================");
        $stop;
    end

    // مانیتور کردن تغییرات
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time=%0t, ACC=%0d (signed), Zero=%b, Sign=%b", 
                     $time, $signed(acc_out), zero_flag, sign_flag);
        end
    end

endmodule