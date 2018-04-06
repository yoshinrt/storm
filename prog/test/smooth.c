/*** smoothing **************************************************************/

#include <storm.h>

#define SizeX	160
#define SizeY	120

#define BMP_DATA_OFFSET	0x36		// byte address
#define BUFSIZE			28827		// word size: .bmp file size = 57654bytes

/*** gloval var def. ********************************************************/

UINT	Data[ BUFSIZE ],
		Data2[ BUFSIZE ];

/*** 8bit access function ***************************************************/

INLINE UINT GetCharData( UINT *pBase, UINT uAddr ){
	
	return(( uAddr & 1 )?
		( pBase[ uAddr >> 1 ] >> 8 ) :		// odd:	High word
		( pBase[ uAddr >> 1 ] & 0xFF ));	// even: Low word
}

INLINE void SetCharData( UINT *pBase, UINT uAddr, UINT uData ){
	
	UINT	uPreData = pBase[ uAddr >> 1 ];
	
	pBase[ uAddr >> 1 ] = ( uAddr & 1 )?
		(( uPreData & 0xFF ) | ( uData << 8 )) :		// odd
		(( uPreData & 0xFF00 ) | ( uData & 0xFF ));		// even
}

/*** main procedure *********************************************************/

void main( void ){
	
	UINT	x, y, c;
	int		sx, sy;
	UINT	uPix;
	
	for( y = 1; y < SizeY - 1; ++y ){
		for( x = 1; x < SizeX - 1; ++x ){
			for( c = 0; c < 3; ++c ){
				
				uPix = 0;
				
				for( sy = -1; sy <= 1; ++sy ){
					for( sx = -1; sx <= 1; ++sx ){
						uPix += GetCharData(
							Data,
							(( x + sx ) + ( y + sy ) * SizeX ) * 3 + c );
					}
				}
				
				SetCharData(
					Data2,
					( x + y * SizeX ) * 3 + c,
					uPix / 9 );
			}
		}
	}
}
