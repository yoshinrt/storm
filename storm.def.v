/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		STORM.def.v -- STORM core + RAM + other unit

******************************************************************************

2001.07.10	adjust PC witdh == 9
2001.07.11	adopt Instruction code format V1.1
			add IRAM async mode
			correct oID_wSetPC
2001.07.13	add DRAM async mode
2001.07.14	adopt Instruction code format V1.2
			( chg. mm, SS, DD interpret / add nop )
			many Bug fix (^^;
2001.07.15	add pipeline adder mode
2001.07.17	enable wStall when adc/sbb after FlagsWE
			correct oEX_DRAM_Addr @ PIPELINE_ADDER mode
2001.07.18	add RegNum1 pre decode mode
2001.07.19	move preparation of DRAM_WBData ID -> EX
2001.07.26	add pipeline interlock @ !PIPELINE_ADDER mode
2001.07.28	disable wStall @ DRAM_WB's reg R.A.W.
2001.08.07	reduce Jcc's delay slot 3 -> 2 ( but slow )
2001.08.09	adopt ICF v1.21 ( move SS / DD's pos )
			add JMP_R7ONLY mode ( very little fast??? )
2001.08.10	correct wRegNum1's sensitivity list
2001.08.16	add JMP_RADR_ONLY mode
			chg. conn. of oDataLED  PC --> r1
2001.08.26	chg. IO base address 0xFC00 -> 0x4000
			add `&& NonStall' @DRAM_REnb for avoid stall bug of IOReq
			add swp instruction
2001.10.29	add ExtBoard I/F
2001.11.08	enable PIO+InputSW mode
			delete configuration of ASYNC RAM mode
2002.03.23	add SAFELY_PIO mode

*** best compiler setting ****************************************************

+NONE					F9 :44.44MHz
+PIO_MODE				F10:44.64MHz
 +LED_MATRIX			F?
  +PUSH_SW				F10:41.32MHz

*** configuration ***********************************************************/

//#define USE_ADDER_MACRO	// use adder macro instead of '+' operator
#define PIPELINE_ADDER		// use 2stage pipline adder
//#define FAST_JCC			// jcc delay slot# == 2
#define PREID_REGNUM1		// decode RegNum1 in IF stage
//#define JMP_R7ONLY		// allow jmp reg only r7
#define JMP_RADR_ONLY		// allow jmp reg only r0, 1, 4, 7
#define PIO_MODE			// use parallel I/O module
#define LED_MATRIX			// use EXT Board LED Matrix
#define PUSH_SW				// use EXT Board Push/Dip SW
#define SAFELY_PIO			// safely PIO sequence

/*** const ******************************************************************/

#define tDATA_W			16
#define tDATA			[15:0]

#define tADDRI_W		9
#define tADDRI			[8:0]
#define ExpandPC( x )	{ 7'b0000000, x }

#define tADDRD_W		10
#define tADDRD			[9:0]

/*** macros *****************************************************************/

#define DefineReg	always@( posedge iClk or posedge iRst )

#define Register( reg, data, init )	\
			DefineReg if( iRst ) reg <= init; else reg <= data 

#define RegisterWE( reg, data, we, init )	\
			DefineReg if( iRst ) reg <= init; else if( we ) reg <= data 

// PIO:0x4000  Ext:0x8000
#define IsDRAMAddr( x )	( x[15:14] == 2'b00 || x[15:14] == 2'b11 )
#define IsPIOAddr( x )	( x[15:14] == 2'b01 )
#define IsExtAddr( x )	( x[15:14] == 2'b10 )

$wire	[io](.+)	$1

#include "storm.h"

/*** IF stage ***************************************************************/

module IFStage(
	// I/O port
	
	input			iClk;			// clock
	input			iRst;			// reset
	
	input	tADDRI	iID_wPC;		// set PC data from ID
	input			iID_wSetPC;		// set PC request from ID
	
	input	tADDRI	iEX_wPC;		// set PC data from EX
	input			iEX_wSetPC;		// set PC request from EX
	
	input			iID_wStall;		// pipeline stall
	
	output	tADDRI	oIF_IRAM_Addr;	// instruction RAM addr
	input	tDATA	iIRAM_Data;		// instruction RAM data
	
	outreg	tDATA	oIF_IR;			// IF stage IR
	output	tDATA	oIF_wIR;		// IF stage IR ( wire )
	outreg	tADDRI	oIF_PC;			// IF stage PC
);

// wire / reg

wire	tADDRI	PC;				// PC
reg		tADDRI	RegPC;			// PC register
wire	tADDRI	PC_plus1;		// ++RegPC

	/*** IR / PC regisger ***************************************************/
	
	RegisterWE( oIF_IR, iIRAM_Data, !iID_wStall, 0 );
	RegisterWE( oIF_PC, PC_plus1,   !iID_wStall, 0 );
	
	assign oIF_wIR = iIRAM_Data;
	
	/*** PC *****************************************************************/
	
	assign PC_plus1 = RegPC + tADDRI_W'd1;
	
	assign PC = iEX_wSetPC ? iEX_wPC	:
				iID_wSetPC ? iID_wPC	:
							 PC_plus1	;
	
	assign oIF_IRAM_Addr = RegPC;
	RegisterWE( RegPC, PC, !iID_wStall, 0 );
	
endmodule

/*** get source reg data from RegFiles, Pipeline latch ***********************/

module SrcRegData(
	input	tREG	iRegNum;
	
	input	tDATA	iWB_Reg0;		// registers
	input	tDATA	iWB_Reg1;
	input	tDATA	iWB_Reg2;
	input	tDATA	iWB_Reg3;
	input	tDATA	iWB_Reg4;
	input	tDATA	iWB_Reg5;
	input	tDATA	iWB_Reg6;
	input	tDATA	iWB_Reg7;
	
	input	tDATA	iEX_wWBData;
	input	tREG	iEX_wWBReg;
	input			iEX_wWBEnb;
	
	input	tDATA	iMA_wWBData;
	input	tREG	iMA_wWBReg;
	input			iMA_wWBEnb;
	
	input	tDATA	iWB_wWBData;
	input	tREG	iWB_wWBReg;
	input			iWB_wWBEnb;
	
	outreg	tDATA	oSrcData;
);

	always@(
		iRegNum or
		
		iWB_Reg0 or	iWB_Reg1 or	iWB_Reg2 or	iWB_Reg3 or
		iWB_Reg4 or	iWB_Reg5 or	iWB_Reg6 or	iWB_Reg7 or
		
		iEX_wWBData	or iEX_wWBReg or iEX_wWBEnb or
		iMA_wWBData	or iMA_wWBReg or iMA_wWBEnb or
		iWB_wWBData	or iWB_wWBReg or iWB_wWBEnb
	) begin
		if	   ( iEX_wWBEnb && iRegNum == iEX_wWBReg ) oSrcData = iEX_wWBData;
		else if( iMA_wWBEnb && iRegNum == iMA_wWBReg ) oSrcData = iMA_wWBData;
		else if( iWB_wWBEnb && iRegNum == iWB_wWBReg ) oSrcData = iWB_wWBData;
		else Case( iRegNum )
			REG0: oSrcData = iWB_Reg0;
			REG1: oSrcData = iWB_Reg1;
			REG2: oSrcData = iWB_Reg2;
			REG3: oSrcData = iWB_Reg3;
			REG4: oSrcData = iWB_Reg4;
			REG5: oSrcData = iWB_Reg5;
			REG6: oSrcData = iWB_Reg6;
			REG7: oSrcData = iWB_Reg7;
			default: oSrcData = tDATA_W'bx;
		endcase
	end
endmodule

module SrcRegJmpData(
	input	tREG	iRegNum;
	
	#ifndef JMP_R7ONLY
	input	tDATA	iWB_Reg0;		// registers
	input	tDATA	iWB_Reg1;
	input	tDATA	iWB_Reg2;
	input	tDATA	iWB_Reg3;
	input	tDATA	iWB_Reg4;
	input	tDATA	iWB_Reg5;
	input	tDATA	iWB_Reg6;
	#endif
	input	tDATA	iWB_Reg7;
	
	input	tDATA	iMA_wWBData;
	input	tREG	iMA_wWBReg;
	input			iMA_wWBEnb;
	
	input	tDATA	iWB_wWBData;
	input	tREG	iWB_wWBReg;
	input			iWB_wWBEnb;
	
	outreg	tADDRI	oSrcData;
);

	always@(
		iRegNum or
		
		iWB_Reg7 or
		
	#ifndef JMP_R7ONLY
		iWB_Reg0 or	iWB_Reg1 or
		iWB_Reg4 or
		
	 #ifndef JMP_RADR_ONLY
		iWB_Reg2 or	iWB_Reg3 or
		iWB_Reg5 or	iWB_Reg6 or
	 #endif
	#endif
		
		iMA_wWBData	or iMA_wWBReg or iMA_wWBEnb or
		iWB_wWBData	or iWB_wWBReg or iWB_wWBEnb
	) begin
		if	   ( iMA_wWBEnb && iRegNum == iMA_wWBReg ) oSrcData = iMA_wWBData;
		else if( iWB_wWBEnb && iRegNum == iWB_wWBReg ) oSrcData = iWB_wWBData;
		else
			#ifdef JMP_R7ONLY
				oSrcData = iWB_Reg7;
			#else
				Case( iRegNum )
					REG0: oSrcData = iWB_Reg0;
					REG1: oSrcData = iWB_Reg1;
					REG4: oSrcData = iWB_Reg4;
					REG7: oSrcData = iWB_Reg7;
				#ifndef JMP_RADR_ONLY
					REG2: oSrcData = iWB_Reg2;
					REG3: oSrcData = iWB_Reg3;
					REG5: oSrcData = iWB_Reg5;
					REG6: oSrcData = iWB_Reg6;
				#endif
					default: oSrcData = tADDRI_W'bx;
				endcase
			#endif
	end
endmodule

module SrcRegDRAM_WBData(
	input	tREG	iRegNum;
	
	input	tDATA	iWB_Reg0;		// registers
	input	tDATA	iWB_Reg1;
	input	tDATA	iWB_Reg2;
	input	tDATA	iWB_Reg3;
	input	tDATA	iWB_Reg4;
	input	tDATA	iWB_Reg5;
	input	tDATA	iWB_Reg6;
	input	tDATA	iWB_Reg7;
	
	input	tDATA	iMA_wWBData;
	input	tREG	iMA_wWBReg;
	input			iMA_wWBEnb;
	
	input	tDATA	iWB_wWBData;
	input	tREG	iWB_wWBReg;
	input			iWB_wWBEnb;
	
	outreg	tDATA	oSrcData;
);

	always@(
		iRegNum or
		
		iWB_Reg0 or	iWB_Reg1 or	iWB_Reg2 or	iWB_Reg3 or
		iWB_Reg4 or	iWB_Reg5 or	iWB_Reg6 or	iWB_Reg7 or
		
		iMA_wWBData	or iMA_wWBReg or iMA_wWBEnb or
		iWB_wWBData	or iWB_wWBReg or iWB_wWBEnb
	) begin
		if	   ( iMA_wWBEnb && iRegNum == iMA_wWBReg ) oSrcData = iMA_wWBData;
		else if( iWB_wWBEnb && iRegNum == iWB_wWBReg ) oSrcData = iWB_wWBData;
		else Case( iRegNum )
			REG0: oSrcData = iWB_Reg0;
			REG1: oSrcData = iWB_Reg1;
			REG2: oSrcData = iWB_Reg2;
			REG3: oSrcData = iWB_Reg3;
			REG4: oSrcData = iWB_Reg4;
			REG5: oSrcData = iWB_Reg5;
			REG6: oSrcData = iWB_Reg6;
			REG7: oSrcData = iWB_Reg7;
			default: oSrcData = tDATA_W'bx;
		endcase
	end
endmodule

/*** ID stage ***************************************************************/

module IDStage(
	// I/O port
	
	input			iClk;			// clock
	input			iRst;			// reset
	
	// pipline latch in
	
	input	tADDRI	iIF_PC;			// PC from IF
	input	tDATA	iIF_IR;			// IR from IF
	input	tDATA	iIF_wIR;		// IR from IF ( wire )
	
	// register in
	
	input	tDATA	iWB_Reg0;		// registers
	input	tDATA	iWB_Reg1;
	input	tDATA	iWB_Reg2;
	input	tDATA	iWB_Reg3;
	input	tDATA	iWB_Reg4;
	input	tDATA	iWB_Reg5;
	input	tDATA	iWB_Reg6;
	input	tDATA	iWB_Reg7;
	
	// src reg bypass in
	
	input	tDATA	iEX_wWBData;
	input	tREG	iEX_wWBReg;
	input			iEX_wWBEnb;
	input			iEX_wDataRdyMA;		// ALUCmd is using adder? or read DRAM?
	#ifdef PIPELINE_ADDER
	input			iEX_wFlagsWE;		// flags WE
	#endif
	
	input	tDATA	iMA_wWBData;
	input	tREG	iMA_wWBReg;
	input			iMA_wWBEnb;
	
	input	tDATA	iWB_wWBData;
	input	tREG	iWB_wWBReg;
	input			iWB_wWBEnb;
	
	// pipeline latch out
	
	outreg	tALUCMD	oID_ALUCmd;		// ALU command
	outreg	tREG	oID_WBReg;		// write back register#
	outreg			oID_WBEnb;		// write back enable
	outreg	tDATA	oID_Opr1;		// ALU operand1
	outreg	tDATA	oID_Opr2;		// ALU operand2
	outreg	tREG	oID_RegNumDRAM_WB;	// Reg# of DataRAM WB Data
	outreg			oID_FlagsWE;	// FlagsReg WE
	
	output			oID_wStall;		// pipeline stall signal
	outreg			oID_DataRdyMA;	// ALUCmd is using adder? or read DRAM?
	
	// DRAM RE / WE
	
	outreg	oID_DRAM_REnb;
	outreg	oID_DRAM_WEnb;
	
	// PC bypass out
	
	output	tADDRI	oID_wPC;		// set PC data to IF ( absolute address )
	output			oID_wSetPC;		// set PC request to IF
	
	// PC & JumpCond to EX
	
	outreg	tADDRI	oID_PC;			// Jump address ( absolute addres )
	outreg	tJCC	oID_JmpCond;	// Jump condition code
);

// reg/wire

wire	tDATA	Imm11,			// 11 --> 16bit sx immediate
				Imm8;			//  8 --> 16bit sx immediate

wire	tDATA	Inst	= iIF_IR;

reg		tALUCMD	ALUCmd;			// ALU command
wire			DataRdyMA;		// ALU Cmd is using adder? or read DRAM?
wire			ALUCmdAdc;		// ALU Cmd is using cy input?
reg		tREG	RegNum1;		// Opr1 reg#
wire	tREG	RegNum2;		// Opr2 reg#
wire	tREG	RegNumDRAM_WB;	// Data RAM WB data

reg				UseRegNum1;		// really used RegNumX for Stall check
reg				UseRegNum2;

wire			DRAM_REnb;		// DRAM read insn?

	/*** Imm sign extender **************************************************/
	
	assign Imm11 = {
		Inst[10],	// 15
		Inst[10],	// 14
		Inst[10],	// 13
		Inst[10],	// 12
		Inst[10],	// 11
		Inst[10:0]	// 10-0
	};
	
	assign Imm8 = {
		Inst[7],	// 15
		Inst[7],	// 14
		Inst[7],	// 13
		Inst[7],	// 12
		Inst[7],	// 11
		Inst[7],	// 10
		Inst[7],	//  9
		Inst[7],	//  8
		Inst[7:0]	//  7-0
	};
	
	/*** pipeline stall detection *******************************************/
	
	assign oID_wStall =
		(
			(
				( iEX_wWBReg == RegNum1	&& UseRegNum1 )	||
				( iEX_wWBReg == RegNum2	&& UseRegNum2 )
			) && iEX_wWBEnb && iEX_wDataRdyMA
	  #ifdef PIPELINE_ADDER
		) || (
			// Flags R.A.W
			ALUCmdAdc && iEX_wFlagsWE
	  #endif
		);
	
	#define NonStall	!oID_wStall
	
	/*** ALU cmd ************************************************************/
	
	#ifdef PIPELINE_ADDER
		
		// ALUCmd is ADD - XOR ?
		wire	UseALUCmd = ( Inst[15:14] == 2'b10 || { Inst[15:11], Inst[7] } == 6'b111100 );
		
		// ALUCmd is ADD - SBB, or reading DRAM?
		assign DataRdyMA = (( ALUCmd[2] == 1'b0 ) && UseALUCmd ) || DRAM_REnb;
		
		// ALUCmd is ADC / SBB ?
		assign ALUCmdAdc = ( ALUCmd[2:1] == 2'b01 ) && UseALUCmd;
		
	#else
		// reading DRAM?
		assign DataRdyMA = DRAM_REnb;
	#endif
	
	Register( oID_DataRdyMA, DataRdyMA, 0 );
	
	
	always@( Inst ) begin
		Casex( Inst[15:7] )
			9'b00xxxxxxx,									// mov r,i
			9'b110xxxxxx,									// mov r,[i]/[i],r
			9'b11111xxxx: ALUCmd = ALUCMD_MOV;				// mov, ret, setpc, hlt
			9'b01xxxxxxx: ALUCmd = ALUCMD_ADD;				// mov r,m / m,r
			
			9'b10xxxxxxx,									// add r,i / r,r
			9'b11110xxx0: ALUCmd = ( Inst[10:8] == ALUCMD_MOV )
							? ALUCMD_SUB : { 1'b0, Inst[10:8] };
			
			9'b11110xxx1: ALUCmd = { 1'b1, Inst[10:8] };	// sh r,r
			default:	  ALUCmd = tALUCMD_w'bx;			// others
		endcase
	end
	
	Register( oID_ALUCmd, ALUCmd, tALUCMD_w'd0 );
	
	/*** opr1 / 2 ***********************************************************/
	
	// op1 / 2 reg#
	
	wire	tDATA	RegData1;
	wire	tDATA	RegData2;
	reg		tREG	wRegNum1;
	wire	tDATA	PreIDInst;
	
	always@( PreIDInst ) begin
		Casex( PreIDInst[15:7] )
			9'b01xxxxxxx: wRegNum1 = { PreIDInst[9], 1'b0, PreIDInst[8] };	// mm addr's base reg
			9'b10xxxxxxx,													// add r,i
			9'b110xxxxxx: wRegNum1 = PreIDInst[13:11];						// mov [i],r
			9'b11110xxx0: wRegNum1 = PreIDInst[5:3];						// add r,r
			9'b11110xxx1,													// sh  r,r
			9'b11111xxxx: wRegNum1 = PreIDInst[2:0];						// mov r,r
			default:	  wRegNum1 = tREG_w'bx;
		endcase
	end
	
	#ifdef PREID_REGNUM1
		assign PreIDInst = iIF_wIR;
		RegisterWE( RegNum1, wRegNum1, !oID_wStall, 0 );
	#else
		assign PreIDInst = iIF_IR;
		always@( wRegNum1 ) RegNum1 = wRegNum1;
	#endif
	
	assign RegNum2		 = Inst[2:0];
	assign RegNumDRAM_WB = Inst[13:11];
	Register( oID_RegNumDRAM_WB, RegNumDRAM_WB, 0 );
	
	
	// op1 / 2
	
	instance SrcRegData SrcRegData1 * (
		iRegNum		RegNum1			W
		oSrcData	RegData1		W
		(.*)		$1
	);
	
	instance SrcRegData SrcRegData2 * (
		iRegNum		RegNum2			W
		oSrcData	RegData2		W
		(.*)		$1
	);
	
	// op1 / 2 data reg
	
	DefineReg begin
		if( iRst )	oID_Opr1 <= 0;
		else Casex( Inst[15:10] )
			6'b00xxxx,										// mov r,i
			6'b110xxx: oID_Opr1 <= Imm11;					// mov r,[i]/[i],r
			6'b01xxxx,										// mm base reg
			6'b10xxxx,										// add r,i
			6'b11110x,										// add/sh r,r
			6'b111110: oID_Opr1 <= RegData1;				// mov r,r
			6'b111111: oID_Opr1 <= ExpandPC( iIF_PC );		// spc
			default:   oID_Opr1 <= tDATA_W'bx;
		endcase
	end
	
	DefineReg begin
		if( iRst )	oID_Opr2 <= 0;
		else Casex( Inst[15:14] )
			2'b01,							// mm index imm
			2'b10:  oID_Opr2 <= Imm8;		// add r,i
			2'b11:  oID_Opr2 <= RegData2;	// add/sh r,r
			default:oID_Opr2 <= tDATA_W'bx;
		endcase
	end
	
	// really used RegNumX etc... ?
	
	always@( Inst[15:10] ) begin
		Casex( Inst[15:10] )
			6'b01xxxx,					// mm addr's base reg
			6'b10xxxx,					// add r,i
			6'b110xx1,					// mov [i],r
			6'b11110x,					// add/sh r,r
			6'b111110: UseRegNum1 = 1;	// mov r,r / jmp r
			default:   UseRegNum1 = 0;
		endcase
	end
	
	always@( Inst[15:10] ) begin
		Casex( Inst[15:10] )
			6'b11110x,					// add/sh r,r
			6'b111110: UseRegNum2 = 1;	// mov r,r / jmp r
			default:   UseRegNum2 = 0;
		endcase
	end
	
	/*** WBReg / WBEnb ******************************************************/
	
	DefineReg begin
		if( iRst ) oID_WBReg <= 0;
		else Casex( Inst[15:13] )
			3'b0xx,
			3'b10x,										// mov r,i/m,r/r,m
			3'b110: oID_WBReg <= Inst[13:11];			// mov r,[i]
			3'b111: oID_WBReg <= Inst[5:3];				// opc r,r
			default:oID_WBReg <= tREG_w'bx;
		endcase
	end
	
	DefineReg begin
		if( iRst ) oID_WBEnb <= 0;
		else Casex( Inst[15:7] )
			9'b10xxxxxxx,							// add
			9'b11110xxx0: oID_WBEnb <= ( Inst[10:8] != ALUCMD_MOV && NonStall );
			
			9'b00xxxxxxx,							// mov r,i
			9'b01xxx0xxx,							// mov r,m
			9'b110xx0xxx,							// mov r,[i]
			9'b11110xxx1,							// sh
			9'b1111100xx,							// mov r,r
			9'b1111110xx: oID_WBEnb <= NonStall;	// spc
			default:	  oID_WBEnb <= 0;
		endcase
	end
	
	/*** FlagsWE ************************************************************/
	
	// add / sh
	DefineReg begin
		if( iRst )	oID_FlagsWE <= 0;
		else oID_FlagsWE <= NonStall && (
				Inst[15:11] == 5'b11110 ||	// add/sh r,r
				Inst[15:14] == 2'b10	);	// add r,i
	end
	
	/*** DRAM RE / WE *******************************************************/
	
	wire	DRAM_Access	= ( Inst[15:14] == 2'b01 || Inst[15:13] == 3'b110 )
							&& NonStall;
	assign	DRAM_REnb	= DRAM_Access && ~Inst[10];
	
	DefineReg begin
		if( iRst ) begin
			oID_DRAM_REnb <= 0;
			oID_DRAM_WEnb <= 0;
		end else begin
			// mov r,m[i]
			oID_DRAM_REnb <= DRAM_REnb;
			
			// mov m[i],r
			oID_DRAM_WEnb <= DRAM_Access && Inst[10];
		end
	end
	
	/*** JMP insn check *****************************************************/
	
	wire	tADDRI	RegJmpAddr;		// register stored jmp address
	wire			RegJmpInsn;		// register jmp insn?
	
	instance SrcRegJmpData SrcRegJmpData * (
		iRegNum		Inst[2:0]		W
		oSrcData	RegJmpAddr		W
		(.*)		$1
	);
	
	assign RegJmpInsn	= ( Inst[15:9] == 7'b1111101 );
	assign oID_wPC		= RegJmpInsn ? RegJmpAddr : ( iIF_PC + Imm11 );
	assign oID_wSetPC	= ( Inst[15:9] == 7'b1110111 || RegJmpInsn );
	
	Register( oID_PC, ( iIF_PC + Imm8 ), 0 );
	
	// Jump Cond
	
	Register(
		oID_JmpCond,
		( Inst[15:12] == 4'b1110 && Inst[11:9] != 3'b111 && NonStall )
			? Inst[11:8] : JCC_NOP,
		JCC_NOP
	);
	
endmodule

/*** EX stage ***************************************************************/

module EXStage(
	input			iClk;			// clock
	input			iRst;			// reset
	
	input	tALUCMD	iID_ALUCmd;		// ALU command
	input			iID_DataRdyMA;	// ALU is using adder? or read DRAM?
	input	tDATA	iID_Opr1;		// ALU operand1
	input	tDATA	iID_Opr2;		// ALU operand2
	input			iID_FlagsWE;	// Flags WE
	
	input	tREG	iID_WBReg;		// WB reg#
	input			iID_WBEnb;		// WB enable
	input			iID_DRAM_REnb;	// data RAM Read Enb
	input			iID_DRAM_WEnb;	// data RAM Write Enb
	input	tREG	iID_RegNumDRAM_WB;	// Reg# of DRAM WB data
	
	input	tADDRI	iID_PC;
	input	tJCC	iID_JmpCond;	// jump conditon code
	input			iID_wStall;		// pipeline stall?
	
	// register in
	
	input	tDATA	iWB_Reg0;		// registers
	input	tDATA	iWB_Reg1;
	input	tDATA	iWB_Reg2;
	input	tDATA	iWB_Reg3;
	input	tDATA	iWB_Reg4;
	input	tDATA	iWB_Reg5;
	input	tDATA	iWB_Reg6;
	input	tDATA	iWB_Reg7;
	
	// src reg bypass in
	
	input	tDATA	iMA_wWBData;
	input	tREG	iMA_wWBReg;
	input			iMA_wWBEnb;
	
	input	tDATA	iWB_wWBData;
	input	tREG	iWB_wWBReg;
	input			iWB_wWBEnb;
	
	//////////////////////////////////
	
	outreg	tDATA	oEX_Result;		// ALU result
	outreg	tREG	oEX_WBReg;		// WB reg#
	outreg			oEX_WBEnb;		// WB enable
	#ifdef PIPELINE_ADDER
	output	tDATA	oEX_wResult2;	// 1+2 stage ALU result
	#endif
	
	output	tDATA	oEX_wWBData;	// ALU result ( == wResult )
	output	tREG	oEX_wWBReg;		// WB reg#
	output			oEX_wWBEnb;		// WB enable wire
	output			oEX_wDataRdyMA;	// ALUCmd is using adder? or read DRAM?
	#ifdef PIPELINE_ADDER
	output			oEX_wFlagsWE;	// flags WE
	#endif
	
	outreg	tDATA	oEX_DRAM_DataO;	// ALU result ( wire? / reg? )
	#ifdef PIPELINE_ADDER
	outreg	tADDRD	oEX_DRAM_Addr;	// ALU result ( reg )
	#else
	output	tADDRD	oEX_DRAM_Addr;	// ALU result ( wire )
	#endif
	outreg			oEX_DRAM_REnb;	// data RAM Read Enb
	outreg			oEX_DRAM_WEnb;	// data RAM Write Enb
	
	output	tADDRI	oEX_wPC;		// Jmp addr to IF
	output			oEX_wSetPC;		// Jmp request to IF
	
	/// PIO / ExtBord IOrequest //////
	
	#ifdef PIO_MODE
	outreg			oEX_PIO_REnb;		// PIO RE
	outreg			oEX_PIO_WEnb;		// PIO WE
	#endif
	
	#ifdef PUSH_SW
	outreg			oEX_ExtB_REnb;		// ExtBord RE ( SW )
	#endif
	
	#ifdef LED_MATRIX
	outreg			oEX_ExtB_WEnb;		// ExtBord WE ( LED )
	#endif
);

// wire / reg
reg				FlagRegO,		// Flagss
				FlagRegS,
				FlagRegZ,
				FlagRegC;

	/*** 2stage pipeline adder **********************************************/
	
	reg		tDATA	wResult;
	wire	tDATA	AddResult;
	
	#ifndef PIPELINE_ADDER
		wire			AddCout,
						AddOout;
	#endif
	
	reg		tDATA	AddOp1,
					AddOp2;
	reg				AddCin;
	reg				CyInv;
	
	reg				FlagO,
					FlagC;
	wire			FlagS,
					FlagZ;
	
	#ifdef PIPELINE_ADDER
		
		reg				DataRdyMA2;		// 2nd stage iID_DataRdyMA
		reg		[5:0]	AddOp1Reg,		// AddOp1 High-6bit
						AddOp2Reg;		// AddOp2 High-6bit
		wire	[9:0]	AddResultLw;	// 1st stage adder result ( wire )
		reg		[9:0]	AddResultL;		// ~~~~~~~~~~~~~~~~~~~~~~ ( reg )
		wire	[5:0]	AddResultHw;	// 2nd stage adder result ( wire )
		
		wire	tDATA	AddResult2;		// 1+2 stage adder result
		wire			AddCout2,		// 1+2 stage cy out
						AddOout2;		// 1+2 stage ov out
		
		wire			HalfCyOut;		// 1st stage cy out ( wire )
		reg				HalfCy;			// ~~~~~~~~~~~~~~~~ ( reg )
		reg				HalfCyInv;		// cy out invert request
		
		reg				HalfFlagC,		// 1st stage ALU's cy out
						HalfFlagO;		// 1st stage ALU's ov out
		
		assign AddResult  = { 6'b0, AddResultLw };
		assign AddResult2 = { AddResultHw, AddResultL };
		
		Register( DataRdyMA2, iID_DataRdyMA, 0 );
		Register( AddOp1Reg,  AddOp1[15:10], 0 );
		Register( AddOp2Reg,  AddOp2[15:10], 0 );
		Register( AddResultL, AddResultLw,	 0 );
		Register( HalfCy,	  HalfCyOut,	 0 );
		Register( HalfCyInv,  CyInv,		 0 );
		
		Register( HalfFlagC,  FlagC,   0 );
		Register( HalfFlagO,  FlagO,   0 );
		
		instance ADDER10 * ADDER10.v (
			dataa		AddOp1[9:0]		W
			datab		AddOp2[9:0]		W
			cin			AddCin			W
			result		AddResultLw		W
			cout		HalfCyOut		W
		);
		
		instance ADDER6 * ADDER6.v (
			dataa		AddOp1Reg		W
			datab		AddOp2Reg		W
			cin			HalfCy			W
			result		AddResultHw		W
			cout		AddCout2		W
			overflow	AddOout2		W
		);
		
	#elif defined USE_ADDER_MACRO
	/*** normal adder *******************************************************/
		
		instance ADDER * ADDER.v (
			dataa		AddOp1			W
			datab		AddOp2			W
			cin			AddCin			W
			result		AddResult		W
			cout		AddCout			W
			overflow	AddOout			W
		);
	#else
		assign { AddCout, AddResult } = AddOp1 + AddOp2 + AddCin;
		assign AddOout = ( AddOp1[15] == AddOp2[15] && AddOp1[15] != AddResult[15] );
	#endif
	
	/*** 1st stage ALU ******************************************************/
	
	always@(
		iID_Opr1 or iID_Opr2 or iID_ALUCmd or FlagRegC or AddResult
		#ifndef PIPELINE_ADDER
		or AddCout or AddOout
		#endif
	) begin
		
		AddOp1	= iID_Opr1;
		AddOp2	= tDATA_W'bx;
		AddCin	= 1'bx;
		CyInv	= 1'bx;
		
		FlagC	= 1'bx;
		FlagO	= 1'bx;
		
		Case( iID_ALUCmd )
			ALUCMD_ADD,
			ALUCMD_ADC,
			ALUCMD_SUB,
			ALUCMD_SBB: begin
				
				Case( iID_ALUCmd )
					ALUCMD_SUB, ALUCMD_SBB: { CyInv, AddOp2 } = { 1'b1, ~iID_Opr2 };
					default:				{ CyInv, AddOp2 } = { 1'b0,  iID_Opr2 };
				endcase
				
				Case( iID_ALUCmd )
					ALUCMD_ADC: AddCin = FlagRegC;
					ALUCMD_SUB: AddCin = 1;
					ALUCMD_SBB: AddCin = ~FlagRegC;
					default:	AddCin = 0;
				endcase
				
				#ifdef PIPELINE_ADDER
					wResult = tDATA_W'bx;
				#else
					wResult = AddResult;
					FlagC	= AddCout ^ CyInv;
					FlagO	= AddOout;
				#endif
			end
			
			ALUCMD_AND:	begin
				wResult = iID_Opr1 & iID_Opr2;
				FlagC	= 0;
				FlagO	= 0;
			end
			
			ALUCMD_OR:	begin
				wResult = iID_Opr1 | iID_Opr2;
				FlagC	= 0;
				FlagO	= 0;
			end
			
			ALUCMD_XOR: begin
				wResult = iID_Opr1 ^ iID_Opr2;
				FlagC	= 0;
				FlagO	= 0;
			end
			
			ALUCMD_SHL:	begin
				wResult = iID_Opr1 << 1;
				FlagC	= iID_Opr1[15];
				FlagO	= ( iID_Opr1[15] != iID_Opr1[14] );
			end
			
			ALUCMD_SHR:	begin
				wResult = { 1'b0, iID_Opr1[15:1] };
				FlagC	= iID_Opr1[0];
				FlagO	= 0;
			end
			
			ALUCMD_SAR:	begin
				wResult = { iID_Opr1[15], iID_Opr1[15:1] };
				FlagC	= iID_Opr1[0];
				FlagO	= 0;
			end
			
			ALUCMD_SWP:	begin
				wResult = { iID_Opr1[7:0], iID_Opr1[15:8] };
				FlagC	= iID_Opr1[0];
				FlagO	= 0;
			end
			
			ALUCMD_MOV:	begin
				wResult = iID_Opr1;
				FlagC	= 0;
				FlagO	= 0;
			end
			
			default:	begin
				wResult = tDATA_W'bx;
			end
		endcase
	end
	
	Register( oEX_Result, wResult, tDATA_W'd0 );
	
	#ifdef PIPELINE_ADDER
	/*** 2nd stage ALU result ***********************************************/
	
	assign oEX_wResult2 = DataRdyMA2 ? AddResult2 : oEX_Result;
	
	/*** Flag reg for PIPELINE_ADDER ****************************************/
	
	wire	FlagO2,
			FlagC2;
	
	reg		FlagsWE2;
	
	assign FlagO2 = DataRdyMA2 ? AddOout2 : HalfFlagO;
	assign FlagS  = oEX_wResult2[15];
	assign FlagZ  = ( oEX_wResult2[15:0] == tDATA_W'd0 );
	assign FlagC2 = DataRdyMA2 ? AddCout2 ^ HalfCyInv : HalfFlagC;
	
	Register( FlagsWE2, iID_FlagsWE, 0 );
	
	 DefineReg
	 	if( iRst )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <= 4'b0;
	 	else if( FlagsWE2 )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <=
	 										{ FlagO2, FlagS, FlagZ, FlagC2 };
	
	#else
	
	/*** Flag reg for normal adder ******************************************/
	
	assign FlagS = wResult[15];
	assign FlagZ = ( wResult[15:0] == tDATA_W'd0 );
	
	 DefineReg
	 	if( iRst )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <= 4'b0;
	 	else if( iID_FlagsWE )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <=
	 										{ FlagO, FlagS, FlagZ, FlagC };
	#endif
	
	/*** Jmp condition check ************************************************/
	
	reg				JmpRequest;
	reg		tADDRI	JmpAddr;
	reg		tJCC	JmpCond;
	
	// flag used for CC check
	wire			JccFlagO,
					JccFlagS,
					JccFlagZ,
					JccFlagC;
	
	RegisterWE( JmpAddr, iID_PC,      !iID_wStall, 0 );
	RegisterWE( JmpCond, iID_JmpCond, !iID_wStall, JCC_NOP );
	
	#if defined FAST_JCC && defined PIPELINE_ADDER
		assign JccFlagO = FlagsWE2 ? FlagO : FlagRegO;
		assign JccFlagS = FlagsWE2 ? FlagS : FlagRegS;
		assign JccFlagZ = FlagsWE2 ? FlagZ : FlagRegZ;
		assign JccFlagC = FlagsWE2 ? FlagC : FlagRegC;
	#else
		assign JccFlagO = FlagRegO;
		assign JccFlagS = FlagRegS;
		assign JccFlagZ = FlagRegZ;
		assign JccFlagC = FlagRegC;
	#endif
	
	always@( JmpCond or JccFlagO or JccFlagS or JccFlagZ or JccFlagC ) begin
		Case( JmpCond )
			JCC_Z,	JCC_NZ:	JmpRequest = JccFlagZ;
			JCC_S,	JCC_NS:	JmpRequest = JccFlagS;
			JCC_O,	JCC_NO:	JmpRequest = JccFlagO;
			JCC_C,	JCC_NC:	JmpRequest = JccFlagC;
			JCC_BE,	JCC_A:	JmpRequest = JccFlagC | JccFlagZ;
			JCC_L,	JCC_GE:	JmpRequest = ( JccFlagS != JccFlagO );
			JCC_LE,	JCC_G:	JmpRequest = ( JccFlagS != JccFlagO ) | JccFlagZ;
			default:		JmpRequest = 0;
		endcase
	end
	
	assign oEX_wPC		= JmpAddr;
	assign oEX_wSetPC	= JmpRequest ^ JmpCond[ 0 ];
	
	/*** DRAM addr / ctrl / data ********************************************/
	/* iID_ALUCmd[ 0 ] means ( iID_ALUCMD == ALUCMD_MOV ) */
	
	wire	tDATA	DRAM_WBData;
	
	instance SrcRegDRAM_WBData SrcRegDRAM_WBData * (
		iRegNum		iID_RegNumDRAM_WB
		oSrcData	DRAM_WBData
		(.*)		$1
	);
	
	#ifdef PIPELINE_ADDER
		Register( oEX_DRAM_Addr, ( iID_ALUCmd[ 0 ] ? wResult : AddResult ), 0 );
	#else
		assign oEX_DRAM_Addr = oEX_Result;
	#endif
	
	Register( oEX_DRAM_DataO,	DRAM_WBData  ,	0 );
	
	#ifdef PIO_MODE
	/*** Port I/O RE/WE *****************************************************/
	
	Register( oEX_PIO_REnb, IsPIOAddr( iID_Opr1 ) & iID_DRAM_REnb, 0 );
	Register( oEX_PIO_WEnb, IsPIOAddr( iID_Opr1 ) & iID_DRAM_WEnb, 0 );
	#endif
	
	/*** ExtBord I/O RE/WE **************************************************/
	
	#ifdef PUSH_SW
		Register( oEX_ExtB_REnb, IsExtAddr( iID_Opr1 ) & iID_DRAM_REnb, 0 );
	#endif
	
	#ifdef LED_MATRIX
		Register( oEX_ExtB_WEnb, IsExtAddr( iID_Opr1 ) & iID_DRAM_WEnb, 0 );
	#endif
	
	/*** DRAM RE/WE *********************************************************/
	
	#if defined PIO_MODE || defined PUSH_SW
		Register( oEX_DRAM_REnb, iID_DRAM_REnb & IsDRAMAddr( iID_Opr1 ), 0 );
	#else
		Register( oEX_DRAM_REnb, iID_DRAM_REnb, 0 );
	#endif
	
	#if defined PIO_MODE || defined LED_MATRIX
		Register( oEX_DRAM_WEnb, iID_DRAM_WEnb & IsDRAMAddr( iID_Opr1 ), 0 );
	#else
		Register( oEX_DRAM_WEnb, iID_DRAM_WEnb, 0 );
	#endif
	
	/*** other latch ********************************************************/
	
	Register( oEX_WBReg, iID_WBReg, tREG_w'd0 );
	Register( oEX_WBEnb, iID_WBEnb, 0 );
	
	assign oEX_wWBData		= wResult;
	assign oEX_wWBReg		= iID_WBReg;
	assign oEX_wWBEnb		= iID_WBEnb;
	assign oEX_wDataRdyMA	= iID_DataRdyMA;
	#ifdef PIPELINE_ADDER
	assign oEX_wFlagsWE		= iID_FlagsWE;
	#endif
	
endmodule

/*** MA stage ***************************************************************/

module MAStage(
	input			iClk;			// clock
	input			iRst;			// reset
	
	input	tDATA	iEX_Result;		// ALU result
	#ifdef PIPELINE_ADDER
	input	tDATA	iEX_wResult2;	// 1+2 stage ALU result
	#endif
	input	tREG	iEX_WBReg;		// WB reg#
	input			iEX_WBEnb;		// WB enable
	input			iEX_DRAM_REnb;	// data RAM Read Enb
	
	input	tDATA	iDRAM_DataI;	// data from Data RAM
	
	#ifdef PIO_MODE
	input	tDATA	iPIO_DataI;		// data from PIO
	input			iEX_PIO_REnb;	// PIO REnb
	#endif
	
	#ifdef PUSH_SW
	input	tDATA	iExtB_DataI;	// data from ExtBoard InputSW
	input			iEX_ExtB_REnb;	// InputSW REnb
	#endif
	
	outreg	tDATA	oMA_WBData;		// WB data
	outreg	tREG	oMA_WBReg;		// WB reg#
	outreg			oMA_WBEnb;		// WB enable
	
	output	tDATA	oMA_wWBData;	// WB data
	output	tREG	oMA_wWBReg;		// WB reg#
	output			oMA_wWBEnb;		// WB enable
);

	Register( oMA_WBData, oMA_wWBData, 0 );
	Register( oMA_WBReg,  iEX_WBReg,   tREG_w'd0 );
	Register( oMA_WBEnb,  iEX_WBEnb,   0 );
	
	/*** data source selector ***********************************************/
	
	assign oMA_wWBData =
					( iEX_DRAM_REnb	) ? iDRAM_DataI	:
				
				#ifdef PIO_MODE
					( iEX_PIO_REnb	) ? iPIO_DataI	:
				#endif
				
				#ifdef PUSH_SW
					( iEX_ExtB_REnb	) ? iExtB_DataI	:
				#endif
				
				#ifdef PIPELINE_ADDER
										iEX_wResult2;
				#else
										iEX_Result;
				#endif
	
	/************************************************************************/
	
	assign oMA_wWBReg	= iEX_WBReg;
	assign oMA_wWBEnb	= iEX_WBEnb;
	
endmodule

/*** WB stage ***************************************************************/

module WBStage(
	input			iClk;			// clock
	input			iRst;			// reset
	
	input	tDATA	iMA_WBData;		// WB data
	input	tREG	iMA_WBReg;		// WB reg#
	input			iMA_WBEnb;		// WB enable
	
	outreg	tDATA	oWB_Reg0;		// registers
	outreg	tDATA	oWB_Reg1;
	outreg	tDATA	oWB_Reg2;
	outreg	tDATA	oWB_Reg3;
	outreg	tDATA	oWB_Reg4;
	outreg	tDATA	oWB_Reg5;
	outreg	tDATA	oWB_Reg6;
	outreg	tDATA	oWB_Reg7;
	
	output	tDATA	oWB_wWBData;	// WB data
	output	tREG	oWB_wWBReg;		// WB reg#
	output			oWB_wWBEnb;		// WB enable
);

	DefineReg begin
		if( iRst ) begin
			oWB_Reg0 <= tDATA_W'd0;
			oWB_Reg1 <= tDATA_W'd0;
			oWB_Reg2 <= tDATA_W'd0;
			oWB_Reg3 <= tDATA_W'd0;
			oWB_Reg4 <= tDATA_W'd0;
			oWB_Reg5 <= tDATA_W'd0;
			oWB_Reg6 <= tDATA_W'd0;
			oWB_Reg7 <= tDATA_W'd0;
			
		end else if( iMA_WBEnb ) Case( iMA_WBReg )
			REG0: oWB_Reg0 <= iMA_WBData;
			REG1: oWB_Reg1 <= iMA_WBData;
			REG2: oWB_Reg2 <= iMA_WBData;
			REG3: oWB_Reg3 <= iMA_WBData;
			REG4: oWB_Reg4 <= iMA_WBData;
			REG5: oWB_Reg5 <= iMA_WBData;
			REG6: oWB_Reg6 <= iMA_WBData;
			REG7: oWB_Reg7 <= iMA_WBData;
		endcase
	end
	
	assign oWB_wWBData	= iMA_WBData;
	assign oWB_wWBReg	= iMA_WBReg;
	assign oWB_wWBEnb	= iMA_WBEnb;

endmodule

/*** STORM core module ******************************************************/

module STORM_CORE(
	input			iClk;			// clock
	input			iRst;			// reset
	
	output	[8:0]	oData7Seg;		// display 7seg data
	output	[7:0]	oDataLED;		// display 8bit LED data
	
	input	tDATA	iIRAM_Data;
	output	tADDRI	oIRAM_Addr;
	input	tDATA	iDRAM_DataI;
	output	tDATA	oDRAM_DataO;
	output	tADDRD	oDRAM_Addr;
	output			oDRAM_REnb;
	output			oDRAM_WEnb;
	
	#ifdef PIO_MODE
	input	tDATA	iPIO_DataI;		// PIO data in
	output			oPIO_REnb;		// PIO RE
	output			oPIO_WEnb;		// PIO WE
	#endif
	
	#ifdef PUSH_SW
	input	tDATA	iExtB_DataI;
	output			oExtB_REnb;		// ExtBord RE ( SW )
	#endif
	
	#ifdef LED_MATRIX
	output			oExtB_WEnb;		// ExtBord WE ( LED )
	#endif
);

	assign oData7Seg = WB_Reg0[8:0];
	assign oDataLED  = WB_Reg1[7:0];
	
	instance IFStage * * (
		iClk				iClk
		iRst				iRst
		(iIRAM_Data)		$1
		oIF_IRAM_Addr		oIRAM_Addr
	);
	
	instance IDStage * * (
		iClk				iClk
		iRst				iRst
	);
	
	instance EXStage * * (
		iClk				iClk
		iRst				iRst
		oEX_DRAM_DataO		oDRAM_DataO
		oEX_DRAM_Addr		oDRAM_Addr
		oEX_(.*_WEnb)		o$1
	);
	
	assign oDRAM_REnb = EX_DRAM_REnb;
	
	#ifdef PIO_MODE
	assign oPIO_REnb = EX_PIO_REnb;		// PIO RE
	#endif
	
	#ifdef PUSH_SW
	assign oExtB_REnb = EX_ExtB_REnb;	// ExtBord RE ( SW )
	#endif
	
	instance MAStage * * (
		iClk				iClk
		iRst				iRst
		(i.*DataI)			$1
	);
	
	instance WBStage * * (
		iClk				iClk
		iRst				iRst
	);
	
endmodule

/*** 7seg decoder ***********************************************************/

module Seg7Decode(
	input	[3:0]	iData;
	outreg	[6:0]	oSegData;
);
	always@( iData ) begin
		Case( iData )		 // GFEDCBA
			4'h0: oSegData = 7'b1000000;
			4'h1: oSegData = 7'b1111001;
			4'h2: oSegData = 7'b0100100;
			4'h3: oSegData = 7'b0110000;
			4'h4: oSegData = 7'b0011001;
			4'h5: oSegData = 7'b0010010;
			4'h6: oSegData = 7'b0000010;
			4'h7: oSegData = 7'b1011000;
			4'h8: oSegData = 7'b0000000;
			4'h9: oSegData = 7'b0010000;
			4'hA: oSegData = 7'b0001000;
			4'hB: oSegData = 7'b0000011;
			4'hC: oSegData = 7'b1000110;
			4'hD: oSegData = 7'b0100001;
			4'hE: oSegData = 7'b0000110;
			4'hF: oSegData = 7'b0001110;
			default:oSegData = 7'bx;
		endcase
	end
endmodule

/*** STORM + RAM + others ***************************************************/

module STORM(
	input			iClk;			// clock
	input			iRst;			// reset ( High active )
	
	output	[6:0]	oData7Seg0,		// 7seg display data
					oData7Seg1;
	output			oData7SegP;		// 7seg 0's dp
	output	[7:0]	oDataLED;		// 8bit LED data
	
	#ifdef PIO_MODE
	// PIO module I/O
	
	input	[3:0]	iPData;		// mc
	input	[4:0]	iCtrl;		// ms
	output	[7:0]	oPData;		// md
	
	#endif
	
	#ifdef LED_MATRIX
	// LED Matrix/Beep I/O
	
	output	[9:0]	oLED_Data;		// 1line data
	output	[19:0]	oLED_LineSel;	// line select
	output			oLED_Beep;		// Beep SP
	#endif
	
	#ifdef PUSH_SW
	// Push/Dip SW
	
	input	[7:0]	iPushSW;
	input	[7:0]	iDipSW;
	#endif
);
	#ifdef PIO_MODE
	wire			DRAM_WEnb;
	#endif
	
	/*** Delayed Data RAM WEnb **********************************************/
	
	wire	DRAM_WEnbDly;
	
	LCELL	LCELL0( iClk, DlyClk0 );
	LCELL	LCELL1( DlyClk0, DlyClk1 );
	LCELL	LCELL2( DlyClk1, DlyClk2 );
	
	assign DRAM_WEnbDly = DlyClk2 & DRAM_WEnb;
	
	/*** CORE ***************************************************************/
	
	instance STORM_CORE * *(
		iClk				iClk
		iRst				iRst
		oDRAM_WEnb								W
		oDRAM_REnb								W
		oDataLED								W
	);
	
	/*** 7seg decoder & LED *************************************************/
	
	instance Seg7Decode Seg7_0 * (
		iData		Data7Seg[7:4]
		oSegData	oData7Seg0
	);
	
	instance Seg7Decode Seg7_1 * (
		iData		Data7Seg[3:0]
		oSegData	oData7Seg1
	);
	
	assign oData7SegP	= ~Data7Seg[8];
	assign oDataLED		= ~DataLED;
	
	/*** RAM ****************************************************************/
	
	instance IRAM * IRAM.v (
		q			IRAM_Data
		address		IRAM_Addr
	);
	
	instance DRAM * DRAM.v(
		we			DRAM_WEnbDly
		q			DRAM_DataI
		data		DRAM_DataO
		address		DRAM_Addr
	);
	
	/*** parallel I/O module ************************************************/
	
	#ifdef PIO_MODE
	instance PIO * * (
		iClk			iClk
		iRst			iRst
		iAddr			DRAM_Addr
		iData			DRAM_DataO
		iREnb			PIO_REnb
		iWEnb			PIO_WEnb
		oData			PIO_DataI
		([io]PData)		$1				O
		(iCtrl)			$1				O
	);
	#endif
	
	/*** LED Matrix/Beep module *********************************************/
	
	#ifdef LED_MATRIX
	instance LEDMatrix * * (
		iAddr			DRAM_Addr
		iData			DRAM_DataO
		iWEnb			ExtB_WEnb
		(.*)			$1
	);
	#endif
	
	/*** Push/Dip SW module *************************************************/
	
	#ifdef PUSH_SW
	
	instance InputSW * * (
		iClk			iClk
		iRst			iRst
		iAddr			DRAM_Addr
		iREnb			ExtB_REnb
		oData			ExtB_DataI
		(.*)			$1
	);
	#endif
endmodule

/*** other modules **********************************************************/

#ifdef PIO_MODE
 #include "PIO.def.v"
#endif

#include "EXTBoard.def.v"
