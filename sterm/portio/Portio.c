/*** port I/O procedure for STERM *******************************************/

#include <windows.h>
#include <conio.h>
//#define _DEBUG
#include "dds.h"
#include "dds_lib.h"

/*** macros *****************************************************************/

#define INP( port )			_inp(( USHORT )( port ))
#define OUTP( port, data )	_outp(( USHORT )( port ), ( int )( data ))

/*** DLL entry? *************************************************************/

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
	return( INP( port ));
}

__declspec( dllexport ) int _stdcall Outp( USHORT port, int data ){
	return( OUTP( port, data ));
}

__declspec( dllexport ) void _stdcall CPUIntCtrl( BOOL bEnable ){
	if( bEnable )	__asm{ sti }
	else			__asm{ cli }
}

/*** NT 上かどうか? *********************************************************/

BOOL IsRunningOnNT( void ){
	OSVERSIONINFO	osvi;
	
	osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
	GetVersionEx( &osvi );
	
	DebugMsgW(
		osvi.dwPlatformId == VER_PLATFORM_WIN32_NT ?
		"Running on NT" : "Running on Win9x"
	);
	
	return( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT );
}

/*****************************************************************************

デバイスドライバを登録・開始する
戻り値
	TRUE	正常終了
	FALSE	ドライバー登録，開始失敗
			デバイスドライバを制御できる権限がないと失敗する

引数
	szFileName		ドライバーのファイル名
	szDriverName	ドライバーの名前．ドライバーを特定できる名前
					UnloadDriverの引数にも使う

*****************************************************************************/

__declspec( dllexport ) int _stdcall LoadDriver( char *szFileName, char *szDriverName ){
	SC_HANDLE		hSCManager;
	SC_HANDLE		hService;
	SERVICE_STATUS	serviceStatus;
	BOOL			bRet = FALSE;
	
	if( !IsRunningOnNT()) return( TRUE );
	
	// サービスコントロールマネージャを開く
	hSCManager = OpenSCManager( NULL, NULL, SC_MANAGER_ALL_ACCESS );
	if( !hSCManager ) return( FALSE );
	
	// 既にドライバーが存在するか確認するためにドライバーを開く
	hService = OpenService(
		hSCManager,
		szDriverName,
		SERVICE_ALL_ACCESS
	);
	
	if( hService ){
		// 既に動作している場合は停止させて削除する
		// 通常はドライバーが存在するときはLoadDriverを呼び出さないので普段はありえない
		// ドライバの異常が考えられる
		bRet = ControlService( hService, SERVICE_CONTROL_STOP, &serviceStatus );
		bRet = DeleteService( hService );
		CloseServiceHandle( hService );
	}
	
	// ドライバーを登録する
	hService = CreateService(
		hSCManager,
		szDriverName,
		szDriverName,
		SERVICE_ALL_ACCESS,
		SERVICE_KERNEL_DRIVER,		// カーネルドライバ
		SERVICE_DEMAND_START,		// 後でStartService()によって開始する
		SERVICE_ERROR_NORMAL,
		szFileName,					// ドライバーファイルのパス
		NULL, NULL, NULL, NULL, NULL
	);
	
	if( hService ) {
		
		// ドライバーを開始する
		bRet = StartService( hService, 0, NULL );
		
		// ハンドルを閉じる
		CloseServiceHandle( hService );
	}
	// サービスコントロールマネージャを閉じる
	CloseServiceHandle( hSCManager );
	
	return( bRet );
}

/*****************************************************************************

ドライバーを停止する
戻り値
	TRUE	正常終了
	FALSE	失敗

引数
	szDriverName	ドライバーの名前

*****************************************************************************/

__declspec( dllexport ) int _stdcall UnloadDriver( char *szDriverName ){
	SC_HANDLE		hSCManager;
	SC_HANDLE		hService;
	SERVICE_STATUS  serviceStatus;
	BOOL			bRet = FALSE;
	
	if( !IsRunningOnNT()) return( TRUE );
	
	// サービスコントロールマネージャを開く
	hSCManager = OpenSCManager( NULL, NULL, SC_MANAGER_ALL_ACCESS );
	if( !hSCManager ) return FALSE;
	
	// ドライバーのサービスを開く
	hService = OpenService( hSCManager, szDriverName, SERVICE_ALL_ACCESS );
	
	if( hService ) {
		// ドライバーを停止させる 
		bRet = ControlService( hService, SERVICE_CONTROL_STOP, &serviceStatus );
		
		// ドライバーの登録を消す
		if( bRet == TRUE ) bRet = DeleteService( hService );
		
		// ハンドルを閉じる
		CloseServiceHandle( hService );
	}
	// サービスコントロールマネージャを閉じる
	CloseServiceHandle( hSCManager );
	
	return( bRet );
}

/*** カレント dir の giveio.sys をロードする ********************************/
/*
	入力 : szDriverName は LoadDriver のそれと同じ
	出力 : TRUE = 成功
*/
__declspec( dllexport ) int _stdcall LoadGiveIO( char *szDriverName ){
	
	HANDLE	hDriver;
	char	szModuleName[ MAX_PATH ];
	char	*p;
	
	if( !IsRunningOnNT()) return( TRUE );
	
	GetModuleFileName( NULL, szModuleName, MAX_PATH );
	if( p = StrTokFile( NULL, szModuleName, STF_NODE )) strcpy( p, "GIVEIO.SYS" );
	
	if( !LoadDriver( szModuleName, szDriverName )) return( FALSE );
	
    hDriver = CreateFile(
    	"\\\\.\\giveio", GENERIC_READ, 0, NULL,
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
	);
    
    if( hDriver == INVALID_HANDLE_VALUE ) return( FALSE );
	
	CloseHandle( hDriver );
	DebugMsgW( "Load GiveIO.sys successful." );
	return( TRUE );
}

/*** AccessPIO C version ****************************************************/

__declspec( dllexport ) USHORT _stdcall AccessPIO(
	USHORT	Cmd,
	USHORT	Data,
	USHORT	PIOBase
){
	
	int iTOCnt		= 0;
	int iRecvData	= 0;
	
	// パラレルポートの初期化
	
	OUTP( PIOBase + 2, 0x4 );	// port#37A
	OUTP( PIOBase,	   0xDA );	// port#378
	OUTP( PIOBase + 2, 0x6 );	// port#37A
	OUTP( PIOBase + 2, 0x4 );	// port#37A
	
	// 初期化完了待ち
	// チェック回数が 100 を超えたら接続異常っぽいので強制終了
	
	while( INP( PIOBase + 1 ) & 0x78 != 0x48 ){
		if( ++iTOCnt >= 100 ){
			return( -1 );
		}
	}
	
	// コマンドコードを送信
	
	OUTP( PIOBase, 0xC2 | (( Cmd & 0xF ) << 2 ));	// cmd
	OUTP( PIOBase, 0xC0 | (( Cmd & 0xF ) << 2 ));
	
	if( Cmd & 0x8 ){
		
		// 下位，上位の順にデータ受信
		
		OUTP( PIOBase, 0xC0 );
		iRecvData  = ( INP( PIOBase + 1 ) & 0x78 ) >> 3;
		OUTP( PIOBase, 0xC2 );
		iRecvData |= ( INP( PIOBase + 1 ) & 0x78 ) << 1;
		OUTP( PIOBase, 0xC0 );
		
	}else{
		
		// 下位，上位の順にデータ送信
		
		OUTP( PIOBase, 0xC0 | (( Data &  0xF ) << 2 ));	// data L
		OUTP( PIOBase, 0xC2 | (( Data &  0xF ) << 2 ));	// data L
		OUTP( PIOBase, 0xC2 | (( Data & 0xF0 ) >> 2 ));	// data H
		OUTP( PIOBase, 0xC0 | (( Data & 0xF0 ) >> 2 ));	// data H
	}
	
	return( iRecvData );
}
