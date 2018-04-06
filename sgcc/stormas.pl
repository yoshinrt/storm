#!/bin/perl

#*****************************************************************************
#
#		STORM assembler
#		Copyright(C) 2002 by Deyu Deyu Software ( Yoshihisa Tanaka )
#
# 2001.07.23	add neg macro / remove neg real insn (;_;)
# 2001.08.09	ICF v1.21
# 2001.08.10	add skip insn
#				$bRedoAsm が発生時は bit 幅オーバーフローエラーを出さない
# 2001.08.13	SrcMrg で data seg のソースをマージしてた
#				add ri の code gen のポカミス修正
# 2001.08.15	ラベルに $ 使用可 ( 先頭以外 )
# 2001.08.16	storm_uselib.h 作成機能追加 (-h)
#				.lst ファイル作成オプション追加 (-l)
#				rs, rr のデフォルトを定義・二重定義エラー抑止
#				_main != 0 時は jmp _main を自動追加
# 2001.08.17	マクロもオペランドを認識するよう変更
#				　ただし，同一 opc で * とその他が混在してはいけない
#				マルチ push / pop 追加
#				マクロ機能追加 (^^;
# 2001.08.20	equ * のヘボバグ修正 ( 常に $Imm == '' になってた )
# 2001.08.21	perl のバグ回避コード削除
# 2001.08.25	[i] のアドレスの bit overflow チェック削除
# 2001.08.26	swp 追加
#
#*****************************************************************************

$CSymbol	= '\b[_a-zA-Z][$\w]*\b';
$RegName	= '\b[Rr][0-7]\b';
$SimLogFile	= 'STORM_exec.log';
$ImmPfx		= '_i$';
$MaxPathCnt	= 10;
$HdrFile	= "storm_uselib.h";

$LabelList{ 'rs' } = 'r5';
$LabelList{ 'rr' } = 'r7';

@InsnTbl = (
	# standard insn		m = [r+i]   M = [i]
	# code	 mnemonic  operand	category
	'0x0000		mov		ri		mri',
	'0x4000		mov		rm		11,0',
	'0x4400		mov		mr		0,11',
	'0xF800		mov		rr		3,0',
	'0xE000		movh	ri		mh',
	
	'0x8000		add		ri		A',
	'0x8100		sub		ri		A',
	'0x8200		adc		ri		A',
	'0x8300		sbb		ri		A',
	'0x8400		and		ri		A',
	'0x8500		cmp		ri		A',
	'0x8600		or		ri		A',
	'0x8700		xor		ri		A',
	
	'0xF000		add		rr		3,0',
	'0xF100		sub		rr		3,0',
	'0xF200		adc		rr		3,0',
	'0xF300		sbb		rr		3,0',
	'0xF400		and		rr		3,0',
	'0xF500		cmp		rr		3,0',
	'0xF600		or		rr		3,0',
	'0xF700		xor		rr		3,0',
	'0xF080		sar		rr?		S',
#	'0xF180		neg		rr?		S',
	'0xF280		shr		rr?		S',
	'0xF380		shl		rr?		S',
	'0xF480		czx		rr?		S',
	'0xF580		csx		rr?		S',
	'0xF680		pack	rr		3,0',
	
	'0xD000		jz		i		J',
	'0xD100		jnz		i		J',
	'0xD200		js		i		J',
	'0xD300		jns		i		J',
	'0xD400		jo		i		J',
	'0xD500		jno		i		J',
	'0xD600		jc		i		J',
	'0xD600		jnae	i		J',
	'0xD700		jnc		i		J',
	'0xD700		jae		i		J',
	'0xD800		jbe		i		J',
	'0xD800		jna		i		J',
	'0xD900		ja		i		J',
	'0xD900		jnbe	i		J',
	'0xDA00		jl		i		J',
	'0xDA00		jnge	i		J',
	'0xDB00		jge		i		J',
	'0xDB00		jnl		i		J',
	'0xDC00		jle		i		J',
	'0xDC00		jng		i		J',
	'0xDD00		jg		i		J',
	'0xDD00		jnle	i		J',
	
	'0xC000		jmp		i		jmp',
	'0xFA00		jmp		r		0,0',
	'0xFC00		spc		r		3,0',
	
	'0xDE00		nop		-		0,0',
	
	# virtual insn
	
	'V			push	r+		push',
	'V			pop		r+		pop',
	'V			text	-		text',
	'V			data	-		data',
	'V			equ		*		equ',
	'V			db		i+		db',
	'V			dw		i+		dw',
	'V			org		i		org',
	'V			skip	i		skip',
	'V			macro	*		macro',
	
	# macro insn
	
	'M			add		rri		movi $2, $3; add $1, $2',
	'M			sub		rri		movi $2, $3; sub $1, $2',
	'M			adc		rri		movi $2, $3; adc $1, $2',
	'M			sbb		rri		movi $2, $3; sbb $1, $2',
	'M			and		rri		movi $2, $3; and $1, $2',
	'M			cmp		rri		movi $2, $3; cmp $1, $2',
	'M			or		rri		movi $2, $3; or  $1, $2',
	'M			xor		rri		movi $2, $3; xor $1, $2',
	'M			inc		*		add	$1, 1',
	'M			dec		*		sub	$1, 1',
	'M			not		r		xor	$1, -1',
	'M			not		rr		mov	$1, $2; xor	$1, -1',
	'M			neg		r		not	$1; inc	$1',
	'M			neg		rr		mov $1, 0; sub $1, $2',
	'M			tst		*		or	$1, $1',
	'M			call	*		jmp	$1; spc	rr',
	'M			ret		*		jmp	rr',
#	'M			push	*		mov	[rs-1], $1; dec	rs',
#	'M			pop		*		mov	$1, [rs]; inc	rs',
#	'M			nop		*		mov	r0, r0;',
	'M			hlt		*		jmp	$; jmp $-1',
);

&main();
exit( $bError );

### main procedure ###########################################################

sub main{
	
	local( $SegBaseText	) = 0;
	local( $SegBaseData	) = 0;
	
	
	$bError		= 0;
	
	while( $ARGV[ 0 ] =~ /^-/ ){
		
		if( $ARGV[ 0 ] eq "-ot" ){
			$TxtFile = $ARGV[ 1 ];
			shift( @ARGV );
			
		}elsif( $ARGV[ 0 ] eq "-od" ){
			$DatFile = $ARGV[ 1 ];
			shift( @ARGV );
			
		}else{
			$bSimOut	= 1 if( $ARGV[ 0 ] =~ /s/ );
			$bMrgSim	= 1 if( $ARGV[ 0 ] =~ /m/ );
			$bLibHeader	= 1 if( $ARGV[ 0 ] =~ /h/ );
			$bLstOut	= 1 if( $ARGV[ 0 ] =~ /l/ );
		}
		
		shift( @ARGV );
	}
	
	# setup file name
	
	$SceFile = $ARGV[ 0 ];
	
	$SceFile  =~ /(.*)\./;
	$BaseName = ( $1 ne "" ) ? $1 : $SceFile;
	$TxtFile  = $BaseName . "_text" . (( $bSimOut ) ? ".obj" : ".mif" ) if( $TxtFile eq "" );
	$DatFile  = $BaseName . "_data" . (( $bSimOut ) ? ".obj" : ".mif" ) if( $DatFile eq "" );
	$LstFile  = "$BaseName.lst";
	$MrgFile  = "$BaseName.log";
	
	# if -h, create lib header file & exit
	
	if( $bLibHeader ){
		&CreateLibHeader();
		return;
	}
	
	# setup instruction table
	
	if( $#ARGV < 0 ){
		$0 =~ /[^\\\/]+$/;
		print( "usage : $& [-lsmh] [-ot | -od <output file>] <source file>\n" );
		return;
	}
	
	&SetupInsnTbl();
	
	$PathCnt = 0;
	
	&Parser();
	while( $bRedoAsm && !$bError && $PathCnt < $MaxPathCnt ){
		&Parser();
	}
	
	Error( "max path count reached" ) if( $PathCnt >= $MaxPathCnt );
	
	if( $bError ){
		#unlink( $LstFile );
		return;
	}
	
	# Code 出力
	
	unlink( $TxtFile );
	unlink( $DatFile );
	&OutputCode( $TxtFile,  512, @CodeText ) if( $#CodeText >= 0 );
	&OutputCode( $DatFile, 1024, @CodeData ) if( $#CodeData >= 0 );
	
	# sim 結果とマージ
	
	&MargeSim_Src() if( $bMrgSim );
}

### output code ##############################################################

sub OutputCode{
	
	local( $FileName, $Len, @Code ) = @_;
	local( $i );
	
	open( fpOut, "> $FileName" );
	
	if( !$bSimOut ){
		$0 =~ /[^\\\/]+$/;
		print( fpOut <<EOF );
-- $& - generated Memory Initialization File

WIDTH = 16;
DEPTH = $Len;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT BEGIN 0:

EOF
	}
	
	for( $i = 0; $i <= $#Code; ++$i ){
		printf( fpOut "%04X%s", $Code[ $i ],
			( $i % 8 == 7 || $i == $#Code ) ? "\n" : ' ' );
	}
	
	print( fpOut "; END;\n" ) if( !$bSimOut );
	
	close( fpOut );
}

### parser ###################################################################

sub Parser{
	
	local(
		$Line,
		$i
	);
	
	$bRedoAsm				= 0;
	local( $LineCnt )		= 0;
	local( $LocCnt )		= 0;
	local( $LocCntText )	= $SegBaseText;
	local( $LocCntData )	= $SegBaseData;
	local( $bTextSeg )		= 1;
	@CodeText				= ();
	@CodeData				= ();
	
	#print( "path $PathCnt DSEG = $SegBaseData\n" );
	
	if( !open( fpIn, "< $SceFile" )){
		print( "Can't open file \"$SceFile\"\n" );
		$bError = 1;
		return;
	}
	
	if( $bLstOut ){
		if( !open( fpLst, "> $LstFile" )){
			print( "Can't open file \"$LstFile\"\n" );
			$bError = 1;
			return;
		}
	}
	
	# if( _main != 0 ) jmp _main; 追加
	
	if( defined( $LabelList{ '_main' } ) && $LabelList{ '_main' } != 0 ){
		&MultiLineParser( "jmp _main; nop", 1 );
	}
	
	# 構文解析ループ
	
	while( $Line = <fpIn> ){
		
		# 改行削除
		
		$Line =~ s/[\x0D\x0A]//g;
		++$LineCnt;
		
		&MultiLineParser( $Line );
	}
	
	# text seg の word alignment
	push( @CodeText, 0 ) if( $#CodeText & 1 == 0 );
	
	# DATA seg の base addr が違ってれば RedoAsm
	$i				= $#CodeText + 1;
	$bRedoAsm		= 1 if( $SegBaseData != $i );
	$SegBaseData	= $i;
	
	# text + data
	push( @CodeText, @CodeData );
	
	close( fpIn );
	close( fpLst ) if( $bLstOut );
	
	++$PathCnt;
}

### multi line parser ########################################################

sub MultiLineParser{
	
	local( $Line, $bExpandMacro ) = @_;
	local(
		$Line2,
		$Label,
		$Mnemonic,
		$Optype,
		$Code,
		$Category,
		$OperandStr,
		@Operands,
		@MacroOpr,
		@CodeBuf,
		$i,
		$OrgLine,
		$bOverflow,
		$Tmp
	);
	
	$OrgLine = $Line;
	
	$Line =~ s/#.*//g;			# コメント削除
	$Line =~ s/^\s+//g;			# 行前後空白削除
	$Line =~ s/\s+$//g;
	$Line =~ s/\s+/ /g;			# 空白圧縮
	$Line =~ s/\s*;\s*/;/g;		# 行セパレータ前後空白削除
	
	&PrintLstFile() if( $Line eq '' );
	
	while( $Line ne '' ){
		@CodeBuf = ();
		
		if( $Line  =~ /(?<!\\);/ ){
			$Line2 = $`;
			$Line  = $';
		}else{
			$Line2 = $Line;
			$Line  = '';
		}
		
		if( $Line !~ /^\s*$/ && !$bExpandMacro ){
			&PrintLstFile();
			$bExpandMacro = 1;
		}
		
		#print( "$Line2 @@@ $Line\n" );
		( $Label, $Mnemonic, $Optype, $OperandStr, @Operands )
			= &LineParser( $Line2 );
		
		#print( "$Label, $Mnemonic, $Optype, '$OperandStr', @Operands\n" );
		
		### equ 処理 #########################################################
		
		if( $Mnemonic eq 'equ' ){
			
			Error( "syntax error" ) if( $Label eq "" );
			#print( "$Label, $OperandStr\n" );
			&DefineLabel( $Label, $OperandStr );
			
			goto PutCode;
		}
		
		### Label 定義 #######################################################
		
		&DefineLabel( $Label, $LocCnt ) if( $Label ne "" );
		
		# opecode がなければ次
		
		goto PutCode if( $Mnemonic eq "" );
		
		### Mnemonic 別のパラメータ get ######################################
		
		for( $i = 0; $i <= $#MnmOprList; ++$i ){
			
			#print( "$Mnemonic:$Optype == $MnmOprList[ $i ]\n" );
			
			if( "$Mnemonic:$Optype" =~ /^$MnmOprList[ $i ]$/ ){
				$Code		= $InsnCodeList[ $i ];
				$Category	= $CategoryList[ $i ];
				
				last;
			}
		}
		
		if( $i > $#MnmOprList ){
			Error( "unmatch operand type" );
		}
		
		### マクロ展開 #######################################################
		
		if( $Code eq 'M' ){
			@MacroOpr = split( /\s*,\s*/, $OperandStr );
			
			$Category =~ s/\$(\d+)/$MacroOpr[ $1 - 1 ]/g;
			
			#print( "Macro>$OperandStr:$Category\n" );
			&PrintLstFile();
			
			&MultiLineParser( $Category, 1 );
			
			next;
		}
		
		if( $Mnemonic eq 'push' ){		### multi push #######################
			
			for( $Tmp = "", $i = 0; substr( $Optype, $i, 1 ) ne ''; ++$i ){
				
				$Tmp .= sprintf( "mov\t[rs-%d], r%d;",
					$i + 1, $Operands[ $i ] );
			}
			
			$Tmp .= "sub\trs, $i";
			
			&PrintLstFile();
			&MultiLineParser( $Tmp, 1 );
			
			next;
		}
		
		if( $Mnemonic eq 'pop' ){		### multi pop ########################
			
			for( $Tmp = "", $i = 0; substr( $Optype, $i, 1 ) ne ''; ++$i ){
				
				$Tmp .= sprintf( "mov\tr%d, [rs+%d];",
					pop( @Operands ), $i );
			}
			
			$Tmp .= "add\trs, $i";
			
			&PrintLstFile();
			&MultiLineParser( $Tmp, 1 );
			
			next;
		}
		
		### マクロ定義 #######################################################
		
		if( $Mnemonic eq 'macro' ){
			&DefineMacro( $OperandStr );
			
			&PrintLstFile();
			next;
		}
		
		### code 生成 ########################################################
		
		if( $Category =~ /^(\d+),(\d+)$/ ){ ### 計算ですむやつ ###############
			
			&PushCodeW( $Code | ( $Operands[ 0 ] << $1 ) |
								( $Operands[ 1 ] << $2 ));
			
		}elsif( $Category eq 'mri' ){	### mov r,i ##########################
			
			( $i, $bOverflow ) = &CheckImmSize( $Operands[ 1 ], 11, 1 );
			
			if( $bOverflow ){	# movh; mov に分割
				&PrintLstFile();
				
				&MultiLineParser(
					"movh	r$Operands[ 0 ], $Operands[ 1 ];" .
					"or		r$Operands[ 0 ], $Operands[ 1 ] & 0x7F", 1
				);
				next;
				
			}elsif(( $Operands[ 1 ] & 0x7F ) == 0 ){	# movh only
				
				goto MoveH;
				
			}else{				# そのままで可
				&PushCodeW( $Code | ( $Operands[ 0 ] << 11 ) | $i );
			}
			
		}elsif( $Category eq 'mh' ){	### movh #############################
			
		  MoveH:
			&PushCodeW( $Code |
				( $Operands[ 0 ] << 3 ) |
				(( $Operands[ 1 ] & 0xFC00 ) >> 4 ) |
				(( $Operands[ 1 ] & 0x0380 ) >> 7 )
			);
			
		}elsif( $Category eq 'A' ){	### add r,i ##############################
			
			$i = ( &CheckImmSize( $Operands[ 1 ], 8 ))[ 0 ];
			&PushCodeW( $Code | ( $Operands[ 0 ] << 11 ) | $i );
			
		}elsif( $Category eq 'S' ){	### sh r[,r] #############################
			
			$Operands[ 1 ] = $Operands[ 0 ] if( $Optype eq 'r' );
			&PushCodeW( $Code | ( $Operands[ 0 ] << 3 ) | $Operands[ 1 ] );
			
		}elsif( $Category eq 'J' ){	### jcc ##################################
			
			#print( "addr:$Operands[ 0 ], $LocCnt\n" );
			$i = ( &CheckImmSize(( $Operands[ 0 ] - $LocCnt - 2 ) >> 1, 8 ))[ 0 ];
			&PushCodeW( $Code | $i );
			
		}elsif( $Category eq 'jmp' ){	### jmp ##############################
			
			$i = ( &CheckImmSize(( $Operands[ 0 ] - $LocCnt - 2 ) >> 1, 12 ))[ 0 ];
			&PushCodeW( $Code | $i );
			
		}elsif( $Mnemonic eq 'text' ){	### text #############################
			
			if( !$bTextSeg ){
				$LocCntData = $LocCnt;
				$LocCnt		= $LocCntText;
				$bTextSeg	= 1;
			}
			
		}elsif( $Mnemonic eq 'data' ){	### data #############################
			
			if( $bTextSeg ){
				$LocCntText = $LocCnt;
				$LocCnt		= $LocCntData;
				$bTextSeg	= 0;
			}
			
		}elsif( $Mnemonic eq 'db' ){	### db ###############################
			
			&PushCodeB( @Operands );
			
		}elsif( $Mnemonic eq 'dw' ){	### dw ###############################
			
			&PushCodeW( @Operands );
			
		}elsif( $Mnemonic eq 'org' ){	### org ##############################
			
			Error( "org address is exceeded by \$" ) if( $Operands[ 0 ] < $LocCnt );
			
			for( $i = $LocCnt; $i < $Operands[ 0 ]; ++$i ){
				&PushCodeB( 0 );
			}
		}elsif( $Mnemonic eq 'skip' ){	### skip #############################
			
			for( $i = 0; $i < $Operands[ 0 ]; ++$i ){
				&PushCodeB( 0 );
			}
		}
		
		### code 出力 ########################################################
		
	  PutCode:
		
		if( $bLstOut ){
			# 最初のリストを出力
			PrintLstFile();
			
			# 残りのリストを出力
			for( $i = 4; $i <= $#CodeBuf; ++$i ){
				printf( fpLst "%s%04X:", ( $bTextSeg ? 'T' : 'D' ), $LocCnt + $i )
					if( $i % 4 == 0 );
					
				printf( fpLst " %02X", $CodeBuf[ $i ] );
				print( fpLst "\n" ) if( $i % 4 == 3 || $#CodeBuf == $i );
			}
		}
		
		if( $bTextSeg ){
			push( @CodeText, @CodeBuf );
			$LocCnt = $SegBaseText + $#CodeText + 1;
		}else{
			push( @CodeData, @CodeBuf );
			$LocCnt = $SegBaseData + $#CodeData + 1;
		}
	}
}

### push code ################################################################

sub PushCodeW {
	local( $Code ) = @_;
	
	if( $LocCnt & 1 == 1 ){
		Error( "invalid word allignment" );
		push( @CodeBuf, 0 );
	}
	
	push( @CodeBuf, ( $Code & 0xFF00 ) >> 8 );
	push( @CodeBuf,   $Code & 0x00FF );
}

sub PushCodeB {
	local( $Code ) = @_;
	push( @CodeBuf, $Code & 0x00FF );
}

### print insn list file #####################################################

sub PrintLstFile{
	
	local( $i ) = 0;
	local( $Line );
	
	return if( !$bLstOut || $#CodeBuf < 0 && $bExpandMacro );
	
	if( $#CodeBuf < 0 ){
		print( fpLst "     " );
	}else{
		printf( fpLst "%04X:", $LocCnt );
		
		for( $i = 0; $i <= $#CodeBuf && $i < 4; ++$i ){
			printf( fpLst " %02X", $CodeBuf[ $i ] );
		}
	}
	
	print( fpLst ' ' x (( 4 - $i ) * 3 ));
	
	if( $bExpandMacro ){
		$Line2 =~ /^($CSymbol:)? ?($CSymbol) ?(.*)/;
		$Line = sprintf( "      +%s\t%s\t%s", $1, $2, $3 );
	}else{
		$Line = sprintf( "%5d: %s", $LineCnt, $OrgLine );
	}
	
	print( fpLst "$Line\n" );
	$SrcBuf[ $LocCnt ] = $Line if( $bTextSeg );
}

### line parser ##############################################################

sub LineParser{
	
	local( $Line ) = @_;
	
	local(
		$Label,
		$Mnemonic,
		$Opr,
		@Operands,
		$OperandStr,
		$Optype,
		$Imm,
		$RegNum
	);
	
	# label 判別
	
	if( $Line =~ /^($CSymbol): ?(.*)/ || $Line =~ /^($CSymbol) (equ .*)/ ){
		$Label = $1;
		$Line  = $2;
	}
	
	# ニーモニック判別
	
	if( $Line =~ /^($CSymbol) ?(.*)/ ){
		$Mnemonic = $1;
		$Line	  = $2;
		
		if( !defined( $OptypeList{ $Mnemonic } )){
			Error( "unknown opecode \"$Mnemonic\"" );
			return( $Label );
		}
	}
	
	# オペランド解析 - *
	
	if( $OptypeList{ $Mnemonic } eq '-' && $Line ne '' ){
		Error( "disused operand exists" );
		return( $Label, $Mnemonic );
	}
	
	if( $OptypeList{ $Mnemonic } =~ /[\*\@]/ ){
		return( $Label, $Mnemonic, '', $Line, () );
	}
	
	# オペランド解析
	$Line =~ s/ *, */,/g;
	$OperandStr = $Line;
	
	# equ define されたものを変換
	$Line =~ s/$CSymbol/&Label2Str( $& )/ge;
	#print( "equ chg.>$Line\n" );
	
	while( $Line ne '' ){
		if( $Line =~ /^([^,]*),(.+)/ ){
			$Opr  = $1;
			$Line = $2;
		}else{
			$Opr  = $Line;
			$Line = ();
		}
		
		if( $Opr eq '' ){
			Error( "syntax error ( null operand )" );
			next;
		}
		
		if( $Opr =~ /^$RegName$/ ){
			# register
			
			push( @Operands, &GetRegNumber( $Opr ));
			$Optype .= 'r';
			
		}elsif( $Opr =~ /^\[ *(.*) *\]/ ){
			# memory
			
			$Opr = $1;
			
			if( $Opr =~ /^($RegName) *(.*)/ ){
				# [ r4 + imm ]
				
				$Opr    = $2;
				$RegNum = &GetRegNumber( $1 );
				
				if(( $RegNum & 2 ) == 2 ){
					Error( "bad mem base register \"r$RegNum\"" );
				}
				
				$Imm = ( &CheckImmSize( &ImmExpression( $Opr ), 8 ))[ 0 ]
					if( $Opr !~ /^\s*$/ );
				
				push( @Operands, (( $RegNum & 4 ) << 7 ) | (( $RegNum & 1 ) << 8 ) | $Imm );
				$Optype .= 'm';
				
			}else{
				# [ imm ]
				push( @Operands, ( &CheckImmSize( &ImmExpression( $Opr ), 10, 1 ))[ 0 ] );
				$Optype .= 'M';
			}
		}else{
			# imm
			push( @Operands, &ImmExpression( $Opr ));
			$Optype .= 'i';
		}
	}
	
	return( $Label, $Mnemonic, $Optype, $OperandStr, @Operands );
}

### 定数式計算 ###############################################################

sub ImmExpression{
	local( $Line ) = @_;
	local(
		$ret
	);
	
	if( $Line =~ /$RegName/ ){
		&Error( "invalid operand \"$Line\" ( imm requred )" );
		return();
	}
	
	# label --> imm
	$Line =~ s/$CSymbol/&Label2Imm( $& )/ge;
	
	# $ --> $LocCnt
	$Line =~ s/\$/$LocCnt/g;
	
	# 00h --> 0x00
	$Line =~ s/\b(\d\w*)h\b/0x$1/g;
	
	# 00b, 0b00 --> dec
	$Line =~ s/\b0b(\d+)\b/&Bin2Dec( $1 )/ge;
	$Line =~ s/\b(\d+)b\b/&Bin2Dec( $1 )/ge;
	
	# calculation
	eval( '$ret = ' . $Line );
	Error( "syntax error ( imm expression )" ) if( $@ );
	
	return( $ret & 0xFFFF );
}

### Imm size check ###########################################################

sub CheckImmSize{
	local( $Imm, $Size, $bNoErrOut ) = @_;
	local( $bOverflow );
	
	local( $MaskValue ) = ( 1 << ( $Size - 1 )) - 1;
	local( $MaskSign  ) = ~$MaskValue & 0xFFFF;
	
	#printf( "%04X %04X %04X %04X\n", $Imm, $MaskValue, $MaskSign, $Imm & $MaskSign );
	
	if(
		( $Imm & $MaskSign ) != 0 &&
		( $Imm & $MaskSign ) != $MaskSign
		
	){
		$bOverflow = 1;
		Error( "imm ($Imm) size exceeded $Size bit" )
			if( !$bNoErrOut && !$bRedoAsm );
	}
	
	return( $Imm & (( 1 << $Size ) - 1 ) & 0xFFFF, $bOverflow );
}

### define label #############################################################

sub DefineLabel{
	local( $Label, $Imm, $bImmMode ) = @_;
	
	#print( "in>path=$PathCnt, Lab=$Label, Imm='$Imm', M=$bImmMode, Redo=$bRedoAsm\n" );
	
	# rs, rr のみ特別扱い
	
	if( $Label eq 'rs' || $Label eq 'rr' ){
		$LabelList{ $Label } = $Imm;
		return;
	}
	
	# 二重定義?
	Error( "redefined label \"$Label\"" )
		if( !$PathCnt && defined( $LabelList{ $Label } ) && !$bImmMode );
	
	# アドレス値が違う ( 再アセンブル必要 )
	if( $LabelList{ $Label } ne $Imm ){
		$bRedoAsm = 1;
		$LabelList{ $Label } = $Imm;
		
		#print( "!!>path=$PathCnt, Lab=$Label, Imm=$Imm, M=$bImmMode, Redo=$bRedoAsm\n" );
	}
}

### label --> addr ###########################################################

sub Label2Imm{
	
	local( $Label ) = @_;
	
	#print( "L2I>$Label\n" );
	
	# defined
	return( $LabelList{ $Label } ) if( defined( $LabelList{ $Label } ));
	
	# undefined
	Error( "undefined label \"$Label\"" ) if( $PathCnt );
	return( 0 );
}

### label --> string #########################################################

sub Label2Str{
	
	local( $Label ) = @_;
	
	#print( "L2S>$Label\n" );
	
	# defined
	return( $LabelList{ $Label } ) if( defined( $LabelList{ $Label } ));
	return( $Label );
}

### get reg number ###########################################################

sub GetRegNumber{
	
	local( $Line ) = @_;
	if( $Line =~ /\s*$RegName\s*/ ){
		$Line =~ /\d/;
		return( 0 + $& );
	}
	
	Error( "invalid operand \"$Line\" ( reg requred )" );
	return;
}

### setup insn tbl ###########################################################

sub SetupInsnTbl{
	
	local(
		$i,
		$Code,
		$Optype
	);
	
#	@InsnTbl = sort( @InsnTbl );
	
	while( $#InsnTbl >= 0 ){
		&AddInsnTbl( shift( @InsnTbl ));
	}
}

sub AddInsnTbl{
	
	local( $Line ) = @_;
	local(
		$Code,
		$Optype
	);
	
	$Line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(.+)/;
	
	$Code			   = $1;
#	push( @MnemonicList, $2 );
	$Optype			   = $3;
	push( @CategoryList, $4 );
	
	# ニーモニックが複数あるときは，最後のやつが代表で登録される
	# だから同じニーモニックで * とそれ以外が混じってるとまずい
	$OptypeList{ $2 } = $Optype;
	
	$Optype = '' if( $Optype eq '-' || $Optype eq '*' );
	push( @MnmOprList, "$2:$Optype" );
	
	if( $Code =~ /^0x(.*)/ ){
		$Code = Hex2Dec( $1 );
	}
	
	push( @InsnCodeList, $Code );
	
	#$i = $#InsnCodeList;
	#print( "tbl>$i, $InsnCodeList[ $i ], $MnmOprList[ $i ], $CategoryList[ $i ]\n" );
}

### マクロ定義 ###############################################################

sub DefineMacro{
	local( $Line ) = @_;
	local(
		$Opc,
		$Opr
	);
	
	$Line =~ s/\\;/;/g;
	
	if( $Line =~ /^\s*($CSymbol:?\S*)\s+(.+)/ ){
		$Opc = $1;
		$Opr = $2;
		
		if( $Opc =~ /:/ ){		# optype 指定があれば spc で分離
			$Opc =~ s/:/ /g;
		}else{					# optype 指定がなければ '*' 指定
			$Opc .= ' *';
		}
		
		&AddInsnTbl( "M $Opc $Opr" );
	}else{
		Error( "invalid macro definition" );
	}
}

### print Error ##############################################################

sub Error{
	print( "$SceFile($LineCnt): $_[ 0 ]\n" );
	$bError = 1;
}

### atoi functions ###########################################################

sub Bin2Dec{
	unpack( "N", pack( "B32", substr( "0" x 32 . $_[ 0 ], -32 )));
}

sub Hex2Dec{
	unpack( "N", pack( "H8", substr( "0" x 8 . $_[ 0 ], -8 )));
}

### marge Sim result & Src / disasm code #####################################

sub MargeSim_Src{
	
	local(
		$Line,
		$LocCnt
	);
	
	local( $TSC )		= 0;
	local( $StallCnt )	= 0;
	
	if( !open( fpSim, "< $SimLogFile" )){
		print( "Can't open file \"$SimLogFile\"\n" );
		$bError = 1;
		return;
	}
	
	if( !open( fpMrg, "> $MrgFile" )){
		print( "Can't open file \"$MrgFile\"\n" );
		$bError = 1;
		return;
	}
	
	while( $Line = <fpSim> ){
		last if( $Line =~ /^\s*$/ );
		
		++$TSC;
		
		# レジスタ値はそのまま出力
		$Line =~ s/[\x0D\x0A]//g;
		print( fpMrg $Line );
		$LocCnt = Hex2Dec( substr( $Line, 46, 3 ));
		
		++$StallCnt if( substr( $Line, 50, 4 ) eq 'fe00' );
		
		# アセンブリコードの出力
		
		if( substr( $Line, 45, 1 ) eq '*' ){
			#print( fpMrg "  (stall)\n" );
			print( fpMrg "\n" );
			++$StallCnt;
			
		}elsif( !defined( $SrcBuf[ $LocCnt ] )){
			print( fpMrg "  (no src?)\n" );
		}else{
			printf( fpMrg "   $SrcBuf[ $LocCnt ]\n" );
		}
	}
	
	printf( fpMrg "\nExecution Time (stall/total) = %d/%d (%.1f%%)\n\n",
						$StallCnt, $TSC, $StallCnt * 100 / $TSC );
	
	while( $Line = <fpSim> ){
		printf( fpMrg $Line );
	}
	
	close( fpMrg );
	close( fpSim );
}

### create lib header ########################################################

sub CreateLibHeader{
	
	local( $Line );
	
	if( !open( fpIn, "< $SceFile" )){
		print( "Can't open file \"$SceFile\"\n" );
		$bError = 1;
		return;
	}
	
	if( !open( fpHdr, "> $HdrFile" )){
		print( "Can't open file \"$HdrFile\"\n" );
		$bError = 1;
		return;
	}
	
	while( $Line = <fpIn> ){
		
		if( $Line =~ /^#extern (.*)/ ){
			printf( fpHdr "#define USELIB$1\n" );
		}
	}
	
	close( fpIn );
	close( fpHdr );
}
