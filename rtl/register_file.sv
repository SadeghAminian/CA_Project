module RegisterFile (
    input  logic clk,
    input  logic rst,

    output logic [23:0] acc_out,

    input  logic [23:0] data_in,
    input  logic        write_en,
    input  logic [3:0]  write_addr,  // 0 = ACC, 1 = NIL

    input  logic swap,
    input  logic sav        
);

    logic [23:0] acc_reg;
    logic [23:0] bak_reg;

    assign acc_out = acc_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_reg <= 24'h0;
            bak_reg <= 24'h0;
        end
        else begin
            if (swap) begin
                acc_reg <= bak_reg;
                bak_reg <= acc_reg;
            end
            else if (sav) begin
                bak_reg <= acc_reg;
            end

            else if (write_en && (write_addr == 4'h0)) begin
                acc_reg <= data_in;
            end
        end
    end

// این بخش منتقل شد به خود برنچ دیکودر
//بخش تعین فلگ ها
// always_comb begin
//     assign S = acc_reg[23]; // فلگ علامت
//     assign Z = (acc_reg == 24'h0);  // فلگ صفر
// end

endmodule