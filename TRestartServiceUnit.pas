unit TRestartServiceUnit;

interface

uses classes, windows, sysutils, Variants, ADODB, WinSvc;

type
  ThRestartService = class(TThread)
  public
    constructor Create(CreateSuspennded: Boolean;OpType:integer;LogFile,ServiceName:string;Descriptor:THandle);
    destructor Destroy; override;
    procedure Execute; override;
  var
   Fstop:boolean;
   _FileNameLog:string;
   _ServiceName:string;
   _OpType:integer; // 1- Старт , 0 - Стоп
   FDescriptor:THandle;
  end;

     PServiceStatusProcess = ^TServiceStatusProcess;
  {$EXTERNALSYM _SERVICE_STATUS_PROCESS}
  _SERVICE_STATUS_PROCESS = record
    dwServiceType: DWORD;
    dwCurrentState: DWORD;
    dwControlsAccepted: DWORD;
    dwWin32ExitCode: DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint: DWORD;
    dwWaitHint: DWORD;
    dwProcessId: DWORD;
    dwServiceFlags: DWORD;
  end;
  {$EXTERNALSYM SERVICE_STATUS_PROCESS}
  SERVICE_STATUS_PROCESS = _SERVICE_STATUS_PROCESS;
  TServiceStatusProcess = _SERVICE_STATUS_PROCESS;

const
  SC_STATUS_PROCESS_INFO = 0;
  HEAP_ZERO_MEMORY     = $00000008;


  var
  AOwner: TComponent;

implementation

uses MainFormUnit, FunctionsUnit, ActiveX, DataModuleUnit, ConstUnit;


function QueryServiceStatusEx(hService: DWORD; InfoLevel: DWORD; var
  lpServiceStatus: SERVICE_STATUS_PROCESS; cbBufSize: DWORD;
  pcbBytesNeeded: LPDWORD): BOOL; stdcall; external advapi32;


function StopCustomService(hSCM: DWord; hService: DWORD; StopDependencies: BOOL;
  dwTimeout: DWORD): DWORD;
var
  i: Integer;

  ssp: SERVICE_STATUS_PROCESS;
  ss: SERVICE_STATUS;
  ess: _ENUM_SERVICE_STATUS;

  dwStartTime, dwBytesNeeded: DWORD;
  dwCount: DWORD;
  lpDependencies: PEnumServiceStatus;
  hDepService: DWORD;
begin
  dwStartTime := GetTickCount;

   // Make sure the service is not already stopped
  if not QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO,
    ssp, SizeOf(SERVICE_STATUS_PROCESS), @dwTimeout) then
  begin
    Result := GetLastError;
    Exit;
  end;

  if ssp.dwCurrentState = SERVICE_STOPPED then
    Result := ERROR_SUCCESS;

   // If a stop is pending, just wait for it
  while ssp.dwCurrentState = SERVICE_STOP_PENDING do
  begin
    Sleep(ssp.dwWaitHint);
    if not QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO,
      ssp, SizeOf(SERVICE_STATUS_PROCESS), @dwTimeout) then
      Result := GetLastError;

    if ssp.dwCurrentState = SERVICE_STOPPED then
      Result := ERROR_SUCCESS;

    if GetTickCount - dwStartTime > dwTimeout then
      Result := ERROR_TIMEOUT;
  end;

   // If the service is running, dependencies must be stopped first
  if StopDependencies then
  begin
    // Pass a zero-length buffer to get the required buffer size
    if not EnumDependentServices(hService, SERVICE_ACTIVE,
      lpDependencies^, 0, dwBytesNeeded, dwCount) then
         // If the Enum call succeeds, then there are no dependent
         // services so do nothing
      begin
        if GetLastError <> ERROR_MORE_DATA then
          Result := GetLastError; // Unexpected error

         // Allocate a buffer for the dependencies
        lpDependencies := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, dwBytesNeeded);
        if Assigned(lpDependencies) then
        begin
          try
            // Enumerate the dependencies
            if not EnumDependentServices(hService, SERVICE_ACTIVE,
              lpDependencies^, dwBytesNeeded, dwBytesNeeded, dwCount) then
              Result := GetLastError();

            for i := 0 to dwCount - 1 do
            begin
              lpDependencies := Pointer(Integer(lpDependencies) + i);
              MoveMemory(@ess, lpDependencies, SizeOf(_ENUM_SERVICE_STATUS));

              // Open the service
              hDepService := OpenService(hSCM, ess.lpServiceName,
                 SERVICE_STOP or SERVICE_QUERY_STATUS);

              if hDepService = 0 then
                Result := GetLastError;

              try
                   // Send a stop code
                if not ControlService(hDepService, SERVICE_CONTROL_STOP, ss) then
                  Result := GetLastError;

                  // Wait for the service to stop
                while ss.dwCurrentState <> SERVICE_STOPPED do
                begin
                  Sleep(ssp.dwWaitHint);
                  if not QueryServiceStatusEx(hDepService, SC_STATUS_PROCESS_INFO,
                     ssp, SizeOf(SERVICE_STATUS_PROCESS), @dwBytesNeeded) then
                     Result := GetLastError;

                  if (ssp.dwCurrentState = SERVICE_STOPPED ) then
                     Break;

                  if (GetTickCount() - dwStartTime > dwTimeout ) then
                     Result := ERROR_TIMEOUT;
                end;
              finally
                // Always release the service handle
                CloseServiceHandle( hDepService );
              end;

            end;

          finally
          // Always free the enumeration buffer
            HeapFree( GetProcessHeap, 0, lpDependencies);
          end;

        end else
          Result := GetLastError;
       end;

    end;

   // Send a stop code to the main service
   if not ControlService(hService, SERVICE_CONTROL_STOP, ss) then
      Result := GetLastError;

   // Wait for the service to stop
   while ss.dwCurrentState <> SERVICE_STOPPED do
   begin
     Sleep(ss.dwWaitHint );
     if not QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO,
        ssp, sizeof(SERVICE_STATUS_PROCESS), @dwBytesNeeded) then
        Result := GetLastError;

      if (ssp.dwCurrentState = SERVICE_STOPPED ) then
        Break;

      if GetTickCount() - dwStartTime > dwTimeout then
         Result := ERROR_TIMEOUT;

   end;
   // Return success
   Result := ERROR_SUCCESS;
end;

function StartCustomService(hService: DWORD; dwTimeout: DWORD): DWORD;
var
  ssStatus: SERVICE_STATUS_PROCESS;
  dwOldCheckPoint: DWORD;
  dwStartTickCount: DWORD;
  dwWaitTime: DWORD;
  dwBytesNeeded: DWORD;
  pTmp: PChar;
begin
  pTmp := nil;

  if not StartService(hService, 0, pTmp) then
  begin
    Result := GetLastError;
    Exit;
  end;

    // Check the status until the service is no longer start pending.

  if not QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, ssStatus,
    SizeOf(SERVICE_STATUS_PROCESS), @dwBytesNeeded) then
  begin
    Result := GetLastError;
    Exit;
  end;

    // Save the tick count and initial checkpoint.

  dwStartTickCount := GetTickCount;
  dwOldCheckPoint := ssStatus.dwCheckPoint;

  while ssStatus.dwCurrentState = SERVICE_START_PENDING do
  begin
    dwWaitTime := Round(ssStatus.dwWaitHint / 10);
    if dwWaitTime < 1000 then dwWaitTime := 1000
      else if dwWaitTime > 10000 then dwWaitTime := 10000;

    Sleep(dwWaitTime);

      // Check the status again.

    if not QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO,
      ssStatus, SizeOf(SERVICE_STATUS_PROCESS), @dwBytesNeeded) then
      Break;

    if ssStatus.dwCheckPoint > dwOldCheckPoint then
    begin
          // The service is making progress.
      dwStartTickCount := GetTickCount;
      dwOldCheckPoint := ssStatus.dwCheckPoint;
    end else
      if GetTickCount - dwStartTickCount > dwTimeout then
      begin
            // No progress made within the wait hint
        Result := ERROR_TIMEOUT;
        Break;
      end;
  end;

  Result := ERROR_SUCCESS;
end;


constructor ThRestartService.Create(CreateSuspennded: Boolean;OpType:integer;LogFile,ServiceName:string;Descriptor:THandle);
begin
_FileNameLog:=LogFile;
_ServiceName:=ServiceName;
_OpType:=OpType;
FDescriptor:=Descriptor;
inherited Create(CreateSuspennded);
end;

destructor ThRestartService.Destroy;
begin
  inherited;
end;

procedure ThRestartService.Execute;
var
  hService, hSCManager: DWORD;
  lMachineName: string;
i,i1:integer;
E:Error;
f:textfile;
begin
try
try
AssignFile(f,_FileNameLog);
Rewrite(f);
Writeln(f,timetostr(time)+' =====> СТАРТ формирования остатков ...');
FreeOnTerminate:=true;
OnTerminate:=fMain.ThreadsRestartServiceDone;
EnterCriticalSection(CS);
Writeln(f,timetostr(time)+' занимаем критическую секцию основного приложения');
CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
Writeln(f,timetostr(time)+' инициализация апартамент COM-сервера');
if _OpType=0 then
ViewLog(3,'Выключение СОД','Завершение работы СОД');
if _OpType=1 then
ViewLog(3,'Включение СОД','Старт работы СОД');
if Fstop then
Terminate;
try
Writeln(f,timetostr(time)+' ------------------ >>');
if _OpType=0 then
Writeln(f,timetostr(time)+' Приступаю к завершению службы СОД');
if _OpType=1 then
Writeln(f,timetostr(time)+' Приступаю к запуску службы СОД');


  lMachineName := GetEnvironmentVariable('S-SQL-GA');
  hSCManager := OpenSCManager(PChar(lMachineName), SERVICES_ACTIVE_DATABASE, SC_MANAGER_CONNECT);
  if hSCManager > 0 then
  begin
    hService := OpenService(hSCManager, pchar(_ServiceName), SC_MANAGER_ALL_ACCESS);
    if hService > 0 then
    begin
     if _OpType=0 then
       StopCustomService(hSCManager, hService, False, 10000);
     if _OpType=1 then
       StartCustomService(hService, 10000);
      CloseServiceHandle(hService);
    end else
      RaiseLastOSError;
    CloseServiceHandle(hSCManager);
  end else
    RaiseLastOSError;


except
 on E:exception do
  begin
   Writeln(f,timetostr(time)+' ===> ОШИБКА');
   Writeln(f,timetostr(time)+e.Message);
   if _OpType=0 then
    ViewLog(3,'Выключение СОД','В ходе работы возникла ошибка');
   if _OpType=1 then
    ViewLog(3,'Включение СОД','В ходе работы возникла ошибка');
  end;
end;
except
 on E:Exception do
  begin
   Writeln(f,timetostr(time)+' ===> ОШИБКА перед процедурой ...');
   if _OpType=0 then
    ViewLog(3,'Выключение СОД','Ошибка подготовки ...');
   if _OpType=1 then
    ViewLog(3,'Включение СОД','Ошибка подготовки ...');
  end;
end;
 finally
  CoUninitialize;
  Writeln(f,timetostr(time)+' деинициалицая аппартамент СОМ-сервера.');
  ReleaseMutex(FDescriptor);
  LeaveCriticalSection(CS);
  Writeln(f,timetostr(time)+' критическая секция освобождена.');
  Writeln(f,timetostr(time)+' ===> Работа завершена.');
   if _OpType=0 then
    ViewLog(3,'Выключение СОД','Работа завершена');
   if _OpType=1 then
    ViewLog(3,'Включение СОД','Работа завершена');
  CloseFile(f);
 end;
end;


end.
