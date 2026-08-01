`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 19:51:30
// Design Name: 
// Module Name: uart_controller
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

module uart_controller
(
    input  wire clk,
    input  wire rst,
    input  wire [3:0] command,
    input  wire       valid_cmd,
    output reg control_out,
    output reg [1:0] current_mode
);

//////////////////////////////////////////////////////
// Command Definitions
//////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////
// Blink Limits
//////////////////////////////////////////////////////

localparam MODE25_LIMIT  = 32'd25000000;
localparam MODE50_LIMIT  = 32'd12500000;
localparam MODE75_LIMIT  = 32'd8333333;
localparam MODE100_LIMIT = 32'd6250000;

//////////////////////////////////////////////////////
// Registers
//////////////////////////////////////////////////////

reg [31:0] counter;
reg [31:0] blink_limit;
reg led_enable;

//////////////////////////////////////////////////////
// Command Execution
//////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        current_mode <= 2'd0;
        blink_limit  <= MODE25_LIMIT;
        led_enable   <= 1'b1;

    end

    else if(valid_cmd)
    begin

        case(command)

        CMD_25:
        begin
            current_mode <= 2'd0;
            blink_limit  <= MODE25_LIMIT;
        end

        CMD_50:
        begin
            current_mode <= 2'd1;
            blink_limit  <= MODE50_LIMIT;
        end

        CMD_75:
        begin
            current_mode <= 2'd2;
            blink_limit  <= MODE75_LIMIT;
        end

        CMD_100:
        begin
            current_mode <= 2'd3;
            blink_limit  <= MODE100_LIMIT;
        end

       CMD_ON:
begin
    current_mode <=2'd1;
    led_enable<=1'b1;
end

CMD_OFF:
begin
    current_mode <=2'd3;
    led_enable <=1'b0;
end

        CMD_RESET:
        begin
            current_mode <= 2'd0;
            blink_limit  <= MODE25_LIMIT;
            led_enable   <= 1'b1;
        end

        default:
        begin
            // Do Nothing
        end

        endcase

    end

end

//////////////////////////////////////////////////////
// Output Generation
//////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        counter     <= 32'd0;
        control_out <= 1'b0;
    end
    else if(led_enable)
    begin
        if(counter >= blink_limit)
        begin
            counter     <= 32'd0;
            control_out <= ~control_out;
        end
        else
        begin
            counter <= counter + 1'b1;
        end
    end
    else
    begin
        counter     <= 32'd0;
        control_out <= 1'b0;
    end
end
endmodule