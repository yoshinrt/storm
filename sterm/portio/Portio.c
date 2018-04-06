#include <windows.h>
#include <conio.h>

BOOL APIENTRY DllMain(
	HANDLE	hModule,
	DWORD	ul_reason_for_call, 
	LPVOID	lpReserved
){
	/*
	switch( ul_reason_for_call ){
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
		break;
	}
	*/
	return TRUE;
}


__declspec( dllexport ) int _stdcall Inp( USHORT port ){
	return( _inp( port ));
}

__declspec( dllexport ) int _stdcall Outp( USHORT port, int data ){
	return( _outp( port, data ));
}

__declspec( dllexport ) void _stdcall CPUIntCtrl( BOOL bEnable ){
	if( bEnable )	__asm{ sti }
	else			__asm{ cli }
}

/*
__declspec( dllexport ) USHORT _stdcall AccessPIO(
	USHORT	Cmd,
	USHORT	Data,
	USHORT	PIOBase
){
	
	int iTOCnt		= 0;
	int iRecvData	= 0;
	
	// パラレルポートの初期化
	
	_outp( PIOBase + 2, 0x4 );	// port#37A
	_outp( PIOBase,	   0xDA );	// port#378
	_outp( PIOBase + 2, 0x6 );	// port#37A
	_outp( PIOBase + 2, 0x4 );	// port#37A
	
	// 初期化完了待ち
	// チェック回数が 100 を超えたら接続異常っぽいので強制終了
	
	while( _inp( PIOBase + 1 ) & 0x78 != 0x48 ){
		if( ++iTOCnt >= 100 ){
			return( -1 );
		}
	}
	
	// コマンドコードを送信
	
	_outp( PIOBase, 0xC2 | (( Cmd & 0xF ) << 2 ));	// cmd
	_outp( PIOBase, 0xC0 | (( Cmd & 0xF ) << 2 ));
	
	if( Cmd & 0x8 ){
		
		// 下位，上位の順にデータ受信
		
		_outp( PIOBase, 0xC0 );
		iRecvData  = ( _inp( PIOBase + 1 ) & 0x78 ) >> 3;
		_outp( PIOBase, 0xC2 );
		iRecvData |= ( _inp( PIOBase + 1 ) & 0x78 ) << 1;
		_outp( PIOBase, 0xC0 );
		
	}else{
		
		// 下位，上位の順にデータ送信
		
		_outp( PIOBase, 0xC0 | (( Data &  0xF ) << 2 ));	// data L
		_outp( PIOBase, 0xC2 | (( Data &  0xF ) << 2 ));	// data L
		_outp( PIOBase, 0xC2 | (( Data & 0xF0 ) >> 2 ));	// data H
		_outp( PIOBase, 0xC0 | (( Data & 0xF0 ) >> 2 ));	// data H
	}
	
	return( iRecvData );
}
*/
