`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 19:28:19
// Design Name: 
// Module Name: uart_rx
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
module uart_rx #(
    parameter CLKS_PER_BIT = 434
)(
    input        i_Clock,
    input        i_Reset,
    input        i_Rx_Serial,
    output reg [7:0] o_Rx_Byte,
    output reg       o_Rx_DV
);

localparam S_IDLE  = 3'd0;
localparam S_START = 3'd1;
localparam S_DATA  = 3'd2;
localparam S_STOP  = 3'd3;

reg rx_sync1, rx_sync2;

always @(posedge i_Clock)
begin
    if(i_Reset)
    begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end
    else
    begin
        rx_sync1 <= i_Rx_Serial;
        rx_sync2 <= rx_sync1;
    end
end

wire rx_s = rx_sync2;

reg [2:0] state;
reg [15:0] baud_cnt;
reg [2:0] bit_idx;
reg [7:0] rx_shift;

localparam HALF_BIT = CLKS_PER_BIT/2;

always @(posedge i_Clock)
begin

    if(i_Reset)
    begin
        state     <= S_IDLE;
        baud_cnt  <= 0;
        bit_idx   <= 0;
        rx_shift  <= 0;
        o_Rx_Byte <= 0;
        o_Rx_DV   <= 1'b0;
    end
    else
    begin

        o_Rx_DV <= 1'b0;

        case(state)

        //-------------------------------------------------
        S_IDLE:
        begin
            baud_cnt <= 0;
            bit_idx  <= 0;

            if(rx_s == 1'b0)
                state <= S_START;
        end

        //-------------------------------------------------
        S_START:
        begin
            if(baud_cnt == HALF_BIT-1)
            begin
                baud_cnt <= 0;

                if(rx_s == 1'b0)
                    state <= S_DATA;
                else
                    state <= S_IDLE;
            end
            else
                baud_cnt <= baud_cnt + 1;
        end

        //-------------------------------------------------
        S_DATA:
        begin
            if(baud_cnt == CLKS_PER_BIT-1)
            begin
                baud_cnt <= 0;

                rx_shift[bit_idx] <= rx_s;

                if(bit_idx == 3'd7)
                begin
                    bit_idx <= 0;
                    state <= S_STOP;
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
            if(baud_cnt == CLKS_PER_BIT-1)
            begin
                baud_cnt <= 0;

                o_Rx_Byte <= rx_shift;
                o_Rx_DV   <= 1'b1;

                state <= S_IDLE;
            end
            else
                baud_cnt <= baud_cnt + 1;
        end

        //-------------------------------------------------
        default:
            state <= S_IDLE;

        endcase

    end

end

endmodule