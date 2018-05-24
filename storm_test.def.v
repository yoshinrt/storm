$header

/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		STORM_TEST.def.v -- STORM test bench

2001.11.13	Not include IRAM.v DRAM.v

*****************************************************************************/

`timescale 1ns/1ns

#include "storm.def.v"

/****************************************************************************/

testmodule STORM_TEST;

reg		tADDRI	PC2, PC3, PC4;
reg		[3:0]	FG4;

parameter	STEP =	24;
integer		TSC;
integer		fd;

	instance STORM * *(
		(.*)	$1
	);
	
	initial begin
	`ifdef OUTPUT_LOG
		fd		= $fopen( "STORM_exec.log" );
	`endif
	`ifdef VCD_WAVE
		$dumpfile( "storm.vcd" );
		$dumpvars;
	`endif
		
		iClk	= 1;
		iRst	<= 1;
		
	#ifdef PIO_MODE
		iCtrl	<= 0;
		iPData	<= 0;
	#endif
		
	#ifdef PUSH_SW
		iPushSW	<= 0;
		iDipSW	<= 0;
	#endif
	
		TSC		<= -4;
	
	#( STEP / 2 );
		iRst	<= 0;
	end
	
	always #( STEP / 2 )	iClk = ~iClk;
	
	wire tDATA	IR = STORM.IRAM.ROM[PC4];
	
	always@( posedge iClk ) begin
		
		PC4 <= PC3;
		PC3 <= PC2;
		PC2 <= STORM.STORM_CORE.IF_PC - 1;
		
		FG4 <= { STORM.STORM_CORE.EXStage.FlagRegO,
				 STORM.STORM_CORE.EXStage.FlagRegS,
				 STORM.STORM_CORE.EXStage.FlagRegZ,
				 STORM.STORM_CORE.EXStage.FlagRegC };
		
	`ifdef OUTPUT_LOG
		// output log
		
		if( TSC >= 0 ) begin
			$fdisplay( fd, "%h %h %h %h %h %h %h %h %s%s%s%s %s%h:%h",
				STORM.STORM_CORE.WBStage.oWB_Reg0,
				STORM.STORM_CORE.WBStage.oWB_Reg1,
				STORM.STORM_CORE.WBStage.oWB_Reg2,
				STORM.STORM_CORE.WBStage.oWB_Reg3,
				STORM.STORM_CORE.WBStage.oWB_Reg4,
				STORM.STORM_CORE.WBStage.oWB_Reg5,
				STORM.STORM_CORE.WBStage.oWB_Reg6,
				STORM.STORM_CORE.WBStage.oWB_Reg7,
				( FG4[ 3 ] === 1 ? "O" : FG4[ 3 ] === 0 ? "." : "?" ),
				( FG4[ 2 ] === 1 ? "-" : FG4[ 2 ] === 0 ? "+" : "?" ),
				( FG4[ 1 ] === 1 ? "Z" : FG4[ 1 ] === 0 ? "." : "?" ),
				( FG4[ 0 ] === 1 ? "C" : FG4[ 0 ] === 0 ? "." : "?" ),
				( PC4 === PC3 ? "*" : " " ),
				PC4, IR
			);
		end
	`endif
		
		if(( IR == 16'hEFFF || IR === 16'hxxxx || PC4 === tADDRI_W'bx ) && TSC >= 0 ) begin
			if( IR === 16'hxxxx || PC4 === tADDRI_W'bx )
				$display( "***** STORM crashed!! *****" );
			
		`ifdef OUTPUT_LOG
			DumpIRAM;
			DumpDRAM;
			$fclose( fd );
		`endif
			$finish;
		end
		
		TSC = TSC + 1;
	end
	
/*** core dump **************************************************************/

task DumpIRAM;
	integer	i;
begin
	
	$fdisplay( fd, "" );
	$fdisplay( fd, "*** Instruction RAM dump ***********************************************************" );
	$fdisplay( fd, "ADDR   +0   +1   +2   +3   +4   +5   +6   +7   +8   +9   +A   +B   +C   +D   +E   +F" );
	
	for( i = 0; i < 512; i = i + 1 ) begin
		if( i % 16 == 0 ) $fwrite( fd, "%h:", i[11:0] );
		
		if( i % 16 == 15 )
			$fdisplay( fd, " %h", STORM.IRAM.ROM[ i ] );
		else
			$fwrite  ( fd, " %h", STORM.IRAM.ROM[ i ] );
	end
end endtask

task DumpDRAM;
	integer	i;
begin
	
	$fdisplay( fd, "" );
	$fdisplay( fd, "*** Data RAM dump ******************************************************************" );
	$fdisplay( fd, "ADDR   +0   +1   +2   +3   +4   +5   +6   +7   +8   +9   +A   +B   +C   +D   +E   +F" );
	
	for( i = 0; i < 1024; i = i + 1 ) begin
		if( i % 16 == 0 ) $fwrite( fd, "%h:", i[11:0] );
		
		if( i % 16 == 15 )
			$fdisplay( fd, " %h", STORM.DRAM.RAM[ i ] );
		else
			$fwrite  ( fd, " %h", STORM.DRAM.RAM[ i ] );
	end
end endtask

endmodule

/*** TEXT ROM ***************************************************************/

module IRAM(
	// I/O port
	input	tADDRI	address;
	output	tDATA	q;
);

// reg / wire

reg		tDATA	ROM[0:511];
reg		tADDRI	RegAddr;

	initial begin
		$readmemh( "text.obj", ROM );
		RegAddr	= 0;
	end
	
	assign q = ROM[ address ];
	
endmodule

/*** DATA RAM ***************************************************************/

module DRAM(;
	// I/O port
	input	tADDRD	address;
	input			we;
	input	tDATA	data;
	output	tDATA	q;
);

// reg / wire

reg		tDATA	RAM[0:1023];

reg		tDATA	RegData;
reg		tADDRD	RegAddr;
reg				RegWE;

	initial begin
		$readmemh( "data.obj", RAM );
		RegData	<= 0;
		RegAddr	<= 0;
		RegWE	<= 0;
	end
	
	always@( we or address or data ) begin
		if( we ) RAM[ address ] = data;
	end
	
	assign q = RAM[ address ];
	
endmodule

#ifdef USE_ADDER_MACRO
/*** adder ******************************************************************/

module ADDER(;
	input	tDATA	dataa;
	input	tDATA	datab;
	input			cin;
	output	tDATA	result;
	output			cout;
	output			overflow;
);
// wire / reg

wire	tDATA	Result;
wire			COut;
wire			OOut;

	assign { COut, Result } = dataa + datab + cin;
	assign OOut = ( dataa[15] == datab[15] && dataa[15] != result[15] );
	
	assign result	= Result;
	assign cout		= COut;
	assign overflow	= OOut;
	
endmodule

#endif

#ifdef PIPELINE_ADDER
/*** adder 10bit ************************************************************/

module ADDER10(;
	input	[9:0]	dataa;
	input	[9:0]	datab;
	input			cin;
	output	[9:0]	result;
	output			cout;
);
// wire / reg

wire	[9:0]	Result;
wire			COut;
wire			OOut;

	assign { COut, Result } = dataa + datab + cin;
	
	assign result	= Result;
	assign cout		= COut;
	
endmodule

/*** adder 6bit *************************************************************/

module ADDER6(;
	input	[5:0]	dataa;
	input	[5:0]	datab;
	input			cin;
	output	[5:0]	result;
	output			cout;
	output			overflow;
);
// wire / reg

wire	[5:0]	Result;
wire			COut;
wire			OOut;

	assign { COut, Result } = dataa + datab + cin;
	assign OOut = ( dataa[5] == datab[5] && dataa[5] != result[5] );
	
	assign result	= Result;
	assign cout		= COut;
	assign overflow	= OOut;
	
endmodule

#endif

/*** LCELL ******************************************************************/

module LCELL(;
	input			in;
	outreg			out;
);
	always@( in ) out <= #3 in;
	
endmodule
