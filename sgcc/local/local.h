/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		local.h -- target macro for STORM

*****************************************************************************/

typedef unsigned	UINT;

/*
void StormInitialEliminationOffset( int, int, int );
void StormFunctionPrologue();
void StormFunctionEpilogue();
void StormInitTargetOptabs( void );
void StormNoticeUpdateCc();
void StormAsmFileStart();
void StormAsmFileEnd();
void StormPrintOperand();
void StormPrintOperandAddress();
int StormExtraConstraint();
int StormGoIfLegitimateAddress();
*/

extern char	*pTargetMaxRegNum,			/* target マシンで使用可能な reg 数	*/
			*pMaxFuncArgRegNum,			/* 引数渡しに使えるレジスタの *数*	*/
			*pCalleeSaveRegNum;			/* callee save が必要な 先頭 reg#	*/

extern UINT	uMaxFuncArgRegNum;
extern char	pcRealRegNum[];

/*** Run-time Target ********************************************************/

#define CPP_PREDEFINES "-DSTORM -Acpu(storm) -Amachine(storm)"
#define TARGET_DEFAULT 0
#define TARGET_SWITCHES { { "", 0 } }

/*
#define TARGET_OPTIONS	{ \
	{ "max-regnum-",			&pTargetMaxRegNum },	\
	{ "arg-regnum-",			&pMaxFuncArgRegNum },	\
	{ "callee-save-regnum-",	&pCalleeSaveRegNum }};
*/

#define TARGET_VERSION { fprintf (stderr, " (storm)"); }
#define CAN_DEBUG_WITHOUT_FP

extern int target_flags;

/*** Storage Layout *********************************************************/

#define BITS_BIG_ENDIAN				0
#define BYTES_BIG_ENDIAN			0
#define WORDS_BIG_ENDIAN			0
#define BITS_PER_UNIT				16
#define BITS_PER_WORD				16
#define UNITS_PER_WORD				1
#define POINTER_SIZE				16
#define PARM_BOUNDARY				16
#define STACK_BOUNDARY				16
#define FUNCTION_BOUNDARY			16
#define BIGGEST_ALIGNMENT			16
#define EMPTY_FIELD_BOUNDARY		16
#define STRICT_ALIGNMENT			1
#define PCC_BITFIELD_TYPE_MATTERS	1
#define TARGET_FLOAT_FORMAT			IEEE_FLOAT_FORMAT

/*** Type Layout ************************************************************/

#define DEFAULT_SIGNED_CHAR	0

#define TARGET_BELL		007
#define TARGET_BS		010
#define TARGET_TAB		011
#define TARGET_NEWLINE	012
#define TARGET_VT		013
#define TARGET_FF		014
#define TARGET_CR		015

/*** Registers **************************************************************/

/* Register Basics */

#define FIRST_PSEUDO_REGISTER	STORM_MAX_REGNUM
#define FIXED_REGISTERS			{ 0, 0, 0, 0, 0, 1, 0, 0 }
#define CALL_USED_REGISTERS		{ 1, 1, 1, 1, 0, 1, 0, 0 }

#define CONDITIONAL_REGISTER_USAGE	StormConditionalRegUsage();

/* Allocation Order */

//						 r0 r1 r2 r3 r4 r5 r6 r7
#define REG_ALLOC_ORDER	{ 0, 1, 2, 3, 4, 7, 5, 6 }

/* Values in Registers */

#define HARD_REGNO_NREGS(REGNO, MODE) (GET_MODE_SIZE ((MODE)))

#define HARD_REGNO_MODE_OK(REGNO, MODE)	1
#define MODES_TIEABLE_P(MODE1, MODE2)	1

/* Leaf Functions */
/* Stack Registers */
/* Obsolete Register Macros */

/*** Register Classes *******************************************************/

enum reg_class {
	NO_REGS, BASE_REGS, LOAD_REGS, ALL_REGS, LIM_REG_CLASSES
};

#define GENERAL_REGS			ALL_REGS
#define N_REG_CLASSES			((int) LIM_REG_CLASSES)
#define REG_CLASS_NAMES { \
	"NO_REGS", "BASE_REGS", "LOAD_REGS", "ALL_REGS" }

#define REG_CLASS_CONTENTS { \
	0, 0x33, 0x0F, 0xFF \
}

#define REGNO_REG_CLASS(REGNO)			ALL_REGS
#define BASE_REG_CLASS					BASE_REGS
#define INDEX_REG_CLASS					NO_REGS

#define REG_CLASS_FROM_LETTER( C )		(( C ) == 'l' ? LOAD_REGS : NO_REGS )

#define REGNO_OK_FOR_BASE_P( NUM )	( \
	( NUM ) == 0 || ( unsigned )reg_renumber[ NUM ] == 0 || \
	( NUM ) == 1 || ( unsigned )reg_renumber[ NUM ] == 1 || \
	( NUM ) == 4 || ( unsigned )reg_renumber[ NUM ] == 4 || \
	( NUM ) == 5 || ( unsigned )reg_renumber[ NUM ] == 5 )
/*
#define REGNO_OK_FOR_BASE_P( NUM )	( \
	( NUM ) < FIRST_PSEUDO_REGISTER || \
	( unsigned )reg_renumber[ NUM ] < FIRST_PSEUDO_REGISTER )
*/

#define REGNO_OK_FOR_INDEX_P(NUM)			0

#define PREFERRED_RELOAD_CLASS( X, CLASS )	(				\
	( GET_CODE( X ) == CONST_INT && !INT_11( INTVAL( X )))	\
		? ( LOAD_REGS ) : ( CLASS ))

#define SMALL_REGISTER_CLASSES				1
#define CLASS_MAX_NREGS(CLASS, MODE)		( HARD_REGNO_NREGS( 0, ( MODE )))

// this is STORM local macro
#define INT_8( x )	( -128  <= ( x ) && ( x ) <=  127 )
#define INT_11( x )	( -1024 <= ( x ) && ( x ) <= 1023 )

#define CONST_OK_FOR_LETTER_P( VALUE, C )	(	\
	( C ) == 'I' ? INT_8( VALUE )	:			\
	( C ) == 'J' ? INT_11( VALUE )	:			\
	0 )

#define CONST_DOUBLE_OK_FOR_LETTER_P( VALUE, C )	0

#define EXTRA_CONSTRAINT( OP, C )	StormExtraConstraint(( OP ), ( C ))

/*** Stack and Calling ******************************************************/

/* Frame Layout */

#define STACK_GROWS_DOWNWARD
#define FRAME_GROWS_DOWNWARD
#define STARTING_FRAME_OFFSET		0
#define FIRST_PARM_OFFSET(FNDECL)	0

/* Frame Registers */

#define STACK_POINTER_REGNUM	5
#define FRAME_POINTER_REGNUM	4
#define ARG_POINTER_REGNUM		FRAME_POINTER_REGNUM
#define STATIC_CHAIN_REGNUM		6

/* Elimination */

#define FRAME_POINTER_REQUIRED	0

#define ELIMINABLE_REGS \
	{{ FRAME_POINTER_REGNUM, STACK_POINTER_REGNUM }}

#define CAN_ELIMINATE(FROM_REG, TO_REG)	1

#define INITIAL_ELIMINATION_OFFSET(FROM_REG, TO_REG, OFFSET_VAR) \
	StormInitialEliminationOffset(( FROM_REG ), ( TO_REG ), &( OFFSET_VAR ))

/* Stack Arguments */

#define RETURN_POPS_ARGS(FUNDECL, FUNTYPE, STACK_SIZE)	0

/* Register Arguments */

#define FUNCTION_ARG(CUM, MODE, TYPE, NAMED) \
  (( NAMED )&&( CUM ) + GET_MODE_SIZE( MODE ) <= MAX_FUNC_ARG_REGNUM \
   ? gen_rtx( REG, ( MODE ), ( CUM )) \
   : NULL_RTX )

#define FUNCTION_ARG_PARTIAL_NREGS(CUM, MODE, TYPE, NAMED)	0

#define FUNCTION_ARG_PASS_BY_REFERENCE(CUM, MODE, TYPE, NAMED) \
  MUST_PASS_IN_STACK ((MODE), (TYPE))

#define CUMULATIVE_ARGS int

#define INIT_CUMULATIVE_ARGS(CUM,FNTYPE,LIBNAME,INDIRECT) \
  ((CUM) = 0)

#define FUNCTION_ARG_ADVANCE(CUM, MODE, TYPE, NAMED) \
  ((CUM) += GET_MODE_SIZE ((MODE)))

#define FUNCTION_ARG_REGNO_P(REGNO) \
  ((REGNO) < MAX_FUNC_ARG_REGNUM )

/* Scalar Return */

#define FUNCTION_VALUE(VALTYPE, FUNC) \
  (gen_rtx (REG, TYPE_MODE ((VALTYPE)), 0))

#define LIBCALL_VALUE(MODE) \
  (gen_rtx (REG, (MODE), 0))

#define FUNCTION_VALUE_REGNO_P(REGNO) \
  ((REGNO) == 0)

/* Aggregate Return */

#define RETURN_IN_MEMORY(TYPE)		(int_size_in_bytes ((TYPE)) > 2)
#define DEFAULT_PCC_STRUCT_RETURN	0
#define STRUCT_VALUE_REGNUM			0

/* Caller Saves */
/* Function Entry */

#define FUNCTION_PROLOGUE(FILE, SIZE) StormFunctionPrologue(( FILE ), ( SIZE ))
#define FUNCTION_EPILOGUE(FILE, SIZE) StormFunctionEpilogue(( FILE ), ( SIZE ))

/* Profiling */

#define FUNCTION_PROFILER(FILE, LABELNO) \
  { abort (); }

/*** Trampolines ***/

#define TRAMPOLINE_TEMPLATE(FILE)	{ abort(); }
#define INITIALIZE_TRAMPOLINE(ADDR, FNADDR, STATIC_CHAIN)	{ abort (); }
#define TRAMPOLINE_SIZE 0

/*** Library Calls ***/

#define	INIT_TARGET_OPTABS	StormInitTargetOptabs()

/*** Addressing Modes ***/

#define CONSTANT_ADDRESS_P(X)	( CONSTANT_P(( X )))
#define MAX_REGS_PER_ADDRESS	1

#define REG_OK_FOR_BASE_P_STRICT(X, STRICT) \
   (( STRICT ) || ( unsigned )( REGNO( X )) < FIRST_PSEUDO_REGISTER \
	? REGNO_OK_FOR_BASE_P( REGNO( X )) \
	: 1 )

// this is STORM local macro
#define RTX_OK_FOR_BASE_P( X )		( REG_P( X ) && REG_OK_FOR_BASE_P( X ))
#define RTX_OK_FOR_OFFSET_P( X )	\
			( GET_CODE( X ) == CONST_INT && INT_8( INTVAL( X )))

#define GO_IF_LEGITIMATE_ADDRESS( MODE, X, LABEL )	\
	if( StormGoIfLegitimateAddress(( MODE ), ( X ))) goto LABEL;

#ifdef REG_OK_STRICT
#define REG_OK_FOR_BASE_P(X)	REG_OK_FOR_BASE_P_STRICT(X, 1)
#else /* REG_OK_STRICT */
#define REG_OK_FOR_BASE_P(X)	1
#endif /* REG_OK_STRICT */

#define REG_OK_FOR_INDEX_P(X)	0

#define LEGITIMIZE_ADDRESS(X, OLDX, MODE, WIN)		{ ; }

#define GO_IF_MODE_DEPENDENT_ADDRESS(ADDR, LABEL)

#define LEGITIMATE_CONSTANT_P(X)	1

/*** Condition Code ***/

#define NOTICE_UPDATE_CC(EXP, INSN) \
  { StormNoticeUpdateCc(( EXP ), ( INSN )); }

/*** Costs ******************************************************************/

#define CONST_COSTS( X, CODE, OUTER_CODE )	\
  case CONST_INT:							\
	if( INT_11( INTVAL( X )))	return 0;	\
								return 4;	\
  case CONST:								\
  case LABEL_REF:							\
  case SYMBOL_REF:				return 0;	\
  case CONST_DOUBLE:			return 4;

#define ADDRESS_COST( ADDR )											\
/*	StormMemRefR7( ADDR ) ? 8 :*/											\
	( CONSTANT_ADDRESS_P( ADDR ) || GET_CODE( ADDR ) == REG || (		\
		GET_CODE( ADDR ) == PLUS				&&						\
		RTX_OK_FOR_BASE_P( XEXP( ADDR, 0 ))		&&						\
		RTX_OK_FOR_OFFSET_P( XEXP( ADDR, 1 ))							\
	) ? 0 : 4 )

#define RTX_COSTS( X, CODE, OUTER_CODE )		\
  case PLUS:									\
  case MINUS:									\
  case AND:										\
  case IOR:										\
  case XOR:										\
  case NOT:										\
	return( 2 );								\
  case NEG:										\
	return( 4 );								\
  case MULT:									\
  case DIV:										\
  case UDIV:									\
  case MOD:										\
  case UMOD:									\
	return( 100 * 2 );							\
  case ASHIFT:									\
  case ASHIFTRT:								\
  case LSHIFTRT:								\
  case ROTATE:									\
  case ROTATERT:								\
	if( GET_CODE( XEXP( X, 1 )) == CONST_INT )	\
		return( INTVAL( XEXP( X, 1 )) * 2 );	\
	return( 30 * 2 );

#define BRANCH_COST				2
#define SLOW_BYTE_ACCESS		0
#define MOVE_RATIO				2

#define NO_FUNCTION_CSE
#define NO_RECURSIVE_FUNCTION_CSE

/*** Sections ***************************************************************/

#define TEXT_SECTION_ASM_OP		"\ttext"
#define DATA_SECTION_ASM_OP		"\tdata"
#define BSS_SECTION_ASM_OP		"\tdata"
#define READONLY_DATA_SECTION	data_section

/*** Assembler Format *******************************************************/

/* File Framework */

#define ASM_FILE_START( STREAM )	( StormAsmFileStart( STREAM ))
#define ASM_FILE_END( STREAM )		( StormAsmFileEnd( STREAM ))
#define ASM_IDENTIFY_GCC( FILE )
//#define ASM_APP_ON	"#APP"
//#define ASM_APP_OFF	"#NO_APP"
#define ASM_APP_ON	""
#define ASM_APP_OFF	""

/* Data Output */

#define ASM_OUTPUT_SHORT_FLOAT(STREAM, VALUE) \
  fprintf ((STREAM), "\t.float\t%f\n", (VALUE))

#define ASM_OUTPUT_BYTE(STREAM, VALUE) \
  fprintf ((STREAM), "\t%s\t0x%x\n", ASM_BYTE_OP, (VALUE))

#define ASM_BYTE_OP		"db"
#define ASM_OPEN_PAREN	"("
#define ASM_CLOSE_PAREN	")"

/* Uninitialized Data */

#define ASM_OUTPUT_COMMON(STREAM, NAME, SIZE, ROUNDED) { \
	data_section(); \
	ASM_GLOBALIZE_LABEL(( STREAM ), ( NAME )); \
	ASM_OUTPUT_LABEL(( STREAM ), ( NAME )); \
	ASM_OUTPUT_SKIP(( STREAM ), ( ROUNDED )); \
}

#define ASM_OUTPUT_LOCAL(STREAM, NAME, SIZE, ROUNDED) { \
	data_section(); \
	ASM_OUTPUT_LABEL (( STREAM ) ,( NAME )); \
	ASM_OUTPUT_SKIP (( STREAM ), ( ROUNDED )); \
}

/* Label Output */

#define ASM_OUTPUT_LABEL( STREAM, NAME ) {	\
	assemble_name(( STREAM ), ( NAME ));	\
	fprintf(( STREAM ), ":\n" );			\
}

#define ASM_GLOBALIZE_LABEL( STREAM, NAME ) {	\
	fprintf(( STREAM ), "#global " );			\
	assemble_name(( STREAM ), ( NAME ));		\
	fprintf(( STREAM ), "\n" );					\
}

#define ASM_OUTPUT_EXTERNAL( STREAM, DECL, NAME ) {	\
	fprintf(( STREAM ), "#extern " );				\
	assemble_name(( STREAM ), ( NAME ));			\
	fprintf(( STREAM ), "\n" );						\
}

#define ASM_OUTPUT_EXTERNAL_LIBCALL( STREAM, SYMREF ) {	\
	fprintf(( STREAM ), "#extern " );					\
	assemble_name(( STREAM ), XSTR( SYMREF, 0 ));		\
	fprintf(( STREAM ), "\n" );							\
}

#define ASM_OUTPUT_LABELREF(STREAM, NAME) \
	( fprintf(( STREAM ), "_%s", ( NAME )))

#define ASM_OUTPUT_INTERNAL_LABEL(STREAM, PREFIX, NUM) \
  (fprintf ((STREAM), "%s$%d:\n", (PREFIX), (NUM)))

#define ASM_GENERATE_INTERNAL_LABEL(STRING, PREFIX, NUM) \
  (sprintf ((STRING), "*%s$%d", (PREFIX), (NUM)))

#define ASM_FORMAT_PRIVATE_NAME(OUTVAR, NAME, NUMBER) \
  ((OUTVAR) = (char *) alloca (strlen ((NAME)) + 10), \
   sprintf ((OUTVAR), "%s$%d", (NAME), (NUMBER)))

/* initialization routines */

#define HAS_INIT_SECTION

/* Instruction Output */

#define REGISTER_NAMES { \
	"r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7" }

#define PRINT_OPERAND( STREAM, X, CODE ) \
	StormPrintOperand(( STREAM ), ( X ), ( CODE ))

#define PRINT_OPERAND_ADDRESS( STREAM, X ) \
	StormPrintOperandAddress(( STREAM ), ( X ))

#define PRINT_OPERAND_PUNCT_VALID_P( CHAR )	\
	(( CHAR ) == '#' || ( CHAR ) == '@' || ( CHAR ) == 'S' )

//#define DBR_OUTPUT_SEQEND( FILE )	fprintf( FILE, "\tnop x %d\n", dbr_sequence_length());
#define ASM_OUTPUT_REG_PUSH(STREAM, REGNO)	(abort ())
#define ASM_OUTPUT_REG_POP(STREAM, REGNO)	(abort ())

/* Dispatch Tables */

/* #define ASM_OUTPUT_ADDR_DIFF_ELT(STREAM, VALUE, REL) \ */
#define ASM_OUTPUT_ADDR_DIFF_ELT(STREAM, BODY, VALUE, REL) \
  (fprintf ((STREAM), "\tdb\tL%d-L%d\n", (VALUE), (REL)))

#define ASM_OUTPUT_ADDR_VEC_ELT(STREAM, VALUE) \
  (fprintf ((STREAM), "\tdb\tL%d\n", (VALUE)))

/* Alignment Output */

#define ASM_OUTPUT_SKIP(STREAM, NBYTES) \
  (fprintf ((STREAM), "\tskip\t%d\n", (NBYTES)))

#define ASM_OUTPUT_ALIGN(STREAM, POWER) \
  (fprintf ((STREAM), "\t.align\t%d\n", 1 << (POWER)))

/*** Debugging Info ***/

/* All Debuggers */

#define DBX_REGISTER_NUMBER(REGNO)	(REGNO)
#define PREFERRED_DEBUGGING_TYPE	DBX_DEBUG

/* DBX Options */

#define DBX_DEBUGGING_INFO
#define ASM_STABS_OP		".stabs"
#define ASM_STABD_OP		".stabd"
#define ASM_STABN_OP		".stabn"
#define DBX_CONTIN_LENGTH	0

/* DBX Hooks */
/* File Names and DBX */
/* SDB and DWARF */

/*** Misc ***/

#define CASE_VECTOR_MODE	QImode
#define EASY_DIV_EXPR		TRUNC_DIV_EXPR
#define MOVE_MAX			1
#define TRULY_NOOP_TRUNCATION(OUTPREC, INPREC)   1
#define Pmode				QImode
#define FUNCTION_MODE		QImode

#define STORM_MAX_EXPAND_SHIFT		3
#define STORM_MAX_REGNUM			8	/* STORM でサポートする reg の最大数*/
#define STORM_MIN_REGNUM			8	/* STORM でサポートする reg の最小数*/
#define STORM_RESERVED_REGNUM		4	/* sp, fp などの制限された reg 数	*/
#define RETURN_ADDR_REGNUM			7
#define MAX_FUNC_ARG_REGNUM			4	/* 引数渡しに使えるレジスタの *数*	*/

/* regnum map
	8	STORM_MAX_REGNUM ( == FIRST_PSEUDO_REGISTER )
	7	ret addr
	6	static chain
	5	sp
	4	fp
	3--user
*/
