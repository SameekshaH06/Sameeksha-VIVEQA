`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 19:29:51
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_tx #(
    parameter CLKS_PER_BIT = 434
)(
    input        i_Clock,
    input        i_Tx_DV,
    input  [7:0] i_Tx_Byte,

    output reg   o_Tx_Active,
    output reg   o_Tx_Serial,
    output reg   o_Tx_Done
);

localparam S_IDLE  = 2'd0;
localparam S_START = 2'd1;
localparam S_DATA  = 2'd2;
localparam S_STOP  = 2'd3;

reg [1:0] state;
reg [15:0] baud_cnt;
reg [2:0] bit_idx;
reg [7:0] tx_shift;

always @(posedge i_Clock)
begin

    o_Tx_Done <= 1'b0;

    case(state)

    //-------------------------------------------------
    S_IDLE:
    begin
        o_Tx_Serial <= 1'b1;
        o_Tx_Active <= 1'b0;
        baud_cnt    <= 0;
        bit_idx     <= 0;

        if(i_Tx_DV)
        begin
            tx_shift    <= i_Tx_Byte;
            o_Tx_Active <= 1'b1;
            state       <= S_START;
        end
    end

    //-------------------------------------------------
    S_START:
    begin
        o_Tx_Serial <= 1'b0;

        if(baud_cnt == CLKS_PER_BIT-1)
        begin
            baud_cnt <= 0;
            state    <= S_DATA;
        end
        else
            baud_cnt <= baud_cnt + 1;
    end

    //-------------------------------------------------
    S_DATA:
    begin
        o_Tx_Serial <= tx_shift[bit_idx];

        if(baud_cnt == CLKS_PER_BIT-1)
        begin
            baud_cnt <= 0;

            if(bit_idx == 3'd7)
            begin
                bit_idx <= 0;
                state   <= S_STOP;
            end
            else
                bit_idx <= bit_idx + 1;
        end
        else
            baud_cnt <= baud_cnt + 1;
    end

    //-------------------------------------------------
    S_STOP:
    begin
        o_Tx_Serial <= 1'b1;

        if(baud_cnt == CLKS_PER_BIT-1)
        begin
            baud_cnt    <= 0;
            o_Tx_Active <= 1'b0;
            o_Tx_Done   <= 1'b1;
            state       <= S_IDLE;
        end
        else
            baud_cnt <= baud_cnt + 1;
    end

    default:
        state <= S_IDLE;

    endcase

end

initial
begin
    state       = S_IDLE;
    o_Tx_Serial = 1'b1;
    o_Tx_Active = 1'b0;
    o_Tx_Done   = 1'b0;
    baud_cnt    = 0;
    bit_idx     = 0;
    tx_shift    = 0;
end

endmodule