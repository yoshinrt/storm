#include <storm.h>

void main( void ){
	
	UINT	u = 0xF000,
			uSum = u;
	
	while( --u ) uSum += u;
	DisplayData( uSum );
}
