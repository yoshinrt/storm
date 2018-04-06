/*****************************************************************************
	
	Mine Sweeper for STORM
	Copyright(C) 2002 by Deyu Deyu Software
	
*****************************************************************************/

#include <storm.h>

/*** const ******************************************************************/

#define MINES	25						// 地雷の数

#define FIELD_MINE		1
#define FIELD_OPENED	2
#define FIELD_FLAG		4
#define FIELD_OPEN		8

#define C_CLOSE			0x87			// 開けてない	灰色
#define C_OPEN			0xC5			// 開けた		シアン
#define C_FLAG			0xC6			// フラグ		黄色
#define C_MISS			0xC2			// ミス			赤
#define C_MINE			0xC3			// 地雷			マゼンタ

/*** macro ******************************************************************/

#define X( n )			(( int )(( n ) & 0xF ))
#define Y( n )			(( int )(( n ) >> 4 ))

/*** extern *****************************************************************/

extern UINT	uRandomSeed;

/*** gloval var *************************************************************/

UINT uField[128];						// 地雷原

/*** フィールド全開 *********************************************************/

INLINE void OpenAllField( void ){
	
	UINT	u;
	
	for( u = 0; u < 128; ++u ){
		
		PortOutput( PORT_SetButtNo, u );
		
		if( uField[ u ] & FIELD_MINE ){
			if( uField[ u ] & FIELD_OPENED ){
				
				// 地雷を踏んだ
				PortOutput( PORT_SetButtColor, C_MISS );
				PortOutput( PORT_SetButtChar,  '*' );
				
			}else if(( uField[ u ] & FIELD_FLAG ) == 0 ){
				
				// 何もしてない地雷
				PortOutput( PORT_SetButtColor, C_MINE );
				PortOutput( PORT_SetButtChar,  '*' );
			}
		}else{
			if( uField[ u ] & FIELD_FLAG ){
				// 地雷なしでフラグがたってた
				
				PortOutput( PORT_SetButtColor, C_MISS );
			}
		}
	}
}

/*** フィールドを開ける処理 *************************************************/

INLINE void OpenField( void ){
	
	UINT	u;
	UINT	uMines;
	int		x, y, i, j;
	BOOL	bRescan;
	
	do{
		bRescan = FALSE;
		
		for( u = 0; u < 128; ++u ){
			
			// open 要求があった?
			if( uField[ u ] & FIELD_OPEN ){
				
				// とりあえずリクエストをクリア
				uField[ u ] &= ~FIELD_OPEN;
				uField[ u ] |= FIELD_OPENED;
				
				x = u &  0xF;
				y = u & ~0xF;
				uMines = 0;
				
				// 地雷の数を数える
				for( j = y - 16; j <= y + 16; j += 16 ){
					for( i = x - 1; i <= x + 1; ++i ){
						
						if(
							0 <= i && i <= 15 &&
							0 <= j && j <= 127
						){
							uMines += uField[ j + i ] & FIELD_MINE;
						}
					}
				}
				
				PortOutput( PORT_SetButtNo, u );
				PortOutput( PORT_SetButtColor, C_OPEN );
				PortOutput( PORT_SetButtChar,  '0' + uMines );		// 数
				
				// 地雷の数が 0 なら，近辺も開ける
				if( uMines == 0 ){
					for( j = y - 16; j <= y + 16; j += 16 ){
						for( i = x - 1; i <= x + 1; ++i ){
							
							if(
								0 <= i && i <= 15  &&
								0 <= j && j <= 127 &&
								( uField[ j + i ] & ( FIELD_OPENED | FIELD_FLAG )) == 0
							){
								uField[ j + i ] |= FIELD_OPEN;
								bRescan = TRUE;
							}
						}
					}
					PortOutput( PORT_SetButtChar, ' ' );		// 数
				}
			}
		}
	}while( bRescan );
}

/*** main procedure *********************************************************/

void main( void ){
	
	UINT	uButtNo,
			uPreButtNo;
	UINT	uFlags;
	UINT	u, v;
	
	PortOutput( PORT_ResetTerm, 0 );
	PutStr( "Mine Sweeper -- Push any button\n" );
	
  NewGame:
	
	while(( uButtNo = GetButton()) == 0xFF ){
		++uRandomSeed;
	}
	
	// ボタン初期化
	PortOutput( PORT_SetButtNo,    0xFF );		// 全ボタン
	PortOutput( PORT_SetButtColor, C_CLOSE );
	PortOutput( PORT_SetButtChar,  ' ' );		// 空白
	
	// field 初期化
	for( u = 0; u < 128; ++u ) uField[ u ] = 0;
	
	// 地雷敷設
	for( u = 0; u < MINES; ){
		v = Random() & 0x7F;
		if(( uField[ v ] & FIELD_MINE ) == 0 ){
			uField[ v ] |= FIELD_MINE;
			++u;
		}
	}
	
	// その他初期化
	uPreButtNo	= -1;
	uFlags		= 0;
	
	for(;;){
		// ボタン push 待ち
		while(( uButtNo = GetButton()) == 0xFF ) ++uRandomSeed;
		
		// PortOutput( PORT_SetButtNo, uButtNo );
		
		if(( uField[ uButtNo ] & ( FIELD_OPENED | FIELD_FLAG )) == 0 ){
			// 何もしていないところに，旗を立てる
			uField[ uButtNo ] |= FIELD_FLAG;
			PortOutput( PORT_SetButtColor, C_FLAG );
			PortOutput( PORT_SetButtChar, 'P' );		// 旗
			++uFlags;
			
		}else if( uField[ uButtNo ] & FIELD_FLAG ){
			
			uField[ uButtNo ] &= ~FIELD_FLAG;
			--uFlags;
			
			if( uPreButtNo != uButtNo ){
				// 前回クリックが違うボタンなら，フラグ解除
				PortOutput( PORT_SetButtColor, C_CLOSE );
				PortOutput( PORT_SetButtChar, ' ' );	// 無旗
				
			}else{
				// 旗が立っていたら，開ける
				uField[ uButtNo ] |= FIELD_OPENED;
				
				if( uField[ uButtNo ] & FIELD_MINE ){
					// 地雷を踏んだ
					OpenAllField();
					PutStr( "Game Over (;_;)\n" );
					goto NewGame;
				}else{
					// 地雷の数を数える
					uField[ uButtNo ] |= FIELD_OPEN;
					OpenField();
				}
			}
		}
		uPreButtNo = uButtNo;
	}
}
