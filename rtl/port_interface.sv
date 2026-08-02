// Module: port_interface
import cpu_type_pkg::*;

module port_interface (
    input  logic        clk,
    input  logic        rst,
    
    // کنترل از سمت FSM
    input  PortType     port_dst, 
    input  PortType     port_src,
    input  logic        ready_en,
    input  logic        write_en,
    input  logic signed [23:0] write_data,
    
    input  logic signed [23:0] left_data_in,
    input  logic signed [23:0] right_data_in,
    input  logic signed [23:0] up_data_in,
    input  logic signed [23:0] down_data_in,

    input  logic left_valid_in,
    input  logic right_valid_in,
    input  logic up_valid_in,
    input  logic down_valid_in,
    input  logic left_ready_in,
    input  logic right_ready_in,
    input  logic up_ready_in,
    input  logic down_ready_in,
    
    
    output logic signed [23:0] data_out, // خروجی دیتای ماژول
    output logic signed [23:0] buffered_data_out, // همون رجیستر بافر
    output logic read_done, // سیگنال تائید عملیات خوندن
    output logic write_done, // سیگنال تائید عملیات نوشتن
    
    output logic left_ready_out,
    output logic right_ready_out,
    output logic up_ready_out,
    output logic down_ready_out,

    output logic left_valid_out,
    output logic right_valid_out,
    output logic up_valid_out,
    output logic down_valid_out
);


    logic signed [23:0] port_buff_reg;
    logic signed [23:0] mux_data_in;
    logic               read_en;

    assign data_out = write_data;

    //==================================
    //         Data_in MUX
    //==================================
    always_comb begin
        case (port_src)
            LEFT:  mux_data_in = left_data_in;
            RIGHT: mux_data_in = right_data_in;
            UP:    mux_data_in = up_data_in;
            DOWN:  mux_data_in = down_data_in;
            default: mux_data_in = 24'sd0;
        endcase
    end

    //==================================
    //         Port Buffer logic
    //==================================
    always_ff @(posedge clk or posedge rst) begin : PortBuffer_Register
        if (rst)
            port_buff_reg <= 24'sd0;
        else if (read_en)
            port_buff_reg <= mux_data_in;
    end

    assign buffered_data_out = port_buff_reg;

    //==================================
    //       Ready Signals Decoder
    //==================================
    always_comb begin : Ready_Signals_Decoder
        left_ready_out  = 1'b0;
        right_ready_out = 1'b0;
        up_ready_out    = 1'b0;
        down_ready_out  = 1'b0;
        
        if (ready_en) begin
            case (port_src)
                LEFT:  left_ready_out  = 1'b1;
                RIGHT: right_ready_out = 1'b1;
                UP:    up_ready_out    = 1'b1;
                DOWN:  down_ready_out = 1'b1;
                default: ;
            endcase
        end
    end

    //==================================
    //         Valid input MUX
    //==================================
    logic is_valid;
    always_comb begin
        is_valid = 1'b0;
        case (port_src)
            LEFT:  is_valid = left_valid_in;
            RIGHT: is_valid = right_valid_in;
            UP:    is_valid = up_valid_in;
            DOWN:  is_valid = down_valid_in;
            default: ;
        endcase
    end

    assign read_en  = (is_valid & ready_en);
    assign read_done = read_en;

    //==================================
    //       Valid Signals Decoder
    //==================================
    always_comb begin : Valid_Signals_Decoder
        left_valid_out  = 1'b0;
        right_valid_out = 1'b0;
        up_valid_out    = 1'b0;
        down_valid_out  = 1'b0;
        
        if (write_en) begin
            case (port_dst)
                LEFT:  left_valid_out  = 1'b1;
                RIGHT: right_valid_out = 1'b1;
                UP:    up_valid_out    = 1'b1;
                DOWN:  down_valid_out = 1'b1;
                default: ;
            endcase
        end
    end

    //==================================
    //         Ready input MUX
    //==================================
    logic is_ready;
    always_comb begin
        is_ready = 1'b0;
        case (port_dst)
            LEFT:  is_ready = left_ready_in;
            RIGHT: is_ready = right_ready_in;
            UP:    is_ready = up_ready_in;
            DOWN:  is_ready = down_ready_in;
            default: ;
        endcase
    end

    assign write_done = (is_ready & write_en);

endmodule