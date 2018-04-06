/*****************************************************************************

		STORM -- STandard Optimized Risc Machine
		Copyright(C) 2002 by Deyu Deyu HW/SW designs ( Yoshihisa Tanaka )
		
		storm.h --- storm standard header

2001.08.16	v1.0 create

*****************************************************************************/

#ifndef _STORM_H
#define _STORM_H

/*** macros *****************************************************************/

#define INLINE		static inline
#define SIGN_BIT	0x8000
#define WORD_MASK	0xFFFF

#define FALSE		0
#define TRUE		( !FALSE )

enum{
	PORT_GetButt,
	PORT_SetButt,
	PORT_SetButtNo,
	PORT_SetButtState,
	PORT_SetButtColor,
	PORT_SetButtChar,
	PORT_GetData,
	PORT_GetDataAry,
	PORT_Putc,
	PORT_DataL,
	PORT_DataH,
	PORT_ResetTerm,
	PORT_VOID,
};

/*** new type ***************************************************************/

#ifdef STORM
typedef unsigned		UINT;
#else

#include <stdio.h>

typedef unsigned short	UINT;
#define	int				short
#endif

typedef unsigned char	BOOL;

/*** input / output procedure ***********************************************/
#ifdef STORM

#define SetButtNo( n )		PortOutput( PORT_SetButtNo, n )
#define SetButtState( n )	PortOutput( PORT_SetButtState, n )

#define Return( x )		return( x )

/*** for not storm compiler *************************************************/

#else

#define DisplayDataWait( x )	DisplayData( x )

int InputData( void ){
	char szBuf[ 20 ];
	
	printf( "DataIn  ? " );
	fgets( szBuf, 20, stdin );
	return( strtol( szBuf, NULL, 0 ) & WORD_MASK );
}

void DisplayData( UINT u ){
	
	u &= WORD_MASK;
	
	printf( "DataOut : 0x%04X %5u %6d\n",
		u , u , ( u & SIGN_BIT ) ? ( u | ~WORD_MASK ) : u );
}

#define Return( x )	\
	do{ printf( "return = %04X %u %d\n", ( x ), ( x ), ( x )); return( x ); }while( 0 )

#endif /* STORM */
#endif /* _STORM_H */
