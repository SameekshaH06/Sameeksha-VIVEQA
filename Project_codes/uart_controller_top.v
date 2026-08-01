`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2026 19:53:33
// Design Name: 
// Module Name: uart_controller_top
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
module uart_controller_top
(
    input  wire clk_24mhz,
    input  wire rst,

    input  wire uart_rx,

    output wire uart_tx,

    output wire control_out,

    output wire locked
);


//////////////////////////////////////////////////////
// Clock Wizard
//////////////////////////////////////////////////////

wire clk50;

clk_wiz_0 clock_generator
(
    .clk_in1(clk_24mhz),
    .reset(rst),

    .clk_out1(clk50),
    .locked(locked)
);

//////////////////////////////////////////////////////
// UART Receiver
//////////////////////////////////////////////////////

wire [7:0] rx_data;
wire rx_valid;

uart_rx
#(
    .CLKS_PER_BIT(434)
)
uart_receiver
(
    .i_Clock(clk50),
    .i_Reset(rst),
    .i_Rx_Serial(uart_rx),
    .o_Rx_DV(rx_valid),
    .o_Rx_Byte(rx_data)
);
//////////////////////////////////////////////////////
// Command Parser
//////////////////////////////////////////////////////

wire [3:0] command;
wire valid_cmd;

uart_command_parser parser
(
    .clk(clk50),
    .rst(rst),

    .rx_data(rx_data),
    .rx_valid(rx_valid),

    .command(command),
    .valid_cmd(valid_cmd)
);

//////////////////////////////////////////////////////
// UART Controller
//////////////////////////////////////////////////////

wire [1:0] current_mode;
uart_controller controller
(
    .clk(clk50),
    .rst(rst),

    .command(command),
    .valid_cmd(valid_cmd),

    .control_out(control_out),
    .current_mode(current_mode)
);

//////////////////////////////////////////////////////
// Response Generator
//////////////////////////////////////////////////////

wire tx_start;
wire [7:0] tx_data;
wire tx_busy;

uart_response_generator response_generator
(
    .clk(clk50),
    .rst(rst),

    .command(command),
    .valid_cmd(valid_cmd),

    .current_mode(current_mode),

    .tx_busy(tx_busy),

    .tx_start(tx_start),
    .tx_data(tx_data)
);

//////////////////////////////////////////////////////
// UART Transmitter
//////////////////////////////////////////////////////

wire tx_done;

uart_tx
#(
    .CLKS_PER_BIT(434)
)
uart_transmitter
(
    .i_Clock(clk50),
    .i_Tx_DV(tx_start),
    .i_Tx_Byte(tx_data),
    .o_Tx_Active(tx_busy),
    .o_Tx_Serial(uart_tx),
    .o_Tx_Done(tx_done)
);
endmodule