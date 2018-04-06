#include <storm.h>

void qsort( int iStart, int iStop );

#define	FULLAUTO

int iData[ 0x200 ];
int	iCnt = 500;

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
	qsort( 0, iCnt - 1 );
	
	// check
	for( i = 0; i < iCnt - 1; ++i ){
		if( iData[ i ] > iData[ i + 1 ] ) return( 0xFFFF );
		DisplayData( iData[ i ] );
	}
	return( 0 );
}

void qsort( int iStart, int iStop ){
	
	int		i = iStart,
			j = iStop,
			iKey = iData[ ( i + j ) >> 1 ],
			iSwp;
	
	if( i >= j ) return;
	if( i + 1 == j ){
		if( iData[ i ] > iData[ j ] ){
			iSwp = iData[ i ]; iData[ i ] = iData[ j ]; iData[ j ] = iSwp;
		}
		return;
	}
	
	do{
		while( iData[ i ] < iKey ) ++i;
		while( iData[ j ] > iKey ) --j;
		if( i >= j ) break;
		iSwp = iData[ i ]; iData[ i ] = iData[ j ]; iData[ j ] = iSwp;
		++i; --j;
	}while( i <= j );
	
	if( i == j ){
		++i;
		--j;
	}
	qsort( iStart, j );
	qsort( i, iStop );
}
