/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		local.c --- target macro file support

*****************************************************************************/
/*
stack frame structure:

LO			[CalleeSaveReg]		<-- SP
			[CalleeSaveReg]
				...
			[CalleeSaveReg]
			[LocalVar]
			[LocalVar]
				...
			[LocalVar]
			[Arg]				<-- FP
			[Arg]
			...
HI			[Arg]

*****************************************************************************/

#include "config.h"
#include "system.h"
#include "tree.h"
#include "rtl.h"
#include "regs.h"
#include "hard-reg-set.h"
#include "real.h"
#include "insn-config.h"
#include "conditions.h"
#include "output.h"
#include "insn-attr.h"
#include "flags.h"
#include "function.h"
#include "expr.h"
#include "recog.h"
#include "toplev.h"
#include "tm_p.h"

/*** macros *****************************************************************/

//#define DEBUG

#define min( a, b )	(( a )<( b )?( a ):( b ))
#define max( a, b )	(( a )>( b )?( a ):( b ))

#define DebugMsg( s )	//printf( s )

/*** gloval var definition **************************************************/

char	*pTargetMaxRegNum	= NULL,		/* target マシンで使用可能な reg 数	*/
		*pMaxFuncArgRegNum	= NULL,		/* 引数渡しに使えるレジスタの *数*	*/
		*pCalleeSaveRegNum	= NULL;		/* callee save が必要な 先頭 reg#	*/

UINT	uTargetMaxRegNum	= 8,		/* target マシンで使用可能な reg 数	*/
		uMaxFuncArgRegNum	= 4,		/* 引数渡しに使えるレジスタの *数*	*/
		uCalleeSaveRegNum	= 4;		/* callee save が必要な 先頭 reg#	*/

char	pcUsedReg[ STORM_MAX_REGNUM ] = { 0 };/* reg 使用履歴				*/
char	pcRealRegNum[ STORM_MAX_REGNUM ] = { STORM_MAX_REGNUM };
										/* 使用可 reg のリナンバリング		*/

/*** get callee-save-reg num. ***********************************************/

int GetCalleeSaveRegNum( void ){
	
	int	num = 0,
		reg;
	
	/* if "main", no need save callee reg */
	if( strcmp( current_function_name, "main" )){
		for( reg = 0; reg < FIRST_PSEUDO_REGISTER; ++reg ){
			if( regs_ever_live[ reg ] && !call_used_regs[ reg ] ) ++num;
		}
	}
	return( num );
}

/*** compute difference between FP & SP *************************************/

void StormInitialEliminationOffset(
	int	from_reg,
	int	to_reg,
	int	*offset ){
	
	if( from_reg != FRAME_POINTER_REGNUM ||
		to_reg   != STACK_POINTER_REGNUM ) abort();
	
	*offset = GetCalleeSaveRegNum() + get_frame_size();
}

/*** output function information ********************************************/

#ifdef _DEBUG
void PrintFuncInfo( FILE *fp, int size ){
	
	int	reg;
	
	fprintf( fp, "\t# name : %s\n", current_function_name );
	
	fprintf( fp, "\t# live " );
	for( reg = 0; reg < FIRST_PSEUDO_REGISTER; ++reg )
		fprintf( fp, "%d", regs_ever_live[ reg ]);
	
	fprintf( fp, "\n\t# call " );
	for( reg = 0; reg < FIRST_PSEUDO_REGISTER; ++reg )
		fprintf( fp, "%d", call_used_regs[ reg ]);
	fprintf( fp, "\n" );
	
	fprintf( fp, "\t# size=%d arg=%d fp=%d fsize=%d\n",
		size, current_function_pretend_args_size, frame_pointer_needed,
		get_frame_size() );
}
#endif /* _DEBUG */

/*** function prologure *****************************************************/

void StormFunctionPrologue( FILE *fp, int size ){
	
	int reg,
		iSaveRegNum,
		i;
	
#ifdef _DEBUG
	PrintFuncInfo( fp, size );
#endif
	
	/* record reg usage log */
	for( reg = 0; reg < STORM_MAX_REGNUM; ++reg )
		pcUsedReg[ reg ] |= regs_ever_live[ reg ];
	
	/* setup sp */
	/*
	if( !strcmp( current_function_name, "main" ))
		fprintf( fp, "\tmov\tr%d, 0x3FF\n", STACK_POINTER_REGNUM );
	*/
	
	iSaveRegNum = GetCalleeSaveRegNum();
	
	/* sp -= ( frame_size + iSaveRegNum ) */
	if( i = size + iSaveRegNum ){
		for( ; i > 128; i -= 128 ){
			fprintf( fp, "\tadd\tr%d, -128\n", STACK_POINTER_REGNUM );
		}
		fprintf( fp, "\tadd\tr%d, -%d\n", STACK_POINTER_REGNUM, i );
	}
	
	/* push callee-save register */
	if( iSaveRegNum ){
		i = 0;
		for( reg = 0; reg < FIRST_PSEUDO_REGISTER; ++reg ){
			if( regs_ever_live[ reg ] && !call_used_regs[ reg ]){
				
				fprintf( fp, "\tmov\t[r%d+%d], r%d\n",
					STACK_POINTER_REGNUM, i++, reg );
			}
		}
	}
	
	/* setup fp = sp + ( frame_size + iSaveRegNum ) */
	if( frame_pointer_needed ){
		fprintf( fp, "\tmov\tr%d, r%d\n",
			FRAME_POINTER_REGNUM, STACK_POINTER_REGNUM );
		
		if( i = size + iSaveRegNum ){
			for( ; i > 128; i -= 128 ){
				fprintf( fp, "\tsub\tr%d, -128\n", FRAME_POINTER_REGNUM );
			}
			fprintf( fp, "\tsub\tr%d, -%d\n", FRAME_POINTER_REGNUM, i );
		}
	}
	
#ifdef _DEBUG
	fprintf( fp, "\t# E.O.function prologue\n" );
#endif
}

/*** function epilogure *****************************************************/

void StormFunctionEpilogue( FILE *fp, int size ){
	
	int	reg,
		iSaveRegNum,
		i;
	
#ifdef _DEBUG
	PrintFuncInfo( fp, size );
#endif
	
	if( strcmp( current_function_name, "main" )){
		
		iSaveRegNum = GetCalleeSaveRegNum();
		
		/* if fp is used, gen. code --> mov [sp-1],fp; restore fp; mov sp,[sp-1] */
		if( frame_pointer_needed ){
			fprintf( fp, "\tmov\t[r%d-1], r%d\n",
				STACK_POINTER_REGNUM, FRAME_POINTER_REGNUM
			);
		}
		
		/* pop callee-save register */
		if( iSaveRegNum ){
			i = iSaveRegNum - 1;
			for( reg = FIRST_PSEUDO_REGISTER - 1; reg >= 0; --reg ){
				if( regs_ever_live[ reg ] && !call_used_regs[ reg ]){
					
					fprintf( fp, "\tmov\tr%d, [r%d+%d]\n",
						reg, STACK_POINTER_REGNUM, i-- );
				}
			}
		}
		
		if( !frame_pointer_needed ){
			/* if i > 128, then sp += 128 while( i <= 128 ) */
			for( i = size + iSaveRegNum; i > 128; i -= 128 ){
				fprintf( fp, "\tsub\tr%d, -128\n", STACK_POINTER_REGNUM );
			}
		}
		
		/* return */
		fprintf( fp, "\tret\n" );
		
		if( frame_pointer_needed ){
			/* if fp is used, sp's original value is in fp */
			fprintf( fp,"\tmov\tr%d, [r%d-1]\n",
				STACK_POINTER_REGNUM, STACK_POINTER_REGNUM
			);
		}else{
			/* sp -= ( frame_size + iSaveRegNum ) ( in delay slot ) */
			fprintf( fp, i ? "\tsub\tr%d, -%d\n" : "\tnop\n",
				STACK_POINTER_REGNUM, i
			);
		}
	}else{
		/* main()'s epilogue code */
		fprintf( fp, "\thlt\n" );
	}
}

/*** library function setup *************************************************/

void StormInitTargetOptabs( void ){
	
	smul_optab->handlers[( int )QImode ].libfunc
		= gen_rtx (SYMBOL_REF, Pmode, "_mul" );
	
	sdiv_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_idiv" );
	
	udiv_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_div" );
	
	smod_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_imod" );
	
	umod_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_mod" );
	
	ashl_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_shl" );
	
	ashr_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_sar" );
	
	lshr_optab->handlers[( int )QImode ].libfunc
		= gen_rtx( SYMBOL_REF, Pmode, "_shr" );
}

/*** initialize FIXED_REGISTERS / CALL_USED_REGISTERS ***********************/

void StormConditionalRegUsage( void ){
#if 0
	
	UINT	u,
			uRealNum;
	
	/* setup register class */
	if( pTargetMaxRegNum != NULL ){
		u = atoi( pTargetMaxRegNum );
		uTargetMaxRegNum  = min( max( STORM_MIN_REGNUM, u ), STORM_MAX_REGNUM );
	//	uMaxFuncArgRegNum = uTargetMaxRegNum - STORM_RESERVED_REGNUM;
		uMaxFuncArgRegNum = uTargetMaxRegNum / 2;
		uCalleeSaveRegNum = uTargetMaxRegNum / 2;
	}
	
	if( pMaxFuncArgRegNum != NULL ){
		u = atoi( pMaxFuncArgRegNum );
		uMaxFuncArgRegNum = min( max( 0, u ), STORM_MAX_REGNUM );
	}
	
	if( pCalleeSaveRegNum != NULL ){
		u = atoi( pCalleeSaveRegNum );
		uCalleeSaveRegNum = min( max( 0, u ), STORM_MAX_REGNUM );
	}
	
	// renumbering
	uRealNum = 0;
	
	for( u = 0; u < STORM_MAX_REGNUM; ++u ){
		if( u ==( uTargetMaxRegNum - STORM_RESERVED_REGNUM ))
			u = STORM_MAX_REGNUM - STORM_RESERVED_REGNUM;
		
		pcRealRegNum[ u ] = uRealNum++;
	}
	
	for( u = 0; u < uTargetMaxRegNum - STORM_RESERVED_REGNUM; ++u )
		fixed_regs[ u ] = 0;
	
	for( u = 0; u < STORM_MAX_REGNUM; ++u ){
		if( fixed_regs[ u ] == 0 && pcRealRegNum[ u ] >= uCalleeSaveRegNum )
			call_used_regs[ u ] = 0;
	}
#endif
}

/****************************************************************************/

void StormNoticeUpdateCc( rtx exp, rtx insn ){
	
	CC_STATUS_INIT;
	
	if( GET_CODE( exp )== SET ){
		switch ( GET_CODE( SET_SRC( exp ))){
		  case PLUS:
		  case MINUS:
		  case AND:
		  case IOR:
		  case XOR:
		  case NOT:
		  case NEG:
		  case ASHIFT:
		  case ASHIFTRT:
		  case LSHIFTRT:
			cc_status.value1 = SET_SRC( exp );
			
			if( SET_DEST( exp ) != cc0_rtx )
				cc_status.value2 = SET_DEST( exp );
		  default:
			break;
		}
	}
}

/*** asm file header ********************************************************/

void StormAsmFileStart( FILE *fp ){
	fputs(
		"# generated by gcc for STORM\n"
		, fp );
}

/*** asm file footer ********************************************************/

void StormAsmFileEnd( FILE *fp ){
	/*
	UINT	u;
	
	fprintf( fp,
		"\n"
		"# register usage report:\n"
		"# MaxReg:%d FuncArg:%d CalleeSave:%d\n"
		"# used :",
		uTargetMaxRegNum, uMaxFuncArgRegNum, uCalleeSaveRegNum );
	
	for( u = 0; u < FIRST_PSEUDO_REGISTER; ++ u )
		fprintf( fp, "%d", pcUsedReg[ u ] );
	
	fputs( "\n# call :", fp );
	
	for( u = 0; u < FIRST_PSEUDO_REGISTER; ++ u )
		fprintf( fp, "%d", call_used_regs[ u ] );
	
	fputc( '\n', fp );
	*/
}

/*** output operand *********************************************************/

void StormPrintOperand( FILE *fp, rtx x, int code ){
	
	int	iSlot;
	int iFilledSlot;
	
	switch( code ){
		
		/*** fill delay slot ************************************************/
		
	  case '#':
		/*
		iSlot = 1;
		goto FillSlot;
		*/
		
	  case '@':
		/*
		iSlot = 3;
		
	  FillSlot:
		while( iFilledSlot++ < iSlot ) fprintf( fp, "\n\tnop\t# slot" );
		*/
		fprintf( fp, ", %d", dbr_sequence_length());
		break;
		
	  case 'S':	// shift operator
		switch( GET_CODE( x )){
		  case ASHIFT:		fputs( "shl", fp ); break;
		  case ASHIFTRT:	fputs( "sar", fp ); break;
		  case LSHIFTRT:	fputs( "shr", fp ); break;
		  default:			abort();
		}
		break;
		
		/*** normal operand *************************************************/
		
	  default:
		switch( GET_CODE( x )){
		  case REG:
			fprintf( fp, "%s", reg_names[ REGNO( x ) ] );
			break;
			
		  case MEM:
			output_address( XEXP( x, 0 ));
			break;
			
		  case CONST_DOUBLE:
			abort();
			break;
			
		  default:
			output_addr_const( fp, x );
		}
	}
}

void StormPrintOperandAddress( FILE *fp, rtx x ){
	
	switch( GET_CODE( x )){
	  case REG:
		fprintf( fp, "[%s]", reg_names[ REGNO( x )]);
		break;
		
	  case PLUS:
		fprintf( fp, "[%s", reg_names[ REGNO( XEXP( x, 0 )) ] );
		if( INTVAL( XEXP( x, 1 )) >= 0 ) fputc( '+', fp );
		output_addr_const( fp, XEXP( x, 1 ));
		fputc( ']', fp );
		break;
		
	  default:
		fprintf( fp, "[" );
		output_addr_const( fp, x );
		fprintf( fp, "]" );
	}
}

/*** match operator for shift ***********************************************/

int shift_operator( rtx x, enum machine_mode mode ){
	
	if( GET_MODE( x ) != mode ) return FALSE;
	
	{
		enum rtx_code code = GET_CODE( x );
		
		return(
			code == ASHIFT		||
			code == ASHIFTRT	||
			code == LSHIFTRT	/*||
			code == ROTATERT*/
		);
	}
}

/*** load / store operands ( not include [r7] ) *****************************/

#if 0
int StormIsRegR7( rtx x ){
	return(
		REG_P( x )	&& (
			REGNO( x ) == RETURN_ADDR_REGNUM	||
			REGNO( x ) <  FIRST_PSEUDO_REGISTER	&&
			( unsigned )reg_renumber[ REGNO( x ) ] == RETURN_ADDR_REGNUM
		)
	);
}

int StormMemRefR7( rtx x ){
	
	#ifdef DEBUG
		if( GET_CODE( x ) == MEM ){
			printf( "MemRef:" );
			
			if( REG_P( XEXP( x, 0 ))){
				printf( "Reg:%d", REGNO( XEXP( x, 0 )));
			}else{
				printf( "other" );
			}
			printf( "\n" );
		}
	#endif
	
	return( GET_CODE( x ) == MEM && StormIsRegR7( XEXP( x, 0 )));
}

int StormMemRefNotR7( rtx x ){
	
	#ifdef DEBUG
		if( GET_CODE( x ) == MEM ){
			printf( "MemRef:" );
			
			if( REG_P( XEXP( x, 0 ))){
				printf( "Reg:%d", REGNO( XEXP( x, 0 )));
			}else{
				printf( "other" );
			}
			printf( "\n" );
		}
	#endif
	
	return( !(
		GET_CODE( x ) == MEM	&&
		REG_P( XEXP( x, 0 ))	&& (
			REGNO( XEXP( x, 0 )) == RETURN_ADDR_REGNUM		||
			REGNO( XEXP( x, 0 )) <  FIRST_PSEUDO_REGISTER	&&
			( unsigned )reg_renumber[ REGNO( XEXP( x, 0 )) ] == RETURN_ADDR_REGNUM
		)
	));
}

int load_operand( rtx x, enum machine_mode mode ){
	
	//if( GET_MODE( x ) != mode ) return( FALSE );
	return( general_operand( x, mode ) && StormMemRefNotR7( x ));
}

int store_operand( rtx x, enum machine_mode mode ){
	
	//if( GET_MODE( x ) != mode ) return( FALSE );
	return( nonimmediate_operand( x, mode ) && StormMemRefNotR7( x ));
}
#endif

/*** EXTRA_CONSTRAINT *******************************************************/

#if 0
int StormRegOKForBaseReg( rtx x ){
	
	int iRegNo;
	
	DebugMsg( ">StormRegOKForBaseReg\n" );
	
	if( REG_P( x )){
		iRegNo = REGNO( x );
		
		DebugMsg( "<StormRegOKForBaseReg\n" );
		
		/*
		return(
			iRegNo >= FIRST_PSEUDO_REGISTER ||
			iRegNo == 0 || ( unsigned )reg_renumber[ iRegNo ] == 0 ||
			iRegNo == 1 || ( unsigned )reg_renumber[ iRegNo ] == 1 ||
			iRegNo == 4 || ( unsigned )reg_renumber[ iRegNo ] == 4 ||
			iRegNo == 5 || ( unsigned )reg_renumber[ iRegNo ] == 5
		);
		*/
		return(
		//	iRegNo >= FIRST_PSEUDO_REGISTER ||
			iRegNo == 0 ||
			iRegNo == 1 ||
			iRegNo == 4 ||
			iRegNo == 5
		);
	}
	
	DebugMsg( "<StormRegOKForBaseReg\n" );
	return( 0 );
}
#endif

int StormExtraConstraint( rtx x, char c ){
	
	DebugMsg( ":StormExtraConstraint\n" );
	
	return(
		
		/*
		// [imm] / [r0145] / [???+???]
		c == 'Q' ?
			StormExtraConstraint( x, 'R' )	||
			GET_CODE( x ) == MEM && CONSTANT_ADDRESS_P( XEXP( x, 0 ))		:
		*/
		
		/*
		// [r0145] / [???+???]
		c == 'R' ? GET_CODE( x ) == MEM && (
		//	StormRegOKForBaseReg( XEXP( x, 0 )) ||
			RTX_OK_FOR_BASE_P( XEXP( x, 0 ))	&&
			GET_CODE( XEXP( x, 0 )) == PLUS
		)																	:
		*/
		
		/*
		// [imm] / [r7]
		c == 'S' ? GET_CODE( x ) == MEM && (
			CONSTANT_ADDRESS_P( XEXP( x, 0 )) ||
			StormMemRefR7( x )
		)																	:
		
		// [imm]
		c == 'T' ? GET_CODE( x ) == MEM && CONSTANT_ADDRESS_P( XEXP( x, 0 )):
		*/
		
		0
	);
}

/*** GO_IF_LEGITIMATE_ADDRESS ***********************************************/

int StormGoIfLegitimateAddress( enum machine_mode mode, rtx x ){
	
	DebugMsg( ":StormGoIfLegitimateAddress\n" );
	
	// data mem ref
	return(
		CONSTANT_ADDRESS_P( x )		||
		RTX_OK_FOR_BASE_P( x )		|| (
			GET_CODE( x )== PLUS				&&
			RTX_OK_FOR_BASE_P( XEXP( x, 0 ))	&&
			RTX_OK_FOR_OFFSET_P( XEXP( x, 1 ))
		)
	);
}
