char	hoge[128];

char f( char *p ){
	p[ 333 ] = 'z';
	return( p[ 4 ] );
}

void main( void ){
	
	z( hoge + 3 );
	hoge[0] = f( hoge );
}