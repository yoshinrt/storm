/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		PIO.def.v -- parallel port I/O module

2001.11.23	clear OutDataBuf when input data from PC
2002.02.23	delete read from PC sequence FSM

*****************************************************************************/

#define tPORT	[3:0]
#define tPORT_W	4

#define tCMD	[3:0]
#define tCMD_W	4

#define SetCmd	( iCtrl[1] && !iCtrl[0] )
#define SetL	( iCtrl[2] &&  iCtrl[0] )
#define SetH	( iCtrl[3] && !iCtrl[0] )
#define Clear	  iCtrl[4]

#define CMD_W_PORT	tCMD_W'h1
#define CMD_W_DATA	tCMD_W'h2
#define CMD_R_PORT	tCMD_W'h9
#define CMD_R_DATA	tCMD_W'hA

module PIO(

input			iClk;		// clk
input			iRst;		// reset

// from / to PIO
input	[3:0]	iPData;		// mc
input	[4:0]	iCtrl;		// ms
outreg	[7:0]	oPData;		// md

// from / to CPU
input	tADDRD	iAddr;		// port address
input	tDATA	iData;		// data in
input			iREnb;		// port read enb
input			iWEnb;		// port write enb
output	tDATA	oData;		// stat / addr / data out
);

// wire / reg

reg		tCMD	Cmd;		// command register
//reg		tPORT	PortIn;		// input port#
reg		[7:0]	DataIn;		// input data
reg		tPORT	PortOut;	// output port#
reg		[7:0]	DataOut;	// output data

reg				BFullIn;	// input buffer full
reg				BFullOut;	// output buffer full

	/*** command register ***************************************************/
	
	RegisterWE( Cmd, iPData, SetCmd, 0 );
	
	/*** PIO input **********************************************************/
	
	wire	SetDL,	// data (L) we
			SetDH;	// data (H) we
	reg		SetDH_Tn1;
	
	assign SetDL = ( Cmd == CMD_W_DATA && iCtrl[2] &&  iCtrl[0] );
	assign SetDH = ( Cmd == CMD_W_DATA && iCtrl[3] && !iCtrl[0] );
	
	Register( SetDH_Tn1, SetDH, 0 );
	wire SetDHRaise = !SetDH_Tn1 && SetDH;
	
	RegisterWE( DataIn[3:0], iPData, SetDL, 0 );
	RegisterWE( DataIn[7:4], iPData, SetDH, 0 );
	
	DefineReg begin
		if( iRst )				BFullIn = 0;
		else if( SetDHRaise )	BFullIn = 1;	// input from PC, buffer full
		else if( iREnb )		BFullIn = 0;	// read data by CPU, buffer empty
	end
	
	assign oData = {
		~BFullIn,		// 15 : read data is invalid
		BFullOut,		// 14 : data output buffer is full
		6'd0,			// 13 -  8
	//	PortIn,			// 11 -  8 port address
		DataIn			//  7 -  0 data
	};
	
	/*** PIO output *********************************************************/
	
	RegisterWE( PortOut, iAddr, iWEnb && !BFullOut, 0 );
	RegisterWE( DataOut, iData, iWEnb && !BFullOut, 0 );
	
	// read complete signal
	
	#ifndef SAFELY_PIO
		reg		Ctrl3Reg;
		Register( Ctrl3Reg, iCtrl[3], 0 );
		wire	ReadComplete = ( Cmd == CMD_R_DATA ) && Ctrl3Reg && !iCtrl[3];
	#endif
	
	DefineReg begin
		if( iRst )
			BFullOut = 0;
		else if(
			#ifndef SAFELY_PIO
				ReadComplete ||
			#endif
			SetDHRaise
		)
			// read complete, or input from PC, then clear out buffer
			BFullOut = 0;
		else if( iWEnb )
			// if write by CPU, buffer full
			BFullOut = 1;
	end
	
	always@( PortOut or DataOut or Cmd or BFullOut ) begin
		Case( Cmd )
			CMD_R_PORT:	oPData = {
							~BFullOut,	// 7 : read data is invalid
							3'd0,		// 6 - 4
							PortOut		// 3 - 0 port address
						};
			CMD_R_DATA:	oPData = DataOut;
			default:	oPData = 8'bx;
		endcase
	end
endmodule
