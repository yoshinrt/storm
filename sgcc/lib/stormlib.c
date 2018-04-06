/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		stormlib.c --- storm standard library

2001.08.16	v1.0 create

*****************************************************************************/

#include <storm.h>
#include "storm_uselib.h"

/*** const ******************************************************************/

#define PORT_BASE_ADDR		0x4000
#define PORT_BASE_ADDR_S	"0x4000"

/*** data input/output function *********************************************/

#ifdef USELIB_GetButton
#define USELIB_PortOutput
#define USELIB_PortInput
UINT GetButton( void ){
	
	PortOutput( PORT_GetButt, 0 );
	return( PortInput());
}
#endif

#ifdef USELIB_PutStr
#define USELIB_PortOutput
void PutStr( char *s ){
	while( *s ) PortOutput( PORT_Putc, *s );
}
#endif

#ifdef USELIB_PutChar
#define USELIB_PortOutput
void PutChar( char c ){
	PortOutput( PORT_Putc, c );
}
#endif

#ifdef USELIB_DisplayData
#define USELIB_PortOutput
void DisplayData( UINT uData ){
	
	PortOutput( PORT_DataL, uData );
	asm( "swp\t%0, %1" : "=r" ( uData ) : "r" ( uData ));
	PortOutput( PORT_DataH, uData );
}
#endif

#ifdef USELIB_PortInput
UINT PortInput( void ){
	UINT	uRet;
	
	asm volatile(
		"movi	r1, " PORT_BASE_ADDR_S ";"
		"mov	%0, [r1];"
		"tst	%0;"
		"js		$ - 2;"
		"mov	r2, 0xFF;"
		"and	%0, r2;"
		"nop;"
		: "=l" ( uRet ) :: "r1", "r2"
	);
	return( uRet );
}
#endif

#ifdef USELIB_PortOutput
void PortOutput( UINT uPort, UINT uData ){
	
	uPort += PORT_BASE_ADDR;
	
	asm volatile(
		"or		r2, -1;"		// set FlagS
		"js		$;"
		"mov	r2, [%0];"
		"nop;"
		"shl	r2;"
		"mov	[%0], %2;"
		: "=l" ( uPort ) : "0" ( uPort ), "r" ( uData ) : "r2"
	);
}
#endif

/*** arithmetic routine *****************************************************/

#ifdef USELIB__mul
UINT _mul( UINT a, UINT b ){
	
	UINT	result = 0;
	
	for(;;){
		if( a & 1 ) result += b;
		if( !( a >>= 1 )) break;
		if( !( b <<= 1 )) break;
	}
	return( result );
}
#endif

#ifdef USELIB__div

#if defined( STORM ) && defined( __OPTIMIZE__ )
#define LShiftSetCY( dest, carry ) \
	asm( "shl %0, %0; adc %1, 0;" \
		: "=r" ( dest ), "=r" ( carry ) \
		: "0"  ( dest ), "1"  ( carry ));
#else
#define LShiftSetCY( dest, carry ) { \
	if( dest & SIGN_BIT ) ++carry; dest <<= 1; }
#endif

UINT _div( UINT a, UINT b ){
	
	UINT	uResult = a,
			uHigh,
			uCnt;
	
	if( b == 0 ) return( 0 );
	
	uHigh = 0;
	uCnt  = 16;
	
	do{
		uHigh <<= 1;
		LShiftSetCY( uResult, uHigh );
		
		if( uHigh >= b ){
			uHigh -= b;
			uResult |= 1;
		}
	}while( --uCnt );
	
	return( uResult );
}
#endif

/*** shift ******************************************************************/

#ifdef USELIB__shr
UINT _shr( UINT u, UINT cnt ){
	do u >>= 1; while( --cnt );
	return( u );
}
#endif

#ifdef USELIB__shl
UINT _shl( UINT u, UINT cnt ){
	do u <<= 1; while( --cnt );
	return( u );
}
#endif

#ifdef USELIB__sar
int _sar( int i, UINT cnt ){
	do i >>= 1; while( --cnt );
	return( i );
}
#endif

/*** memory function ********************************************************/

#ifdef USELIB__bzero
void bzero( char *p, UINT cnt ){
	do{
		*( p++ )= 0;
	}while( --cnt );
}
#endif

#ifdef USELIB__bcopy
void bcopy( char *pDst, char *pSce, UINT cnt ){
	do{
		*( pDst++ )= *( pSce++ );
	}while( --cnt );
}
#endif
