module RegisterFile (
    input logic clk,
    input logic rst,

    input logic [3:0] read_addr,
    output logic [23:0] out,

    input logic [23:0] data_in,
    input logic write_en,
    input logic [3:0] write_addr,

    input logic swap,
    input logic sav,

    output logic Z,
    output logic S,
);

logic [23:0] acc_reg;
logic [23:0] bak_reg;

always_comb begin
    if(read_addr == 4'h1)  // NIL
        out = 24'h0;
    else 
        out = acc_reg;
end

always_ff @( posedge clk or posedge rst ) begin
    if(rst) begin
        acc_reg <= 24'h0;
        bak_reg <= 24'h0;
    end
    else begin
        if(swap) begin
            acc_reg <= bak_reg;
            bak_reg <= acc_reg;
        end
        else if (sav) begin
            bak_reg <= acc_reg;
        end
        else if(write_en and read_addr!=4'h1) begin
            acc_reg <= data_in;
        end
    end
end

//بخش تعین فلگ ها
always_comb begin
    assign S = acc_reg[23]; // فلگ علامت
    assign Z = (acc_reg == 24'h0);  // فلگ صفر
end

endmodule