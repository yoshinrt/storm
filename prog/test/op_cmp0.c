int	a = -1;
int b = 6;
int c = 0;


int z( int a, int b ){
	
	if( a & 4 ) ++b;
	
	return( b );
}

void main( void ){
	c = z( a, b );
}