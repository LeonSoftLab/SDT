unit ThReturns;

interface

uses classes, windows, sysutils, Variants, ADODB;

type
  TReturns = class(TThread)
  public
    constructor Create(CreateSuspennded: Boolean;LogFile,sConn,DataBase:string;Descriptor:THandle;AWorkPath:string);
    destructor Destroy; override;
    procedure Execute; override;
  var
   Fstop:boolean;
   FileNameLog:string;
   ConnectString:string;
   DataBaseName:string;
   FDescriptor:THandle;
   FWorkPath:string;
   ADOConnect:TADOConnection;
   ADOQuery_UpdateDataReturnsToBD:TADOQuery;
   ADOQuery_SaveReturnsToXML:TADOQuery;
  end;

  var
  AOwner: TComponent;

implementation

uses MainFormUnit, FunctionsUnit, ActiveX, DataModuleUnit, ConstUnit;

constructor TReturns.Create(CreateSuspennded:Boolean;LogFile,sConn,DataBase:string;Descriptor:THandle;AWorkPath:string);
begin
FileNameLog:=LogFile;
ConnectString:=sConn;
DataBaseName:=DataBase;
FDescriptor:=Descriptor;
FWorkPath:=AWorkPath;
inherited Create(CreateSuspennded);
end;

destructor TReturns.Destroy;
begin
  inherited;
end;

procedure TReturns.Execute;
var
i,i1:integer;
E:Error;
f:textfile;
begin
try
try
AssignFile(f,FileNameLog);
Rewrite(f);
Writeln(f,timetostr(time)+' =====> ����� ������������ �������� ...');
FreeOnTerminate:=true;
OnTerminate:=fMain.ThreadsReturnsDone;
EnterCriticalSection(CS);
CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
ViewLog(3,'�������','����� ������������ ��������.');

ADOConnect:=TADOConnection.Create(AOwner);
ADOConnect.ConnectionString:=ConnectString;
ADOConnect.DefaultDatabase:=DataBaseName;
ADOConnect.CursorLocation:=clUseServer;
ADOConnect.CommandTimeout:=0;

ADOQuery_UpdateDataReturnsToBD:=TADOQuery.Create(AOwner);
ADOQuery_UpdateDataReturnsToBD.SQL.Text:=' EXEC [workot].[dbo].rplRests';
ADOQuery_UpdateDataReturnsToBD.Connection:=ADOConnect;
ADOQuery_UpdateDataReturnsToBD.CursorLocation:=clUseServer;
ADOQuery_UpdateDataReturnsToBD.CommandTimeout:=0;

ADOQuery_SaveReturnsToXML:=TADOQuery.Create(AOwner);
ADOQuery_SaveReturnsToXML.SQL.Text:=
' USE [workot] '+
' DECLARE @result int; '+
' DECLARE @OutputFileName varchar(150); '+
' DECLARE @cmd varchar(150); '+
' SET @OutputFileName = '''+FWorkPath+'\registers.xml'''+
' SET @cmd = ''BCP "EXEC [workot].[dbo].rplRestsXML" queryout "'' + @OutputFileName + ''" -N -C OEM -w -r -t -T'''+
' EXEC @result = master..xp_cmdshell @cmd';
ADOQuery_SaveReturnsToXML.Connection:=ADOConnect;
ADOQuery_SaveReturnsToXML.CursorLocation:=clUseServer;
ADOQuery_SaveReturnsToXML.CommandTimeout:=0;
Writeln(f,timetostr(time)+' ���������� ��� ������ � �� ������� � ���������');
if Fstop then
Terminate;
ADOConnect.LoginPrompt:=false;
ADOConnect.Connected:=true;
ViewLog(0,'�������','����������� �������');
Writeln(f,timetostr(time)+' ����������� �������������');
try
Writeln(f,timetostr(time)+' ------------------ >>');
Writeln(f,timetostr(time)+' ��������� � ���������� ������ �������� [workot].[dbo].rplRests; ...');
ViewLog(2,'�������','�������� ������ �� �������� ...');
ADOQuery_UpdateDataReturnsToBD.Close;
ADOQuery_UpdateDataReturnsToBD.ExecSQL;
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
Writeln(f,timetostr(time)+' ���������� ������ � �� workot �� �������� �� ������� ���������.');
Writeln(f,timetostr(time)+' <<------------------');
if Fstop then
Terminate;
Writeln(f,timetostr(time)+' ------------------ >>');
Writeln(f,timetostr(time)+' ��������� � �������� ������ � ���� Registers.xml ...');
ViewLog(2,'�������','������� �������� �������� � ���� Registers.xml');
ADOQuery_SaveReturnsToXML.Close;
ADOQuery_SaveReturnsToXML.ExecSQL;
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
Writeln(f,timetostr(time)+' ������ ��������� � ����.');
Writeln(f,timetostr(time)+' <<------------------');
except
 on E:exception do
  begin
   Writeln(f,timetostr(time)+' ===> ������ ��� ������������');
   Writeln(f,timetostr(time)+e.Message);
   ViewLog(3,'�������','������ ������������ ...');
  end;
end;
except
 on E:Exception do
  begin
   Writeln(f,timetostr(time)+' ===> ������ ���������� ...');
   ViewLog(3,'�������','������ ���������� ...');
  end;
end;
 finally
  ADOConnect.Connected:=false;
  ViewLog(1,'�������','������������');
  Writeln(f,timetostr(time)+' ����������� ���������������');
  FreeAndNil(ADOQuery_SaveReturnsToXML);
  FreeAndNil(ADOQuery_UpdateDataReturnsToBD);
  FreeAndNil(ADOConnect);
  Writeln(f,timetostr(time)+' ���������� ���������� ������.');
  CoUninitialize;
  Writeln(f,timetostr(time)+' ������������� ����������� ���-�������.');
  ReleaseMutex(FDescriptor);
  LeaveCriticalSection(CS);
  Writeln(f,timetostr(time)+' ����������� ������ �����������.');
  Writeln(f,timetostr(time)+' ===> ������������ ���������.');
  ViewLog(3,'�������','������������ ���������.');
  CloseFile(f);
 end;
end;


end.
