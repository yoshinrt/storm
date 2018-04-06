/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		STORM.def.v -- STORM core + RAM + other unit

******************************************************************************

2001.09.21	start STORM2 project

******************************************************************************

30MHz???

*****************************************************************************/

#define USE_ADDER_MACRO		// use adder macro instead of '+' operator
#define PREID_REGNUM1		// decode RegNum1 in IF stage
//#define JMP_R7ONLY		// allow jmp reg only r7
#define JMP_RADR_ONLY		// allow jmp reg only r0, 1, 4, 7
#define OUTPUT_LOG			// output execution log ( for TESTBENCH )

/*** const ******************************************************************/

#define tDATA_W		16
#define tDATA		[15:0]

#define tADDR_W		15
#define tADDR		[14:0]

#define	tVADDR		[8:0]				/* virtual page addr				*/
#define tPADDR		[2:0]				/* real page addr					*/
#define tOADDR		[5:0]				/* offset addr						*/
#define tCADDR		[8:0]				/* cache RAM addr					*/

#define VAddr( x )		( x[15:7] )		/* V-addr to V-page addr#			*/
#define OffsAddr( x )	( x[6:1] )		/* V-addr to offset					*/
#define Page2Addr( x )	{ x, 7'b0 }		/* V-page addr to V-addr			*/

#define AddrToData( x )	{ x, 1'b0 }		/* tADDR --> tDATA					*/
#define DataToAddr( x )	( x[15:1] )		/* tDATA --> tADDR					*/

// page in/out port address

#define PORT_PAGE_IN_I	8'h7C
//#define PORT_PAGE_OUT_I	8'h7D
#define PORT_PAGE_IN_D	8'h7E
#define PORT_PAGE_OUT_D	8'h7F

enum tALUCMD {
	ALUCMD_ADD,
	ALUCMD_SUB,
	ALUCMD_ADC,
	ALUCMD_SBB,
	ALUCMD_AND,
	ALUCMD_MOV,
	ALUCMD_OR,
	ALUCMD_XOR,
	
	ALUCMD_SAR,
	ALUCMD_NEG,		// not impremented (--#
	ALUCMD_SHR,
	ALUCMD_SHL,
	
	ALUCMD_CZX,		// zero extension
	ALUCMD_CSX,		// sign extension
	ALUCMD_PACK,	// byte to word packing
};

enum tREG {
	REG0,
	REG1,
	REG2,
	REG3,
	REG4,
	REG5,
	REG6,
	REG7,
};

enum tJCC {
	JCC_Z,	JCC_NZ
	JCC_S,	JCC_NS,
	JCC_O,	JCC_NO,
	JCC_C,	JCC_NC,
	JCC_BE,	JCC_A,
	JCC_L,	JCC_GE,
	JCC_LE,	JCC_G,
	JCC_NOP,JCC_JMP
};

/*** macros *****************************************************************/

#define DefineReg	always@( posedge Clk or posedge Reset )

#define Register( reg, data, init )	\
			DefineReg if( Reset ) reg <= init; else reg <= data 

#define RegisterWE( reg, data, we, init )	\
			DefineReg if( Reset ) reg <= init; else if( we ) reg <= data 

/*** PF stage ***************************************************************/

module PFStage;

// I/O port

input			Clk;			// clock
input			Reset;			// reset

input	tADDR	iID_wPC;		// set PC data from ID
input			iID_wSetPC;		// set PC request from ID
input	tADDR	iEX_wPC;		// set PC data from EX
input			iEX_wSetPC;		// set PC request from EX

input			iID_wStall;		// pipeline stall

outreg	tADDR	oIF_PC;			// IF stage PC

// wire / reg

wire	tADDR	PC;				// PC
reg		tADDR	RegPC;			// PC register
wire	tADDR	PC_plus1;		// ++RegPC

	/*** IR / PC regisger ***************************************************/
	
	RegisterWE( oIF_IR, iIRAM_Data, !iID_wStall, 0 );
	RegisterWE( oIF_PC, PC_plus1,   !iID_wStall, 0 );
	
	assign oIF_wIR = iIRAM_Data;
	
	/*** PC *****************************************************************/
	
	assign PC_plus1 = RegPC + tADDR_W'd1;
	
	assign PC = iEX_wSetPC ? iEX_wPC	:
				iID_wSetPC ? iID_wPC	:
							 PC_plus1	;
	
	assign oIF_IRAM_Addr = RegPC;
	RegisterWE( RegPC, PC, !iID_wStall, 0 );
	
endmodule

/*** IF stage ***************************************************************/

module IFStage;

// I/O port

input			Clk;			// clock
input			Reset;			// reset

input	tADDR	iID_wPC;		// set PC data from ID
input			iID_wSetPC;		// set PC request from ID

input	tADDR	iEX_wPC;		// set PC data from EX
input			iEX_wSetPC;		// set PC request from EX

input			iID_wStall;		// pipeline stall

output	tADDR	oIF_IRAM_Addr;	// instruction RAM addr
input	tDATA	iIRAM_Data;		// instruction RAM data

outreg	tDATA	oIF_IR;			// IF stage IR
output	tDATA	oIF_wIR;		// IF stage IR ( wire )
outreg	tADDR	oIF_PC;			// IF stage PC

// wire / reg

wire	tADDR	PC;				// PC
reg		tADDR	RegPC;			// PC register
wire	tADDR	PC_plus1;		// ++RegPC

	/*** IR / PC regisger ***************************************************/
	
	RegisterWE( oIF_IR, iIRAM_Data, !iID_wStall, 0 );
	RegisterWE( oIF_PC, PC_plus1,   !iID_wStall, 0 );
	
	assign oIF_wIR = iIRAM_Data;
	
	/*** PC *****************************************************************/
	
	assign PC_plus1 = RegPC + tADDR_W'd1;
	
	assign PC = iEX_wSetPC ? iEX_wPC	:
				iID_wSetPC ? iID_wPC	:
							 PC_plus1	;
	
	assign oIF_IRAM_Addr = RegPC;
	RegisterWE( RegPC, PC, !iID_wStall, 0 );
	
endmodule

/*** get source reg data from RegFiles, Pipeline latch ***********************/

module SrcRegData;

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

module SrcRegJmpData;

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

outreg	tADDR	oSrcData;
	
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
					REG0: oSrcData = DataToAddr( iWB_Reg0 );
					REG1: oSrcData = DataToAddr( iWB_Reg1 );
					REG4: oSrcData = DataToAddr( iWB_Reg4 );
					REG7: oSrcData = DataToAddr( iWB_Reg7 );
				#ifndef JMP_RADR_ONLY
					REG2: oSrcData = DataToAddr( iWB_Reg2 );
					REG3: oSrcData = DataToAddr( iWB_Reg3 );
					REG5: oSrcData = DataToAddr( iWB_Reg5 );
					REG6: oSrcData = DataToAddr( iWB_Reg6 );
				#endif
					default: oSrcData = tADDR_W'bx;
				endcase
			#endif
	end
endmodule

module SrcRegDRAM_WBData;

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

module IDStage;

// I/O port

input			Clk;			// clock
input			Reset;			// reset

// pipline latch in

input	tADDR	iIF_PC;			// PC from IF
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

output	tADDR	oID_wPC;		// set PC data to IF ( absolute address )
output			oID_wSetPC;		// set PC request to IF

// PC & JumpCond to EX

outreg	tADDR	oID_PC;			// Jump address ( absolute addres )
outreg	tJCC	oID_JmpCond;	// Jump condition code

// reg/wire

wire	tDATA	Imm12,			// 12 --> 16bit sx immediate
				Imm11,			// 11 --> 16bit sx immediate
				Imm8,			//  8 --> 16bit sx immediate
				ImmH;			// movh immediate

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
		Inst[10:0]	// 10 - 0
	};
	
	assign Imm12 = {
		Inst[11],	// 15
		Inst[11],	// 14
		Inst[11],	// 13
		Inst[11],	// 12
		Inst[11:0]	// 11 - 0
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
		Inst[7:0]	//  7 - 0
	};
	
	assign ImmH = {
		Inst[11:6],	// 15 - 10
		Inst[2:0],	//  9 -  7
		7'd0		//  6 -  0
	};
	
	/*** pipeline stall detection *******************************************/
	
	assign oID_wStall =
		(
			(
				( iEX_wWBReg == RegNum1	&& UseRegNum1 )	||
				( iEX_wWBReg == RegNum2	&& UseRegNum2 )
			) && iEX_wWBEnb && iEX_wDataRdyMA
		);
	
	#define NonStall	!oID_wStall
	
	/*** ALU cmd ************************************************************/
	
	// reading DRAM?
	assign DataRdyMA = DRAM_REnb;
	
	Register( oID_DataRdyMA, DataRdyMA, 0 );
	
	
	always@( Inst ) begin
		Casex( Inst[15:7] )
			9'b00xxxxxxx,									// mov r,i
			9'b1110xxxxx,									// movh
			9'b11111xxxx: ALUCmd = ALUCMD_MOV;				// mov, ret, setpc, hlt
			9'b01xxxxxxx: ALUCmd = ALUCMD_ADD;				// mov r,m / m,r
			
			9'b10xxxxxxx,									// add r,i / r,r
			9'b11110xxx0: ALUCmd = ( Inst[10:8] == ALUCMD_MOV )
							? ALUCMD_SUB : { 1'b0, Inst[10:8] };
			
			9'b11110xxx1: ALUCmd = { 1'b1, Inst[10:8] };	// sh r,r
			default:	  ALUCmd = tALUCMD_W'bx;			// others
		endcase
	end
	
	Register( oID_ALUCmd, ALUCmd, tALUCMD_W'd0 );
	
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
			9'b11110xxx0,													// add r,r
			9'b1111011x1: wRegNum1 = PreIDInst[5:3];						// pack r,r
			
			9'b1111000x1,													// sh  r,r
			9'b1111001x1,													// sh  r,r
			9'b1111010x1,													// sh  r,r
			9'b11111xxxx: wRegNum1 = PreIDInst[2:0];						// mov r,r
			
			default:	  wRegNum1 = tREG_W'bx;
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
		if( Reset )	oID_Opr1 <= 0;
		else Casex( Inst[15:10] )
			6'b00xxxx: oID_Opr1 <= Imm11;					// mov r,i
			6'b01xxxx,										// mm base reg
			6'b10xxxx,										// add r,i
			6'b11110x,										// add/sh r,r
			6'b111110: oID_Opr1 <= RegData1;				// mov r,r
			6'b1110xx: oID_Opr1 <= ImmH;					// movh
			6'b111111: oID_Opr1 <= AddrToData( iIF_PC );	// spc
			default:   oID_Opr1 <= tDATA_W'bx;
		endcase
	end
	
	DefineReg begin
		if( Reset )	oID_Opr2 <= 0;
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
		if( Reset ) oID_WBReg <= 0;
		else Casex( Inst[15:13] )
			3'b0xx,
			3'b10x: oID_WBReg <= Inst[13:11];			// mov r,i/m,r/r,m
			3'b111: oID_WBReg <= Inst[5:3];				// movh / opc r,r
			default:oID_WBReg <= tREG_W'bx;
		endcase
	end
	
	DefineReg begin
		if( Reset ) oID_WBEnb <= 0;
		else Casex( Inst[15:7] )
			9'b10xxxxxxx,							// add
			9'b11110xxx0: oID_WBEnb <= ( Inst[10:8] != ALUCMD_MOV && NonStall );
			
			9'b00xxxxxxx,							// mov r,i
			9'b01xxx0xxx,							// mov r,m
			9'b1110xxxxx,							// movh
			9'b11110xxx1,							// sh
			9'b1111100xx,							// mov r,r
			9'b1111110xx: oID_WBEnb <= NonStall;	// spc
			default:	  oID_WBEnb <= 0;
		endcase
	end
	
	/*** FlagsWE ************************************************************/
	
	// add / sh
	DefineReg begin
		if( Reset )	oID_FlagsWE <= 0;
		else oID_FlagsWE <= NonStall && (
				Inst[15:11] == 5'b11110 ||	// add/sh r,r
				Inst[15:14] == 2'b10	);	// add r,i
	end
	
	/*** DRAM RE / WE *******************************************************/
	
	wire	DRAM_Access	= Inst[15:14] == 2'b01;
	assign	DRAM_REnb	= DRAM_Access && ~Inst[10] && NonStall;
	
	DefineReg begin
		if( Reset ) begin
			oID_DRAM_REnb <= 0;
			oID_DRAM_WEnb <= 0;
		end else begin
			// mov r,m[i]
			oID_DRAM_REnb <= DRAM_REnb;
			
			// mov m[i],r
			oID_DRAM_WEnb <= DRAM_Access && Inst[10] && NonStall;
		end
	end
	
	/*** JMP insn check *****************************************************/
	
	wire	tADDR	RegJmpAddr;		// register stored jmp address
	wire			RegJmpInsn;		// register jmp insn?
	
	instance SrcRegJmpData SrcRegJmpData * (
		iRegNum		Inst[2:0]		W
		oSrcData	RegJmpAddr		W
		(.*)		$1
	);
	
	assign RegJmpInsn	= ( Inst[15:9] == 7'b1111101 );
	assign oID_wPC		= RegJmpInsn ? RegJmpAddr : ( iIF_PC + Imm12 );
	assign oID_wSetPC	= ( Inst[15:12] == 4'b1100 || RegJmpInsn );
	
	Register( oID_PC, ( iIF_PC + Imm8 ), 0 );
	
	// Jump Cond
	
	Register(
		oID_JmpCond,
		( Inst[15:12] == 4'b1101 && NonStall ) ? Inst[11:8] : JCC_NOP,
		JCC_NOP
	);
	
endmodule

/*** EX stage ***************************************************************/

module EXStage;

input			Clk;			// clock
input			Reset;			// reset

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

input	tADDR	iID_PC;
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

output	tDATA	oEX_wWBData;	// ALU result ( == wResult )
output	tREG	oEX_wWBReg;		// WB reg#
output			oEX_wWBEnb;		// WB enable wire
output			oEX_wDataRdyMA;	// ALUCmd is using adder? or read DRAM?

output	tDATA	oEX_DRAM_DataO;	// ALU result ( wire? / reg? )
output	tADDR	oEX_DRAM_Addr;	// ALU result ( wire )
outreg			oEX_DRAM_REnb;	// data RAM Read Enb
output			oEX_DRAM_WEnb;	// data RAM Write Enb

reg		tDATA	oEX_DRAM_DataO;	// ALU result ( reg )
reg				oEX_DRAM_WEnb;	// data RAM Write Enb

output	tADDR	oEX_wPC;		// Jmp addr to IF
output			oEX_wSetPC;		// Jmp request to IF

// wire / reg

reg				FlagRegO,		// Flags
				FlagRegS,
				FlagRegZ,
				FlagRegC,
				FlagRegOdd;		// Even / Odd flag

	/*** 2stage pipeline adder **********************************************/
	
	reg		tDATA	wResult;
	wire	tDATA	AddResult;
	
	wire			AddCout,
					AddOout;
	
	reg		tDATA	AddOp1,
					AddOp2;
	reg				AddCin;
	reg				CyInv;
	
	reg				FlagO,
					FlagC;
	wire			FlagS,
					FlagZ;
	
	#ifdef USE_ADDER_MACRO
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
	
	Register( FlagRegOdd, AddResult[0], 0 );
	
	/*** 1st stage ALU ******************************************************/
	
	always@(
		iID_Opr1 or iID_Opr2 or iID_ALUCmd or FlagRegC or AddResult
		or AddCout or AddOout
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
				
				wResult = AddResult;
				FlagC	= AddCout ^ CyInv;
				FlagO	= AddOout;
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
			
			ALUCMD_CZX:	begin
				wResult = { 8'd0, ( FlagRegOdd ? iID_Opr1[15:8] : iID_Opr1[7:0] ) };
				FlagC	= 0;
				FlagO	= 0;
			end
			
			ALUCMD_CSX:	begin
				wResult = FlagRegOdd ? {
					iID_Opr1[7],	// 15	odd : Low byte
					iID_Opr1[7],	// 14
					iID_Opr1[7],	// 13
					iID_Opr1[7],	// 12
					iID_Opr1[7],	// 11
					iID_Opr1[7],	// 10
					iID_Opr1[7],	//  9
					iID_Opr1[7],	//  8
					iID_Opr1[7:0]	//  7 - 0
				} : {
					iID_Opr1[15],	// 15	even : High byte
					iID_Opr1[15],	// 14
					iID_Opr1[15],	// 13
					iID_Opr1[15],	// 12
					iID_Opr1[15],	// 11
					iID_Opr1[15],	// 10
					iID_Opr1[15],	//  9
					iID_Opr1[15],	//  8
					iID_Opr1[15:8]	//  7 - 0
				};
				FlagC	= 0;
				FlagO	= 0;
			end
			
			ALUCMD_PACK:	begin
				wResult = FlagRegOdd ?
								{ iID_Opr1[15:8], iID_Opr2[7:0] } :	// odd:  Low byte
								{ iID_Opr2[7:0],  iID_Opr1[7:0] };	// even: High byte
				FlagC	= 0;
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
	
	/*** Flag reg for normal adder ******************************************/
	
	assign FlagS = wResult[15];
	assign FlagZ = ( wResult[15:0] == tDATA_W'd0 );
	
	 DefineReg
	 	if( Reset )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <= 4'b0;
	 	else if( iID_FlagsWE )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <=
	 										{ FlagO, FlagS, FlagZ, FlagC };
	
	/*** Jmp condition check ************************************************/
	
	reg				JmpRequest;
	reg		tADDR	JmpAddr;
	reg		tJCC	JmpCond;
	
	RegisterWE( JmpAddr, iID_PC,      !iID_wStall, 0 );
	RegisterWE( JmpCond, iID_JmpCond, !iID_wStall, JCC_NOP );
	
	always@( JmpCond or FlagRegO or FlagRegS or FlagRegZ or FlagRegC ) begin
		Case( JmpCond )
			JCC_Z,	JCC_NZ:	JmpRequest = FlagRegZ;
			JCC_S,	JCC_NS:	JmpRequest = FlagRegS;
			JCC_O,	JCC_NO:	JmpRequest = FlagRegO;
			JCC_C,	JCC_NC:	JmpRequest = FlagRegC;
			JCC_BE,	JCC_A:	JmpRequest = FlagRegC | FlagRegZ;
			JCC_L,	JCC_GE:	JmpRequest = ( FlagRegS != FlagRegO );
			JCC_LE,	JCC_G:	JmpRequest = ( FlagRegS != FlagRegO ) | FlagRegZ;
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
	
	assign oEX_DRAM_Addr = DataToAddr( oEX_Result );
	Register( oEX_DRAM_DataO,	DRAM_WBData  , 0 );
	Register( oEX_DRAM_WEnb,	iID_DRAM_WEnb, 0 );
	
	/*** other latch ********************************************************/
	
	Register( oEX_WBReg,	 iID_WBReg,		tREG_W'd0 );
	Register( oEX_WBEnb,	 iID_WBEnb,		0 );
	Register( oEX_DRAM_REnb, iID_DRAM_REnb, 0 );
	
	assign oEX_wWBData		= wResult;
	assign oEX_wWBReg		= iID_WBReg;
	assign oEX_wWBEnb		= iID_WBEnb;
	assign oEX_wDataRdyMA	= iID_DataRdyMA;
	
endmodule

/*** MA stage ***************************************************************/

module MAStage;

input			Clk;			// clock
input			Reset;			// reset

input	tDATA	iEX_Result;		// ALU result
input	tREG	iEX_WBReg;		// WB reg#
input			iEX_WBEnb;		// WB enable
input			iEX_DRAM_REnb;	// data RAM Read Enb

input	tDATA	iDRAM_DataI;	// data from Data RAM

outreg	tDATA	oMA_WBData;		// WB data
outreg	tREG	oMA_WBReg;		// WB reg#
outreg			oMA_WBEnb;		// WB enable

output	tDATA	oMA_wWBData;	// WB data
output	tREG	oMA_wWBReg;		// WB reg#
output			oMA_wWBEnb;		// WB enable

	Register( oMA_WBData, oMA_wWBData, tREG_W'd0 );
	Register( oMA_WBReg,  iEX_WBReg,   tREG_W'd0 );
	Register( oMA_WBEnb,  iEX_WBEnb,   0 );
	
	assign oMA_wWBData	= iEX_DRAM_REnb ? iDRAM_DataI : iEX_Result;
	
	assign oMA_wWBReg	= iEX_WBReg;
	assign oMA_wWBEnb	= iEX_WBEnb;
	
endmodule

/*** WB stage ***************************************************************/

module WBStage;

input			Clk;			// clock
input			Reset;			// reset

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

	DefineReg begin
		if( Reset ) begin
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

module STORM_CORE;

input			Clk;			// clock
input			Reset;			// reset

output	[8:0]	oData7Seg;		// display 7seg data
output	[7:0]	oDataLED;		// display 8bit LED data

input	tDATA	iIRAM_Data;
output	tADDR	oIRAM_Addr;
input	tDATA	iDRAM_DataI;
output	tDATA	oDRAM_DataO;
output	tADDR	oDRAM_Addr;
output			oDRAM_REnb;
output			oDRAM_WEnb;


	assign oData7Seg = WB_Reg0[8:0];
	assign oDataLED  = WB_Reg1[7:0];
	
	instance IFStage * * (
		(iIRAM_Data)		$1
		oIF_IRAM_Addr		oIRAM_Addr
	);
	
	instance IDStage * *;
	
	instance EXStage * * (
		oEX_DRAM_DataO		oDRAM_DataO
		oEX_DRAM_Addr		oDRAM_Addr
		oEX_DRAM_WEnb		oDRAM_WEnb
	);
	
	assign oDRAM_REnb = EX_DRAM_REnb;
	
	instance MAStage * * (
		(iDRAM_DataI)		$1
	);
	
	instance WBStage * *;
	
endmodule

/*** 7seg decoder ***********************************************************/

module Seg7Decode;

input	[3:0]	iData;
outreg	[6:0]	oSegData;

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

module STORM;

input			Clk;			// clock
input			Reset;			// reset ( High active )

output	[6:0]	oData7Seg0,		// 7seg display data
				oData7Seg1;
output			oData7SegP;		// 7seg 0's dp
output	[7:0]	oDataLED;		// 8bit LED data


	/*** Delayed Data RAM WEnb **********************************************/
	
	wire	DRAM_WEnbDly;
	
	LCELL	LCELL0( Clk, DlyClk0 );
	LCELL	LCELL1( DlyClk0, DlyClk1 );
	LCELL	LCELL2( DlyClk1, DlyClk2 );
	
	assign DRAM_WEnbDly = DlyClk2 & DRAM_WEnb;
	
	/*** CORE ***************************************************************/
	
	instance STORM_CORE * *(
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
		q			DRAM_DataI		W
		data		DRAM_DataO
		address		DRAM_Addr
	);
endmodule
