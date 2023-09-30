unit TExpDataByRoute;

interface

uses classes, windows, sysutils, Variants, ADODB;

type
  ThExpDataByRoute = class(TThread)
  public
    constructor Create(CreateSuspennded: Boolean;FileRoute,LogFile,sConn,DataBase:string;Descriptor:THandle;TimeStart:TTime;Manual:boolean);
    destructor Destroy; override;
    procedure Execute; override;
  var
   Fstop,FManual:boolean;
   FileNameLog:string;
   ConnectString:string;
   DataBaseName:string;
   RoutesFileName:string;
   IsError:boolean;
   FDescriptor:THandle;
   ADOConnect:TADOConnection;
   ADOStoredProcExpAllShedByRoute:TADOStoredProc;
   ADODataSetExecDeleteTables:TADOQuery;
   ADODataSetExecUpdatePriceList:TADOQuery;
   ResString:array[1..3]of string[50];
   ListRoutes,ListRoutesERR:array[1..9]of TStringList; // id, Name, Deleted, Code, IsOffice, IdLandStore(refStores.Id), refStores.Name , idPosition(refPositions.Id), refPositions.Name
  StatComplete,StatErrors,StatWait:integer;
  end;

  var
  AOwner: TComponent;

implementation

uses MainFormUnit, FunctionsUnit, ActiveX, DataModuleUnit, ConstUnit,
  Unit_ExpAllShed;

constructor ThExpDataByRoute.Create(CreateSuspennded:Boolean;FileRoute,LogFile,sConn,DataBase:string;Descriptor:THandle;TimeStart:TTime;Manual:boolean);
begin
FDescriptor:=Descriptor;
RoutesFileName:=FileRoute;
ConnectString:=sConn;
FileNameLog:=LogFile;
DataBaseName:=DataBase;
IsError:=false;
StatComplete:=0;StatErrors:=0;StatWait:=0;
Fstop:=false;fmanual:=manual;
inherited Create(CreateSuspennded);
end;

destructor ThExpDataByRoute.Destroy;
begin
  inherited;
end;

procedure ThExpDataByRoute.Execute;
var
i,i1:integer;
E:error;
f,f2,ferr:textfile;
s,tmps:string;
ii:integer;
begin
try
AssignFile(f,FileNameLog);
Rewrite(f);
AssignFile(ferr,ExtractFilePath(FileNameLog)+'ERROR'+ExtractFileName(FileNameLog));
Rewrite(ferr);
AssignFile(f2,RoutesFileName);
Reset(f2);
Writeln(f,timetostr(time)+' =======> ����� �������� �������� ������ ��� ��������');
if FManual then
 begin
  Form_ExpAllShed.Memo_Log.Lines.Add('');
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' =======> ����� �������� �������� ������ ��� ��������');
 end;
 try
FreeOnTerminate:=true;
OnTerminate:=fMain.ThreadsExpDataByRouteDone;
EnterCriticalSection(CS);
Writeln(f,timetostr(time)+' �������� ����������� ������ ��������� ����������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' �������� ����������� ������ ��������� ����������');
CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
Writeln(f,timetostr(time)+' ������������� ���������� COM-������� �������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������������� ���������� COM-������� �������');
ViewLog(3,'������� ������ ��� ���','��������� ������� �������� ������ ��� ���');

ADOConnect:=TADOConnection.Create(AOwner);
ADOConnect.ConnectionString:=ConnectString;
ADOConnect.DefaultDatabase:=DataBaseName;
ADOConnect.CursorLocation:=clUseServer;
ADOConnect.CommandTimeout:=0;

for i:=1 to 9 do
begin
ListRoutes[i]:=TStringList.Create;
ListRoutesERR[i]:=TStringList.Create;
end;

ADODataSetExecUpdatePriceList:=TADOQuery.Create(AOwner);
ADODataSetExecUpdatePriceList.SQL.Text:=' USE [chicago_n1] update refbuypoints set IdPricetype = rb.IdPricetype, CreditDeadline = rb.CreditDeadline from refbuypoints rbp inner join refbuyers rb on rb.id=rbp.idbuyer;';
ADODataSetExecUpdatePriceList.Connection:=ADOConnect;
ADODataSetExecUpdatePriceList.CursorLocation:=clUseServer;
ADODataSetExecUpdatePriceList.CommandTimeout:=0;

ADODataSetExecDeleteTables:=TADOQuery.Create(AOwner);
ADODataSetExecDeleteTables.SQL.Text:=' USE [chicago_n1] declare @date datetime set @date = dateadd(d, 0, getdate()) exec dbo.sp_expCmnTables_Delete @WorkDay = @date';
ADODataSetExecDeleteTables.Connection:=ADOConnect;
ADODataSetExecDeleteTables.CursorLocation:=clUseServer;
ADODataSetExecDeleteTables.CommandTimeout:=0;

ADOStoredProcExpAllShedByRoute:=TADOStoredProc.Create(AOwner);
ADOStoredProcExpAllShedByRoute.Connection:=ADOConnect;
ADOStoredProcExpAllShedByRoute.CursorLocation:=clUseServer;
ADOStoredProcExpAllShedByRoute.ProcedureName:=mData.ADOStoredProc_ExpAllShedbyRoute.ProcedureName;
ADOStoredProcExpAllShedByRoute.Parameters:=mData.ADOStoredProc_ExpAllShedbyRoute.Parameters;
ADOStoredProcExpAllShedByRoute.CommandTimeout:=0;

Writeln(f,timetostr(time)+' ���������� ��� ������ � �� ������� � ���������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ���������� ��� ������ � �� ������� � ���������');
ADOConnect.LoginPrompt:=false;
ADOConnect.Connected:=true;
ViewLog(0,'������� ������ ��� ���','����������� �������');
Writeln(f,timetostr(time)+' ����������� �������������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ����������� �������������');
ADODataSetExecUpdatePriceList.Close;
  try
   ADODataSetExecUpdatePriceList.ExecSQL;
  except
   Writeln(f,timetostr(time)+' ������ ��� ���������� �������');
    if FManual then
   Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������ ��� ���������� �������');
  end;
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
     begin
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
     if FManual then
     Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
     end;
 Writeln(f,timetostr(time)+' ���������� ����� ������ ���������.');
  if FManual then
 Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ���������� ����� ������ ���������.');

Readln(f2,s);
ii:=strtoint(s);
for i:=1 to 9 do
for i1:=1 to ii do
 begin
  Readln(f2,s);
  ListRoutes[i].Add(s);
 end;
if FManual then
begin
Form_ExpAllShed.ProgressBar1.Max:=ii;
Form_ExpAllShed.ProgressBar1.Position:=0;
end;

Writeln(f,timetostr(time)+' ������ �� '+IntToStr(ii)+' ��������� ��������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������ '+IntToStr(ii)+' ��������� ��������');
    ADOConnect.Errors.Clear;
    ADODataSetExecDeleteTables.Close;
    try
    ADODataSetExecDeleteTables.ExecSQL;
    except
     Writeln(f,timetostr(time)+' ������ ��� ������ �� ���������� ������');
      if FManual then
     Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������ ��� ������ �� ���������� ������');
    end;
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
     begin
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
     if FManual then
     Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
     end;
    ADOConnect.Errors.Clear;
Writeln(f,timetostr(time)+' �������� �� ���������� ������ ���������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' �������� �� ���������� ������ ���������');
ViewLog(2,'������� ������ ��� ���','���� ������� ������������ ������...');
for i:=0 to ii-1 do
begin
 try
  if Fstop then
  Terminate;
  Writeln(f,timetostr(time)+' �������� ������� '+ListRoutes[4].Strings[i]+' ('+ListRoutes[2].Strings[i]+')...');
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' �������� ������� '+ListRoutes[4].Strings[i]+' ('+ListRoutes[2].Strings[i]+')...');
  ADOStoredProcExpAllShedByRoute.Close;
  sleep(1);
  ADOConnect.BeginTrans;
  ADOStoredProcExpAllShedByRoute.Parameters.ParamValues['@offset']:=0;
  ADOStoredProcExpAllShedByRoute.Parameters.ParamValues['@CodeRoutes']:=ListRoutes[4].Strings[i];
  sleep(1);
  ADOStoredProcExpAllShedByRoute.ExecProc;
  Writeln(f,timetostr(time)+'    ------------- >>');
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+'    ------------- >>');
  Writeln(f,timetostr(time)+' ������� '+ListRoutes[4].Strings[i]+' ('+ListRoutes[2].Strings[i]+') ��� ������������� � ����� ����������:');
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������� '+ListRoutes[4].Strings[i]+' ('+ListRoutes[2].Strings[i]+') ��� ������������� � ����� ����������:');
  ResString[1]:=VarToStr(ADOStoredProcExpAllShedByRoute.Parameters.ParamValues['@Step1']);
  ResString[2]:=VarToStr(ADOStoredProcExpAllShedByRoute.Parameters.ParamValues['@Step2']);
  ResString[3]:=VarToStr(ADOStoredProcExpAllShedByRoute.Parameters.ParamValues['@Step3']);
  Writeln(f,timetostr(time)+ResString[1]);
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+ResString[1]);
  Writeln(f,timetostr(time)+ResString[2]);
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+ResString[2]);
  Writeln(f,timetostr(time)+ResString[3]);
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+ResString[3]);
  ADOConnect.CommitTrans;
  StatComplete:=StatComplete+1;
  StatWait:=ii-(i+1);
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
     begin
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
      if FManual then
      Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
     end;
//    ADOConnect.Errors.Clear;
  Writeln(f,timetostr(time)+'    ------------- <<');
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+'    ------------- <<');
  if FManual then
  begin
   Form_ExpAllShed.Label_Complete.Caption:=inttostr(StatComplete);
   Form_ExpAllShed.Label_Error.Caption:=inttostr(StatErrors);
   Form_ExpAllShed.Label_Wait.Caption:=inttostr(StatWait);
   Form_ExpAllShed.ProgressBar1.Position:=i+1;
  end;
 except
  on E:Exception do
   begin
    ADOConnect.RollbackTrans;
    StatErrors:=StatErrors+1;
      if FManual then
       begin
        Form_ExpAllShed.Label_Complete.Caption:=inttostr(StatComplete);
        Form_ExpAllShed.Label_Error.Caption:=inttostr(StatErrors);
        Form_ExpAllShed.Label_Wait.Caption:=inttostr(StatWait);
       end;
    Writeln(f,timetostr(time)+' ======> ������ ������������ ������ ��� �������� '+ListRoutes[4].Strings[i]);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ======> ������ ������������ ������ ��� �������� '+ListRoutes[4].Strings[i]);
    Writeln(f,timetostr(time)+e.Message);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+e.Message);
    Writeln(f,timetostr(time)+' ���������� ���� ��������, ��������� ��������� �������� �� ��������� ������:');
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ���������� ���� ��������, ��������� ��������� �������� �� ��������� ������:');
    Writeln(f,timetostr(time)+ResString[1]);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+ResString[1]);
    Writeln(f,timetostr(time)+ResString[2]);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+ResString[2]);
    Writeln(f,timetostr(time)+ResString[3]);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+ResString[3]);
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
     begin
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
      if FManual then
      Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
     end;
//    ADOConnect.Errors.Clear;
    for i1:=1 to 9 do
    ListRoutesERR[i1].Add(ListRoutes[i1].Strings[i]);
    IsError:=true;
   end;
 end;
end;
except
  on E:Exception do
   begin
    Writeln(f,timetostr(time)+' ======> ������ ��� ���������� � ������������ ������ '+ListRoutes[4].Strings[i]);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ======> ������ ��� ���������� � ������������ ������ '+ListRoutes[4].Strings[i]);
    Writeln(f,timetostr(time)+e.Message);
    if FManual then
    Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+e.Message);
    ViewLog(3,'������� ������ ��� ���','������! ��������� �������� � ����.');
   end;
end;
finally
ADOConnect.Connected:=false;
ViewLog(1,'������� ������ ��� ���','������������');
Writeln(f,timetostr(time)+' ����������� ���������������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ����������� ���������������');
if IsError then
 begin
  for i:=1 to 9 do
   for i1:=1 to ListRoutesERR[i1].Count do
    begin
     Writeln(ferr,ListRoutesERR[i1].Strings[i1]);
    end;
  Writeln(f,timetostr(time)+' ������ ��������� � �������� ��������');
  if FManual then
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������ ��������� � ������� ��������');
 end;
FreeAndNil(ADOStoredProcExpAllShedByRoute);
FreeAndNil(ADODataSetExecDeleteTables);
FreeAndNil(ADODataSetExecUpdatePriceList);
FreeAndNil(ADOConnect);
for i:=1 to 9 do
 begin
  FreeAndNil(ListRoutes[i]);
  FreeAndNil(ListRoutesERR[i]);
 end;
CloseFile(f2);
CloseFile(ferr);
if not IsError then
DeleteFile(ExtractFilePath(FileNameLog)+'ERROR'+ExtractFileName(FileNameLog));
Writeln(f,timetostr(time)+' ���������� ���������� ������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ���������� ���������� ������');
CoUninitialize;
Writeln(f,timetostr(time)+' ������������� ����������� ���-������� �������');
if FManual then
Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ������������� ����������� ���-������� �������');
if IsError then
ViewLog(3,'������� ������ ��� ���','������������ ������ ��� ��� �������� � �������')
else
ViewLog(3,'������� ������ ��� ���','������������ ������ ��� ��� ��������');
ReleaseMutex(FDescriptor);
LeaveCriticalSection(CS);
Writeln(f,timetostr(time)+' ����������� ������ �����������');
CloseFile(f);
if FManual then
 begin
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' ����������� ������ �����������');
  Form_ExpAllShed.Memo_Log.Lines.Add(timetostr(time)+' =======> ������������ ������ ��� ��� ���������. ���������� ��������� � ���� �����:');
  Form_ExpAllShed.Memo_Log.Lines.Add(TimeToStr(time)+'   '+FileNameLog);
  Form_ExpAllShed.StatusBar1.SimpleText:='';
 end;
end;
end;

end.
