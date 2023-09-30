unit FunctionsUnit;

interface

uses
  Windows, SHFolder, StrUtils, ADOInt, ActiveX, ComObj, OLEDB, DB, ADODB,
  Variants, Classes, DateUtils, SysUtils, Registry;

  function GetFolder(csidl: Integer; ForceFolder: Boolean = False): string;
  function GetLocalAppDataFolder(ForceFolder: Boolean = False): string;
  function GetAppDataFolder(ForceFolder: Boolean = False): string;
  function GetPersonalFolder(ForceFolder: Boolean = False): string;
  function GetCommonAppDataFolder(ForceFolder: Boolean = False): string;
  function GetCommonDocumentsFolder(ForceFolder: Boolean = False): string;
  function GetMyPicturesFolder(ForceFolder: Boolean = False): string;
  function CreateADOObject(const ClassID: TGUID): IUnknown;
  function GetApplicationRun: Boolean;
  (* Функции для работы с датами *)
  function CurrentDateTimeToString: string;
  function CheckDateFormat(SDate: string): string;
  (* Доп функции для таймеров*) {TODO: Перенести в необходимые объекты}
  function GetDay(const Day: Integer): Boolean;
  procedure GetMSSQLServerNamesList(Names: TStrings);
  procedure ViewLog(const ImgIndex: Integer; const ActionName, Comment: string);
  procedure SetApplicationRun(const RunAs: Boolean; const AppName: string);
  function changeDBname(ConnString,DBname:string):string;

const
_const_OffSet=0;  // корректировка даты в заказах

var
  Reg: TRegistry;

implementation

uses MainFormUnit;

////////////////// Блок установки каталогов лога и настроек программы //////////
function GetFolder(csidl: Integer; ForceFolder: Boolean = False): string;
var
  i: Integer;
begin
  SetLength(Result, MAX_PATH);
  if ForceFolder then
    SHGetFolderPath(0, csidl or CSIDL_FLAG_CREATE, 0, 0, PChar(Result))
  else
    SHGetFolderPath(0, csidl, 0, 0, PChar(Result));
  i := pos(#0, Result);
  if i > 0 then
    SetLength(Result, Pred(i));
end;

function GetLocalAppDataFolder(ForceFolder: Boolean = False): string;
begin
  Result := GetFolder(CSIDL_LOCAL_APPDATA, ForceFolder);
end;

function GetAppDataFolder(ForceFolder: Boolean = False): string;
begin
  Result := GetFolder(CSIDL_APPDATA, ForceFolder);
end;

function GetPersonalFolder(ForceFolder: Boolean = False): string;
begin
  Result := GetFolder(CSIDL_PERSONAL, ForceFolder);
end;

function GetCommonAppDataFolder(ForceFolder: Boolean = False): string;
begin
  Result := GetFolder(CSIDL_COMMON_APPDATA, ForceFolder);
end;

function GetCommonDocumentsFolder(ForceFolder: Boolean = False): string;
begin
  Result := GetFolder(CSIDL_COMMON_DOCUMENTS, ForceFolder);
end;

function GetmyPicturesFolder(ForceFolder: Boolean = False): string;
begin
  Result := GetFolder(CSIDL_MYPICTURES, ForceFolder);
end;
////////////////// Блок поиска активных SQL серверов в сети ////////////////////
function CreateADOObject(const ClassID: TGUID): IUnknown;
var
   Status: HResult;
   FPUControlWord: Word;
begin
   asm
    FNSTCW FPUControlWord
   end;
   Status := CoCreateInstance(CLASS_Recordset, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,
   IUnknown, Result);
   asm
    FNCLEX
    FLDCW FPUControlWord
  end;
  OleCheck(Status);
end;

procedure GetMSSQLServerNamesList(Names: TStrings);
var
  RSCon: ADORecordsetConstruction;
  Rowset: IRowset;
  SourcesRowset: ISourcesRowset;
  SourcesRecordset: _Recordset;
  SourcesName, SourcesType: TField;
begin
  SourcesRecordset := CreateADOObject(CLASS_Recordset) as _Recordset;
  RSCon := SourcesRecordset as ADORecordsetConstruction;
  SourcesRowset := CreateComObject(ProgIDToClassID('SQLOLEDB Enumerator')) as ISourcesRowset;
  OleCheck(SourcesRowset.GetSourcesRowset(nil, IRowset, 0, nil, IUnknown(Rowset)));
  RSCon.Rowset := RowSet;
  with TADODataSet.Create(nil) do
  try
    Recordset := SourcesRecordset;
    SourcesName := FieldByName('SOURCES_NAME');
    SourcesType := FieldByName('SOURCES_TYPE');
    Names.BeginUpdate;
    try
      while not EOF do
      begin
        if (SourcesType.AsInteger = DBSOURCETYPE_DATASOURCE) and (SourcesName.AsString <> '')
        then Names.Add(SourcesName.AsString);
        Next;
      end;
    finally
      Names.EndUpdate;
    end;
  finally
    Free;
  end;
end;

{function BoolToChar(Value: Boolean): Char;
begin
  if (Value) then
    Value := '1'
  else
    Value := '0';
end;

function CharToBool(Value: Char): Boolean;
begin
  if (Value = '1') then
    Result := True
  else
    Result := False;
end; }

////////////////// Управление датой и временем ////////////////////
function CurrentDateTimeToString: string;
begin
   Result := FormatDateTime('yyyymmddhhnnss', Now);
end;

function CheckDateFormat(SDate: string): string;
var
  IDateChar: string;
  x, y: Integer;
begin
  IDateChar := '-,\/';
  for y := 1 to length(IDateChar) do
  begin
    x := pos(IDateChar[y], SDate);
    while x > 0 do
    begin
      Delete(SDate, x, 1);
      Insert('.', SDate, x);
      x := pos(IDateChar[y], SDate);
    end;
  end;
  CheckDateFormat := SDate;
end;

function GetDay(const Day: Integer): Boolean;
var
  CurrentDay: Integer;
begin
  CurrentDay := DayOfWeek(Now);
  if Day = CurrentDay then
    Result := True
  else
    Result := False;
end;

//////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

procedure ViewLog(const ImgIndex: Integer; const ActionName, Comment: string);
var
  index: Integer;
  sDate, sTime: string;
begin
  index := fMain.vLogList.Items.Count;
  DateTimeToString(sDate, 'dd.mm.yyyy', Now);
  DateTimeToString(sTime, 'hh:mm:ss', Now);
  fMain.vLogList.Items.Add.SubItems.Add(sDate);
  if index = 0 then
  begin
    fMain.vLogList.Items[0].ImageIndex := ImgIndex;
    fMain.vLogList.Items[0].SubItems.Add(sTime);
    fMain.vLogList.Items[0].SubItems.Add(ActionName);
    fMain.vLogList.Items[0].SubItems.Add(Comment);
  end
  else
  begin
    fMain.vLogList.Items[index].ImageIndex := ImgIndex;
    fMain.vLogList.Items[index].SubItems.Add(sTime);
    fMain.vLogList.Items[index].SubItems.Add(ActionName);
    fMain.vLogList.Items[index].SubItems.Add(Comment);
  end;
end;


//////////////////////////////////////////////////////////////////////
procedure SetApplicationRun(const RunAs: Boolean; const AppName: string);
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      RootKey := HKEY_CURRENT_USER;
      OpenKey('Software', False);
      OpenKey('Microsoft', False);
      OpenKey('Windows', False);
      OpenKey('CurrentVersion', False);
      OpenKey('Run', False);
      case RunAs of
        True: WriteString('Service Data Transfer', AppName);
        False: DeleteValue('Service Data Transfer');
      end;
    end;
  finally
    Reg.Free;
  end;
end;

function GetApplicationRun: Boolean;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      RootKey := HKEY_CURRENT_USER;
      OpenKey('Software', False);
      OpenKey('Microsoft', False);
      OpenKey('Windows', False);
      OpenKey('CurrentVersion', False);
      OpenKey('Run', False);
      if ReadString('Service Data Transfer') <> '' then
        Result := True
      else
        Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

function changeDBname(ConnString,DBname:string):string;
var
tmpstr,tmpstr2,tmppppp:string;
begin
tmpstr:=Copy(ConnString,1,Pos('Initial Catalog=',ConnString)+length('Initial Catalog=')-1);
tmppppp:=Copy(ConnString,Pos('Initial Catalog=',ConnString)+length('Initial Catalog='),length(ConnString));
tmpstr2:=copy(tmppppp,pos(';',tmppppp),length(tmppppp));
Result:=tmpstr+DBname+tmpstr2;
end;


end.
