;*****************************************************************************
;
;		STORM -- STandard Optimized Risc Machine
;		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
;		
;		local.md --- STORM machine description
;
;
;	extra constrains
;	I : 8bit signed imm
;	J : 11bit signed imm
;	l : r0 - r3 ( load register )
;	Q : [imm] / R
;	R : [reg +- 8bit]
;	S : [r7] [imm]  call address
;	T : [imm]
;
;
;	special operands
;	%# : print nop if JMP's delay slot is filled no instruction
;	%@ : print nop if jcc's delay slot is filled no instruction
;	%S : shift operator
;
;*****************************************************************************

;*** insn type ***************************************************************

( define_attr "type" "jmp,jcc,call,load,alu,other" ( const_string "other" ))

( define_attr "length" "" ( const_int 1 ))

;*** delay slot **************************************************************

( define_delay ( eq_attr "type" "jmp" ) [
	( and
		( eq_attr "type" "!jmp,jcc,call" )
		( eq_attr "length" "1" )
	) ( nil ) ( nil )
])

( define_delay ( eq_attr "type" "jcc" ) [
	( and
		( eq_attr "type" "!jmp,jcc,call" )
		( eq_attr "length" "1" )
	) ( nil ) ( nil )
	( and
		( eq_attr "type" "!jmp,jcc,call" )
		( eq_attr "length" "1" )
	) ( nil ) ( nil )
	( and
		( eq_attr "type" "!jmp,jcc,call" )
		( eq_attr "length" "1" )
	) ( nil ) ( nil )
])

;*** mov *********************************************************************

( define_insn "movqi"
	[( set
		( match_operand:QI 0 "nonimmediate_operand" "=r,R,m,l,r,l" )
		( match_operand:QI 1 "general_operand"      "rJ,r,l,m,R,i" ))]
	""
	"@
	mov\\t%0, %1
	mov\\t%0, %1
	mov\\t%0, %1
	mov\\t%0, %1
	mov\\t%0, %1
	movi\\t%0, %1"
	[( set_attr "type" "other,other,other,load,load,load" )])

;*** arithmetic operation ****************************************************

( define_insn "addqi3"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( plus:QI
			( match_operand:QI 1 "register_operand"  "%0" )
			( match_operand:QI 2 "nonmemory_operand" "rI" )))]
	""
	"add\\t%0, %2"
	[( set_attr "type" "alu" )])

( define_insn "subqi3"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( minus:QI
			( match_operand:QI 1 "register_operand"  "0" )
			( match_operand:QI 2 "nonmemory_operand" "rI" )))]
	""
	"sub\\t%0, %2"
	[( set_attr "type" "alu" )])

( define_insn "andqi3"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( and:QI
			( match_operand:QI 1 "register_operand"  "%0" )
			( match_operand:QI 2 "nonmemory_operand" "rI" )))]
	""
	"and\\t%0, %2"
	[( set_attr "type" "alu" )])

( define_insn "iorqi3"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( ior:QI
			( match_operand:QI 1 "register_operand"  "%0" )
			( match_operand:QI 2 "nonmemory_operand" "rI" )))]
	""
	"or\\t%0, %2"
	[( set_attr "type" "alu" )])

( define_insn "xorqi3"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( xor:QI
			( match_operand:QI 1 "register_operand"  "%0" )
			( match_operand:QI 2 "nonmemory_operand" "rI" )))]
	""
	"xor\\t%0, %2"
	[( set_attr "type" "alu" )])

( define_insn "one_cmplqi2"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( not:QI
			( match_operand:QI 1 "register_operand" "0" )))]
	""
	"not\\t%0"
	[( set_attr "type" "alu" )])

( define_expand "negqi2"
	[( set
		( match_operand:QI 0 "register_operand" "=r,r" )
		( neg:QI
			( match_operand:QI 1 "register_operand" "0,r" )))]
	""
	"{
	rtx	TmpReg = gen_reg_rtx( QImode );
	
	if( which_alternative == 0 ){
		// neg r0, r0 --> not r0, r0; inc r0
		emit_insn( gen_xorqi3( TmpReg, operands[ 0 ], gen_rtx( CONST_INT, VOIDmode, -1 )));
		emit_insn( gen_addqi3( operands[ 0 ], TmpReg, gen_rtx( CONST_INT, VOIDmode,  1 )));
	}else{
		// neg r0, r1 --> mov r0, 0; sub r0, r1
		emit_insn( gen_movqi ( TmpReg, gen_rtx( CONST_INT, VOIDmode, 0 )));
		emit_insn( gen_subqi3( operands[ 0 ], TmpReg, operands[ 1 ] ));
	}
	DONE;
	}" )

;*** compare *****************************************************************

( define_insn "cmpqi"
	[( set ( cc0 )
		( compare:QI
			( match_operand:QI 0 "register_operand"  "r" )
			( match_operand:QI 1 "nonmemory_operand" "rI" )))]
	""
	"cmp\\t%0, %1"
	[( set_attr "type" "alu" )])

;*** shift *******************************************************************

;*** storm insn ***

( define_insn "storm_shl"
	[( set ( match_operand:QI 0 "register_operand" "=r" )
		( ashift:QI
			( match_operand:QI 1 "register_operand" "r" )
			( const_int 1 )))]
	""
	"shl\\t%0, %1" )

( define_insn "storm_shr"
	[( set ( match_operand:QI 0 "register_operand" "=r" )
		( lshiftrt:QI
			( match_operand:QI 1 "register_operand" "r" )
			( const_int 1 )))]
	""
	"shr\\t%0, %1" )

( define_insn "storm_sar"
	[( set ( match_operand:QI 0 "register_operand" "=r" )
		( ashiftrt:QI
			( match_operand:QI 1 "register_operand" "r" )
			( const_int 1 )))]
	""
	"sar\\t%0, %1" )

;*** standard names ***

( define_expand "ashlqi3"
	[( set ( match_operand:QI 0 "register_operand" "=r" )
		( ashift:QI
			( match_operand:QI 1 "register_operand" "r" )
			( match_operand:QI 2 "immediate_operand" "" )))]
	""
	"{
	int	rep;
	rtx	TmpReg;
	
	if( GET_CODE( operands[ 2 ] )!= CONST_INT ||
		( int )INTVAL( operands[ 2 ] ) > STORM_MAX_EXPAND_SHIFT ){
		FAIL;
	}
	
	rep = INTVAL( operands[ 2 ]);
	/*for( ; rep > 0; --rep ){
		if( rep != 1 ){
			TmpReg = gen_reg_rtx( QImode );
			emit_insn( gen_storm_shl( TmpReg, operands[ 1 ] ));
			operands[ 1 ] = TmpReg;
		}else{
			emit_insn( gen_storm_shl( operands[ 0 ], operands[ 1 ] ));
		}
	}*/
	if   ( rep-- > 0 ) emit_insn( gen_storm_shl( operands[ 0 ], operands[ 1 ] ));
	while( rep-- > 0 ) emit_insn( gen_storm_shl( operands[ 0 ], operands[ 0 ] ));
	DONE;
	}" )

( define_expand "lshrqi3"
	[( set ( match_operand:QI 0 "general_operand" "=g" )
		( lshiftrt:QI
			( match_operand:QI 1 "general_operand" "g" )
			( match_operand:QI 2 "immediate_operand" "" )))]
	""
	"{
	int	rep;
	
	if( GET_CODE( operands[ 2 ] )!= CONST_INT ||
		( int )INTVAL( operands[ 2 ] ) > STORM_MAX_EXPAND_SHIFT ){
		FAIL;
	}
	
	rep = INTVAL( operands[ 2 ]);
	if   ( rep-- > 0 ) emit_insn( gen_storm_shr( operands[ 0 ], operands[ 1 ] ));
	while( rep-- > 0 ) emit_insn( gen_storm_shr( operands[ 0 ], operands[ 0 ] ));
	DONE;
	}" )

( define_expand "ashrqi3"
	[( set ( match_operand:QI 0 "general_operand" "=r" )
		( ashiftrt:QI
			( match_operand:QI 1 "general_operand" "" )
			( match_operand:QI 2 "immediate_operand" "" )))]
	""
	"{
	int	rep;
	
	if( GET_CODE( operands[ 2 ] )!= CONST_INT ||
		( int )INTVAL( operands[ 2 ] ) > STORM_MAX_EXPAND_SHIFT ){
		FAIL;
	}
	
	rep = INTVAL( operands[ 2 ]);
	if   ( rep-- > 0 ) emit_insn( gen_storm_sar( operands[ 0 ], operands[ 1 ] ));
	while( rep-- > 0 ) emit_insn( gen_storm_sar( operands[ 0 ], operands[ 0 ] ));
	DONE;
	}" )

;*** jmp *********************************************************************

( define_insn "jump"
	[( set ( pc )
 		( label_ref ( match_operand 0 "" "" )))]
	""
	"jmp\\t%0%#"
	[( set_attr "type" "jmp" )])

( define_insn "indirect_jump"
	[( set ( pc )
		( match_operand:QI 0 "register_operand" "" ))]
	""
	"jmp\\t%0%#\\t;indirect"
	[( set_attr "type" "jmp" )])

;*** call ********************************************************************

( define_insn "call"
	[( call
		( match_operand:QI 0 "memory_operand" "" )
		( match_operand 1 "" "" ))
	( clobber ( reg:QI 7 ))]
	""
	"*
	operands[ 0 ]= XEXP( operands[ 0 ], 0 );
	return( \"call\\t%0\" );
	"
	[( set_attr "type" "call" )])

( define_insn "call_value"
	[( set ( match_operand 0 "" "=g" )
		( call
			( match_operand:QI 1 "memory_operand" "" )
			( match_operand 2 "" "" )))
	( clobber ( reg:QI 7 ))]
	""
	"*
	operands[ 1 ]= XEXP( operands[ 1 ], 0 );
	return( \"call\\t%1\" );
	"
	[( set_attr "type" "call" )])


;( define_insn "return"
;	[( return )]
;	""
;	"; return"
;	[( set_attr "type" "ret" )
;	 ( set_attr "length" "0" )])

;*** condition code **********************************************************

( define_insn "beq"
	[( set ( pc )
		( if_then_else
			( eq ( cc0 ) ( const_int 0 ))
 			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jz\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bne"
	[( set ( pc )
		( if_then_else
			( ne ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jnz\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bgt"
	[( set ( pc )
		( if_then_else
			( gt ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jg\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bgtu"
	[( set ( pc )
		( if_then_else
			( gtu ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"ja\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "blt"
	[( set ( pc )
		( if_then_else
			( lt ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jl\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bltu"
	[( set ( pc )
		( if_then_else
			( ltu ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jc\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bge"
	[( set ( pc )
		( if_then_else
			( ge ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jge\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bgeu"
	[( set ( pc )
		( if_then_else
			( geu ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jae\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "ble"
	[( set ( pc )
		( if_then_else
			( le ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jle\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn "bleu"
	[( set ( pc )
		( if_then_else
			( leu ( cc0 ) ( const_int 0 ))
			( label_ref ( match_operand 0 "" "" ))
			( pc )))]
	""
	"jbe\\t%0%@"
	[( set_attr "type" "jcc" )])

/*** inv ***/

( define_insn ""
	[( set ( pc )
		( if_then_else
			( eq ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jnz\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( ne ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jz\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( gt ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jle\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( gtu ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jbe\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( lt ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jge\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( ltu ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jae\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( ge ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jl\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( geu ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jc\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( le ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"jg\\t%0%@"
	[( set_attr "type" "jcc" )])

( define_insn ""
	[( set ( pc )
		( if_then_else
			( leu ( cc0 ) ( const_int 0 ))
			( pc )
			( label_ref ( match_operand 0 "" "" ))))]
	""
	"ja\\t%0%@"
	[( set_attr "type" "jcc" )])

;*** setcc *******************************************************************

( define_insn "sltu"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( ltu ( cc0 ) ( const_int 0 )))
	( clobber ( cc0 ))]
	""
	"mov\\t%0, 0\\n\\tadc\\t%0, 0"
	[( set_attr "type" "alu" )
	 ( set_attr "length" "2" )])

( define_insn "sgeu"
	[( set
		( match_operand:QI 0 "register_operand" "=r" )
		( geu ( cc0 ) ( const_int 0 )))
	( clobber ( cc0 ))]
	""
	"mov\\t%0, 1\\n\\tsbb\\t%0, 0"
	[( set_attr "type" "alu" )
	 ( set_attr "length" "2" )])

;*** misc ********************************************************************

( define_insn "nop"
	[( const_int 0 )]
	""
	"nop" )

;*** function unit ***********************************************************

( define_function_unit "alu" 1 0
	( eq_attr "type" "alu" )
	2 0 )

( define_function_unit "load" 1 0
	( eq_attr "type" "load" )
	2 0 )
