/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		EXTBoard.def.v -- LED Matrix & input sw board I/F

2001.11.08	automatic anti-chattering

*****************************************************************************/

#define tPORT	[3:0]

#define PORT_PushSW			0
#define PORT_DipSW			1

#define PORT_LEDData		0
#define PORT_LEDLine		1
#define PORT_BeepDivider	2
#define PORT_BeepDivident	3

#define BeepCnt2Data( x )	( x[18:3] )

#ifdef LED_MATRIX
/*** LED Matrix & Beep SP ***************************************************/

module LEDMatrix(
input			iClk;
input			iRst;

// from / to Ext Board

outreg	[9:0]	oLED_Data;		// 1line data
outreg	[19:0]	oLED_LineSel;	// line select
outreg			oLED_Beep;		// Beep SP

// from / to CPU
input	tADDRD	iAddr;			// port address
input	tDATA	iData;			// data in
input			iWEnb;			// port write enb
);

// local I/O address
wire	tPORT	Addr = iAddr;

	/*** LED Matrix registers ***********************************************/
	
	wire	[4:0]	LineSelCnt = iData;
	reg		[9:0]	LED_Data;
	
	/*** scan line out ***/
	
	DefineReg if( iRst ) begin
		oLED_LineSel <= 20'hFFFFF;
		oLED_Data	 <= 0;
		
	end else if( iWEnb && Addr == PORT_LEDLine ) begin
		Case( LineSelCnt )
			 0:	 oLED_LineSel <= 20'b11111111111111111110;
			 1:	 oLED_LineSel <= 20'b11111111111111111101;
			 2:	 oLED_LineSel <= 20'b11111111111111111011;
			 3:	 oLED_LineSel <= 20'b11111111111111110111;
			 4:	 oLED_LineSel <= 20'b11111111111111101111;
			 5:	 oLED_LineSel <= 20'b11111111111111011111;
			 6:	 oLED_LineSel <= 20'b11111111111110111111;
			 7:	 oLED_LineSel <= 20'b11111111111101111111;
			 8:	 oLED_LineSel <= 20'b11111111111011111111;
			 9:	 oLED_LineSel <= 20'b11111111110111111111;
			10:	 oLED_LineSel <= 20'b11111111101111111111;
			11:	 oLED_LineSel <= 20'b11111111011111111111;
			12:	 oLED_LineSel <= 20'b11111110111111111111;
			13:	 oLED_LineSel <= 20'b11111101111111111111;
			14:	 oLED_LineSel <= 20'b11111011111111111111;
			15:	 oLED_LineSel <= 20'b11110111111111111111;
			16:	 oLED_LineSel <= 20'b11101111111111111111;
			17:	 oLED_LineSel <= 20'b11011111111111111111;
			18:	 oLED_LineSel <= 20'b10111111111111111111;
			19:	 oLED_LineSel <= 20'b01111111111111111111;
			default: oLED_LineSel <= 20'bx;
		endcase
		
		oLED_Data <= LED_Data;
	end
	
	/*** LED matrix data out ***/
	
	DefineReg begin
		if( iRst ) begin
			LED_Data	<= 0;
		end else if( iWEnb && Addr == PORT_LEDData ) begin
			LED_Data	<= iData;
		end
	end
	
	/*** Beep SP out ********************************************************/
	
	reg		tDATA	BeepCntDivider,
					BeepCntDivident;
	reg		[19:0]	BeepCnt;
	wire	[19:0]	BeepCntInc = BeepCnt + 1;
	
	// Beep frequency setting reg
	
	RegisterWE(
		BeepCntDivider, iData,
		( iWEnb && Addr == PORT_BeepDivider ), 0
	);
	
	RegisterWE(
		BeepCntDivident, iData,
		( iWEnb && Addr == PORT_BeepDivident ), 0
	);
	
	// Beep counter
	
	DefineReg begin
		if( iRst )	BeepCnt	<= 0;
		else if(( BeepCnt2Data( BeepCntInc ) == BeepCntDivider ) ||
				( iWEnb && Addr == PORT_BeepDivider ))
					BeepCnt <= 0;
		else		BeepCnt <= BeepCntInc;
	end
	
	// Beep out
	Register( oLED_Beep, ( BeepCnt2Data( BeepCnt ) >= BeepCntDivident ), 1 );
	
endmodule
#endif

#ifdef PUSH_SW
/*** input SW ***************************************************************/

module InputSW(
input			iClk;
input			iRst;

// from / to EXT Board
input	[7:0]	iPushSW;
input	[7:0]	iDipSW;
input			iREnb;

// from / to CPU
input	tADDRD	iAddr;			// port address
output	tDATA	oData;			// stat / addr / data out
);

// I/O local addr
wire	tPORT	Addr = iAddr;

reg		[7:0]	PushSW,
				DipSW;

reg		[7:0]	SamplingCnt;	// sampling counter for anti-chattering

	DefineReg begin
		if( iRst ) begin
			SamplingCnt	<= 0;
			
			PushSW		<= 0;
			DipSW		<= 0;
		end else begin
			
			SamplingCnt	<= SamplingCnt + 1;
			
			if( SamplingCnt == 0 ) begin
				PushSW	<= iPushSW;
				DipSW	<= iDipSW;
			end
		end
	end
	
	assign oData = ( Addr == PORT_PushSW ) ? PushSW : DipSW;
	
endmodule
#endif
