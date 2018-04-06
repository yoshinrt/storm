#include <storm.h>

void Exclusive( int x, int y ){
	
	int i, j;
	
	for( j = y - 1; j <= y + 1; ++j ) for( i = x - 1; i <= x + 1; ++i ){
		if( 0 <= i && i <= 3 && 0 <= j && j <= 3 && ( i == x || j == y )){
			SetButtNo(( j << 4 ) + i );
			SetButtState( 2 );
		}
	}
}

void main( void ){
	
	UINT	uButtNo;
	
	int		i, j, x, y;
	
	for(;;){
		while(( uButtNo = GetButton()) == 0xFF );
		
		x = uButtNo & 0x7;
		y = uButtNo >> 4;
		
		DisplayData( uButtNo );
		//SetButtNo( uButtNo );
		//SetButtState( 2 );
		
		Exclusive( x, y );
	}
}
