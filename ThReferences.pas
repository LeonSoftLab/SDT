unit ThReferences;

interface

uses classes, windows, sysutils, Variants, ADODB;

type
  THRegerences = class(TThread)
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
   ListRoutesDo:array[1..9]of TStringList;
   ADOConnect:TADOConnection;
   ADOQuery_UpdateRoutesDef:TADODataSet;
   ADOQuery_UpdateDataReferencesToBD:TADOQuery;
   ADOQuery_SaveReferencesToXML:TADOQuery;
  end;

  var
  AOwner: TComponent;

implementation

uses MainFormUnit, FunctionsUnit, ActiveX, DataModuleUnit, ConstUnit;

constructor THRegerences.Create(CreateSuspennded:Boolean;LogFile,sConn,DataBase:string;Descriptor:THandle;AWorkPath:string);
begin
FileNameLog:=LogFile;
ConnectString:=sConn;
DataBaseName:=DataBase;
FDescriptor:=Descriptor;
FWorkPath:=AWorkPath;
inherited Create(CreateSuspennded);
end;

destructor THRegerences.Destroy;
begin
  inherited;
end;

procedure THRegerences.Execute;
var
i,i1,ii:integer;
E:Error;
f,f1:textfile;
begin
try
try
AssignFile(f,FileNameLog);
Rewrite(f);
Writeln(f,timetostr(time)+' =====> СТАРТ формирования справочников ...');
FreeOnTerminate:=true;
OnTerminate:=fMain.ThreadsReferencesDone;
EnterCriticalSection(CS);
Writeln(f,timetostr(time)+' занимаем критическую секцию основного приложения');
CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
Writeln(f,timetostr(time)+' инициализация апартамент COM-сервера');
ViewLog(3,'Справочники','Старт формирования справочников.');

for i:=1 to 9 do
ListRoutesDo[i]:=TStringList.Create;


ADOConnect:=TADOConnection.Create(AOwner);
ADOConnect.ConnectionString:=ConnectString;
ADOConnect.DefaultDatabase:=DataBaseName;
ADOConnect.CursorLocation:=clUseServer;
ADOConnect.CommandTimeout:=0;

ADOQuery_UpdateDataReferencesToBD:=TADOQuery.Create(AOwner);
ADOQuery_UpdateDataReferencesToBD.SQL.Text:=' USE [workot] EXEC [dbo].rplRoutes; EXEC [dbo].rplBuyers; EXEC [dbo].rplGoods;';
ADOQuery_UpdateDataReferencesToBD.Connection:=ADOConnect;
ADOQuery_UpdateDataReferencesToBD.CursorLocation:=clUseServer;
ADOQuery_UpdateDataReferencesToBD.CommandTimeout:=0;

ADOQuery_UpdateRoutesDef:=TADODataSet.Create(AOwner);
ADOQuery_UpdateRoutesDef.CommandText:=
     'SELECT DISTINCT R.[id] AS RouteId '+
     ' ,R.[Name] AS RouteName '+
     ' ,R.[deleted] AS RouteDeleted '+
     ' ,R.[Code] AS RouteCode '+
     ' ,R.[IsOffice] AS RouteIsOffice '+
     ' ,R.[idLandStore] AS StoreId '+
     ' ,S.[Name] AS StoreName '+
     ' ,R.[idPosition] AS PositionId '+
     ' ,P.[Name] AS PositionName '+
 ' FROM [chicago_n1].[dbo].[refRoutes] R '+
' INNER JOIN [chicago_n1].[dbo].[refStores] S ON R.[idLandStore]=S.[id] '+
' INNER JOIN [chicago_n1].[dbo].[refPositions] P ON R.[idPosition]=P.[id] '+
' WHERE R.[deleted] = 0 '+
' ORDER BY RouteCode ';
ADOQuery_UpdateRoutesDef.Connection:=ADOConnect;
ADOQuery_UpdateRoutesDef.CommandType:=cmdText;
ADOQuery_UpdateRoutesDef.CursorLocation:=clUseServer;
ADOQuery_UpdateRoutesDef.CommandTimeout:=0;

ADOQuery_SaveReferencesToXML:=TADOQuery.Create(AOwner);
ADOQuery_SaveReferencesToXML.SQL.Text:=
' USE [workot] '+
' DECLARE @result int '+
' DECLARE @OutputFileName varchar(150) '+
' DECLARE @cmd varchar(150) '+
' Set @OutputFileName = '''+FWorkPath+'\references.xml'''+
' Set @cmd = ''BCP "EXEC [workot].[dbo].rplReferencesXML" queryout "'' + @OutputFileName + ''"  -C RAW -w  -t -r -T'''+
' EXEC @result = master..xp_cmdshell @cmd';
ADOQuery_SaveReferencesToXML.Connection:=ADOConnect;
ADOQuery_SaveReferencesToXML.CursorLocation:=clUseServer;
ADOQuery_SaveReferencesToXML.CommandTimeout:=0;

Writeln(f,timetostr(time)+' компоненты для работы с БД созданы и настроены');
if Fstop then
Terminate;
ADOConnect.LoginPrompt:=false;
ADOConnect.Connected:=true;
ViewLog(0,'Справочники','Подключение активно');
Writeln(f,timetostr(time)+' подключение активированно');
try
Writeln(f,timetostr(time)+' приступаю к обновлению маршрутов для списка по дефолту ...');
ADOQuery_UpdateRoutesDef.Close;
ADOQuery_UpdateRoutesDef.Open;
ADOQuery_UpdateRoutesDef.First;
  while not ADOQuery_UpdateRoutesDef.Eof do
   begin
    ListRoutesDo[1].Add(ADOQuery_UpdateRoutesDef.FieldByName('RouteId').AsString);
    ListRoutesDo[2].Add(ADOQuery_UpdateRoutesDef.FieldByName('RouteName').AsString);
    ListRoutesDo[3].Add(ADOQuery_UpdateRoutesDef.FieldByName('RouteDeleted').AsString);
    ListRoutesDo[4].Add(ADOQuery_UpdateRoutesDef.FieldByName('RouteCode').AsString);
    ListRoutesDo[5].Add(ADOQuery_UpdateRoutesDef.FieldByName('RouteIsOffice').AsString);
    ListRoutesDo[6].Add(ADOQuery_UpdateRoutesDef.FieldByName('StoreId').AsString);
    ListRoutesDo[7].Add(ADOQuery_UpdateRoutesDef.FieldByName('StoreName').AsString);
    ListRoutesDo[8].Add(ADOQuery_UpdateRoutesDef.FieldByName('PositionId').AsString);
    ListRoutesDo[9].Add(ADOQuery_UpdateRoutesDef.FieldByName('PositionName').AsString);
    ADOQuery_UpdateRoutesDef.Next;
   end;
AssignFile(f1,ExtractFilePath(FileNameLog)+'DefaultListRoutes.cfg');
Rewrite(f1);
Writeln(f1,inttostr(ListRoutesDo[1].Count));
for i:=1 to 9 do
 begin
  for ii:=0 to ListRoutesDo[1].Count-1 do
   begin
    Writeln(f1,ListRoutesDo[i].Strings[ii]);
   end;
 end;
CloseFile(f1);
except
 on E:Exception do
  begin
   Writeln(f,timetostr(time)+' ===> ОШИБКА при формировании маршрутов по дефолту');
   Writeln(f,timetostr(time)+e.Message);
   ViewLog(3,'Справочники','Ошибка маршрутов');
   CloseFile(f1);
  end;
end;
try
Writeln(f,timetostr(time)+' ------------------ >>');
Writeln(f,timetostr(time)+' приступаю к обновлению данных выполняя [dbo].rplRoutes, [dbo].rplBuyers, [dbo].rplGoods ...');
ViewLog(2,'Справочники','Обновляю справочные данные в БД');
ADOQuery_UpdateDataReferencesToBD.Close;
ADOQuery_UpdateDataReferencesToBD.ExecSQL;
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
Writeln(f,timetostr(time)+' Обновление данных в БД workot из БД ОТ выполнено.');
Writeln(f,timetostr(time)+' <<------------------');
if Fstop then
Terminate;
Writeln(f,timetostr(time)+' ------------------ >>');
Writeln(f,timetostr(time)+' Приступаю к выгрузке данных в файл References.xml ...');
ViewLog(2,'Справочники','Начинаю выгрузку справочников в файл References.xml');
ADOQuery_SaveReferencesToXML.Close;
ADOQuery_SaveReferencesToXML.ExecSQL;
    Writeln(f,timetostr(time)+'    OLEDBPROVIDER :');
    for i1:=0 to ADOConnect.Errors.Count-1 do
      Writeln(f,timetostr(time)+' ###'+ADOConnect.Errors.Item[i1].Description);
Writeln(f,timetostr(time)+' Данные выгружены в файл');
Writeln(f,timetostr(time)+' <<------------------');
except
 on E:exception do
  begin
   Writeln(f,timetostr(time)+' ===> ОШИБКА при формировании');
   Writeln(f,timetostr(time)+e.Message);
   ViewLog(3,'Справочники','Ошибка формирования ...');
  end;
end;
except
 on E:Exception do
  begin
   Writeln(f,timetostr(time)+' ===> ОШИБКА подготовки ...');
   ViewLog(3,'Справочники','Ошибка подготовки ...');
  end;
end;
 finally
  ADOConnect.Connected:=false;
  ViewLog(1,'Справочники','Отсоединение');
  Writeln(f,timetostr(time)+' подключение деактивированно');
  for i:=1 to 9 do
  FreeAndNil(ListRoutesDo[i]);
  FreeAndNil(ADOQuery_UpdateRoutesDef);
  FreeAndNil(ADOQuery_SaveReferencesToXML);
  FreeAndNil(ADOQuery_UpdateDataReferencesToBD);
  FreeAndNil(ADOConnect);
  Writeln(f,timetostr(time)+' освободили занимаемую память.');
  CoUninitialize;
  Writeln(f,timetostr(time)+' деинициалицая аппартамент СОМ-сервера.');
  ReleaseMutex(FDescriptor);
  LeaveCriticalSection(CS);
  Writeln(f,timetostr(time)+' критическая секция освобождена.');
  Writeln(f,timetostr(time)+' ===> Формирование завершено.');
  ViewLog(3,'Справочники','Формирование завершено.');
  CloseFile(f);
 end;
end;


end.
