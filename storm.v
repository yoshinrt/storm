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


/*** const ******************************************************************/




/*** macros *****************************************************************/




// PIO:0x4000  Ext:0x8000


/*** IF stage ***************************************************************/

module IFStage(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

// I/O port

	input				iClk,			// clock
	input				iRst,			// reset

	input		[8:0]	iID_wPC,		// set PC data from ID
	input				iID_wSetPC,		// set PC request from ID

	input		[8:0]	iEX_wPC,		// set PC data from EX
	input				iEX_wSetPC,		// set PC request from EX

	input				iID_wStall,		// pipeline stall

	output		[8:0]	oIF_IRAM_Addr,	// instruction RAM addr
	input		[15:0]	iIRAM_Data,		// instruction RAM data

	output reg	[15:0]	oIF_IR,			// IF stage IR
	output		[15:0]	oIF_wIR,		// IF stage IR ( wire )
	output reg	[8:0]	oIF_PC			// IF stage PC
);

// wire / reg

wire	[8:0]	PC;				// PC
reg		[8:0]	RegPC;			// PC register
wire	[8:0]	PC_plus1;		// ++RegPC

	/*** IR / PC regisger ***************************************************/
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oIF_IR <= 0; else if( !iID_wStall ) oIF_IR <= iIRAM_Data;
	always@( posedge iClk or posedge iRst ) if( iRst ) oIF_PC <= 0; else if( !iID_wStall ) oIF_PC <= PC_plus1;
	
	assign oIF_wIR = iIRAM_Data;
	
	/*** PC *****************************************************************/
	
	assign PC_plus1 = RegPC + 9'd1;
	
	assign PC = iEX_wSetPC ? iEX_wPC	:
				iID_wSetPC ? iID_wPC	:
							 PC_plus1	;
	
	assign oIF_IRAM_Addr = RegPC;
	always@( posedge iClk or posedge iRst ) if( iRst ) RegPC <= 0; else if( !iID_wStall ) RegPC <= PC;
	
endmodule

/*** get source reg data from RegFiles, Pipeline latch ***********************/

module SrcRegData(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				tREG	iRegNum,

	input		[15:0]	iWB_Reg0,		// registers
	input		[15:0]	iWB_Reg1,
	input		[15:0]	iWB_Reg2,
	input		[15:0]	iWB_Reg3,
	input		[15:0]	iWB_Reg4,
	input		[15:0]	iWB_Reg5,
	input		[15:0]	iWB_Reg6,
	input		[15:0]	iWB_Reg7,

	input		[15:0]	iEX_wWBData,
	input				tREG	iEX_wWBReg,
	input				iEX_wWBEnb,

	input		[15:0]	iMA_wWBData,
	input				tREG	iMA_wWBReg,
	input				iMA_wWBEnb,

	input		[15:0]	iWB_wWBData,
	input				tREG	iWB_wWBReg,
	input				iWB_wWBEnb,

	output reg	[15:0]	oSrcData
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
		else case( iRegNum ) /* synopsys parallel_case */
			REG0: oSrcData = iWB_Reg0;
			REG1: oSrcData = iWB_Reg1;
			REG2: oSrcData = iWB_Reg2;
			REG3: oSrcData = iWB_Reg3;
			REG4: oSrcData = iWB_Reg4;
			REG5: oSrcData = iWB_Reg5;
			REG6: oSrcData = iWB_Reg6;
			REG7: oSrcData = iWB_Reg7;
			default: oSrcData = 16'bx;
		endcase
	end
endmodule

module SrcRegJmpData(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				tREG	iRegNum,

	input		[15:0]	iWB_Reg0,		// registers
	input		[15:0]	iWB_Reg1,
	input		[15:0]	iWB_Reg2,
	input		[15:0]	iWB_Reg3,
	input		[15:0]	iWB_Reg4,
	input		[15:0]	iWB_Reg5,
	input		[15:0]	iWB_Reg6,
	input		[15:0]	iWB_Reg7,

	input		[15:0]	iMA_wWBData,
	input				tREG	iMA_wWBReg,
	input				iMA_wWBEnb,

	input		[15:0]	iWB_wWBData,
	input				tREG	iWB_wWBReg,
	input				iWB_wWBEnb,

	output reg	[8:0]	oSrcData
);

	always@(
		iRegNum or
		
		iWB_Reg7 or
		
		iWB_Reg0 or	iWB_Reg1 or
		iWB_Reg4 or
		
		
		iMA_wWBData	or iMA_wWBReg or iMA_wWBEnb or
		iWB_wWBData	or iWB_wWBReg or iWB_wWBEnb
	) begin
		if	   ( iMA_wWBEnb && iRegNum == iMA_wWBReg ) oSrcData = iMA_wWBData;
		else if( iWB_wWBEnb && iRegNum == iWB_wWBReg ) oSrcData = iWB_wWBData;
		else
				case( iRegNum ) /* synopsys parallel_case */
					REG0: oSrcData = iWB_Reg0;
					REG1: oSrcData = iWB_Reg1;
					REG4: oSrcData = iWB_Reg4;
					REG7: oSrcData = iWB_Reg7;
					default: oSrcData = 9'bx;
				endcase
	end
endmodule

module SrcRegDRAM_WBData(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				tREG	iRegNum,

	input		[15:0]	iWB_Reg0,		// registers
	input		[15:0]	iWB_Reg1,
	input		[15:0]	iWB_Reg2,
	input		[15:0]	iWB_Reg3,
	input		[15:0]	iWB_Reg4,
	input		[15:0]	iWB_Reg5,
	input		[15:0]	iWB_Reg6,
	input		[15:0]	iWB_Reg7,

	input		[15:0]	iMA_wWBData,
	input				tREG	iMA_wWBReg,
	input				iMA_wWBEnb,

	input		[15:0]	iWB_wWBData,
	input				tREG	iWB_wWBReg,
	input				iWB_wWBEnb,

	output reg	[15:0]	oSrcData
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
		else case( iRegNum ) /* synopsys parallel_case */
			REG0: oSrcData = iWB_Reg0;
			REG1: oSrcData = iWB_Reg1;
			REG2: oSrcData = iWB_Reg2;
			REG3: oSrcData = iWB_Reg3;
			REG4: oSrcData = iWB_Reg4;
			REG5: oSrcData = iWB_Reg5;
			REG6: oSrcData = iWB_Reg6;
			REG7: oSrcData = iWB_Reg7;
			default: oSrcData = 16'bx;
		endcase
	end
endmodule

/*** ID stage ***************************************************************/

module IDStage(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

// I/O port

	input				iClk,			// clock
	input				iRst,			// reset

// pipline latch in

	input		[8:0]	iIF_PC,			// PC from IF
	input		[15:0]	iIF_IR,			// IR from IF
	input		[15:0]	iIF_wIR,		// IR from IF ( wire )

// register in

	input		[15:0]	iWB_Reg0,		// registers
	input		[15:0]	iWB_Reg1,
	input		[15:0]	iWB_Reg2,
	input		[15:0]	iWB_Reg3,
	input		[15:0]	iWB_Reg4,
	input		[15:0]	iWB_Reg5,
	input		[15:0]	iWB_Reg6,
	input		[15:0]	iWB_Reg7,

// src reg bypass in

	input		[15:0]	iEX_wWBData,
	input				tREG	iEX_wWBReg,
	input				iEX_wWBEnb,
	input				iEX_wDataRdyMA,		// ALUCmd is using adder? or read DRAM?
	input				iEX_wFlagsWE,		// flags WE

	input		[15:0]	iMA_wWBData,
	input				tREG	iMA_wWBReg,
	input				iMA_wWBEnb,

	input		[15:0]	iWB_wWBData,
	input				tREG	iWB_wWBReg,
	input				iWB_wWBEnb,

// pipeline latch out

	output reg			tALUCMD	oID_ALUCmd,		// ALU command
	output reg			tREG	oID_WBReg,		// write back register#
	output reg			oID_WBEnb,		// write back enable
	output reg	[15:0]	oID_Opr1,		// ALU operand1
	output reg	[15:0]	oID_Opr2,		// ALU operand2
	output reg			tREG	oID_RegNumDRAM_WB,	// Reg# of DataRAM WB Data
	output reg			oID_FlagsWE,	// FlagsReg WE

	output				oID_wStall,		// pipeline stall signal
	output reg			oID_DataRdyMA,	// ALUCmd is using adder? or read DRAM?

// DRAM RE / WE

	output reg			oID_DRAM_REnb,
	output reg			oID_DRAM_WEnb,

// PC bypass out

	output		[8:0]	oID_wPC,		// set PC data to IF ( absolute address )
	output				oID_wSetPC,		// set PC request to IF

// PC & JumpCond to EX

	output reg	[8:0]	oID_PC,			// Jump address ( absolute addres )
	output reg			tJCC	oID_JmpCond	// Jump condition code
);

// reg/wire

wire	[15:0]	Imm11,			// 11 --> 16bit sx immediate
				Imm8;			//  8 --> 16bit sx immediate

wire	[15:0]	Inst	= iIF_IR;

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
		) || (
			// Flags R.A.W
			ALUCmdAdc && iEX_wFlagsWE
		);
	
	
	/*** ALU cmd ************************************************************/
	
		
		// ALUCmd is ADD - XOR ?
		wire	UseALUCmd = ( Inst[15:14] == 2'b10 || { Inst[15:11], Inst[7] } == 6'b111100 );
		
		// ALUCmd is ADD - SBB, or reading DRAM?
		assign DataRdyMA = (( ALUCmd[2] == 1'b0 ) && UseALUCmd ) || DRAM_REnb;
		
		// ALUCmd is ADC / SBB ?
		assign ALUCmdAdc = ( ALUCmd[2:1] == 2'b01 ) && UseALUCmd;
		
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oID_DataRdyMA <= 0; else oID_DataRdyMA <= DataRdyMA;
	
	
	always@( Inst ) begin
		casex( Inst[15:7] ) /* synopsys parallel_case */
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
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oID_ALUCmd <= tALUCMD_w'd0; else oID_ALUCmd <= ALUCmd;
	
	/*** opr1 / 2 ***********************************************************/
	
	// op1 / 2 reg#
	
	wire	[15:0]	RegData1;
	wire	[15:0]	RegData2;
	reg		tREG	wRegNum1;
	wire	[15:0]	PreIDInst;
	
	always@( PreIDInst ) begin
		casex( PreIDInst[15:7] ) /* synopsys parallel_case */
			9'b01xxxxxxx: wRegNum1 = { PreIDInst[9], 1'b0, PreIDInst[8] };	// mm addr's base reg
			9'b10xxxxxxx,													// add r,i
			9'b110xxxxxx: wRegNum1 = PreIDInst[13:11];						// mov [i],r
			9'b11110xxx0: wRegNum1 = PreIDInst[5:3];						// add r,r
			9'b11110xxx1,													// sh  r,r
			9'b11111xxxx: wRegNum1 = PreIDInst[2:0];						// mov r,r
			default:	  wRegNum1 = tREG_w'bx;
		endcase
	end
	
		assign PreIDInst = iIF_wIR;
		always@( posedge iClk or posedge iRst ) if( iRst ) RegNum1 <= 0; else if( !oID_wStall ) RegNum1 <= wRegNum1;
	
	assign RegNum2		 = Inst[2:0];
	assign RegNumDRAM_WB = Inst[13:11];
	always@( posedge iClk or posedge iRst ) if( iRst ) oID_RegNumDRAM_WB <= 0; else oID_RegNumDRAM_WB <= RegNumDRAM_WB;
	
	
	// op1 / 2
	
	SrcRegData SrcRegData1(
		.tREG				( tREG					),
		.iRegNum			( RegNum1				),
		.iWB_Reg0			( iWB_Reg0				),
		.iWB_Reg1			( iWB_Reg1				),
		.iWB_Reg2			( iWB_Reg2				),
		.iWB_Reg3			( iWB_Reg3				),
		.iWB_Reg4			( iWB_Reg4				),
		.iWB_Reg5			( iWB_Reg5				),
		.iWB_Reg6			( iWB_Reg6				),
		.iWB_Reg7			( iWB_Reg7				),
		.iEX_wWBData		( iEX_wWBData			),
		.tREG				( tREG					),
		.iEX_wWBReg			( iEX_wWBReg			),
		.iEX_wWBEnb			( iEX_wWBEnb			),
		.iMA_wWBData		( iMA_wWBData			),
		.tREG				( tREG					),
		.iMA_wWBReg			( iMA_wWBReg			),
		.iMA_wWBEnb			( iMA_wWBEnb			),
		.iWB_wWBData		( iWB_wWBData			),
		.tREG				( tREG					),
		.iWB_wWBReg			( iWB_wWBReg			),
		.iWB_wWBEnb			( iWB_wWBEnb			)
	);
	
	SrcRegData SrcRegData2(
		.tREG				( tREG					),
		.iRegNum			( RegNum2				),
		.iWB_Reg0			( iWB_Reg0				),
		.iWB_Reg1			( iWB_Reg1				),
		.iWB_Reg2			( iWB_Reg2				),
		.iWB_Reg3			( iWB_Reg3				),
		.iWB_Reg4			( iWB_Reg4				),
		.iWB_Reg5			( iWB_Reg5				),
		.iWB_Reg6			( iWB_Reg6				),
		.iWB_Reg7			( iWB_Reg7				),
		.iEX_wWBData		( iEX_wWBData			),
		.tREG				( tREG					),
		.iEX_wWBReg			( iEX_wWBReg			),
		.iEX_wWBEnb			( iEX_wWBEnb			),
		.iMA_wWBData		( iMA_wWBData			),
		.tREG				( tREG					),
		.iMA_wWBReg			( iMA_wWBReg			),
		.iMA_wWBEnb			( iMA_wWBEnb			),
		.iWB_wWBData		( iWB_wWBData			),
		.tREG				( tREG					),
		.iWB_wWBReg			( iWB_wWBReg			),
		.iWB_wWBEnb			( iWB_wWBEnb			)
	);
	
	// op1 / 2 data reg
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst )	oID_Opr1 <= 0;
		else casex( Inst[15:10] ) /* synopsys parallel_case */
			6'b00xxxx,										// mov r,i
			6'b110xxx: oID_Opr1 <= Imm11;					// mov r,[i]/[i],r
			6'b01xxxx,										// mm base reg
			6'b10xxxx,										// add r,i
			6'b11110x,										// add/sh r,r
			6'b111110: oID_Opr1 <= RegData1;				// mov r,r
			6'b111111: oID_Opr1 <= { 7'b0000000, iIF_PC };		// spc
			default:   oID_Opr1 <= 16'bx;
		endcase
	end
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst )	oID_Opr2 <= 0;
		else casex( Inst[15:14] ) /* synopsys parallel_case */
			2'b01,							// mm index imm
			2'b10:  oID_Opr2 <= Imm8;		// add r,i
			2'b11:  oID_Opr2 <= RegData2;	// add/sh r,r
			default:oID_Opr2 <= 16'bx;
		endcase
	end
	
	// really used RegNumX etc... ?
	
	always@( Inst[15:10] ) begin
		casex( Inst[15:10] ) /* synopsys parallel_case */
			6'b01xxxx,					// mm addr's base reg
			6'b10xxxx,					// add r,i
			6'b110xx1,					// mov [i],r
			6'b11110x,					// add/sh r,r
			6'b111110: UseRegNum1 = 1;	// mov r,r / jmp r
			default:   UseRegNum1 = 0;
		endcase
	end
	
	always@( Inst[15:10] ) begin
		casex( Inst[15:10] ) /* synopsys parallel_case */
			6'b11110x,					// add/sh r,r
			6'b111110: UseRegNum2 = 1;	// mov r,r / jmp r
			default:   UseRegNum2 = 0;
		endcase
	end
	
	/*** WBReg / WBEnb ******************************************************/
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst ) oID_WBReg <= 0;
		else casex( Inst[15:13] ) /* synopsys parallel_case */
			3'b0xx,
			3'b10x,										// mov r,i/m,r/r,m
			3'b110: oID_WBReg <= Inst[13:11];			// mov r,[i]
			3'b111: oID_WBReg <= Inst[5:3];				// opc r,r
			default:oID_WBReg <= tREG_w'bx;
		endcase
	end
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst ) oID_WBEnb <= 0;
		else casex( Inst[15:7] ) /* synopsys parallel_case */
			9'b10xxxxxxx,							// add
			9'b11110xxx0: oID_WBEnb <= ( Inst[10:8] != ALUCMD_MOV && !oID_wStall );
			
			9'b00xxxxxxx,							// mov r,i
			9'b01xxx0xxx,							// mov r,m
			9'b110xx0xxx,							// mov r,[i]
			9'b11110xxx1,							// sh
			9'b1111100xx,							// mov r,r
			9'b1111110xx: oID_WBEnb <= !oID_wStall;	// spc
			default:	  oID_WBEnb <= 0;
		endcase
	end
	
	/*** FlagsWE ************************************************************/
	
	// add / sh
	always@( posedge iClk or posedge iRst ) begin
		if( iRst )	oID_FlagsWE <= 0;
		else oID_FlagsWE <= !oID_wStall && (
				Inst[15:11] == 5'b11110 ||	// add/sh r,r
				Inst[15:14] == 2'b10	);	// add r,i
	end
	
	/*** DRAM RE / WE *******************************************************/
	
	wire	DRAM_Access	= ( Inst[15:14] == 2'b01 || Inst[15:13] == 3'b110 )
							&& !oID_wStall;
	assign	DRAM_REnb	= DRAM_Access && ~Inst[10];
	
	always@( posedge iClk or posedge iRst ) begin
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
	
	wire	[8:0]	RegJmpAddr;		// register stored jmp address
	wire			RegJmpInsn;		// register jmp insn?
	
	SrcRegJmpData SrcRegJmpData(
		.tREG				( tREG					),
		.iRegNum			( Inst[2:0]				),
		.iWB_Reg0			( iWB_Reg0				),
		.iWB_Reg1			( iWB_Reg1				),
		.iWB_Reg2			( iWB_Reg2				),
		.iWB_Reg3			( iWB_Reg3				),
		.iWB_Reg4			( iWB_Reg4				),
		.iWB_Reg5			( iWB_Reg5				),
		.iWB_Reg6			( iWB_Reg6				),
		.iWB_Reg7			( iWB_Reg7				),
		.iMA_wWBData		( iMA_wWBData			),
		.tREG				( tREG					),
		.iMA_wWBReg			( iMA_wWBReg			),
		.iMA_wWBEnb			( iMA_wWBEnb			),
		.iWB_wWBData		( iWB_wWBData			),
		.tREG				( tREG					),
		.iWB_wWBReg			( iWB_wWBReg			),
		.iWB_wWBEnb			( iWB_wWBEnb			)
	);
	
	assign RegJmpInsn	= ( Inst[15:9] == 7'b1111101 );
	assign oID_wPC		= RegJmpInsn ? RegJmpAddr : ( iIF_PC + Imm11 );
	assign oID_wSetPC	= ( Inst[15:9] == 7'b1110111 || RegJmpInsn );
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oID_PC <= 0; else oID_PC <= ( iIF_PC + Imm8 );
	
	// Jump Cond
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oID_JmpCond <= JCC_NOP; else oID_JmpCond <= ( Inst[15:12] == 4'b1110 && Inst[11:9] != 3'b111 && !oID_wStall ) ? Inst[11:8] : JCC_NOP;
	
endmodule

/*** EX stage ***************************************************************/

module EXStage(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				iClk,			// clock
	input				iRst,			// reset

	input				tALUCMD	iID_ALUCmd,		// ALU command
	input				iID_DataRdyMA,	// ALU is using adder? or read DRAM?
	input		[15:0]	iID_Opr1,		// ALU operand1
	input		[15:0]	iID_Opr2,		// ALU operand2
	input				iID_FlagsWE,	// Flags WE

	input				tREG	iID_WBReg,		// WB reg#
	input				iID_WBEnb,		// WB enable
	input				iID_DRAM_REnb,	// data RAM Read Enb
	input				iID_DRAM_WEnb,	// data RAM Write Enb
	input				tREG	iID_RegNumDRAM_WB,	// Reg# of DRAM WB data

	input		[8:0]	iID_PC,
	input				tJCC	iID_JmpCond,	// jump conditon code
	input				iID_wStall,		// pipeline stall?

// register in

	input		[15:0]	iWB_Reg0,		// registers
	input		[15:0]	iWB_Reg1,
	input		[15:0]	iWB_Reg2,
	input		[15:0]	iWB_Reg3,
	input		[15:0]	iWB_Reg4,
	input		[15:0]	iWB_Reg5,
	input		[15:0]	iWB_Reg6,
	input		[15:0]	iWB_Reg7,

// src reg bypass in

	input		[15:0]	iMA_wWBData,
	input				tREG	iMA_wWBReg,
	input				iMA_wWBEnb,

	input		[15:0]	iWB_wWBData,
	input				tREG	iWB_wWBReg,
	input				iWB_wWBEnb,

//////////////////////////////////

	output reg	[15:0]	oEX_Result,		// ALU result
	output reg			tREG	oEX_WBReg,		// WB reg#
	output reg			oEX_WBEnb,		// WB enable
	output		[15:0]	oEX_wResult2,	// 1+2 stage ALU result

	output		[15:0]	oEX_wWBData,	// ALU result ( == wResult )
	output				tREG	oEX_wWBReg,		// WB reg#
	output				oEX_wWBEnb,		// WB enable wire
	output				oEX_wDataRdyMA,	// ALUCmd is using adder? or read DRAM?
	output				oEX_wFlagsWE,	// flags WE

	output reg	[15:0]	oEX_DRAM_DataO,	// ALU result ( wire? / reg? )
	output		[9:0]	oEX_DRAM_Addr,	// ALU result ( wire )
	reg			[9:0]	oEX_DRAM_Addr,	// ALU result ( reg )
	output reg			oEX_DRAM_REnb,	// data RAM Read Enb
	output reg			oEX_DRAM_WEnb,	// data RAM Write Enb

	output		[8:0]	oEX_wPC,		// Jmp addr to IF
	output				oEX_wSetPC,		// Jmp request to IF

/// PIO / ExtBord IOrequest //////

	output reg			oEX_PIO_REnb,		// PIO RE
	output reg			oEX_PIO_WEnb,		// PIO WE

	output reg			oEX_ExtB_REnb,		// ExtBord RE ( SW )

	output reg			oEX_ExtB_WEnb		// ExtBord WE ( LED )
);

// wire / reg

reg				FlagRegO,		// Flagss
				FlagRegS,
				FlagRegZ,
				FlagRegC;

	/*** 2stage pipeline adder **********************************************/
	
	reg		[15:0]	wResult;
	wire	[15:0]	AddResult;
	
	
	reg		[15:0]	AddOp1,
					AddOp2;
	reg				AddCin;
	reg				CyInv;
	
	reg				FlagO,
					FlagC;
	wire			FlagS,
					FlagZ;
	
		
		reg				DataRdyMA2;		// 2nd stage iID_DataRdyMA
		reg		[5:0]	AddOp1Reg,		// AddOp1 High-6bit
						AddOp2Reg;		// AddOp2 High-6bit
		wire	[9:0]	AddResultLw;	// 1st stage adder result ( wire )
		reg		[9:0]	AddResultL;		// ~~~~~~~~~~~~~~~~~~~~~~ ( reg )
		wire	[5:0]	AddResultHw;	// 2nd stage adder result ( wire )
		
		wire	[15:0]	AddResult2;		// 1+2 stage adder result
		wire			AddCout2,		// 1+2 stage cy out
						AddOout2;		// 1+2 stage ov out
		
		wire			HalfCyOut;		// 1st stage cy out ( wire )
		reg				HalfCy;			// ~~~~~~~~~~~~~~~~ ( reg )
		reg				HalfCyInv;		// cy out invert request
		
		reg				HalfFlagC,		// 1st stage ALU's cy out
						HalfFlagO;		// 1st stage ALU's ov out
		
		assign AddResult  = { 6'b0, AddResultLw };
		assign AddResult2 = { AddResultHw, AddResultL };
		
		always@( posedge iClk or posedge iRst ) if( iRst ) DataRdyMA2 <= 0; else DataRdyMA2 <= iID_DataRdyMA;
		always@( posedge iClk or posedge iRst ) if( iRst ) AddOp1Reg <= 0; else AddOp1Reg <= AddOp1[15:10];
		always@( posedge iClk or posedge iRst ) if( iRst ) AddOp2Reg <= 0; else AddOp2Reg <= AddOp2[15:10];
		always@( posedge iClk or posedge iRst ) if( iRst ) AddResultL <= 0; else AddResultL <= AddResultLw;
		always@( posedge iClk or posedge iRst ) if( iRst ) HalfCy <= 0; else HalfCy <= HalfCyOut;
		always@( posedge iClk or posedge iRst ) if( iRst ) HalfCyInv <= 0; else HalfCyInv <= CyInv;
		
		always@( posedge iClk or posedge iRst ) if( iRst ) HalfFlagC <= 0; else HalfFlagC <= FlagC;
		always@( posedge iClk or posedge iRst ) if( iRst ) HalfFlagO <= 0; else HalfFlagO <= FlagO;
		
	ADDER10 ADDER10(
		.dataa				( AddOp1[9:0]			),
		.datab				( AddOp2[9:0]			),
		.cin				( AddCin				),
		.result				( AddResultLw			),
		.cout				( HalfCyOut				)
	);
		
	ADDER6 ADDER6(
		.dataa				( AddOp1Reg				),
		.datab				( AddOp2Reg				),
		.cin				( HalfCy				),
		.result				( AddResultHw			),
		.cout				( AddCout2				),
		.overflow			( AddOout2				)
	);
		
	
	/*** 1st stage ALU ******************************************************/
	
	always@(
		iID_Opr1 or iID_Opr2 or iID_ALUCmd or FlagRegC or AddResult
	) begin
		
		AddOp1	= iID_Opr1;
		AddOp2	= 16'bx;
		AddCin	= 1'bx;
		CyInv	= 1'bx;
		
		FlagC	= 1'bx;
		FlagO	= 1'bx;
		
		case( iID_ALUCmd ) /* synopsys parallel_case */
			ALUCMD_ADD,
			ALUCMD_ADC,
			ALUCMD_SUB,
			ALUCMD_SBB: begin
				
				case( iID_ALUCmd ) /* synopsys parallel_case */
					ALUCMD_SUB, ALUCMD_SBB: { CyInv, AddOp2 } = { 1'b1, ~iID_Opr2 };
					default:				{ CyInv, AddOp2 } = { 1'b0,  iID_Opr2 };
				endcase
				
				case( iID_ALUCmd ) /* synopsys parallel_case */
					ALUCMD_ADC: AddCin = FlagRegC;
					ALUCMD_SUB: AddCin = 1;
					ALUCMD_SBB: AddCin = ~FlagRegC;
					default:	AddCin = 0;
				endcase
				
					wResult = 16'bx;
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
				wResult = 16'bx;
			end
		endcase
	end
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oEX_Result <= 16'd0; else oEX_Result <= wResult;
	
	/*** 2nd stage ALU result ***********************************************/
	
	assign oEX_wResult2 = DataRdyMA2 ? AddResult2 : oEX_Result;
	
	/*** Flag reg for PIPELINE_ADDER ****************************************/
	
	wire	FlagO2,
			FlagC2;
	
	reg		FlagsWE2;
	
	assign FlagO2 = DataRdyMA2 ? AddOout2 : HalfFlagO;
	assign FlagS  = oEX_wResult2[15];
	assign FlagZ  = ( oEX_wResult2[15:0] == 16'd0 );
	assign FlagC2 = DataRdyMA2 ? AddCout2 ^ HalfCyInv : HalfFlagC;
	
	always@( posedge iClk or posedge iRst ) if( iRst ) FlagsWE2 <= 0; else FlagsWE2 <= iID_FlagsWE;
	
	 always@( posedge iClk or posedge iRst )
	 	if( iRst )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <= 4'b0;
	 	else if( FlagsWE2 )
	 		{ FlagRegO, FlagRegS, FlagRegZ, FlagRegC } <=
	 										{ FlagO2, FlagS, FlagZ, FlagC2 };
	
	
	/*** Jmp condition check ************************************************/
	
	reg				JmpRequest;
	reg		[8:0]	JmpAddr;
	reg		tJCC	JmpCond;
	
	// flag used for CC check
	wire			JccFlagO,
					JccFlagS,
					JccFlagZ,
					JccFlagC;
	
	always@( posedge iClk or posedge iRst ) if( iRst ) JmpAddr <= 0; else if( !iID_wStall ) JmpAddr <= iID_PC;
	always@( posedge iClk or posedge iRst ) if( iRst ) JmpCond <= JCC_NOP; else if( !iID_wStall ) JmpCond <= iID_JmpCond;
	
		assign JccFlagO = FlagRegO;
		assign JccFlagS = FlagRegS;
		assign JccFlagZ = FlagRegZ;
		assign JccFlagC = FlagRegC;
	
	always@( JmpCond or JccFlagO or JccFlagS or JccFlagZ or JccFlagC ) begin
		case( JmpCond ) /* synopsys parallel_case */
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
	
	wire	[15:0]	DRAM_WBData;
	
	SrcRegDRAM_WBData SrcRegDRAM_WBData(
		.tREG				( tREG					),
		.iRegNum			( iID_RegNumDRAM_WB		),
		.iWB_Reg0			( iWB_Reg0				),
		.iWB_Reg1			( iWB_Reg1				),
		.iWB_Reg2			( iWB_Reg2				),
		.iWB_Reg3			( iWB_Reg3				),
		.iWB_Reg4			( iWB_Reg4				),
		.iWB_Reg5			( iWB_Reg5				),
		.iWB_Reg6			( iWB_Reg6				),
		.iWB_Reg7			( iWB_Reg7				),
		.iMA_wWBData		( iMA_wWBData			),
		.tREG				( tREG					),
		.iMA_wWBReg			( iMA_wWBReg			),
		.iMA_wWBEnb			( iMA_wWBEnb			),
		.iWB_wWBData		( iWB_wWBData			),
		.tREG				( tREG					),
		.iWB_wWBReg			( iWB_wWBReg			),
		.iWB_wWBEnb			( iWB_wWBEnb			)
	);
	
		always@( posedge iClk or posedge iRst ) if( iRst ) oEX_DRAM_Addr <= 0; else oEX_DRAM_Addr <= ( iID_ALUCmd[ 0 ] ? wResult : AddResult );
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oEX_DRAM_DataO <= 0; else oEX_DRAM_DataO <= DRAM_WBData  ;
	
	/*** Port I/O RE/WE *****************************************************/
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oEX_PIO_REnb <= 0; else oEX_PIO_REnb <= ( iID_Opr1[15:14] == 2'b01 ) & iID_DRAM_REnb;
	always@( posedge iClk or posedge iRst ) if( iRst ) oEX_PIO_WEnb <= 0; else oEX_PIO_WEnb <= ( iID_Opr1[15:14] == 2'b01 ) & iID_DRAM_WEnb;
	
	/*** ExtBord I/O RE/WE **************************************************/
	
		always@( posedge iClk or posedge iRst ) if( iRst ) oEX_ExtB_REnb <= 0; else oEX_ExtB_REnb <= ( iID_Opr1[15:14] == 2'b10 ) & iID_DRAM_REnb;
	
		always@( posedge iClk or posedge iRst ) if( iRst ) oEX_ExtB_WEnb <= 0; else oEX_ExtB_WEnb <= ( iID_Opr1[15:14] == 2'b10 ) & iID_DRAM_WEnb;
	
	/*** DRAM RE/WE *********************************************************/
	
		always@( posedge iClk or posedge iRst ) if( iRst ) oEX_DRAM_REnb <= 0; else oEX_DRAM_REnb <= iID_DRAM_REnb & ( iID_Opr1[15:14] == 2'b00 || iID_Opr1[15:14] == 2'b11 );
	
		always@( posedge iClk or posedge iRst ) if( iRst ) oEX_DRAM_WEnb <= 0; else oEX_DRAM_WEnb <= iID_DRAM_WEnb & ( iID_Opr1[15:14] == 2'b00 || iID_Opr1[15:14] == 2'b11 );
	
	/*** other latch ********************************************************/
	
	always@( posedge iClk or posedge iRst ) if( iRst ) oEX_WBReg <= tREG_w'd0; else oEX_WBReg <= iID_WBReg;
	always@( posedge iClk or posedge iRst ) if( iRst ) oEX_WBEnb <= 0; else oEX_WBEnb <= iID_WBEnb;
	
	assign oEX_wWBData		= wResult;
	assign oEX_wWBReg		= iID_WBReg;
	assign oEX_wWBEnb		= iID_WBEnb;
	assign oEX_wDataRdyMA	= iID_DataRdyMA;
	assign oEX_wFlagsWE		= iID_FlagsWE;
	
endmodule

/*** MA stage ***************************************************************/

module MAStage(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				iClk,			// clock
	input				iRst,			// reset

	input		[15:0]	iEX_Result,		// ALU result
	input		[15:0]	iEX_wResult2,	// 1+2 stage ALU result
	input				tREG	iEX_WBReg,		// WB reg#
	input				iEX_WBEnb,		// WB enable
	input				iEX_DRAM_REnb,	// data RAM Read Enb

	input		[15:0]	iDRAM_DataI,	// data from Data RAM

	input		[15:0]	iPIO_DataI,		// data from PIO
	input				iEX_PIO_REnb,	// PIO REnb

	input		[15:0]	iExtB_DataI,	// data from ExtBoard InputSW
	input				iEX_ExtB_REnb,	// InputSW REnb

	output reg	[15:0]	oMA_WBData,		// WB data
	output reg			tREG	oMA_WBReg,		// WB reg#
	output reg			oMA_WBEnb,		// WB enable

	output		[15:0]	oMA_wWBData,	// WB data
	output				tREG	oMA_wWBReg,		// WB reg#
	output				oMA_wWBEnb		// WB enable
);

	always@( posedge iClk or posedge iRst ) if( iRst ) oMA_WBData <= 0; else oMA_WBData <= oMA_wWBData;
	always@( posedge iClk or posedge iRst ) if( iRst ) oMA_WBReg <= tREG_w'd0; else oMA_WBReg <= iEX_WBReg;
	always@( posedge iClk or posedge iRst ) if( iRst ) oMA_WBEnb <= 0; else oMA_WBEnb <= iEX_WBEnb;
	
	/*** data source selector ***********************************************/
	
	assign oMA_wWBData =
					( iEX_DRAM_REnb	) ? iDRAM_DataI	:
				
					( iEX_PIO_REnb	) ? iPIO_DataI	:
				
					( iEX_ExtB_REnb	) ? iExtB_DataI	:
				
										iEX_wResult2;
	
	/************************************************************************/
	
	assign oMA_wWBReg	= iEX_WBReg;
	assign oMA_wWBEnb	= iEX_WBEnb;
	
endmodule

/*** WB stage ***************************************************************/

module WBStage(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				iClk,			// clock
	input				iRst,			// reset

	input		[15:0]	iMA_WBData,		// WB data
	input				tREG	iMA_WBReg,		// WB reg#
	input				iMA_WBEnb,		// WB enable

	output reg	[15:0]	oWB_Reg0,		// registers
	output reg	[15:0]	oWB_Reg1,
	output reg	[15:0]	oWB_Reg2,
	output reg	[15:0]	oWB_Reg3,
	output reg	[15:0]	oWB_Reg4,
	output reg	[15:0]	oWB_Reg5,
	output reg	[15:0]	oWB_Reg6,
	output reg	[15:0]	oWB_Reg7,

	output		[15:0]	oWB_wWBData,	// WB data
	output				tREG	oWB_wWBReg,		// WB reg#
	output				oWB_wWBEnb		// WB enable
);

	always@( posedge iClk or posedge iRst ) begin
		if( iRst ) begin
			oWB_Reg0 <= 16'd0;
			oWB_Reg1 <= 16'd0;
			oWB_Reg2 <= 16'd0;
			oWB_Reg3 <= 16'd0;
			oWB_Reg4 <= 16'd0;
			oWB_Reg5 <= 16'd0;
			oWB_Reg6 <= 16'd0;
			oWB_Reg7 <= 16'd0;
			
		end else if( iMA_WBEnb ) case( iMA_WBReg ) /* synopsys parallel_case */
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

module STORM_CORE	input		[8:0]	IF_PC,
	input		[15:0]	IF_IR,
	input		[15:0]	WB_Reg0,
	input		[15:0]	WB_Reg1,
	input		[15:0]	WB_Reg2,
	input		[15:0]	WB_Reg3,
	input		[15:0]	WB_Reg4,
	input		[15:0]	WB_Reg5,
	input		[15:0]	WB_Reg6,
	input		[15:0]	WB_Reg7,
	input				ID_ALUCmd,
	input				ID_DataRdyMA,
	input		[15:0]	ID_Opr1,
	input		[15:0]	ID_Opr2,
	input				ID_FlagsWE,
	input				ID_WBReg,
	input				ID_WBEnb,
	input				ID_DRAM_REnb,
	input				ID_DRAM_WEnb,
	input				ID_RegNumDRAM_WB,
	input		[8:0]	ID_PC,
	input				ID_JmpCond,
	input		[15:0]	EX_Result,
	input				EX_WBReg,
	input				EX_WBEnb,
	input				EX_DRAM_REnb,
	input				EX_PIO_REnb,
	input				EX_ExtB_REnb,
	input		[15:0]	MA_WBData,
	input				MA_WBReg,
	input				MA_WBEnb,
(

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
ALUCMD_SWP,
},

enum tREG {
REG0,
REG1,
REG2,
REG3,
REG4,
REG5,
REG6,
REG7,
},

enum tJCC {
JCC_Z,	JCC_NZ
JCC_S,	JCC_NS,
JCC_O,	JCC_NO,
JCC_C,	JCC_NC,
JCC_BE,	JCC_A,
JCC_L,	JCC_GE,
JCC_LE,	JCC_G,
JCC_NOP,JCC_JMP
},

	input				iClk,			// clock
	input				iRst,			// reset

	output		[8:0]	oData7Seg,		// display 7seg data
	output		[7:0]	oDataLED,		// display 8bit LED data

	input		[15:0]	iIRAM_Data,
	output		[8:0]	oIRAM_Addr,
	input		[15:0]	iDRAM_DataI,
	output		[15:0]	oDRAM_DataO,
	output		[9:0]	oDRAM_Addr,
	output				oDRAM_REnb,
	output				oDRAM_WEnb,

	input		[15:0]	iPIO_DataI,		// PIO data in
	output				oPIO_REnb,		// PIO RE
	output				oPIO_WEnb,		// PIO WE

	input		[15:0]	iExtB_DataI,
	output				oExtB_REnb,		// ExtBord RE ( SW )

	output				oExtB_WEnb		// ExtBord WE ( LED )
1111111111111111111111111111111);
	wire		[8:0]	ID_wPC;
	wire				ID_wSetPC;
	wire		[8:0]	EX_wPC;
	wire				EX_wSetPC;
	wire				ID_wStall;
	wire		[15:0]	IF_wIR;
	input		[8:0]	IF_PC;
	input		[15:0]	IF_IR;
	input		[15:0]	WB_Reg0;
	input		[15:0]	WB_Reg1;
	input		[15:0]	WB_Reg2;
	input		[15:0]	WB_Reg3;
	input		[15:0]	WB_Reg4;
	input		[15:0]	WB_Reg5;
	input		[15:0]	WB_Reg6;
	input		[15:0]	WB_Reg7;
	wire		[15:0]	EX_wWBData;
	wire				EX_wWBReg;
	wire				EX_wWBEnb;
	wire				EX_wDataRdyMA;
	wire				EX_wFlagsWE;
	wire		[15:0]	MA_wWBData;
	wire				MA_wWBReg;
	wire				MA_wWBEnb;
	wire		[15:0]	WB_wWBData;
	wire				WB_wWBReg;
	wire				WB_wWBEnb;
	input				ID_ALUCmd;
	input				ID_DataRdyMA;
	input		[15:0]	ID_Opr1;
	input		[15:0]	ID_Opr2;
	input				ID_FlagsWE;
	input				ID_WBReg;
	input				ID_WBEnb;
	input				ID_DRAM_REnb;
	input				ID_DRAM_WEnb;
	input				ID_RegNumDRAM_WB;
	input		[8:0]	ID_PC;
	input				ID_JmpCond;
	wire		[15:0]	EX_wResult2;
	input		[15:0]	EX_Result;
	input				EX_WBReg;
	input				EX_WBEnb;
	input				EX_DRAM_REnb;
	input				EX_PIO_REnb;
	input				EX_ExtB_REnb;
	input		[15:0]	MA_WBData;
	input				MA_WBReg;
	input				MA_WBEnb;

	assign oData7Seg = WB_Reg0[8:0];
	assign oDataLED  = WB_Reg1[7:0];
	
	IFStage IFStage(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iID_wPC			( ID_wPC				),
		.iID_wSetPC			( ID_wSetPC				),
		.iEX_wPC			( EX_wPC				),
		.iEX_wSetPC			( EX_wSetPC				),
		.iID_wStall			( ID_wStall				),
		.oIF_IRAM_Addr		( oIRAM_Addr			),
		.iIRAM_Data			( iIRAM_Data			),
		.oIF_wIR			( IF_wIR				)
	);
	
	IDStage IDStage(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iIF_PC				( IF_PC					),
		.iIF_IR				( IF_IR					),
		.iIF_wIR			( IF_wIR				),
		.iWB_Reg0			( WB_Reg0				),
		.iWB_Reg1			( WB_Reg1				),
		.iWB_Reg2			( WB_Reg2				),
		.iWB_Reg3			( WB_Reg3				),
		.iWB_Reg4			( WB_Reg4				),
		.iWB_Reg5			( WB_Reg5				),
		.iWB_Reg6			( WB_Reg6				),
		.iWB_Reg7			( WB_Reg7				),
		.iEX_wWBData		( EX_wWBData			),
		.tREG				( 						),
		.iEX_wWBReg			( EX_wWBReg				),
		.iEX_wWBEnb			( EX_wWBEnb				),
		.iEX_wDataRdyMA		( EX_wDataRdyMA			),
		.iEX_wFlagsWE		( EX_wFlagsWE			),
		.iMA_wWBData		( MA_wWBData			),
		.tREG				( 						),
		.iMA_wWBReg			( MA_wWBReg				),
		.iMA_wWBEnb			( MA_wWBEnb				),
		.iWB_wWBData		( WB_wWBData			),
		.tREG				( 						),
		.iWB_wWBReg			( WB_wWBReg				),
		.iWB_wWBEnb			( WB_wWBEnb				),
		.oID_wStall			( ID_wStall				),
		.oID_wPC			( ID_wPC				),
		.oID_wSetPC			( ID_wSetPC				)
	);
	
	EXStage EXStage(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.tALUCMD			( 						),
		.iID_ALUCmd			( ID_ALUCmd				),
		.iID_DataRdyMA		( ID_DataRdyMA			),
		.iID_Opr1			( ID_Opr1				),
		.iID_Opr2			( ID_Opr2				),
		.iID_FlagsWE		( ID_FlagsWE			),
		.tREG				( 						),
		.iID_WBReg			( ID_WBReg				),
		.iID_WBEnb			( ID_WBEnb				),
		.iID_DRAM_REnb		( ID_DRAM_REnb			),
		.iID_DRAM_WEnb		( ID_DRAM_WEnb			),
		.tREG				( 						),
		.iID_RegNumDRAM_WB	( ID_RegNumDRAM_WB		),
		.iID_PC				( ID_PC					),
		.tJCC				( 						),
		.iID_JmpCond		( ID_JmpCond			),
		.iID_wStall			( ID_wStall				),
		.iWB_Reg0			( WB_Reg0				),
		.iWB_Reg1			( WB_Reg1				),
		.iWB_Reg2			( WB_Reg2				),
		.iWB_Reg3			( WB_Reg3				),
		.iWB_Reg4			( WB_Reg4				),
		.iWB_Reg5			( WB_Reg5				),
		.iWB_Reg6			( WB_Reg6				),
		.iWB_Reg7			( WB_Reg7				),
		.iMA_wWBData		( MA_wWBData			),
		.tREG				( 						),
		.iMA_wWBReg			( MA_wWBReg				),
		.iMA_wWBEnb			( MA_wWBEnb				),
		.iWB_wWBData		( WB_wWBData			),
		.tREG				( 						),
		.iWB_wWBReg			( WB_wWBReg				),
		.iWB_wWBEnb			( WB_wWBEnb				),
		.oEX_wResult2		( EX_wResult2			),
		.oEX_wWBData		( EX_wWBData			),
		.tREG				( 						),
		.oEX_wWBReg			( EX_wWBReg				),
		.oEX_wWBEnb			( EX_wWBEnb				),
		.oEX_wDataRdyMA		( EX_wDataRdyMA			),
		.oEX_wFlagsWE		( EX_wFlagsWE			),
		.oEX_DRAM_Addr		( oDRAM_Addr			),
		.oEX_wPC			( EX_wPC				),
		.oEX_wSetPC			( EX_wSetPC				)
	);
	
	assign oDRAM_REnb = EX_DRAM_REnb;
	
	assign oPIO_REnb = EX_PIO_REnb;		// PIO RE
	
	assign oExtB_REnb = EX_ExtB_REnb;	// ExtBord RE ( SW )
	
	MAStage MAStage(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iEX_Result			( EX_Result				),
		.iEX_wResult2		( EX_wResult2			),
		.tREG				( 						),
		.iEX_WBReg			( EX_WBReg				),
		.iEX_WBEnb			( EX_WBEnb				),
		.iEX_DRAM_REnb		( EX_DRAM_REnb			),
		.iDRAM_DataI		( iDRAM_DataI			),
		.iPIO_DataI			( iPIO_DataI			),
		.iEX_PIO_REnb		( EX_PIO_REnb			),
		.iExtB_DataI		( iExtB_DataI			),
		.iEX_ExtB_REnb		( EX_ExtB_REnb			),
		.oMA_wWBData		( MA_wWBData			),
		.tREG				( 						),
		.oMA_wWBReg			( MA_wWBReg				),
		.oMA_wWBEnb			( MA_wWBEnb				)
	);
	
	WBStage WBStage(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iMA_WBData			( MA_WBData				),
		.tREG				( 						),
		.iMA_WBReg			( MA_WBReg				),
		.iMA_WBEnb			( MA_WBEnb				),
		.oWB_wWBData		( WB_wWBData			),
		.tREG				( 						),
		.oWB_wWBReg			( WB_wWBReg				),
		.oWB_wWBEnb			( WB_wWBEnb				)
	);
	
endmodule

/*** 7seg decoder ***********************************************************/

module Seg7Decode(

	input		[3:0]	iData,
	output reg	[6:0]	oSegData
);
	always@( iData ) begin
		case( iData ) /* synopsys parallel_case */		 // GFEDCBA
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

	input				iClk,			// clock
	input				iRst,			// reset ( High active )

	output		[6:0]	oData7Seg0,		// 7seg display data
oData7Seg1,
	output				oData7SegP,		// 7seg 0's dp
	output		[7:0]	oDataLED,		// 8bit LED data

// PIO module I/O

	input		[3:0]	iPData,		// mc
	input		[4:0]	iCtrl,		// ms
	output		[7:0]	oPData,		// md


	wire				DRAM_WEnb,

// LED Matrix/Beep I/O

	output		[9:0]	oLED_Data,		// 1line data
	output		[19:0]	oLED_LineSel,	// line select
	output				oLED_Beep,		// Beep SP

// Push/Dip SW

	input		[7:0]	iPushSW,
	input		[7:0]	iDipSW
);
	wire		[8:0]	Data7Seg;
	wire		[7:0]	DataLED;
	wire		[15:0]	IRAM_Data;
	wire		[8:0]	IRAM_Addr;
	wire		[15:0]	DRAM_DataI;
	wire		[15:0]	DRAM_DataO;
	wire		[9:0]	DRAM_Addr;
	wire				DRAM_REnb;
	wire		[15:0]	PIO_DataI;
	wire				PIO_REnb;
	wire				PIO_WEnb;
	wire		[15:0]	ExtB_DataI;
	wire				ExtB_REnb;
	wire				ExtB_WEnb;

	/*** Delayed Data RAM WEnb **********************************************/
	
	wire	DRAM_WEnbDly;
	
	LCELL	LCELL0( iClk, DlyClk0 );
	LCELL	LCELL1( DlyClk0, DlyClk1 );
	LCELL	LCELL2( DlyClk1, DlyClk2 );
	
	assign DRAM_WEnbDly = DlyClk2 & DRAM_WEnb;
	
	/*** CORE ***************************************************************/
	
	STORM_CORE STORM_CORE(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.oData7Seg			( Data7Seg				),
		.oDataLED			( DataLED				),
		.iIRAM_Data			( IRAM_Data				),
		.oIRAM_Addr			( IRAM_Addr				),
		.iDRAM_DataI		( DRAM_DataI			),
		.oDRAM_DataO		( DRAM_DataO			),
		.oDRAM_Addr			( DRAM_Addr				),
		.oDRAM_REnb			( DRAM_REnb				),
		.oDRAM_WEnb			( DRAM_WEnb				),
		.iPIO_DataI			( PIO_DataI				),
		.oPIO_REnb			( PIO_REnb				),
		.oPIO_WEnb			( PIO_WEnb				),
		.iExtB_DataI		( ExtB_DataI			),
		.oExtB_REnb			( ExtB_REnb				),
		.oExtB_WEnb			( ExtB_WEnb				)
	);
	
	/*** 7seg decoder & LED *************************************************/
	
	Seg7Decode Seg7_0(
		.iData				( Data7Seg[7:4]			)
	);
	
	Seg7Decode Seg7_1(
		.iData				( Data7Seg[3:0]			)
	);
	
	assign oData7SegP	= ~Data7Seg[8];
	assign oDataLED		= ~DataLED;
	
	/*** RAM ****************************************************************/
	
	IRAM IRAM(
		.address			( IRAM_Addr				),
		.q					( IRAM_Data				)
	);
	
	DRAM DRAM(
		.address			( DRAM_Addr				),
		.we					( DRAM_WEnbDly			),
		.data				( DRAM_DataO			),
		.q					( DRAM_DataI			)
	);
	
	/*** parallel I/O module ************************************************/
	
	PIO PIO(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iPData				( iPData				),
		.iCtrl				( iCtrl					),
		.iAddr				( DRAM_Addr				),
		.iData				( DRAM_DataO			),
		.iREnb				( PIO_REnb				),
		.iWEnb				( PIO_WEnb				),
		.oData				( PIO_DataI				)
	);
	
	/*** LED Matrix/Beep module *********************************************/
	
	LEDMatrix LEDMatrix(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iAddr				( DRAM_Addr				),
		.iData				( DRAM_DataO			),
		.iWEnb				( ExtB_WEnb				)
	);
	
	/*** Push/Dip SW module *************************************************/
	
	
	InputSW InputSW(
		.iClk				( iClk					),
		.iRst				( iRst					),
		.iPushSW			( iPushSW				),
		.iDipSW				( iDipSW				),
		.iREnb				( ExtB_REnb				),
		.iAddr				( DRAM_Addr				),
		.oData				( ExtB_DataI			)
	);
endmodule

/*** other modules **********************************************************/

/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		PIO.def.v -- parallel port I/O module

2001.11.23	clear OutDataBuf when input data from PC
2002.02.23	delete read from PC sequence FSM

*****************************************************************************/





module PIO(

	input				iClk,		// clk
	input				iRst,		// reset

// from / to PIO
	input		[3:0]	iPData,		// mc
	input		[4:0]	iCtrl,		// ms
	output reg	[7:0]	oPData,		// md

// from / to CPU
	input		[9:0]	iAddr,		// port address
	input		[15:0]	iData,		// data in
	input				iREnb,		// port read enb
	input				iWEnb,		// port write enb
	output		[15:0]	oData		// stat / addr / data out
);

// wire / reg

reg		[3:0]	Cmd;		// command register
//reg		tPORT	PortIn;		// input port#
reg		[7:0]	DataIn;		// input data
reg		[3:0]	PortOut;	// output port#
reg		[7:0]	DataOut;	// output data

reg				BFullIn;	// input buffer full
reg				BFullOut;	// output buffer full

	/*** command register ***************************************************/
	
	always@( posedge iClk or posedge iRst ) if( iRst ) Cmd <= 0; else if( ( iCtrl[1] && !iCtrl[0] ) ) Cmd <= iPData;
	
	/*** PIO input **********************************************************/
	
	wire	SetDL,	// data (L) we
			SetDH;	// data (H) we
	reg		SetDH_Tn1;
	
	assign SetDL = ( Cmd == 4'h2 && iCtrl[2] &&  iCtrl[0] );
	assign SetDH = ( Cmd == 4'h2 && iCtrl[3] && !iCtrl[0] );
	
	always@( posedge iClk or posedge iRst ) if( iRst ) SetDH_Tn1 <= 0; else SetDH_Tn1 <= SetDH;
	wire SetDHRaise = !SetDH_Tn1 && SetDH;
	
	always@( posedge iClk or posedge iRst ) if( iRst ) DataIn[3:0] <= 0; else if( SetDL ) DataIn[3:0] <= iPData;
	always@( posedge iClk or posedge iRst ) if( iRst ) DataIn[7:4] <= 0; else if( SetDH ) DataIn[7:4] <= iPData;
	
	always@( posedge iClk or posedge iRst ) begin
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
	
	always@( posedge iClk or posedge iRst ) if( iRst ) PortOut <= 0; else if( iWEnb && !BFullOut ) PortOut <= iAddr;
	always@( posedge iClk or posedge iRst ) if( iRst ) DataOut <= 0; else if( iWEnb && !BFullOut ) DataOut <= iData;
	
	// read complete signal
	
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst )
			BFullOut = 0;
		else if(
			SetDHRaise
		)
			// read complete, or input from PC, then clear out buffer
			BFullOut = 0;
		else if( iWEnb )
			// if write by CPU, buffer full
			BFullOut = 1;
	end
	
	always@( PortOut or DataOut or Cmd or BFullOut ) begin
		case( Cmd ) /* synopsys parallel_case */
			4'h9:	oPData = {
							~BFullOut,	// 7 : read data is invalid
							3'd0,		// 6 - 4
							PortOut		// 3 - 0 port address
						};
			4'hA:	oPData = DataOut;
			default:	oPData = 8'bx;
		endcase
	end
endmodule

/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		EXTBoard.def.v -- LED Matrix & input sw board I/F

2001.11.08	automatic anti-chattering

*****************************************************************************/





/*** LED Matrix & Beep SP ***************************************************/

module LEDMatrix(
	input				iClk,
	input				iRst,

// from / to Ext Board

	output reg	[9:0]	oLED_Data,		// 1line data
	output reg	[19:0]	oLED_LineSel,	// line select
	output reg			oLED_Beep,		// Beep SP

// from / to CPU
	input		[9:0]	iAddr,			// port address
	input		[15:0]	iData,			// data in
	input				iWEnb			// port write enb
);

// local I/O address
wire	[3:0]	Addr = iAddr;

	/*** LED Matrix registers ***********************************************/
	
	wire	[4:0]	LineSelCnt = iData;
	reg		[9:0]	LED_Data;
	
	/*** scan line out ***/
	
	always@( posedge iClk or posedge iRst ) if( iRst ) begin
		oLED_LineSel <= 20'hFFFFF;
		oLED_Data	 <= 0;
		
	end else if( iWEnb && Addr == 1 ) begin
		case( LineSelCnt ) /* synopsys parallel_case */
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
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst ) begin
			LED_Data	<= 0;
		end else if( iWEnb && Addr == 0 ) begin
			LED_Data	<= iData;
		end
	end
	
	/*** Beep SP out ********************************************************/
	
	reg		[15:0]	BeepCntDivider,
					BeepCntDivident;
	reg		[19:0]	BeepCnt;
	wire	[19:0]	BeepCntInc = BeepCnt + 1;
	
	// Beep frequency setting reg
	
	always@( posedge iClk or posedge iRst ) if( iRst ) BeepCntDivider <= 0; else if( ( iWEnb && Addr == 2 ) ) BeepCntDivider <= iData;
	
	always@( posedge iClk or posedge iRst ) if( iRst ) BeepCntDivident <= 0; else if( ( iWEnb && Addr == 3 ) ) BeepCntDivident <= iData;
	
	// Beep counter
	
	always@( posedge iClk or posedge iRst ) begin
		if( iRst )	BeepCnt	<= 0;
		else if(( ( BeepCntInc[18:3] ) == BeepCntDivider ) ||
				( iWEnb && Addr == 2 ))
					BeepCnt <= 0;
		else		BeepCnt <= BeepCntInc;
	end
	
	// Beep out
	always@( posedge iClk or posedge iRst ) if( iRst ) oLED_Beep <= 1; else oLED_Beep <= ( ( BeepCnt[18:3] ) >= BeepCntDivident );
	
endmodule

/*** input SW ***************************************************************/

module InputSW(
	input				iClk,
	input				iRst,

// from / to EXT Board
	input		[7:0]	iPushSW,
	input		[7:0]	iDipSW,
	input				iREnb,

// from / to CPU
	input		[9:0]	iAddr,			// port address
	output		[15:0]	oData			// stat / addr / data out
);

// I/O local addr
wire	[3:0]	Addr = iAddr;

reg		[7:0]	PushSW,
				DipSW;

reg		[7:0]	SamplingCnt;	// sampling counter for anti-chattering

	always@( posedge iClk or posedge iRst ) begin
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
	
	assign oData = ( Addr == 0 ) ? PushSW : DipSW;
	
endmodule
