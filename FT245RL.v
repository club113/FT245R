`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:47:23 05/05/2019 
// Design Name: 
// Module Name:    FT245RL 
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
module FT245RL
#(
parameter DELAY_TICKS = 4'd3//5*10ms 
)
(
    input CLK,
    input RST,
	
	input TXEN, // to enable tx_data
	output TX_VALID,// if tx_valid is high the, the IC is sending busy or buffer being full 
	output TX_DONE,
	input [7:0]TX_DATA, //245 send data

	output RX_DONE, //if have received a bytes, it will give a high pulse 
	output [7:0]RX_DATA,// 245 received data

	
    input TXE,   
    input RXF,
    output WR,
    output RD,

    inout [7:0]DATA_IO
    );
localparam[2:0]
IDLE_STATUS = 3'd0,
READ_STATUS = 3'd1,
WRITE_STATUS = 3'd2,
R_WAIT_STATUS = 3'd3, //wait reading a byte completed
W_WAIT_STATUS = 3'd4; //wait write


(* KEEP="TRUE"*) reg [2:0]ReadWriteStatus,ReadWriteStatus_next;
reg RD_reg,WR_reg;
reg RD_reg_next, WR_reg_next;

reg DelayStatus,DelayStatus_next;//for delay counter
reg DelayFlag,DelayFlag_next; //reach the threshold flag
reg CntEn,CntEn_next;//enable counter
localparam [0:0]
IDLE = 1'b0,
CNT = 1'b1;

(* KEEP="TRUE"*) reg [7:0]RX_DATA_reg,RX_DATA_reg_next;
reg TX_DONE_reg,TX_DONE_reg_next;

reg RxDoneReg,RxDoneReg_next;
//main  parse
always@(posedge CLK, negedge RST)
begin
if(!RST)
	begin
	ReadWriteStatus <= IDLE_STATUS;
	RD_reg <= 1'b1;
	WR_reg <= 1'b1;
	
	DelayFlag <= 1'b0;
	RX_DATA_reg <= 1'b0;
	TX_DONE_reg <= 1'b0;
	CntEn <= 1'b0;
	DelayStatus <= 1'b0;
	RxDoneReg <= 1'b0;
	end
else
	begin
	ReadWriteStatus <= ReadWriteStatus_next;
	RD_reg <= RD_reg_next;
	WR_reg <= WR_reg_next;
	
	DelayFlag <= DelayFlag_next;
	
	
	RX_DATA_reg <= RX_DATA_reg_next;
	TX_DONE_reg <= TX_DONE_reg_next;
	CntEn <= CntEn_next;
	DelayStatus <= DelayStatus_next;
	RxDoneReg <= RxDoneReg_next;
	end
end


reg [3:0]Couter;

//delay pulse
always@(posedge CLK, negedge RST)
begin

	if(!RST)
		begin
		Couter = 4'd0;
		DelayStatus_next = IDLE;
		DelayFlag_next = 1'b0;
		end
	else
		begin

		DelayFlag_next = 1'b0;
			case(DelayStatus)
			IDLE:
				begin
				if(CntEn)
					begin
					DelayStatus_next = CNT;
					Couter = 4'd0;					
					end
				end
			CNT:
				begin
				
				if(Couter == DELAY_TICKS)
					begin
					Couter = 4'd0;
					DelayStatus_next = IDLE;
					
					DelayFlag_next = 1'b1;	
					end
				else
					Couter = Couter + 4'd1; 
				
				end
			endcase
		end
end	

//next status parse
always@*
begin
	ReadWriteStatus_next = ReadWriteStatus;
    RD_reg_next= RD_reg;
	WR_reg_next= WR_reg;
	
	CntEn_next = 1'b0;
	RxDoneReg_next = 1'b0;
	
	RX_DATA_reg_next = RX_DATA_reg;
	
	TX_DONE_reg_next = 1'b0;
	case(ReadWriteStatus)
	IDLE_STATUS:
		begin
		if(!RXF)
			begin
			ReadWriteStatus_next = READ_STATUS;	
			RD_reg_next = 1'b0;
			CntEn_next = 1'b1;
			end
		else if(TXEN)
			begin
		    ReadWriteStatus_next = WRITE_STATUS;
			CntEn_next = 1'b1;
			WR_reg_next = 1'b1;
			end
		end
	READ_STATUS:
		begin
			if(DelayFlag)
			begin
			 RX_DATA_reg_next = DATA_IO;
			 ReadWriteStatus_next = R_WAIT_STATUS;
			end
		
		end
	WRITE_STATUS:
		begin
		
			if(DelayFlag)
				WR_reg_next = 1'b0;
				
			if(TXE)
			   ReadWriteStatus_next = W_WAIT_STATUS;
		end
	R_WAIT_STATUS:
		begin
		RD_reg_next = 1'b1;
		if(RXF)
			begin
			ReadWriteStatus_next = IDLE_STATUS;//Wait for read to complete
			RxDoneReg_next = 1'b1;
			end
		end
    W_WAIT_STATUS:
		begin
	    if(!TXE)
			begin
			  ReadWriteStatus_next = IDLE_STATUS;//Wait for write to complete
			  TX_DONE_reg_next = 1'b1;
			end
		end
	default:
	 ReadWriteStatus_next = IDLE_STATUS;
	endcase
end
assign RD = RD_reg;
assign WR = WR_reg;
assign DATA_IO = (ReadWriteStatus == WRITE_STATUS)? TX_DATA : 8'bz; 
assign TX_VALID = TXE;	
assign TX_DONE = TX_DONE_reg;
assign RX_DATA = RX_DATA_reg;
assign RX_DONE = RxDoneReg;
endmodule
