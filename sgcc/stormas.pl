#!/usr/bin/perl

#*****************************************************************************
#
#		STORM assembler
#		Copyright(C) 2002 by Deyu Deyu Software ( Yoshihisa Tanaka )
#
#*****************************************************************************
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
# 2001.10.15	jb jnb 追加 ( 忘れてた (^^; )
# 2001.10.30	マルチラインマクロ機能追加
# 2002.02.21	jcc 自動 near 変換機能追加
#				jcc hoge, 1 の slot 自動 nop 埋め対応
# 2002.02.22	mif / sim 同時だし opt 追加
# 2002.03.01	STORMulator 追加 (^^;
#				marge 時に stall 行を削除するオプション追加
# 2002.03.16	文字列定数をサポート (あまりスマートじゃないけど)
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
	'0xC000		mov		rM		mrM',
	'0xC400		mov		Mr		mMr',
	'0xF800		mov		rr		3,0',
	'0x0000		movi	ri		mi',
	
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
	'0xF480		swp		rr?		S',
	
	'0xE000		jz		ii?		J',
	'0xE100		jnz		ii?		J',
	'0xE200		js		ii?		J',
	'0xE300		jns		ii?		J',
	'0xE400		jo		ii?		J',
	'0xE500		jno		ii?		J',
	'0xE600		jb		ii?		J',
	'0xE600		jc		ii?		J',
	'0xE600		jnae	ii?		J',
	'0xE700		jnb		ii?		J',
	'0xE700		jnc		ii?		J',
	'0xE700		jae		ii?		J',
	'0xE800		jbe		ii?		J',
	'0xE800		jna		ii?		J',
	'0xE900		ja		ii?		J',
	'0xE900		jnbe	ii?		J',
	'0xEA00		jl		ii?		J',
	'0xEA00		jnge	ii?		J',
	'0xEB00		jge		ii?		J',
	'0xEB00		jnl		ii?		J',
	'0xEC00		jle		ii?		J',
	'0xEC00		jng		ii?		J',
	'0xED00		jg		ii?		J',
	'0xED00		jnle	ii?		J',
	'0xEE00		jmp		ii?		jmp',
	'0xFA00		jmp		ri?		jmpr',
	'0xFC00		spc		r		3,0',
	
	'0xFE00		nop		-		0,0',
	
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
	'M			ret		-		jmp	rr',
	'M			ret		i		jmp	rr, $1',
#	'M			push	*		mov	[rs-1], $1; dec	rs',
#	'M			pop		*		mov	$1, [rs]; inc	rs',
#	'M			nop		*		mov	r0, r0;',
	'M			hlt		*		jmp	$; jmp $-1',
);

&main();
exit( $bError );

### main procedure ###########################################################

sub main{
	
	$bError		= 0;
	
	while( $ARGV[ 0 ] =~ /^-/ ){
		
		if( $ARGV[ 0 ] eq '-ot' ){
			$TxtMifFile = $ARGV[ 1 ];
			shift( @ARGV );
			
		}elsif( $ARGV[ 0 ] eq '-od' ){
			$DatMifFile = $ARGV[ 1 ];
			shift( @ARGV );
			
		}else{
			$bMifOut		= 1 if( $ARGV[ 0 ] =~ /f/ );
			$bSimOut		= 1 if( $ARGV[ 0 ] =~ /s/ );
			$bMrgSim		= 1 if( $ARGV[ 0 ] =~ /[mM]/ );
			$bMrgSimStall	= 1 if( $ARGV[ 0 ] =~ /m/ );
			$bLibHeader		= 1 if( $ARGV[ 0 ] =~ /h/ );
			$bLstOut		= 1 if( $ARGV[ 0 ] =~ /l/ );
			$bExecSim		= 1 if( $ARGV[ 0 ] =~ /[eE]/ );
			$bExecSimMrg	= 1 if( $ARGV[ 0 ] =~ /e/ );
		}
		
		shift( @ARGV );
	}
	
	$bMifOut = 1 if( $bMifOut == 0 && $bSimOut == 0 );
	
	# setup file name
	
	$SceFile = $ARGV[ 0 ];
	
	$SceFile  =~ /(.*)\./;
	$BaseName = ( $1 ne '' ) ? $1 : $SceFile;
	
	$TxtMifFile  = $BaseName . '_text.mif' if( $TxtMifFile eq '' );
	$DatMifFile  = $BaseName . '_data.mif' if( $DatMifFile eq '' );
	$TxtSimFile  = $BaseName . '_text.obj'; #if( $TxtSimFile eq '' );
	$DatSimFile  = $BaseName . '_data.obj'; #if( $DatSimFile eq '' );
	
	$LstFile  = "$BaseName.lst";
	$LogFile  = "$BaseName.log";
	$MrgFile  = "$BaseName.mrg";
	
	# if -h, create lib header file & exit
	
	if( $bLibHeader ){
		&CreateLibHeader();
		return;
	}
	
	# setup instruction table
	
	if( $#ARGV < 0 ){
		$0 =~ /[^\\\/]+$/;
		print( "usage : $& [-eEhlmMs] [-ot | -od <output file>] <source file>\n" );
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
	
	if( $bMifOut ){
		unlink( $TxtMifFile );
		unlink( $DatMifFile );
		
		&OutputCode( $TxtMifFile,  512, 0, @CodeText ) if( $#CodeText >= 0 );
		&OutputCode( $DatMifFile, 1024, 0, @CodeData ) if( $#CodeData >= 0 );
	}
	
	if( $bSimOut ){
		unlink( $TxtSimFile );
		unlink( $DatSimFile );
		
		&OutputCode( $TxtSimFile,  512, 1, @CodeText ) if( $#CodeText >= 0 );
		&OutputCode( $DatSimFile, 1024, 1, @CodeData ) if( $#CodeData >= 0 );
	}
	
	# sim 結果とマージ
	&MargeSim_Src() if( $bMrgSim );
	
	# sim 実行
	&Simulator() if( $bExecSim );
}

### output code ##############################################################

sub OutputCode{
	
	local( $FileName, $Len, $bSimOut, @Code ) = @_;
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
		$i,
	);
	
	$bRedoAsm					= 0;
	local( $LineCnt )			= 0;
	local( $LocCnt )			= 0;
	local( $LocCntText )		= 0;
	local( $LocCntData )		= 0;
	local( $bTextSeg )			= 1;
	local( $JccRejmpPoint )		= -1;
	local( $JccRejmpLabel )		= ();
	local( $JccFillSlotPoint )	= -1;
	local( $JccFillSlotCnt )	= 0;
	@CodeText					= ();
	@CodeData					= ();
	@CodeImm					= ();
	
	#print( "path $PathCnt\n" );
	
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
		&MultiLineParser( "jmp _main, 0", 1 );
	}
	
	# 構文解析ループ
	
	while( $Line = <fpIn> ){
		# 改行削除
		
		$Line =~ s/[\x0D\x0A]//g;
		++$LineCnt;
		
		&MultiLineParser( $Line );
	}
	
	# movi 定数の処理
	$i = $#CodeData + 1;
	push( @CodeData, @CodeImm );
	
	print( fpLst ' ' x 30 . ": data	# auto generated imm\n" )
		if( $bLstOut && $#CodeImm >= 0 );
	
	for( ; $i <= $#CodeData; ++$i ){
		&DefineLabel( $ImmPfx . $CodeData[ $i ], $i, 1 );
		
		printf( fpLst "D%03X: %04X" . ' ' x 20 . ": %-10sdw    %d\n",
			$i,
			$CodeData[ $i ],
			$ImmPfx . $CodeData[ $i ] . ':' ,
			$CodeData[ $i ]
		) if( $bLstOut );
	}
	
	#@CodeImm = ();	# なぜか定数処理が二重に行われてしまうので (;_;)
	
	$i = $#CodeText + 1;
	Error( "text size overflow ( $i )" ) if( $i > 512 );
	
	$i = $#CodeData + 1;
	Error( "data size overflow ( $i )" ) if( $i > 1024 );
	
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
		$Tmp,
		$Overflow
	);
	
	$OrgLine = $Line;
	
	# 文字列定数展開
	$Line =~ s/"([^"]+)"/&ExpandString( $1 )/ge;
	$Line =~ s/'([^']+)'/&ExpandString( $1 )/ge;
	
	$Line = &DeleteComment( $Line );
	
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
			&PrintLstFile();
			&DefineMacro( $OperandStr );
			
			next;
		}
		
		### code 生成 ########################################################
		
		if( $Category eq 'mi' ){		### movi #############################
			
			$i = ( &CheckImmSize( $Operands[ 1 ], 11, 1 ))[ 1 ];
			goto MovRI if( !$i );	# non overflow, convert mov r,i
			
			&PrintLstFile();
			&MultiLineParser( "mov	r$Operands[ 0 ], [$ImmPfx$Operands[ 1 ]]", 1 );
			
			# movi リストになければ，登録
			
			for( $i = 0; $i <= $#CodeImm; ++$i ){
				last if( $CodeImm[ $i ] == $Operands[ 1 ] );
			}
			
			push( @CodeImm, $Operands[ 1 ] ) if( $i > $#CodeImm );
			next;
			
		}elsif( $Category =~ /^(\d+),(\d+)$/ ){ ### 計算ですむやつ #########
			
			push( @CodeBuf, $Code | ( $Operands[ 0 ] << $1 ) |
									( $Operands[ 1 ] << $2 ));
			
		}elsif( $Category eq 'mri' ){	### mov r,m ##########################
			
		  MovRI:
			$i = ( &CheckImmSize( $Operands[ 1 ], 11 ))[ 0 ];
			push( @CodeBuf, $Code | ( $Operands[ 0 ] << 11 ) | $i );
			
		}elsif( $Category eq 'mrM' ){	### mov r,M ##########################
			
			Error( "unmatch operand type ( requre r0 - r3 )" )
				if( $Operands[ 0 ] >= 4 );
			
			push( @CodeBuf, $Code | ( $Operands[ 0 ] << 11 ) | $Operands[ 1 ] );
			
		}elsif( $Category eq 'mMr' ){	### mov M,r ##########################
			
			Error( "unmatch operand type ( require r0 - r3 )" )
				if( $Operands[ 1 ] >= 4 );
			
			push( @CodeBuf, $Code | ( $Operands[ 1 ] << 11 ) | $Operands[ 0 ] );
			
		}elsif( $Category eq 'A' ){	### add r,i ##########################
			
			$i = ( &CheckImmSize( $Operands[ 1 ], 8 ))[ 0 ];
			push( @CodeBuf, $Code | ( $Operands[ 0 ] << 11 ) | $i );
			
		}elsif( $Category eq 'S' ){	### sh r[,r] #########################
			
			$Operands[ 1 ] = $Operands[ 0 ] if( $Optype eq 'r' );
			push( @CodeBuf, $Code | ( $Operands[ 0 ] << 3 ) | $Operands[ 1 ] );
			
		}elsif( $Category eq 'J' ){	### jcc ##############################
			
			#print( "addr:$Operands[ 0 ], $LocCnt\n" );
			( $i, $Overflow ) = &CheckImmSize( $Operands[ 0 ] - $LocCnt - 1, 8, 1 );
			
			# slot の nop 埋め予約
			if( $Optype eq 'ii' && $Operands[ 1 ] < 3 ){
				$JccFillSlotPoint = $LocCnt + $Operands[ 1 ] + 1;
				$JccFillSlotCnt   = 3 - $Operands[ 1 ];
			}
			
			if( $Overflow ){
				# near jmp 変換
				if( $Mnemonic =~ /^jn/ ){
					$Mnemonic =~ s/^jn/j/g;
				}else{
					$Mnemonic =~ s/^j/jn/g;
				}
				&PrintLstFile();
				&MultiLineParser( "$Mnemonic \$+6", 1 );
				
				# ここの $LocCnt は jcc 命令の直後になってる
				$JccRejmpPoint = $LocCnt + 3;
				$JccRejmpLabel = $OperandStr;
				
				next;
				
			}else{
				# short jmp のまま
				push( @CodeBuf, $Code | $i );
			}
			
		}elsif( $Category eq 'jmp' ){	### jmp ##############################
			
			# slot の nop 埋め予約
			if( $Optype eq 'ii' && $Operands[ 1 ] < 1 ){
				$JccFillSlotPoint = $LocCnt + $Operands[ 1 ] + 1;
				$JccFillSlotCnt   = 1 - $Operands[ 1 ];
			}
			push( @CodeBuf, $Code | (( $Operands[ 0 ] - $LocCnt - 1 ) & 0x1FF ));
			
		}elsif( $Category eq 'jmpr' ){	### jmpr #############################
			
			# slot の nop 埋め予約
			if( $Optype eq 'ri' && $Operands[ 1 ] < 1 ){
				$JccFillSlotPoint = $LocCnt + $Operands[ 1 ] + 1;
				$JccFillSlotCnt   = 1 - $Operands[ 1 ];
			}
			push( @CodeBuf, $Code | $Operands[ 0 ] );
			
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
			
		}elsif( $Mnemonic eq 'db' ||	### dw / db ##########################
				$Mnemonic eq 'dw' ){
			
			push( @CodeBuf, @Operands );
			
		}elsif( $Mnemonic eq 'org' ){	### org ##############################
			
			Error( "org address is exceeded by \$" ) if( $Operands[ 0 ] < $LocCnt );
			
			for( $i = $LocCnt; $i < $Operands[ 0 ]; ++$i ){
				push( @CodeBuf, 0 );
			}
		}elsif( $Mnemonic eq 'skip' ){	### skip #############################
			
			for( $i = 0; $i < $Operands[ 0 ]; ++$i ){
				push( @CodeBuf, 0 );
			}
		}
		
		### code 出力 ########################################################
		
	  PutCode:
		
		# 最初のリストを出力
		&PrintLstFile();
		
		if( $bLstOut ){
			
			# 残りのリストを出力
			for( $i = 4; $i <= $#CodeBuf; ++$i ){
				printf( fpLst "%s%03X:", ( $bTextSeg ? 'T' : 'D' ), $LocCnt + $i )
					if( $i % 4 == 0 );
					
				printf( fpLst " %04X", $CodeBuf[ $i ] );
				print( fpLst "\n" ) if( $i % 4 == 3 || $#CodeBuf == $i );
			}
		}
		
		if( $bTextSeg ){
			push( @CodeText, @CodeBuf );
			$LocCnt = $#CodeText + 1;
			
			# slot の nop 埋め
			if( $LocCnt == $JccFillSlotPoint ){
				
				&MultiLineParser( "nop",		 1 ) if( $JccFillSlotCnt == 1 );
				&MultiLineParser( "nop;nop",	 1 ) if( $JccFillSlotCnt == 2 );
				&MultiLineParser( "nop;nop;nop", 1 ) if( $JccFillSlotCnt == 3 );
				
				$JccFillSlotPoint = -1;
			}
			
			# JccRejmp を出力
			if( $LocCnt == $JccRejmpPoint ){
				&MultiLineParser( "jmp $JccRejmpLabel; nop", 1 );
				$JccRejmpPoint = -1;
			}
			
		}else{
			push( @CodeData, @CodeBuf );
			$LocCnt = $#CodeData + 1;
		}
	}
}

### print insn list file #####################################################

sub PrintLstFile{
	
	local( $i ) = 0;
	local( $Line );
	
	# asm テキスト整形
	
	if( $bExpandMacro ){
		$Line2 =~ /^($CSymbol:)? ?($CSymbol) ?(.*)/;
		$Line = sprintf( "      +%-8s%-8s%s", $1, $2, $3 );
	}else{
		$Line = sprintf( "%5d: %s", $LineCnt, $OrgLine );
	}
	$SrcBuf[ $LocCnt ] = $Line if( $bTextSeg );
	
	return if( !$bLstOut || $#CodeBuf < 0 && $bExpandMacro );
	
	# コード出力
	
	if( $#CodeBuf < 0 ){
		print( fpLst "     " );
	}else{
		printf( fpLst "%s%03X:", ( $bTextSeg ? 'T' : 'D' ), $LocCnt );
		
		for( $i = 0; $i <= $#CodeBuf && $i < 4; ++$i ){
			printf( fpLst " %04X", $CodeBuf[ $i ] );
		}
	}
	
	print( fpLst ' ' x (( 4 - $i ) * 5 ) . "$Line\n" );
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
	
	@InsnTbl = sort( @InsnTbl );
	
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
		$Opr,
		$OrgLine
	);
	
	$Line =~ s/\\;/;/g;
	
	if( $Line =~ /^\s*($CSymbol:?\S*)\s*(.*)/ ){
		$Opc = $1;
		$Opr = $2;
		
		if( $Opc =~ /:/ ){		# optype 指定があれば spc で分離
			$Opc =~ s/:/ /g;
		}else{					# optype 指定がなければ '*' 指定
			$Opc .= ' *';
		}
		
		# マルチラインマクロ?
		if( $Opr =~ /^\s*$/ ){
			
			$Opr = '';
			
			while( $OrgLine = <fpIn> ){
				
				# 改行削除
				
				$OrgLine =~ s/[\x0D\x0A]//g;
				++$LineCnt;
				&PrintLstFile();
				&DeleteComment( $OrgLine );
				
				last if( $OrgLine eq 'endm' );
				
				$Opr .= ';' . $OrgLine;
			}
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

sub DeleteComment {
	
	local( $Line ) = @_;
	
	$Line =~ s/#.*//g;			# コメント削除
	$Line =~ s/^\s+//g;			# 行前後空白削除
	$Line =~ s/\s+$//g;
	$Line =~ s/\s+/ /g;			# 空白圧縮
	$Line =~ s/\s*;\s*/;/g;		# 行セパレータ前後空白削除
	
	return( $Line );
}

### expand const string ######################################################

sub ExpandString{
	local( $Line ) = @_;
	local( $Data );
	
	$Data = sprintf( "0x%02X", unpack( "C", $Line ));
	$Line = substr( $Line, 1 );
	
	while( $Line ne "" ){
		$Data .= sprintf( ",0x%02X", unpack( "C", $Line ));
		$Line = substr( $Line, 1 );
	}
	
	return( $Data );
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
		
		if( !$bMrgSimStall && substr( $Line, 45, 1 ) eq '*' ){
			++$StallCnt;
			next;
		}
		
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
	
	print( fpMrg "\n" );
	
	while( $Line = <fpSim> ){
		printf( fpMrg $Line );
	}
	
	printf( fpMrg "\nExecution Time (stall/total) = %d/%d (%.1f%%)\n",
						$StallCnt, $TSC, $StallCnt * 100 / $TSC );
	
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

### simulator ################################################################

sub Simulator{
	
	local( @Reg )	= ( 0, 0, 0, 0, 0, 0, 0, 0 );
	local( $PC )	= 0;
	local( $IR )	= 0;
	local( $FlagO, $FlagS, $FlagZ, $FlagC ) = ( 0, 0, 0, 0 );
	local( $InsnIdx );
	local( $bJccTrue );
	local( $Opc );
	local( $Opr1Reg );
	local( $Opr1Val );
	local( $Opr2Val );
	local( $i );
	
	local( @JmpAddr ) = ();
	
	if( !open( fpLog, "> $LogFile" )){
		print( "Can't open file \"$LogFile\"\n" );
		$bError = 1;
		return;
	}
	
	for(;; ++$PC ){
		
		# PC の設定 (遅延分岐関係)
		$PC = $JmpAddr[ 0 ] if( defined( $JmpAddr[ 0 ] ));
		shift( @JmpAddr );
		
		$PC = $PC & 0x1FF;
		$IR = $CodeText[ $PC ];
		
		# レジスタダンプ
		printf( fpLog
			'%04x %04x %04x %04x %04x %04x %04x %04x %s%s%s%s  %03x:%04x',
			$Reg[ 0 ], $Reg[ 1 ], $Reg[ 2 ], $Reg[ 3 ],
			$Reg[ 4 ], $Reg[ 5 ], $Reg[ 6 ], $Reg[ 7 ],
			( $FlagO ? 'O' : '.' ),
			( $FlagS ? '-' : '+' ),
			( $FlagZ ? 'Z' : '.' ),
			( $FlagC ? 'C' : '.' ),
			$PC, $IR
		);
		
		# ソースコードのマージ
		
		if( $bExecSimMrg ){
			if( !defined( $SrcBuf[ $PC ] )){
				print( fpLog "  (no src?)\n" );
			}else{
				printf( fpLog "   $SrcBuf[ $PC ]\n" );
			}
		}else{
			print( '\n' );
		}
		
		# オペコードの判定
		for( $i = 0, $InsnIdx = 0;; ++$i ){
			
			if(
				$IR >= $InsnCodeList[ $i ] &&
				$InsnCodeList[ $i ] > $InsnCodeList[ $InsnIdx ]
			){
				$InsnIdx = $i;
			}
			
			last if(
				$IR <= $InsnCodeList[ $i ] ||
				$MnmOprList[ $i ] eq 'nop:'
			);
		}
		
		# print( fpLog "# $MnmOprList[ $InsnIdx ]\n" );
		
		# 命令の実行
		
		### mov 系 ###########################################################
		
		if( $MnmOprList[ $InsnIdx ] eq 'mov:ri' ){
			# mov r, imm11
			$Reg[ ( $IR >> 11 ) & 7 ] = &GetInsnImm( 11 );
			
		}elsif(
			$MnmOprList[ $InsnIdx ] eq 'mov:rm' ||
			$MnmOprList[ $InsnIdx ] eq 'mov:mr'
		){
			# mov r, m / m, r
			if	 ((( $IR >> 8 ) & 3 ) == 0 ){ $i = $Reg[ 0 ] }
			elsif((( $IR >> 8 ) & 3 ) == 1 ){ $i = $Reg[ 1 ] }
			elsif((( $IR >> 8 ) & 3 ) == 2 ){ $i = $Reg[ 4 ] }
			else							{ $i = $Reg[ 5 ] }
			
			# printf( "%X %X\n", $PC, $i );
			if( $i < 0x4000 || 0xC000 <= $i ){
				# メモリアクセス
				$i = ( $i + &GetInsnImm( 8 )) & 0x3FF;
				
				if( $IR & 0x400 ){
					$CodeData[ $i ] = $Reg[ ( $IR >> 11 ) & 7 ];
				}else{
					$Reg[ ( $IR >> 11 ) & 7 ] = $CodeData[ $i ];
				}
			}else{
				# I/O アクセス
				if( $IR & 0x400 ){
					$CodeData[ $i ] = $Reg[ ( $IR >> 11 ) & 7 ];
				}else{
					$Reg[ ( $IR >> 11 ) & 7 ] = $CodeData[ $i ];
				}
			}
			
		}elsif(
			$MnmOprList[ $InsnIdx ] eq 'mov:rM' ||
			$MnmOprList[ $InsnIdx ] eq 'mov:Mr'
		){
			if( $IR & 0x400 ){
				# mov [imm], r
				$CodeData[ $IR & 0x3FF ] = $Reg[ ( $IR >> 11 ) & 3 ];
			}else{
				# mov r, [imm] 
				$Reg[ ( $IR >> 11 ) & 3 ] = $CodeData[ $IR & 0x3FF ];
			}
		}elsif( $MnmOprList[ $InsnIdx ] eq 'mov:rr' ){
			# mov r, r
			$Reg[ ( $IR >> 3 ) & 7 ] = $Reg[ $IR & 7 ];
			
		}elsif( $MnmOprList[ $InsnIdx ] eq 'spc:r' ){
			# spc r
			$Reg[ ( $IR >> 3 ) & 7 ] = ( $PC + 1 ) & 0x1FF;
			
		### jmp, jcc 系 ######################################################
		
		}elsif( $CategoryList[ $InsnIdx ] eq 'J' ){
			
			$MnmOprList[ $InsnIdx ] =~ /^j(n?)(.+):/;
			
			if	 ( $2 eq 'z'  ){ $bJccTrue = $FlagZ;	}
			elsif( $2 eq 's'  ){ $bJccTrue = $FlagS;	}
			elsif( $2 eq 'o'  ){ $bJccTrue = $FlagO;	}
			elsif( $2 eq 'b'  ){ $bJccTrue = $FlagC;	}
			elsif( $2 eq 'ae' ){ $bJccTrue = !$FlagC;	}
			elsif( $2 eq 'be' ){ $bJccTrue =  ( $FlagC || $FlagZ );	}
			elsif( $2 eq 'a'  ){ $bJccTrue = !( $FlagC || $FlagZ );	}
			elsif( $2 eq 'l'  ){ $bJccTrue =  ( $FlagS != $FlagO );	}
			elsif( $2 eq 'ge' ){ $bJccTrue = !( $FlagS != $FlagO );	}
			elsif( $2 eq 'le' ){ $bJccTrue =  (( $FlagS != $FlagO ) || $FlagZ ); }
			elsif( $2 eq 'g'  ){ $bJccTrue = !(( $FlagS != $FlagO ) || $FlagZ ); }
			
			$bJccTrue = !$bJccTrue if( $1 eq 'n' );
			# print( "$bJccTrue\n" );
			$JmpAddr[ 3 ] = $PC + &GetInsnImm( 8 ) + 1 if( $bJccTrue );
			
		}elsif( $MnmOprList[ $InsnIdx ] eq 'jmp:ii?' ){
			# jmp i, i
			$JmpAddr[ 1 ] = $PC + &GetInsnImm( 9 ) + 1;
			
		}elsif( $MnmOprList[ $InsnIdx ] eq 'jmp:ri?' ){
			# jmp r, i
			$JmpAddr[ 1 ] = $Reg[ $IR & 7 ];
			
		### nop ##############################################################
			
		}elsif( $MnmOprList[ $InsnIdx ] eq 'nop:' ){
			# nop
			
		### 演算 #############################################################
		
		}else{
			if( $CategoryList[ $InsnIdx ] eq 'A' ){
				$Opr2Val	= &GetInsnImm( 8 );
				$Opr1Reg	= ( $IR >> 11 ) & 7;
			}else{
				$Opr2Val	= $Reg[ $IR & 7 ];
				$Opr1Reg	= ( $IR >> 3 ) & 7;
			}
			
			$Opr1Val = $Reg[ $Opr1Reg ];
			$FlagO = 0;
			$MnmOprList[ $InsnIdx ] =~ /^(.+):/;
			
			$Opc  = ( $IR >> 8 ) & 7;
			$Opc += 0x8 if( $CategoryList[ $InsnIdx ] eq 'S' );
			
			#printf( fpLog "%X:%X %X %X\n", $PC, $Opc, $Opr1Reg, $Opr2Val );
			
			if( $Opc == 0x0 ){
				# add
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val + $Opr2Val );
				&SetFlagO( $Reg[ $Opr1Reg ], $Opr1Val, $Opr2Val );
				
			}elsif( $Opc == 0x1 ){
				# sub
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val - $Opr2Val );
				&SetFlagO( $Reg[ $Opr1Reg ], $Opr1Val, ~$Opr2Val );
				
			}elsif( $Opc == 0x2 ){
				# adc
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val + $Opr2Val + $FlagC );
				&SetFlagO( $Reg[ $Opr1Reg ], $Opr1Val, $Opr2Val );
				
			}elsif( $Opc == 0x3 ){
				# sbb
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val - $Opr2Val - $FlagC );
				&SetFlagO( $Reg[ $Opr1Reg ], $Opr1Val, ~$Opr2Val );
				
			}elsif( $Opc == 0x4 ){
				# and
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val & $Opr2Val );
				
			}elsif( $Opc == 0x5 ){
				# cmp
				$i = &SetFlag( $Opr1Val - $Opr2Val );
				&SetFlagO( $i, $Opr1Val, ~$Opr2Val );
				
			}elsif( $Opc == 0x6 ){
				# or
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val | $Opr2Val );
				
			}elsif( $Opc == 0x7 ){
				# xor
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr1Val ^ $Opr2Val );
				
			}elsif( $Opc == 0x8 ){
				# sar
				$Reg[ $Opr1Reg ] = &SetFlag(( $Opr2Val >> 1 ) | ( $Opr2Val & 0x8000 ));
				$FlagC = $Opr2Val & 1;
				
			}elsif( $Opc == 0xA ){
				# shr
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr2Val >> 1 );
				$FlagC = $Opr2Val & 1;
				
			}elsif( $Opc == 0xB ){
				# shl
				$Reg[ $Opr1Reg ] = &SetFlag( $Opr2Val << 1 );
				$FlagO = ( $Reg[ $Opr1Reg ] ^ $Opr2Val ) >> 15;
				
			}elsif( $Opc == 0xC ){
				# swp
				$Reg[ $Opr1Reg ] = &SetFlag(
										(( $Opr2Val & 0x00FF ) << 8 ) |
										(( $Opr2Val & 0xFF00 ) >> 8 ));
				$FlagC = Opr2Val & 1;
				
			}else{
				print( "invalid arthmetic opecode $1\n" );
			}
		}
		last if( $IR == 0xEFFF );
	}
	
	print( fpLog
		"\n" .
		"*** Instruction RAM dump ***********************************************************\n" .
		"ADDR   +0   +1   +2   +3   +4   +5   +6   +7   +8   +9   +A   +B   +C   +D   +E   +F\n"
	);
	
	for( $i = 0; $i < 0x200; ++$i ){
		printf( fpLog "%03x:", $i ) if( $i % 16 == 0 );
		
		if( defined( $CodeText[ $i ] )){
			printf( fpLog " %04x", $CodeText[ $i ] );
		}else{
			print( fpLog " xxxx" );
		}
		print( fpLog "\n" ) if( $i % 16 == 15 );
	}
	
	print( fpLog
		"\n" .
		"*** Data RAM dump ******************************************************************\n" .
		"ADDR   +0   +1   +2   +3   +4   +5   +6   +7   +8   +9   +A   +B   +C   +D   +E   +F\n"
	);
	
	for( $i = 0; $i < 0x400; ++$i ){
		printf( fpLog "%03x:", $i ) if( $i % 16 == 0 );
		
		if( defined( $CodeData[ $i ] )){
			printf( fpLog " %04x", $CodeData[ $i ] );
		}else{
			print( fpLog " xxxx" );
		}
		
		print( fpLog "\n" ) if( $i % 16 == 15 );
	}
	
	close( fpLog );
}

sub GetInsnImm{
	
	local( $Width ) = @_;
	local( $Imm );
	
	$Imm = ( $IR & ( 0xFFFF >> ( 16 - $Width )));
	
	# マイナスの数?
	if( $Imm & ( 1 << ( $Width - 1 ))){
		$Imm -= ( 1 << $Width );
	}
	
	return( $Imm & 0xFFFF );
}

sub SetFlag{
	local( $i ) = @_;
	
	$FlagS = (( $i &  0x8000 ) != 0 );
	$FlagZ = (( $i &  0xFFFF ) == 0 );
	$FlagC = (( $i & 0x10000 ) != 0 );
	
	return( $i & 0xFFFF );
}

sub SetFlagO{
	local( $Result, $Op1, $Op2 ) = @_;
	
	$FlagO = ( ~( $Op1 ^ $Op2 ) & ( $Op1 ^ $Result ) & 0x8000 ) >> 15;
}
