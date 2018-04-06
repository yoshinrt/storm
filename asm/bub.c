#include <storm.h>

void bsort( int iCnt );

#define	FULLAUTO

int iData[ 0x200 ];
int	iCnt = 100;

#ifdef FULLAUTO
INLINE UINT rand( void ){
	static UINT	r = 0xABCD;
	return( r = ( r * 7 + 1 ) & 0xFFFF );
}
#endif

int main( void ){
	int	i;
	//int iCnt = 0;
	
#ifdef FULLAUTO
	//iCnt = 100; /*InputData();*/
	for( i = 0; i < iCnt; ++i ) iData[ i ] = rand();
#else
	while( iData[ iCnt ] = InputData()) ++iCnt;
#endif
	bsort( iCnt );
	
	//for( i = 0; i < iCnt; ++i ) DisplayDataWait( iData[ i ] );
	
	// check
	for( i = 0; i < iCnt - 1; ++i )
		if( iData[ i ] > iData[ i + 1 ] ) Return( 0xFFFF );
	
	Return( 0 );
}

void bsort( int iCnt ){
	
	int	i, j, iSwp;
	
	for( i = iCnt - 2; i >= 0; --i ){
		for( j = 0; j <= i; ++j ){
			if( iData[ j ] > iData[ j + 1 ] ){
				
				iSwp			= iData[ j ];
				iData[ j ] 		= iData[ j + 1 ];
				iData[ j + 1 ]	= iSwp;
			}
		}
	}
}
