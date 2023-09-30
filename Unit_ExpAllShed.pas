unit Unit_ExpAllShed;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ADODB;

type
  TForm_ExpAllShed = class(TForm)
    ListBox_Do: TListBox;
    Label1: TLabel;
    Button_AddAllRoutes: TButton;
    ComboBox_Regions: TComboBox;
    Button_AddRoutesByRegion: TButton;
    Button_AddRoutesByCodePrice: TButton;
    ComboBox_PriceTypes: TComboBox;
    Button_UpdateInfo: TButton;
    Button_Exec: TButton;
    ProgressBar1: TProgressBar;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label_Complete: TLabel;
    Label5: TLabel;
    Button_ClearList: TButton;
    Label_Error: TLabel;
    Label7: TLabel;
    Label_Wait: TLabel;
    StatusBar1: TStatusBar;
    Button_SaveToPlan: TButton;
    Memo_Log: TMemo;
    CheckBox_Deleted: TCheckBox;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Button_LoadFromPlan: TButton;
    Label2: TLabel;
    Label4: TLabel;
    Button_UpdatePriceList: TButton;
    Button_DeleteTables: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button_ClearListClick(Sender: TObject);
    procedure Button_AddAllRoutesClick(Sender: TObject);
    procedure ListBox_DoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button_UpdateInfoClick(Sender: TObject);
    procedure Button_AddRoutesByRegionClick(Sender: TObject);
    procedure Button_AddRoutesByCodePriceClick(Sender: TObject);
    procedure Button_SaveToPlanClick(Sender: TObject);
    procedure ListBox_DoDblClick(Sender: TObject);
    procedure Button_ExecClick(Sender: TObject);
    procedure Button_LoadFromPlanClick(Sender: TObject);
    procedure Button_UpdatePriceListClick(Sender: TObject);
    procedure Button_DeleteTablesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;


var
  Form_ExpAllShed: TForm_ExpAllShed;
  ListRoutesDo,ListRoutesPosle:array[1..9]of TStringList; // id, Name, Deleted, Code, IsOffice, IdLandStore(refStores.Id), refStores.Name , idPosition(refPositions.Id), refPositions.Name
  ListRegions,ListPriceTypes:array[1..5]of TStrings;

implementation

uses TExpDataByRoute, DataModuleUnit, ConstUnit, FunctionsUnit, MainFormUnit,
  Unit_RoutesInfo;

{$R *.dfm}

procedure TForm_ExpAllShed.Button_AddAllRoutesClick(Sender: TObject);
var
E:error;
tmpDeleted:string;
i:integer;
begin
try
 Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> СТАРТ Импорт всех маршрутов');
 StatusBar1.SimpleText:=' Статус: Импорт всех маршрутов ...';
 try
 mData.ADOConn.Connected:=false;
 mData.ADODataSet_GetInfo.Close;
 mData.ADOConn.LoginPrompt:=false;
 mData.ADOConn.Connected:=true;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение активно');
 Application.ProcessMessages;
 mData.ADODataSet_GetInfo.CommandText:=
     'SELECT R.[id] AS RouteId '+
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
' INNER JOIN [chicago_n1].[dbo].[refPositions] P ON R.[idPosition]=P.[id] ';
 if not CheckBox_Deleted.Checked then
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' WHERE R.[deleted]=0';
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' ORDER BY RouteCode';
 mData.ADODataSet_GetInfo.Open;
 mData.ADODataSet_GetInfo.First;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Данные на сервере подготовленны');
 Application.ProcessMessages;
  while not mData.ADODataSet_GetInfo.Eof do
   begin
    ListRoutesDo[1].Add(mData.ADODataSet_GetInfo.FieldByName('RouteId').AsString);
    ListRoutesDo[2].Add(mData.ADODataSet_GetInfo.FieldByName('RouteName').AsString);
    ListRoutesDo[3].Add(mData.ADODataSet_GetInfo.FieldByName('RouteDeleted').AsString);
    ListRoutesDo[4].Add(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString);
    ListBox_Do.Items.Add(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString+' ('+mData.ADODataSet_GetInfo.FieldByName('RouteName').AsString+')');
    ListRoutesDo[5].Add(mData.ADODataSet_GetInfo.FieldByName('RouteIsOffice').AsString);
    ListRoutesDo[6].Add(mData.ADODataSet_GetInfo.FieldByName('StoreId').AsString);
    ListRoutesDo[7].Add(mData.ADODataSet_GetInfo.FieldByName('StoreName').AsString);
    ListRoutesDo[8].Add(mData.ADODataSet_GetInfo.FieldByName('PositionId').AsString);
    ListRoutesDo[9].Add(mData.ADODataSet_GetInfo.FieldByName('PositionName').AsString);
    mData.ADODataSet_GetInfo.Next;
   end;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Добавлен список из '+inttostr(mData.ADODataSet_GetInfo.RecordCount)+' маршрутов');
 Application.ProcessMessages;
 except
  on E:Exception do
   begin
    Memo_Log.Lines.Add(TimeToStr(Time)+' ОШИБКА при импорте всех маршрутов');
    Memo_Log.Lines.Add(TimeToStr(Time)+'   '+E.Message);
   end;
 end;
finally
mData.ADOConn.Connected:=false;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение деактивированно');
mData.ADODataSet_GetInfo.Close;
Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> Импорт всех маршрутов завершен.');
StatusBar1.SimpleText:='';
Application.ProcessMessages;
end;
end;

procedure TForm_ExpAllShed.Button_AddRoutesByCodePriceClick(Sender: TObject);
var
E:error;
tmpDeleted:string;
i:integer;
begin
try
 Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> СТАРТ Импорт маршрутов которые используют прайс '+ComboBox_PriceTypes.Text);
 StatusBar1.SimpleText:=' Статус: Импорт маршрутов которые используют прайс '+ComboBox_PriceTypes.Text+' ...';
 try
 mData.ADOConn.Connected:=false;
 mData.ADODataSet_GetInfo.Close;
 mData.ADOConn.LoginPrompt:=false;
 mData.ADOConn.Connected:=true;
  Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение активно');
 Application.ProcessMessages;
 mData.ADODataSet_GetInfo.CommandText:=
    ' SELECT DISTINCT R.[id] AS RouteId '+
     ' ,R.[Name] AS RouteName '+
     ' ,R.[deleted] AS RouteDeleted '+
     ' ,R.[Code] AS RouteCode '+
     ' ,R.[IsOffice] AS RouteIsOffice '+
     ' ,R.[idLandStore] AS StoreId '+
     ' ,S.[Name] AS StoreName '+
     ' ,PT.[outercode] AS PriceTypeCode '+
     ' ,PT.[Name] AS PriceTypeName '+
 ' FROM [chicago_n1].[dbo].[refRoutes] R '+
' INNER JOIN [chicago_n1].[dbo].[refStores] S ON R.[idLandStore]=S.[id] '+
' INNER JOIN [chicago_n1].[dbo].[refRouteTerritory] RT ON RT.[idRoute]=R.[id] '+
' INNER JOIN [chicago_n1].[dbo].[refBuyPoints] BP ON BP.[id]=RT.[idBuyPoint] '+
' INNER JOIN [chicago_n1].[dbo].[refPriceTypes] PT ON PT.[id]=BP.[idPriceType] ';
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' WHERE R.[deleted]=0 AND S.[deleted]=0 AND RT.[deleted]=0 AND BP.[deleted]=0 AND PT.[deleted]=0 AND PT.[outercode]='+ListPriceTypes[4].Strings[ComboBox_PriceTypes.ItemIndex];
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' ORDER BY RouteCode';
 mData.ADODataSet_GetInfo.Open;
 mData.ADODataSet_GetInfo.First;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Данные на сервере подготовленны');
 Application.ProcessMessages;
  while not mData.ADODataSet_GetInfo.Eof do
   begin
    ListRoutesDo[1].Add(mData.ADODataSet_GetInfo.FieldByName('RouteId').AsString);
    ListRoutesDo[2].Add(mData.ADODataSet_GetInfo.FieldByName('RouteName').AsString);
    ListRoutesDo[3].Add(mData.ADODataSet_GetInfo.FieldByName('RouteDeleted').AsString);
    ListRoutesDo[4].Add(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString);
    ListBox_Do.Items.Add(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString+' ('+mData.ADODataSet_GetInfo.FieldByName('RouteName').AsString+')');
    ListRoutesDo[5].Add(mData.ADODataSet_GetInfo.FieldByName('RouteIsOffice').AsString);
    ListRoutesDo[6].Add(mData.ADODataSet_GetInfo.FieldByName('StoreId').AsString);
    ListRoutesDo[7].Add(mData.ADODataSet_GetInfo.FieldByName('StoreName').AsString);
    ListRoutesDo[8].Add(mData.ADODataSet_GetInfo.FieldByName('PriceTypeCode').AsString);
    ListRoutesDo[9].Add(mData.ADODataSet_GetInfo.FieldByName('PriceTypeName').AsString);
    mData.ADODataSet_GetInfo.Next;
   end;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Добавлен список из '+inttostr(mData.ADODataSet_GetInfo.RecordCount)+' маршрутов');
 Application.ProcessMessages;
 except
  on E:Exception do
   begin
    Memo_Log.Lines.Add(TimeToStr(Time)+' ОШИБКА при импорте маршрутов которые используют прайс: '+ComboBox_PriceTypes.Text);
    Memo_Log.Lines.Add(TimeToStr(Time)+'   '+E.Message);
   end;
 end;
finally
mData.ADOConn.Connected:=false;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение деактивированно');
mData.ADODataSet_GetInfo.Close;
StatusBar1.SimpleText:='';
 Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> Импорт маршрутов которые используют прайс '+ComboBox_PriceTypes.Text+' завершено');
Application.ProcessMessages;
end;
end;

procedure TForm_ExpAllShed.Button_AddRoutesByRegionClick(Sender: TObject);
var
E:error;
tmpDeleted,IdRegion:string;
i,tmpCnt:integer;
begin
try
 Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> СТАРТ Импорт маршрутов по региону: '+ComboBox_Regions.Text);
 StatusBar1.SimpleText:=' Статус: Импорт маршрутов по региону: '+ComboBox_Regions.Text;
 case ComboBox_Regions.ItemIndex of
 0:IdRegion:='2';
 1:IdRegion:='3';
 2:IdRegion:='4';
 3:IdRegion:='5';
 4:IdRegion:='6';
 5:IdRegion:='7';
 6:IdRegion:='8';
 7:IdRegion:='9';
 8:IdRegion:='11';
 9:IdRegion:='12';
 10:IdRegion:='14';
 11:IdRegion:='15';
 12:IdRegion:='17';
 end;
 try
 mData.ADOConn.Connected:=false;
 mData.ADODataSet_GetInfo.Close;
 mData.ADOConn.LoginPrompt:=false;
 mData.ADOConn.Connected:=true;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение активно');
 Application.ProcessMessages;
 mData.ADODataSet_GetInfo.CommandText:=
     'SELECT R.[id] AS RouteId '+
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
' INNER JOIN [chicago_n1].[dbo].[refPositions] P ON R.[idPosition]=P.[id] ';
 if not CheckBox_Deleted.Checked then
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' WHERE R.[deleted]=0';
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' ORDER BY RouteCode';
 mData.ADODataSet_GetInfo.Open;
 mData.ADODataSet_GetInfo.First;
 tmpCnt:=0;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Данные на сервере подготовленны');
 Application.ProcessMessages;
  while not mData.ADODataSet_GetInfo.Eof do
   begin
    if copy(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString,1,length(IdRegion))=IdRegion then
    begin
    tmpCnt:=tmpCnt+1;
    ListRoutesDo[1].Add(mData.ADODataSet_GetInfo.FieldByName('RouteId').AsString);
    ListRoutesDo[2].Add(mData.ADODataSet_GetInfo.FieldByName('RouteName').AsString);
    ListRoutesDo[3].Add(mData.ADODataSet_GetInfo.FieldByName('RouteDeleted').AsString);
    ListRoutesDo[4].Add(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString);
    ListBox_Do.Items.Add(mData.ADODataSet_GetInfo.FieldByName('RouteCode').AsString+' ('+mData.ADODataSet_GetInfo.FieldByName('RouteName').AsString+')');
    ListRoutesDo[5].Add(mData.ADODataSet_GetInfo.FieldByName('RouteIsOffice').AsString);
    ListRoutesDo[6].Add(mData.ADODataSet_GetInfo.FieldByName('StoreId').AsString);
    ListRoutesDo[7].Add(mData.ADODataSet_GetInfo.FieldByName('StoreName').AsString);
    ListRoutesDo[8].Add(mData.ADODataSet_GetInfo.FieldByName('PositionId').AsString);
    ListRoutesDo[9].Add(mData.ADODataSet_GetInfo.FieldByName('PositionName').AsString);
    end;
    mData.ADODataSet_GetInfo.Next;
   end;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Добавлен список из '+inttostr(tmpCnt)+' маршрутов');
 Application.ProcessMessages;
 except
  on E:Exception do
   begin
    Memo_Log.Lines.Add(TimeToStr(Time)+' ОШИБКА при импорте маршрутов по региону');
    Memo_Log.Lines.Add(TimeToStr(Time)+'   '+E.Message);
   end;
 end;
finally
mData.ADOConn.Connected:=false;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение деактивированно');
mData.ADODataSet_GetInfo.Close;
 Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> Импорт маршрутов по региону: '+ComboBox_Regions.Text+' завершен.');
StatusBar1.SimpleText:='';
Application.ProcessMessages;
end;
end;

procedure TForm_ExpAllShed.Button_ClearListClick(Sender: TObject);
var
i:integer;
begin
ListBox_Do.Items.Clear;
for i:=1 to 9 do
 ListRoutesDo[i].Clear;
Memo_Log.Lines.Add(timetostr(time)+' Чистка списка ...')
end;

procedure TForm_ExpAllShed.Button_DeleteTablesClick(Sender: TObject);
var
 tmpConn:TADOConnection;
 tmpQuery:TADOQuery;
begin
try
 tmpConn:=TADOConnection.Create(nil);
 tmpConn.ConnectionString:=changeDBname(fMain.sConn,'chicago_n1');
 tmpConn.LoginPrompt:=false;
 tmpConn.Connected:=true;
 tmpQuery:=TADOQuery.Create(nil);
 tmpQuery.Connection:=tmpConn;
 tmpQuery.CommandTimeout:=30;
 tmpQuery.SQL.Text:=' USE [chicago_n1] declare @date datetime set @date = dateadd(d, 0, getdate()) exec dbo.sp_expCmnTables_Delete @WorkDay = @date';
 tmpQuery.ExecSQL;
except
 on E:Exception do
  begin
   MessageBox(0,pchar(E.Message),'Ошибочка',0);
  end;
end;
if Assigned(tmpQuery) then
 FreeAndNil(tmpQuery);
if Assigned(tmpConn) then
 FreeAndNil(tmpConn);
end;

procedure TForm_ExpAllShed.Button_ExecClick(Sender: TObject);
var
f:textfile;
i,ii:integer;
s,LogFile:string;
E:error;
Descriptor:THandle;
begin
Memo_Log.Lines.Add('');
OpenDialog1.InitialDir:=tSettingFile.GetStringValue('Folders', 'LogFolder');
if OpenDialog1.Execute then
try
Memo_Log.Lines.Add(TimeToStr(time)+' =========> СТАРТ формирования данных по маршрутам из файла:');
StatusBar1.SimpleText:='Идет процесс формирования данных по маршрутам ...';
Memo_Log.Lines.Add(TimeToStr(time)+OpenDialog1.FileName);
Descriptor:=CreateMutex(nil, False, nil);
LogFile:=tSettingfile.GetStringValue('Folders', 'LogFolder')+'\LogGeneration'+CurrentDateTimeToString+'.logs';
PointWorkRoute:=ThExpDataByRoute.Create(false,OpenDialog1.FileName,LogFile,fMain.sConn,'chicago_n1',Descriptor,Time,true);
WorkRoute:=true;
except
 on E:Exception do
  begin
   Memo_Log.Lines.Add(TimeToStr(time)+' ОШИБКА! '+e.Message);
  end;
end;
end;

procedure TForm_ExpAllShed.Button_LoadFromPlanClick(Sender: TObject);
var
f:textfile;
i,ii,i1:integer;
s,LogFile:string;
E:error;
Descriptor:THandle;
begin
Memo_Log.Lines.Add('');
OpenDialog1.InitialDir:=tSettingFile.GetStringValue('Folders', 'LogFolder');
if OpenDialog1.Execute then
try
Memo_Log.Lines.Add(TimeToStr(time)+' =========> СТАРТ загрузки файла со списком:');
StatusBar1.SimpleText:='Идет процесс загрузки списка с маршрутами ...';
Memo_Log.Lines.Add(TimeToStr(time)+OpenDialog1.FileName);
AssignFile(f,OpenDialog1.FileName);
Reset(f);
Readln(f,s);
ii:=strtoint(s);
for i:=1 to 9 do
for i1:=1 to ii do
 begin
  Readln(f,s);
  ListRoutesDo[i].Add(s);
 end;
for i:=0 to ii-1 do
 begin
  ListBox_Do.Items.Add(ListRoutesDo[4].Strings[i]+' ('+ListRoutesDo[2].Strings[i]+')')
 end;
except
 on E:Exception do
  begin
   Memo_Log.Lines.Add(TimeToStr(time)+' ОШИБКА! '+e.Message);
  end;
end;
Memo_Log.Lines.Add(TimeToStr(time)+' =========> загрузка файла со списком завершено, загружено '+inttostr(ii)+' маршрутов');
StatusBar1.SimpleText:='';
end;

procedure TForm_ExpAllShed.Button_SaveToPlanClick(Sender: TObject);
var
f:textfile;
i,ii:integer;
E:error;
begin
SaveDialog1.InitialDir:=tSettingFile.GetStringValue('Folders', 'LogFolder');
if SaveDialog1.Execute then
try
Memo_Log.Lines.Add(TimeToStr(time)+' =========> СТАРТ сохранения списка маршрутов в файл:');
StatusBar1.SimpleText:='Сохранения списка маршрутов в файл ...';
if copy(SaveDialog1.FileName,length(SaveDialog1.FileName)-3,4)<>'.cfg' then
begin
Memo_Log.Lines.Add(TimeToStr(time)+SaveDialog1.FileName+'.cfg');
AssignFile(f,SaveDialog1.FileName+'.cfg');
end
else
begin
Memo_Log.Lines.Add(TimeToStr(time)+SaveDialog1.FileName);
AssignFile(f,SaveDialog1.FileName);
end;
Rewrite(f);
Writeln(f,inttostr(ListRoutesDo[1].Count));
for i:=1 to 9 do
 begin
  for ii:=0 to ListRoutesDo[1].Count-1 do
   begin
    Writeln(f,ListRoutesDo[i].Strings[ii]);
   end;
 end;
 CloseFile(f);
except
 on E:Exception do
  begin
   Memo_Log.Lines.Add(TimeToStr(time)+' ОШИБКА! при сохранении файла: ');
   Memo_Log.Lines.Add(TimeToStr(time)+' '+e.Message);
  end;
end;
Memo_Log.Lines.Add(TimeToStr(time)+' ========> Сохранение маршрутов завершено.');
StatusBar1.SimpleText:='';
end;

procedure TForm_ExpAllShed.Button_UpdateInfoClick(Sender: TObject);
var
E:error;
tmpDeleted:string;
i:integer;
begin
try
 Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> СТАРТ Импорт Прайсов');
 StatusBar1.SimpleText:=' Статус: Импорт прайсов...';
 try
 mData.ADOConn.Connected:=false;
 mData.ADODataSet_GetInfo.Close;
 mData.ADOConn.LoginPrompt:=false;
 mData.ADOConn.Connected:=true;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Подключение активно');
 mData.ADODataSet_GetInfo.CommandText:=
 ' SELECT [id] '+
 '     ,[Name] '+
 '     ,[deleted] '+
 '     ,[outercode] '+
 '     ,[MTCode] '+
 ' FROM [chicago_n1].[dbo].[refPriceTypes] ';
 if not CheckBox_Deleted.Checked then
 mData.ADODataSet_GetInfo.CommandText:=mData.ADODataSet_GetInfo.CommandText+' WHERE [deleted]=0';
 mData.ADODataSet_GetInfo.Open;
 mData.ADODataSet_GetInfo.First;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Данные на сервере подготовленны');
  for i:=1 to 5 do
 ListPriceTypes[i].Clear;
 ComboBox_PriceTypes.Items.Clear;
  while not mData.ADODataSet_GetInfo.Eof do
   begin
    ListPriceTypes[1].Add(mData.ADODataSet_GetInfo.FieldByName('id').AsString);
    ListPriceTypes[2].Add(mData.ADODataSet_GetInfo.FieldByName('Name').AsString);
    ComboBox_PriceTypes.Items.Add(mData.ADODataSet_GetInfo.FieldByName('outercode').AsString+' ('+mData.ADODataSet_GetInfo.FieldByName('Name').AsString+')');
    ListPriceTypes[3].Add(mData.ADODataSet_GetInfo.FieldByName('deleted').AsString);
    ListPriceTypes[4].Add(mData.ADODataSet_GetInfo.FieldByName('outercode').AsString);
    ListPriceTypes[5].Add(mData.ADODataSet_GetInfo.FieldByName('MTCode').AsString);
    mData.ADODataSet_GetInfo.Next;
   end;
 Memo_Log.Lines.Add(TimeToStr(Time)+' Добавлен список из '+inttostr(mData.ADODataSet_GetInfo.RecordCount)+' прайсов');
 except
  on E:Exception do
   begin
    Memo_Log.Lines.Add(TimeToStr(Time)+' ОШИБКА при импорте прайсов');
    Memo_Log.Lines.Add(TimeToStr(Time)+'   '+E.Message);
   end;
 end;
finally
mData.ADOConn.Connected:=false;
mData.ADODataSet_GetInfo.Close;
Memo_Log.Lines.Add(TimeToStr(Time)+' ==========> Импорт прайсов завершен');
StatusBar1.SimpleText:='';
end;
end;

procedure TForm_ExpAllShed.Button_UpdatePriceListClick(Sender: TObject);
var
 tmpConn:TADOConnection;
 tmpQuery:TADOQuery;
begin
try
 tmpConn:=TADOConnection.Create(nil);
 tmpConn.ConnectionString:=changeDBname(fMain.sConn,'chicago_n1');
 tmpConn.LoginPrompt:=false;
 tmpConn.Connected:=true;
 tmpQuery:=TADOQuery.Create(nil);
 tmpQuery.Connection:=tmpConn;
 tmpQuery.CommandTimeout:=30;
 tmpQuery.SQL.Text:=' USE [chicago_n1] update refbuypoints set IdPricetype = rb.IdPricetype, CreditDeadline = rb.CreditDeadline from refbuypoints rbp inner join refbuyers rb on rb.id=rbp.idbuyer;';
 tmpQuery.ExecSQL;
except
 on E:Exception do
  begin
   MessageBox(0,pchar(E.Message),'Ошибочка',0);
  end;
end;
if Assigned(tmpQuery) then
 FreeAndNil(tmpQuery);
if Assigned(tmpConn) then
 FreeAndNil(tmpConn);
end;

procedure TForm_ExpAllShed.FormCreate(Sender: TObject);
var
i:integer;
begin
for i:=1 to 9 do
 begin
  ListRoutesDo[i]:=TStringList.Create;
  ListRoutesPosle[i]:=TStringList.Create;
 end;
for i:=1 to 5 do
 begin
  ListRegions[i]:=TStringList.Create;
  ListPriceTypes[i]:=TStringList.Create;
 end;
end;

procedure TForm_ExpAllShed.ListBox_DoDblClick(Sender: TObject);
begin
Form_RoutesInfo.Label2.Caption:=ListRoutesDo[1].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label4.Caption:=ListRoutesDo[2].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label6.Caption:=ListRoutesDo[3].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label8.Caption:=ListRoutesDo[4].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label10.Caption:=ListRoutesDo[5].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label12.Caption:=ListRoutesDo[6].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label14.Caption:=ListRoutesDo[7].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label16.Caption:=ListRoutesDo[8].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Label18.Caption:=ListRoutesDo[9].Strings[ListBox_Do.ItemIndex];
Form_RoutesInfo.Show;
end;

procedure TForm_ExpAllShed.ListBox_DoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
i,n:integer;
begin
if (Key=46) and (ListBox_Do.ItemIndex>=0) then
 begin
 n:=ListBox_Do.ItemIndex;
  for i:=1 to 9 do
    ListRoutesDo[i].Delete(ListBox_Do.ItemIndex);
  ListBox_Do.Items.Delete(ListBox_Do.ItemIndex);
 end;
 if ListBox_Do.Count>1 then
  ListBox_Do.ItemIndex:=n-1;
end;

end.
