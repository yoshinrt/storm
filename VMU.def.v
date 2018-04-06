/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		VMU.def.v -- Virtual Memory management Unit

*****************************************************************************/

/*** Least Recently Used page num *******************************************/

module LRU;

input			Clk;					// clock
input			Reset;					// reset

input	tPADDR	iLRU_PAddr;				// page# to read
input			iLRU_WEnb;				// write enable

output	tPADDR	oLRU_PAddr;				// LRU page#

// wire / reg

reg		tPADDR	P0,
				P1,
				P2,
				P3,
				P4,
				P5,
				P6,
				P7;

wire	[7:0]	CmpResult;
	
	assign CmpResult = {
		{ iLRU_PAddr == P0 },
		{ iLRU_PAddr == P1 },
		{ iLRU_PAddr == P2 },
		{ iLRU_PAddr == P3 },
		{ iLRU_PAddr == P4 },
		{ iLRU_PAddr == P5 },
		{ iLRU_PAddr == P6 },
		{ iLRU_PAddr == P7 }
	};
	
	DefineReg begin
		if( Reset ) begin
			P0 <= PAGE0;
			P1 <= PAGE1;
			P2 <= PAGE2;
			P3 <= PAGE3;
			P4 <= PAGE4;
			P5 <= PAGE5;
			P6 <= PAGE6;
			P7 <= PAGE7;
			
		end else Casex( CmpResult )
			8'b10000000: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P0,P1,P2,P3,P4,P5,P6,P7 };
			8'b01000000: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P1,P0,P2,P3,P4,P5,P6,P7 };
			8'b00100000: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P2,P0,P1,P3,P4,P5,P6,P7 };
			8'b00010000: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P3,P0,P1,P2,P4,P5,P6,P7 };
			8'b00001000: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P4,P0,P1,P2,P3,P5,P6,P7 };
			8'b00000100: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P5,P0,P1,P2,P3,P4,P6,P7 };
			8'b00000010: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P6,P0,P1,P2,P3,P4,P5,P7 };
			8'b00000001: { P0,P1,P2,P3,P4,P5,P6,P7 } <= { P7,P0,P1,P2,P3,P4,P5,P6 };
			default:	 { P0,P1,P2,P3,P4,P5,P6,P7 } <= 24'bx;
		endcase
	end
	
	assign oLRU_PAddr = P7;
	
endmodule
