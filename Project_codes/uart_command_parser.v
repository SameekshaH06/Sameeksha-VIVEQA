`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 19:46:26
// Design Name: 
// Module Name: uart_command_parser
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

module uart_command_parser
(
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] rx_data,
    input  wire       rx_valid,

    output reg [3:0] command,
    output reg       valid_cmd
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
// Command Buffer
//////////////////////////////////////////////////////////////

reg [7:0] cmd_buffer [0:7];
reg [2:0] cmd_index;

integer i;

//////////////////////////////////////////////////////////////
// Command Parser
//////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        command   <= CMD_NONE;
        valid_cmd <= 1'b0;
        cmd_index <= 3'd0;

        for(i=0;i<8;i=i+1)
            cmd_buffer[i] <= 8'd0;

    end

    else
    begin

        valid_cmd <= 1'b0;

        if(rx_valid)
        begin

            //--------------------------------------------------
            // Store characters until ENTER
            //--------------------------------------------------

            if(rx_data != 8'h0D && rx_data != 8'h0A)
            begin

                if(cmd_index < 7)
                begin
                    cmd_buffer[cmd_index] <= rx_data;
                    cmd_index <= cmd_index + 1;
                end

            end

            //--------------------------------------------------
            // ENTER received
            //--------------------------------------------------

            else
            begin

                //--------------------------------------------------
                // 25
                //--------------------------------------------------

                if(cmd_index==2 &&
                   cmd_buffer[0]=="2" &&
                   cmd_buffer[1]=="5")
                begin

                    command   <= CMD_25;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // 50
                //--------------------------------------------------

                else if(cmd_index==2 &&
                        cmd_buffer[0]=="5" &&
                        cmd_buffer[1]=="0")
                begin

                    command   <= CMD_50;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // 75
                //--------------------------------------------------

                else if(cmd_index==2 &&
                        cmd_buffer[0]=="7" &&
                        cmd_buffer[1]=="5")
                begin

                    command   <= CMD_75;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // 100
                //--------------------------------------------------

                else if(cmd_index==3 &&
                        cmd_buffer[0]=="1" &&
                        cmd_buffer[1]=="0" &&
                        cmd_buffer[2]=="0")
                begin

                    command   <= CMD_100;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // ON
                //--------------------------------------------------

                else if(cmd_index==2 &&
                        cmd_buffer[0]=="O" &&
                        cmd_buffer[1]=="N")
                begin

                    command   <= CMD_ON;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // OFF
                //--------------------------------------------------

                else if(cmd_index==3 &&
                        cmd_buffer[0]=="O" &&
                        cmd_buffer[1]=="F" &&
                        cmd_buffer[2]=="F")
                begin

                    command   <= CMD_OFF;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // RESET
                //--------------------------------------------------

                else if(cmd_index==5 &&
                        cmd_buffer[0]=="R" &&
                        cmd_buffer[1]=="E" &&
                        cmd_buffer[2]=="S" &&
                        cmd_buffer[3]=="E" &&
                        cmd_buffer[4]=="T")
                begin

                    command   <= CMD_RESET;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // STATUS
                //--------------------------------------------------

                else if(cmd_index==6 &&
                        cmd_buffer[0]=="S" &&
                        cmd_buffer[1]=="T" &&
                        cmd_buffer[2]=="A" &&
                        cmd_buffer[3]=="T" &&
                        cmd_buffer[4]=="U" &&
                        cmd_buffer[5]=="S")
                begin

                    command   <= CMD_STATUS;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // Invalid Command
                //--------------------------------------------------

                else
                begin

                    command   <= CMD_ERROR;
                    valid_cmd <= 1'b1;

                end

                //--------------------------------------------------
                // Clear buffer
                //--------------------------------------------------

                cmd_index <= 3'd0;

                for(i=0;i<8;i=i+1)
                    cmd_buffer[i] <= 8'd0;

            end

        end

    end

end

endmodule
