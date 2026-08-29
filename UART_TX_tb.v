`timescale 1ns/1ps
module UART_TX_tb;
parameter W = 8;
reg [W-1:0] P_INPUT;
reg V_INPUT,CLK,RST,P_EN,P_BIT;
wire TX_OUTPUT,BUSY;
UART_TX #(.W(W)) DUT(.P_INPUT(P_INPUT), .V_INPUT(V_INPUT), .CLK(CLK), .RST(RST), .P_EN(P_EN), .P_BIT(P_BIT), .TX_OUTPUT(TX_OUTPUT), .BUSY(BUSY));
always #5 CLK = ~CLK;                // generate clock with 10ns period
always @(posedge CLK) begin
    #1;                              // wait for outputs to update (I had timing issues and searched for a solution, found none. Asked ChatGPT and it suggested this tiny edit; not sure why but doesn't hurt:)
    $display("time=%0t data=%h valid=%b p_en=%b p_bit=%b TX=%b BUSY=%b", $time,P_INPUT,V_INPUT,P_EN,P_BIT,TX_OUTPUT,BUSY);
end
initial begin
    CLK=0; RST=0; V_INPUT=0;                           // set clock, reset and valid input initial values
    P_INPUT=0; P_EN=0; P_BIT=0;                        // set data and parity inputs to zero
    #12 RST=1;                                         // deactivate the reset (active-low)
    #8 P_INPUT=8'hA5; P_EN=1; P_BIT=0; V_INPUT=1;      // send A5 + even parity
    #10 V_INPUT=0;                                     // valid input high for one cycle only
    #30 P_INPUT=8'hFF; P_EN=0; P_BIT=1; V_INPUT=1;     // this valid pulse occurs while BUSY and should be ignored, so it wouldn't alter transmission
    #10 V_INPUT=0;
    #70;
    P_INPUT=8'h3C; P_EN=1; P_BIT=1; V_INPUT=1;       // send 3C +odd parity
    #10 V_INPUT=0;
    #120;
    P_INPUT=8'h96; P_EN=0; P_BIT=0; V_INPUT=1;       // send 96 without parity
    #10 V_INPUT=0;
    #110;
    $display("UART TX test finished");
    $finish;
end
endmodule
