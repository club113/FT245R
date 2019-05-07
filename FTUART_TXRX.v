`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:03:34 05/06/2019 
// Design Name: 
// Module Name:    FTUART_TXRX 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FTUART_TXRX(
    input CLK,
    input RST,
	    
		
	(* KEEP="TRUE"*)input TXE,   	
    input RXF,
    output WR,
    output RD,

    inout [7:0]DATA_IO
    );


(* KEEP="TRUE"*) reg  TxEnable,TxEnable_next;// a high pulse
(* KEEP="TRUE"*) reg  [7:0]TxData,TxData_next;
(* KEEP="TRUE"*) wire TxValid;	
(* KEEP="TRUE"*) wire TxDone;
(* KEEP="TRUE"*) wire RxDone;
(* KEEP="TRUE"*) wire [7:0]RxData;

	
	
FT245RL FT245RL_1(
     .CLK(CLK),
     .RST(RST),
	
	  .TXEN(TxEnable), // to enable tx_data
	  .TX_VALID(TxValid),// if tx_valid is high the, the IC is sending busy or buffer being full 
	  .TX_DONE(TxDone),
	  .TX_DATA(TxData), //245 send data

	  .RX_DONE(RxDone), //if have received a bytes, it will give a high pulse 
	  .RX_DATA(RxData),// 245 received data

	
     .TXE(TXE),   
     .RXF(RXF),
     .WR(WR),
     .RD(RD),

     .DATA_IO(DATA_IO)
    );

(* KEEP="TRUE"*)  reg [1:0]TestStatus,TestStatus_next;
//main function	
always@(posedge CLK, negedge RST)
begin
	if(!RST)
		begin
		TxEnable <= 0;
		TxData <= 0;
		TestStatus <= IDLE_STATUS;
		end
	else
		begin
		TxEnable <= TxEnable_next;
		TxData <= TxData_next;
		TestStatus <= TestStatus_next;
		end
end
	
	

localparam [1:0]
IDLE_STATUS = 2'd0,
RX_STATUS = 2'd1,
TX_STATUS = 2'd2;
//next status parse	
always@*
begin
TxEnable_next = 1'b0;
TxData_next   = TxData;

TestStatus_next = TestStatus;
	case(TestStatus)
	IDLE_STATUS:
		begin
		if(RxDone)
			begin
			TestStatus_next = RX_STATUS;
			end
		end
	RX_STATUS:
		begin
		TestStatus_next = TX_STATUS;
	TxData_next	 = RxData;
		end
	TX_STATUS:
		begin
			if(!TxValid)
			begin
			TestStatus_next = IDLE_STATUS;
			TxEnable_next = 1'b1; 
			end
		end
	default:
		TestStatus_next = IDLE_STATUS;
	
	endcase


end
endmodule
