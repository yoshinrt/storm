/*** bubble / quick sort ****************************************************/

#include <storm.h>

/*** const ******************************************************************/

#define	FULLAUTO
#define NO_DISPLAY

//#define DATA_NUM		0x380
#define DATA_NUM		64
#define ELEM_BSORT		0			// —v‘f‚ª EMEM_BSORT+1 ‚ÌŽž‚Í bsort ‚É‰ñ‚·

/*** gloval var *************************************************************/

int iData[ DATA_NUM ];
int	iCnt = DATA_NUM;

/*** bsort() ****************************************************************/

void bsort( int iStart, int iStop  ){
	
	int		i, j, iSwp;
	BOOL	bContinue;
	
	for( i = iStop - 1; i >= iStart; --i ){
		bContinue = FALSE;
		
		for( j = 0; j <= i; ++j ){
			if( iData[ j ] > iData[ j + 1 ] ){
				
				iSwp			= iData[ j ];
				iData[ j ] 		= iData[ j + 1 ];
				iData[ j + 1 ]	= iSwp;
				
				bContinue = TRUE;
			}
		}
		if( !bContinue ) break;
	}
}

/*** qsort() ****************************************************************/

void qsort( int iStart, int iStop ){
	
	int		i = iStart,
			j = iStop,
			iKey = iData[ ( i + j ) >> 1 ],
			iSwp;
	
	if( j - i <= ELEM_BSORT ) return;
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

/*** main procedure *********************************************************/

int main( void ){
	int	i;
	
	#ifdef FULLAUTO
		for( i = 0; i < iCnt; ++i ) iData[ i ] = Random();
	#else
		while( iData[ iCnt ] = InputData()) ++iCnt;
	#endif
	
	qsort( 0, iCnt - 1 );
	
	#if ELEM_BSORT > 0
		bsort( 0, iCnt - 1 );
	#endif
	
	// check
	for( i = 0; i < iCnt - 1; ++i ){
		if( iData[ i ] > iData[ i + 1 ] ) return( 0xFFFF );
		#ifndef NO_DISPLAY
			DisplayData( iData[ i ] );
		#endif
	}
	return( 0 );
}
