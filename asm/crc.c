#include <storm.h>

#define CRC_KEY		0x1021
#define	UINT_LEN	16

UINT	DataBuf[ 100 ];

INLINE UINT ComputeCRC( UINT uCnt ){
	
	UINT	uCRC = 0x1234,				/* CRC initial value				*/
			uData,						/* data buffer						*/
			uBit,						/* bit counter						*/
			u;
	
	for( u = 0; u < uCnt; ++u ){
		
		// fetch UINT data
		uData = DataBuf[ u ];
		
		for( uBit = 0; uBit < UINT_LEN; ++uBit ){
			
			// shift uCRC
			if( uCRC & SIGN_BIT ){
				uCRC = ( uCRC << 1 ) ^ CRC_KEY;
			}else{
				uCRC <<= 1;
			}
			
			// shift uData
			if( uData & SIGN_BIT ) uCRC ^= 1;
			uData <<= 1;
		}
	}
	return( uCRC );
}

void main( void ){
	//DisplayData( ComputeCRC( InputData()));
	DisplayData( ComputeCRC( 10000 ));
}
