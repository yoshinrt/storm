#include <storm.h>

typedef void ( FUNC )( void );

int z( int a, int b, int c ){
	int sum = a;
	while( --a ) sum += a;
	return( sum + 3 );
}

int sh( int a, int b ){ return( b << 2 ); }
int sel( int a, int b, int c ){ return a ? a * b : c; }
//int mmm( int a, int b ){ return( a * b ); }

void func( FUNC *f ){ f(); }

UINT cmp1( UINT a, UINT b ){ return( a < b ); }
UINT cmp2( UINT a, UINT b ){ return( a >= b ); }
UINT cmp3( UINT a, UINT b ){ return( a > b ); }

void f( char *s, char c, UINT d ){
	PutStr( s );
	PutChar( c );
	DisplayData( d );
}
