// port_interface.sv
// اصلاح شده برای پردازنده TIS-100

module port_interface (
    input  logic        clk, rst,
    input  logic        port_rd,     // دستور خواندن از پورت
    input  logic        port_wr,     // دستور نوشتن در پورت
    input  logic [2:0]  port_sel,    // 2=LEFT, 3=RIGHT, 4=UP, 5=DOWN, 6=ANY, 7=LAST
    input  logic [10:0] wr_data,     // داده ارسالی از ACC
    output logic [10:0] rd_data,     // داده دریافتی برای دیتاپث
    output logic        port_ready,  // سیگنال تکمیل هندشیک (برای خروج از Stall)

    // پورت‌های فیزیکی (0:LEFT, 1:RIGHT, 2:UP, 3:DOWN)
    output logic [3:0]  tx_valid,
    output logic [10:0] tx_data [0:3],
    input  logic [3:0]  tx_ready,

    input  logic [3:0]  rx_valid,
    input  logic [10:0] rx_data [0:3],
    output logic [3:0]  rx_ready
);

    logic [1:0] last_port_reg; // رجیستر داخلی برای ذخیره آخرین پورت ANY
    logic [1:0] any_idx;       // ایندکس انتخاب شده توسط منطق ANY
    logic       any_found;     // آیا در حالت ANY پورتی آماده است؟

    // --- 1. منطق اولویت ANY (Priority Encoder) ---
    // اولویت: LEFT > RIGHT > UP > DOWN
    always_comb begin
        any_idx = 2'd0;
        any_found = 1'b0;
        for (int i = 0; i < 4; i++) begin
            if (!any_found) begin
                if (port_rd && rx_valid[i]) begin
                    any_idx = i[1:0];
                    any_found = 1'b1;
                end else if (port_wr && tx_ready[i]) begin
                    any_idx = i[1:0];
                    any_found = 1'b1;
                end
            end
        end
    end

    // --- 2. انتخاب ایندکس فعال (Active Index) ---
    logic [1:0] active_idx;
    always_comb begin
        case (port_sel)
            3'd2:    active_idx = 2'd0; // LEFT
            3'd3:    active_idx = 2'd1; // RIGHT
            3'd4:    active_idx = 2'd2; // UP
            3'd5:    active_idx = 2'd3; // DOWN
            3'd7:    active_idx = last_port_reg; // LAST
            default: active_idx = any_idx; // ANY (3'd6)
        endcase
    end

    // --- 3. مدیریت هندشیک و انتقال داده ---
    always_comb begin
        // مقادیر پیش‌فرض
        tx_valid   = 4'b0000;
        rx_ready   = 4'b0000;
        rd_data    = 11'd0;
        port_ready = 1'b0;
        
        for (int i = 0; i < 4; i++) tx_data[i] = wr_data;

        if (port_wr) begin
            // در حالت ANY، فقط اگر پورت آماده‌ای پیدا شد معتبر عمل کن
            if (port_sel != 3'd6 || any_found) begin
                tx_valid[active_idx] = 1'b1;
                port_ready = tx_ready[active_idx];
            end
        end else if (port_rd) begin
            if (port_sel != 3'd6 || any_found) begin
                rx_ready[active_idx] = 1'b1;
                port_ready = rx_valid[active_idx];
                rd_data = rx_data[active_idx];
            end
        end
    end

    // --- 4. ذخیره سازی LAST (رجیستر ترتیبی) ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            last_port_reg <= 2'd0;
        end else begin
            // فقط در صورتی LAST تغییر می‌کند که تراکنش روی ANY با موفقیت انجام شده باشد
            if (port_ready && port_sel == 3'd6) begin
                last_port_reg <= active_idx;
            end
        end
    end

endmodule
