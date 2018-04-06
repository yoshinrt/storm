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

/*** NT �ォ�ǂ���? *********************************************************/

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

�f�o�C�X�h���C�o��o�^�E�J�n����
�߂�l
	TRUE	����I��
	FALSE	�h���C�o�[�o�^�C�J�n���s
			�f�o�C�X�h���C�o�𐧌�ł��錠�����Ȃ��Ǝ��s����

����
	szFileName		�h���C�o�[�̃t�@�C����
	szDriverName	�h���C�o�[�̖��O�D�h���C�o�[�����ł��閼�O
					UnloadDriver�̈����ɂ��g��

*****************************************************************************/

__declspec( dllexport ) int _stdcall LoadDriver( char *szFileName, char *szDriverName ){
	SC_HANDLE		hSCManager;
	SC_HANDLE		hService;
	SERVICE_STATUS	serviceStatus;
	BOOL			bRet = FALSE;
	
	if( !IsRunningOnNT()) return( TRUE );
	
	// �T�[�r�X�R���g���[���}�l�[�W�����J��
	hSCManager = OpenSCManager( NULL, NULL, SC_MANAGER_ALL_ACCESS );
	if( !hSCManager ) return( FALSE );
	
	// ���Ƀh���C�o�[�����݂��邩�m�F���邽�߂Ƀh���C�o�[���J��
	hService = OpenService(
		hSCManager,
		szDriverName,
		SERVICE_ALL_ACCESS
	);
	
	if( hService ){
		// ���ɓ��삵�Ă���ꍇ�͒�~�����č폜����
		// �ʏ�̓h���C�o�[�����݂���Ƃ���LoadDriver���Ăяo���Ȃ��̂ŕ��i�͂��肦�Ȃ�
		// �h���C�o�ُ̈킪�l������
		bRet = ControlService( hService, SERVICE_CONTROL_STOP, &serviceStatus );
		bRet = DeleteService( hService );
		CloseServiceHandle( hService );
	}
	
	// �h���C�o�[��o�^����
	hService = CreateService(
		hSCManager,
		szDriverName,
		szDriverName,
		SERVICE_ALL_ACCESS,
		SERVICE_KERNEL_DRIVER,		// �J�[�l���h���C�o
		SERVICE_DEMAND_START,		// ���StartService()�ɂ���ĊJ�n����
		SERVICE_ERROR_NORMAL,
		szFileName,					// �h���C�o�[�t�@�C���̃p�X
		NULL, NULL, NULL, NULL, NULL
	);
	
	if( hService ) {
		
		// �h���C�o�[���J�n����
		bRet = StartService( hService, 0, NULL );
		
		// �n���h�������
		CloseServiceHandle( hService );
	}
	// �T�[�r�X�R���g���[���}�l�[�W�������
	CloseServiceHandle( hSCManager );
	
	return( bRet );
}

/*****************************************************************************

�h���C�o�[���~����
�߂�l
	TRUE	����I��
	FALSE	���s

����
	szDriverName	�h���C�o�[�̖��O

*****************************************************************************/

__declspec( dllexport ) int _stdcall UnloadDriver( char *szDriverName ){
	SC_HANDLE		hSCManager;
	SC_HANDLE		hService;
	SERVICE_STATUS  serviceStatus;
	BOOL			bRet = FALSE;
	
	if( !IsRunningOnNT()) return( TRUE );
	
	// �T�[�r�X�R���g���[���}�l�[�W�����J��
	hSCManager = OpenSCManager( NULL, NULL, SC_MANAGER_ALL_ACCESS );
	if( !hSCManager ) return FALSE;
	
	// �h���C�o�[�̃T�[�r�X���J��
	hService = OpenService( hSCManager, szDriverName, SERVICE_ALL_ACCESS );
	
	if( hService ) {
		// �h���C�o�[���~������ 
		bRet = ControlService( hService, SERVICE_CONTROL_STOP, &serviceStatus );
		
		// �h���C�o�[�̓o�^������
		if( bRet == TRUE ) bRet = DeleteService( hService );
		
		// �n���h�������
		CloseServiceHandle( hService );
	}
	// �T�[�r�X�R���g���[���}�l�[�W�������
	CloseServiceHandle( hSCManager );
	
	return( bRet );
}

/*** �J�����g dir �� giveio.sys �����[�h���� ********************************/
/*
	���� : szDriverName �� LoadDriver �̂���Ɠ���
	�o�� : TRUE = ����
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
	
	// �p�������|�[�g�̏�����
	
	OUTP( PIOBase + 2, 0x4 );	// port#37A
	OUTP( PIOBase,	   0xDA );	// port#378
	OUTP( PIOBase + 2, 0x6 );	// port#37A
	OUTP( PIOBase + 2, 0x4 );	// port#37A
	
	// �����������҂�
	// �`�F�b�N�񐔂� 100 �𒴂�����ڑ��ُ���ۂ��̂ŋ����I��
	
	while( INP( PIOBase + 1 ) & 0x78 != 0x48 ){
		if( ++iTOCnt >= 100 ){
			return( -1 );
		}
	}
	
	// �R�}���h�R�[�h�𑗐M
	
	OUTP( PIOBase, 0xC2 | (( Cmd & 0xF ) << 2 ));	// cmd
	OUTP( PIOBase, 0xC0 | (( Cmd & 0xF ) << 2 ));
	
	if( Cmd & 0x8 ){
		
		// ���ʁC��ʂ̏��Ƀf�[�^��M
		
		OUTP( PIOBase, 0xC0 );
		iRecvData  = ( INP( PIOBase + 1 ) & 0x78 ) >> 3;
		OUTP( PIOBase, 0xC2 );
		iRecvData |= ( INP( PIOBase + 1 ) & 0x78 ) << 1;
		OUTP( PIOBase, 0xC0 );
		
	}else{
		
		// ���ʁC��ʂ̏��Ƀf�[�^���M
		
		OUTP( PIOBase, 0xC0 | (( Data &  0xF ) << 2 ));	// data L
		OUTP( PIOBase, 0xC2 | (( Data &  0xF ) << 2 ));	// data L
		OUTP( PIOBase, 0xC2 | (( Data & 0xF0 ) >> 2 ));	// data H
		OUTP( PIOBase, 0xC0 | (( Data & 0xF0 ) >> 2 ));	// data H
	}
	
	return( iRecvData );
}
