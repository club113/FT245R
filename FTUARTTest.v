`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:50:28 05/06/2019
// Design Name:   FTUART_TXRX
// Module Name:   H:/ISE/ISE_PRJ/007 FT245/FT245/FTUARTTest.v
// Project Name:  FT245
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FTUART_TXRX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FTUARTTest;

	// Inputs
	reg CLK;
	reg RST;
	reg TXE;
	reg RXF;

	// Outputs
	wire WR;
	wire RD;

	// Bidirs
	wire [7:0] DATA_IO;
	reg [7:0] DATA_I;
	wire [7:0] DATA_O;
	assign DATA_IO = DATA_I;
	assign DATA_O =  DATA_IO;
			
	// Instantiate the Unit Under Test (UUT)
	FTUART_TXRX uut (
		.CLK(CLK), 
		.RST(RST), 
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
		TXE = 0;
		RXF = 0;

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
	
	#200;

	RXF = 0; //发送完
	
	#20; //read test
	DATA_I = 100;

	#100;

	RXF = 1;

	
	end
endmodule

