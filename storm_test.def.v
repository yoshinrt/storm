$header

/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		STORM_TEST.def.v -- STORM test bench

*****************************************************************************/

`timescale 1ns/1ns

#include "STORM.def.v"

/****************************************************************************/

testmodule STORM_TEST;

reg		tDATA	IR,  IR0;
reg		tADDRI	PC0, PC1, PC2, PC3, PC4;
reg		[3:0]	FG3, FG4;

parameter	STEP =	24;
integer		TSC;
integer		fd;

	instance STORM * *(
		(.*)	$1
	);
	
	initial begin
	#ifdef OUTPUT_LOG
		fd		= $fopen( "STORM_exec.log" );
	#endif
		
		Clk		= 1;
		Reset	= 1;
		TSC		= -4;
		
	#( STEP / 2 );
		Reset	= 0;
	end
	
	always #( STEP / 2 )	Clk = ~Clk;
	
	always@( posedge Clk ) begin
		
		PC4 = PC3;
		PC3 = PC2;
		PC2 = PC1;
		PC1 = STORMInst.STORM_COREInst.IF_PC - 1;
		
		IR0	= STORMInst.IRAMInst.lpm_rom_component.ROM[PC3];
		IR	= STORMInst.IRAMInst.lpm_rom_component.ROM[PC4];
		
		FG4 = FG3;
		FG3 = { STORMInst.STORM_COREInst.EXStageInst.FlagRegO,
				STORMInst.STORM_COREInst.EXStageInst.FlagRegS,
				STORMInst.STORM_COREInst.EXStageInst.FlagRegZ,
				STORMInst.STORM_COREInst.EXStageInst.FlagRegC };
		
	#ifdef OUTPUT_LOG
		// output log
		
		if( TSC >= 0 ) begin
			$fdisplay( fd, "%h %h %h %h %h %h %h %h %s%s%s%s %s%h:%h",
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg0,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg1,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg2,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg3,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg4,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg5,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg6,
				STORMInst.STORM_COREInst.WBStageInst.oWB_Reg7,
				( FG4[ 3 ] === 1 ? "O" : FG4[ 3 ] === 0 ? "." : "?" ),
				( FG4[ 2 ] === 1 ? "-" : FG4[ 2 ] === 0 ? "+" : "?" ),
				( FG4[ 1 ] === 1 ? "Z" : FG4[ 1 ] === 0 ? "." : "?" ),
				( FG4[ 0 ] === 1 ? "C" : FG4[ 0 ] === 0 ? "." : "?" ),
				( PC4 === PC3 ? "*" : " " ),
				PC4, IR
			);
		end
	#endif
		
		if(( IR == 16'hCFFF || IR === 16'hxxxx || PC4 === tADDRI_W'bx ) && TSC >= 0 ) begin
			if( IR === 16'hxxxx || PC4 === tADDRI_W'bx )
				$display( "***** STORM crashed!! *****" );
			
		#ifdef OUTPUT_LOG
			DumpIRAM;
			DumpDRAM;
			$fclose( fd );
		#endif
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
			$fdisplay( fd, " %h", STORMInst.IRAMInst.lpm_rom_component.ROM[ i ] );
		else
			$fwrite  ( fd, " %h", STORMInst.IRAMInst.lpm_rom_component.ROM[ i ] );
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
			$fdisplay( fd, " %h", STORMInst.DRAMInst.lpm_ram_dq_component.RAM[ i ] );
		else
			$fwrite  ( fd, " %h", STORMInst.DRAMInst.lpm_ram_dq_component.RAM[ i ] );
	end
end endtask

endmodule

#include "IRAM.v"
#include "DRAM.v"

/*** TEXT ROM ***************************************************************/

module lpm_rom;

// I/O port

#ifndef ASYNC_IRAM
input			inclock;
#endif
input	tADDRI	address;
output	tDATA	q;

// reg / wire

reg		tDATA	ROM[0:511];
reg		tADDRI	RegAddr;

// parameter (dummy)

parameter LPM_WIDTH				= 8;
parameter LPM_WIDTHAD			= 8;
parameter LPM_ADDRESS_CONTROL	= "REGISTERED";
parameter LPM_OUTDATA			= "UNREGISTERED";
parameter LPM_FILE				= "text.mif";

	initial begin
		$readmemh( "text.dat", ROM );
		RegAddr	= 0;
	end
	
	assign q = ROM[ address ];
	
endmodule

/*** DATA RAM ***************************************************************/

module lpm_ram_dq;

// I/O port

#ifndef ASYNC_DRAM
input			inclock;
#endif
input	tADDRD	address;
input			we;
input	tDATA	data;
output	tDATA	q;

// reg / wire

reg		tDATA	RAM[0:1023];

reg		tDATA	RegData;
reg		tADDRD	RegAddr;
reg				RegWE;

// parameter (dummy)

parameter LPM_WIDTH				= 8;
parameter LPM_WIDTHAD			= 8;
parameter LPM_INDATA			= "REGISTERED";
parameter LPM_ADDRESS_CONTROL	= "REGISTERED";
parameter LPM_OUTDATA			= "UNREGISTERED";
parameter LPM_FILE				= "data.mif";
parameter LPM_HINT				= "USE_EAB=ON";

	initial begin
		$readmemh( "data.dat", RAM );
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

module ADDER;

input	tDATA	dataa;
input	tDATA	datab;
input			cin;
output	tDATA	result;
output			cout;
output			overflow;

// wire / reg

wire	tDATA	Result;
wire			COut;
wire			OOut;

// parameter (dummy)

parameter LPM_WIDTH				= 16;
parameter LPM_DIRECTION			= "ADD";
parameter ONE_INPUT_IS_CONSTANT	= "NO";
	
	assign { COut, Result } = dataa + datab + cin;
	assign OOut = ( dataa[15] == datab[15] && dataa[15] != result[15] );
	
	assign result	= Result;
	assign cout		= COut;
	assign overflow	= OOut;
	
endmodule

#endif

/*** LCELL ******************************************************************/

module LCELL;

input			in;
outreg			out;
	
	always@( in ) out <= #3 in;
	
endmodule
