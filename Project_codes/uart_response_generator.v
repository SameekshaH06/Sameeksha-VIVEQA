`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 20:06:32
// Design Name: 
// Module Name: uart_response_generator
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
module uart_response_generator
(
    input  wire clk,
    input  wire rst,

    input  wire [3:0] command,
    input  wire       valid_cmd,

    input  wire [1:0] current_mode,

    input  wire       tx_busy,

    output reg        tx_start,
    output reg [7:0]  tx_data
);

//////////////////////////////////////////////////////////////
// Command Definitions
//////////////////////////////////////////////////////////////

localparam CMD_NONE   = 4'd0;
localparam CMD_25     = 4'd1;
localparam CMD_50     = 4'd2;
localparam CMD_75     = 4'd3;
localparam CMD_100    = 4'd4;
localparam CMD_ON     = 4'd5;
localparam CMD_OFF    = 4'd6;
localparam CMD_RESET  = 4'd7;
localparam CMD_STATUS = 4'd8;
localparam CMD_ERROR  = 4'd9;

//////////////////////////////////////////////////////////////
// FSM States
//////////////////////////////////////////////////////////////

localparam IDLE      = 3'd0;
localparam LOAD      = 3'd1;
localparam SEND      = 3'd2;
localparam WAIT_BUSY = 3'd3;
localparam WAIT_DONE = 3'd4;

reg [2:0] state;
//////////////////////////////////////////////////////////////
// Message Memory
//////////////////////////////////////////////////////////////

reg [7:0] message [0:15];
reg [3:0] msg_length;
reg [3:0] msg_index;

integer i;

//////////////////////////////////////////////////////////////
// Response Generator FSM
//////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state      <= IDLE;
        tx_start   <= 1'b0;
        tx_data    <= 8'd0;

        msg_length <= 0;
        msg_index  <= 0;

        for(i=0;i<16;i=i+1)
            message[i] <= 8'd0;

    end

    else
    begin

        tx_start <= 1'b0;

        case(state)

        //////////////////////////////////////////////////////
        // IDLE
        //////////////////////////////////////////////////////

        IDLE:
        begin

          if(valid_cmd)
             state <= LOAD;
        end

        //////////////////////////////////////////////////////
        // LOAD MESSAGE
        //////////////////////////////////////////////////////

        LOAD:
        begin
           for(i = 0; i < 16; i = i + 1)
        message[i] <= 8'd0;
        msg_index  <= 4'd0;
        msg_length <= 4'd0;

            //------------------------------------------------
            // ACK
            //------------------------------------------------

            if(command==CMD_25 ||
               command==CMD_50 ||
               command==CMD_75 ||
               command==CMD_100 ||
               command==CMD_ON ||
               command==CMD_OFF ||
               command==CMD_RESET)
            begin

                message[0] <= "A";
                message[1] <= "C";
                message[2] <= "K";

                msg_length <= 3;

            end

            //------------------------------------------------
            // STATUS
            //------------------------------------------------

            else if(command==CMD_STATUS)
            begin

                message[0] <= "M";
                message[1] <= "O";
                message[2] <= "D";
                message[3] <= "E";
                message[4] <= "=";

                case(current_mode)

                    2'd0:
                    begin
                        message[5] <= "2";
                        message[6] <= "5";
                    end

                    2'd1:
                    begin
                        message[5] <= "5";
                        message[6] <= "0";
                    end

                    2'd2:
                    begin
                        message[5] <= "7";
                        message[6] <= "5";
                    end

                    2'd3:
                    begin
                        message[5] <= "1";
                        message[6] <= "0";
                        message[7] <= "0";
                    end

                endcase

                if(current_mode==2'd3)
                    msg_length <= 8;
                else
                    msg_length <= 7;

            end

            //------------------------------------------------
            // ERROR
            //------------------------------------------------

            else
            begin

                message[0] <= "E";
                message[1] <= "R";
                message[2] <= "R";
                message[3] <= "O";
                message[4] <= "R";

                msg_length <= 5;

            end

            msg_index <= 0;

            state <= SEND;

        end

        //////////////////////////////////////////////////////
        // SEND CHARACTER
        //////////////////////////////////////////////////////
        SEND:
      begin

    if(!tx_busy)
    begin
        tx_data  <= message[msg_index];
        tx_start <= 1'b1;
        state <= WAIT_BUSY;
    end
    end
    
    //////////////////////////////////////////////////////
// WAIT UNTIL UART STARTS
//////////////////////////////////////////////////////

WAIT_BUSY:
begin

    tx_start <= 1'b0;

    if(tx_busy)
        state <= WAIT_DONE;

end
        //////////////////////////////////////////////////////
        // WAIT UNTIL TX FINISHES
        //////////////////////////////////////////////////////
WAIT_DONE:
begin

    if(!tx_busy)
    begin
        if(msg_index >= (msg_length-1))
  begin
    msg_index  <= 4'd0;
    msg_length <= 4'd0;
    state <= IDLE;
   end
        else
        begin
            msg_index <= msg_index + 1;
            state <= SEND;
        end
    end

end

default:
begin
    state <= IDLE;
end

endcase

end

end

endmodule