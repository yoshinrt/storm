/*****************************************************************************
	
	Mine Sweeper for STORM
	Copyright(C) 2002 by Deyu Deyu Software
	
*****************************************************************************/

#include <storm.h>

/*** const ******************************************************************/

#define MINES	25						// ����ο�

#define FIELD_MINE		1
#define FIELD_OPENED	2
#define FIELD_FLAG		4
#define FIELD_OPEN		8

#define C_CLOSE			0x87			// �����Ƥʤ�	����
#define C_OPEN			0xC5			// ������		������
#define C_FLAG			0xC6			// �ե饰		����
#define C_MISS			0xC2			// �ߥ�			��
#define C_MINE			0xC3			// ����			�ޥ���

/*** macro ******************************************************************/

#define X( n )			(( int )(( n ) & 0xF ))
#define Y( n )			(( int )(( n ) >> 4 ))

/*** extern *****************************************************************/

extern UINT	uRandomSeed;

/*** gloval var *************************************************************/

UINT uField[128];						// ���븶

/*** �ե���������� *********************************************************/

INLINE void OpenAllField( void ){
	
	UINT	u;
	
	for( u = 0; u < 128; ++u ){
		
		PortOutput( PORT_SetButtNo, u );
		
		if( uField[ u ] & FIELD_MINE ){
			if( uField[ u ] & FIELD_OPENED ){
				
				// �����Ƨ���
				PortOutput( PORT_SetButtColor, C_MISS );
				PortOutput( PORT_SetButtChar,  '*' );
				
			}else if(( uField[ u ] & FIELD_FLAG ) == 0 ){
				
				// ���⤷�Ƥʤ�����
				PortOutput( PORT_SetButtColor, C_MINE );
				PortOutput( PORT_SetButtChar,  '*' );
			}
		}else{
			if( uField[ u ] & FIELD_FLAG ){
				// ����ʤ��ǥե饰�����äƤ�
				
				PortOutput( PORT_SetButtColor, C_MISS );
			}
		}
	}
}

/*** �ե�����ɤ򳫤������ *************************************************/

INLINE void OpenField( void ){
	
	UINT	u;
	UINT	uMines;
	int		x, y, i, j;
	BOOL	bRescan;
	
	do{
		bRescan = FALSE;
		
		for( u = 0; u < 128; ++u ){
			
			// open �׵᤬���ä�?
			if( uField[ u ] & FIELD_OPEN ){
				
				// �Ȥꤢ�����ꥯ�����Ȥ򥯥ꥢ
				uField[ u ] &= ~FIELD_OPEN;
				uField[ u ] |= FIELD_OPENED;
				
				x = u &  0xF;
				y = u & ~0xF;
				uMines = 0;
				
				// ����ο��������
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
				PortOutput( PORT_SetButtChar,  '0' + uMines );		// ��
				
				// ����ο��� 0 �ʤ顤���դⳫ����
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
					PortOutput( PORT_SetButtChar, ' ' );		// ��
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
	
	// �ܥ�������
	PortOutput( PORT_SetButtNo,    0xFF );		// ���ܥ���
	PortOutput( PORT_SetButtColor, C_CLOSE );
	PortOutput( PORT_SetButtChar,  ' ' );		// ����
	
	// field �����
	for( u = 0; u < 128; ++u ) uField[ u ] = 0;
	
	// ��������
	for( u = 0; u < MINES; ){
		v = Random() & 0x7F;
		if(( uField[ v ] & FIELD_MINE ) == 0 ){
			uField[ v ] |= FIELD_MINE;
			++u;
		}
	}
	
	// ����¾�����
	uPreButtNo	= -1;
	uFlags		= 0;
	
	for(;;){
		// �ܥ��� push �Ԥ�
		while(( uButtNo = GetButton()) == 0xFF ) ++uRandomSeed;
		
		// PortOutput( PORT_SetButtNo, uButtNo );
		
		if(( uField[ uButtNo ] & ( FIELD_OPENED | FIELD_FLAG )) == 0 ){
			// ���⤷�Ƥ��ʤ��Ȥ���ˡ�����Ω�Ƥ�
			uField[ uButtNo ] |= FIELD_FLAG;
			PortOutput( PORT_SetButtColor, C_FLAG );
			PortOutput( PORT_SetButtChar, 'P' );		// ��
			++uFlags;
			
		}else if( uField[ uButtNo ] & FIELD_FLAG ){
			
			uField[ uButtNo ] &= ~FIELD_FLAG;
			--uFlags;
			
			if( uPreButtNo != uButtNo ){
				// ���󥯥�å����㤦�ܥ���ʤ顤�ե饰���
				PortOutput( PORT_SetButtColor, C_CLOSE );
				PortOutput( PORT_SetButtChar, ' ' );	// ̵��
				
			}else{
				// ����Ω�äƤ����顤������
				uField[ uButtNo ] |= FIELD_OPENED;
				
				if( uField[ uButtNo ] & FIELD_MINE ){
					// �����Ƨ���
					OpenAllField();
					PutStr( "Game Over (;_;)\n" );
					goto NewGame;
				}else{
					// ����ο��������
					uField[ uButtNo ] |= FIELD_OPEN;
					OpenField();
				}
			}
		}
		uPreButtNo = uButtNo;
	}
}
