`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:47:33 05/06/2019
// Design Name:   FT245RL
// Module Name:   H:/ISE/ISE_PRJ/007 FT245/FT245/FT245Test.v
// Project Name:  FT245
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FT245RL
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FT245Test;

	// Inputs
	reg CLK;
	reg RST;
	reg TXEN;
	reg [7:0] TX_DATA;
	reg TXE;
	reg RXF;

	// Outputs
	wire TX_VALID;
	wire TX_DONE;
	wire RX_DONE;
	wire [7:0] RX_DATA;
	wire WR;
	wire RD;

	
	reg [7:0]Data;
	// Bidirs
	wire [7:0] DATA_IO;

	// Instantiate the Unit Under Test (UUT)
	FT245RL uut (
		.CLK(CLK), 
		.RST(RST), 
		.TXEN(TXEN), 
		.TX_VALID(TX_VALID), 
		.TX_DONE(TX_DONE), 
		.TX_DATA(TX_DATA), 
		.RX_DONE(RX_DONE), 
		.RX_DATA(RX_DATA), 
		.TXE(TXE), 
		.RXF(RXF), 
		.WR(WR), 
		.RD(RD), 
		.DATA_IO(DATA_IO)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 0;
		TXEN = 0;
		TX_DATA = 0;
		TXE = 0;
		RXF = 0;
        Data = 0;
		// Wait 100 ns for global reset to finish
		#100;
		RST = 1;
		RXF = 1;
		// Add stimulus here
		forever begin
		#10;
		CLK =~CLK;
	
		
		end

	end
	
	initial begin
    #120;
	if(!TX_VALID)
		begin
		TX_DATA = 85;	
		end
	#20;
	TXEN = 1;//使能发送,1个高脉冲
	#20;
	TXEN = 0;
	
	#100;
	TXE = 1; //正在发送
	#100;
	TXE = 0; //发送完
	
	#40; //read test
	RXF = 0;

	#100;

	RXF = 1;

	
	end
  
endmodule

