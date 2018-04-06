/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		PIO.def.v -- parallel port I/O module

*****************************************************************************/

#define tPORT	[6:0]
#define tPORT_W	7

#define tCMD	[3:0]
#define tCMD_W	4

#define SetCmd	( iCtrl[1] && !iCtrl[0] )
#define SetL	( iCtrl[2] &&  iCtrl[0] )
#define SetH	( iCtrl[3] && !iCtrl[0] )
#define Clear	  iCtrl[4]

#define CMD_W_PORT		tCMD_W'h1
#define CMD_W_DATA_H	tCMD_W'h2
#define CMD_W_DATA_L	tCMD_W'h2
#define CMD_R_PORT		tCMD_W'h9
#define CMD_R_DATA_H	tCMD_W'hA
#define CMD_R_DATA_L	tCMD_W'hA

module PIO;

input			Clk;		// clk
input			Reset;		// reset

// from / to PIO
input	[3:0]	iPData;		// mc
input	[4:0]	iCtrl;		// ms
outreg	[7:0]	oPData;		// md

// from / to CPU ( data )

input	tPORT	iAddr;		// port address
input	tDATA	iData;		// data in
input			iREnb;		// port read enb
input			iWEnb;		// port write enb
output			oAck;		// ack

// from / to CPU ( instruction )

input			iREnbI;		// port read enb
input			iWEnbI;		// write burst read request command
output			oAckI;		// ack

// common data output to CPU

outreg	tDATA	oData;		// data out to CPU

// wire / reg

reg		tCMD	Cmd;		// command register
reg		tPORT	PortOut;	// output port#
reg		tDATA	DataOut;	// output data

reg				BFullIn;	// input buffer is full
reg				BFullOut;	// output buffer full

reg				SetOutBuf;	// set BFullOut to 1 request

wire			BusrtMode = iAddr[6];	// burst read address?

	/*** command register ***************************************************/
	
	RegisterWE( Cmd, iPData, SetCmd, 0 );
	
	/*** PIO input **********************************************************/
	
	wire	SetDLL,	// data  3- 0 we
			SetDLH,	// data  8- 4 we
			SetDHL,	// data 11- 9 we
			SetDHH;	// data 15-12 we
	
	assign SetDLL = ( Cmd == CMD_W_DATA_L && iCtrl[2] &&  iCtrl[0] );
	assign SetDLH = ( Cmd == CMD_W_DATA_L && iCtrl[3] && !iCtrl[0] );
	assign SetDHL = ( Cmd == CMD_W_DATA_H && iCtrl[2] &&  iCtrl[0] );
	assign SetDHH = ( Cmd == CMD_W_DATA_H && iCtrl[3] && !iCtrl[0] );
	
	wire   REnb = iREnb | iREnbI;
	
	// I-RAM page in / Virtual I/O / D-RAM page in
	
	RegisterWE( oData[3:0],		iPData, !REnb && SetDLL, 0 );
	RegisterWE( oData[7:4],		iPData, !REnb && SetDLH, 0 );
	RegisterWE( oData[11:9],	iPData, !REnb && SetDHL, 0 );
	RegisterWE( oData[15:12],	iPData, !REnb && SetDHH, 0 );
	
	DefineReg begin
		if( Reset )					BFullIn = 0;
		else if( !REnb && SetDLH )	BFullIn = 1;	// input from PC, buffer full
		else if( REnb )				BFullIn = 0;	// read data by CPU, buffer empty
	end
	
	/*** PIO output *********************************************************/
	
	enum tPIOState {
		S_PIO_Start,
		S_PIO_IRead,
		S_PIO_IWrite,
		S_PIO_BRead,
		S_PIO_Read,
		S_PIO_Read1,
		S_PIO_Write,
	};
	
	DefineReg begin
		if( Reset ) begin
			
			PIOState	<= S_PIO_Start;
			PortOut		<= 0;
			PortData	<= 0;
			
			oAckI		<= 0;
			oAck		<= 0;
			SetBufOut	<= 0;
			
		end else begin
			
			oAckI		<= 0;
			oAck		<= 0;
			SetOutBuf	<= 0;
			
			Case( PIOState )
				S_PIO_Start: Casex( { iREnbI, iWEnbI, BurstMode, iREnb, iWEnb } )
					5'b1xxxx: PIOState <= S_PIO_IRead;
					5'b01xxx: PIOState <= S_PIO_IWrite;
					5'b0011x: PIOState <= S_PIO_BRead;
					5'b0001x: PIOState <= S_PIO_Read;
					5'b00x01: PIOState <= S_PIO_Write;
					default:  PIOState <= tPIOState_W'bx;
				endcase
				
				/*** burst read instruction *********************************/
				// 1. if InBuf = Full, read completed
				
				S_PIO_IRead: begin
					if( BFullIn ) begin
						oAckI		<= 1;
						PIOState	<= S_PIO_Start;
					end
				end
				
				/*** burst write instruction ********************************/
				// 1. if OutBuf = empty, output port, data --> complete
				
				S_PIO_IWrite: begin
					if( BFullOut == 0 ) begin	// out buffer empty
						PortOut		<= iBurst ? PORT_PAGE_IN_I;
						SetOutBuf	<= 1;
						oAckI		<= 1;
						PIOState	<= S_PIO_Start;
					end
				end
				
				/*** burst read data ****************************************/
				// 1. if InBuf = Full, read completed
				
				S_PIO_BRead: begin
					if( BFullIn ) begin
						oAck		<= 1;
						PIOState	<= S_PIO_Start;
					end
				end
				
				/*** read data **********************************************/
				// 1. if OutBuf = empty, output port#
				
				S_PIO_Read: begin
					if( BFullOut == 0 ) begin
						PortOut		<= iAddr;
						SetOutBuf	<= 1;
						PIOState	<= S_PIO_Read1;
					end
				end
				
				// 2. if InBuf = Full, read complete
				
				S_PIO_Read1: begin
					if( BFullIn ) begin
						oAck		<= 1;
						PIOState	<= S_PIO_Start;
					end
				end
				
				/*** write data *********************************************/
				// 1. if OutBuf = empty, output port, data --> complete
				
				S_PIO_IWrite: begin
					if( BFullOut == 0 ) begin	// out buffer empty
						PortOut		<= iAddr;
						DataOut		<= iData;
						SetOutBuf	<= 1;
						oAck		<= 1;
						PIOState	<= S_PIO_Start;
					end
				end
			endcase
		end
	end
	
	/*** output buffer status register **************************************/
	
	DefineReg begin
		if( Reset )
			BFullOut = 0;
		else if( SetOutBuf )
			// if write by CPU, buffer full
			BFullOut = 1;
			
		else if( ReadState == S_CLR_BFO )
			// if read sequence completed, buffer empty
			BFullOut = 0;
	end
	
	/*** read complete detection signal *************************************/
	
	enum tReadState {
		S_WCMD,		// wait CMD_R_DATA
		S_WRFIN,	// wait finish read sequence
		S_CLR_BFO	// output BFullOut clear signal
	};
	
	reg	tReadState ReadState;
	
	DefineReg begin
		if( Reset )	ReadState <= S_WCMD;
		else Case( ReadState )
			S_WCMD:		if( iCtrl[3] == 1'b1 )	ReadState <= S_WRFIN;
			S_WRFIN:	if( iCtrl[3] == 1'b0 )	ReadState <= S_CLR_BFO;
			S_CLR_BFO:	if( BFullOut == 0 )		ReadState <= S_WCMD;
		endcase
	end
	
	/*** oPData selector ****************************************************/
	
	always@( PortOut or DataOut or Cmd or BFullOut ) begin
		Case( Cmd )
			CMD_R_PORT:		oPData = {
								~BFullOut,	// 7 : read data is invalid
								PortOut		// 6 - 0 port address
							};
			CMD_R_DATA_H:	oPData = DataOut[15:8];
			CMD_R_DATA_L:	oPData = DataOut[7:0];
			default:		oPData = 8'bx;
		endcase
	end
endmodule
