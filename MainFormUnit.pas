unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, ActnList, DateUtils, ImgList, XPMan, TSettingsObjectUnit,
  JvMenus, JvTrayIcon, JvComponentBase, ComCtrls, JvAlarms,
  JvExExtCtrls, JvExtComponent, JvClock, Shellapi, StdCtrls;

type
  TfMain = class(TForm)
    XPManifest1: TXPManifest;
    ActionList1: TActionList;
    ImageList1: TImageList;
    aExit: TAction;
    aImportData: TAction;
    aSettingsApp: TAction;
    aExportData: TAction;
    aSettingsFolders: TAction;
    aSettingsShedule: TAction;
    mMenu: TJvMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    JvOfficeMenuItemPainter1: TJvOfficeMenuItemPainter;
    JvTrayIcon1: TJvTrayIcon;
    vLogList: TListView;
    JvPopupMenu1: TJvPopupMenu;
    ImageList2: TImageList;
    N10: TMenuItem;
    N11: TMenuItem;
    aLogShow: TAction;
    N12: TMenuItem;
    Timer1: TTimer;
    N13: TMenuItem;
    N14: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    Referencesxml1: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aImportDataExecute(Sender: TObject);
    procedure aExportDataExecute(Sender: TObject);
    procedure aSettingsSheduleExecute(Sender: TObject);
    procedure aSettingsAppExecute(Sender: TObject);
    procedure aSettingsFoldersExecute(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure aLogShowExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure Referencesxml1Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure N20Click(Sender: TObject);
  private
    { Private declarations }
    RunType: Boolean;
    //SheduleDays: string;
    function GetInterval(const Value: string): Integer;
    function GetHours: Integer;
    function GetMinutes: Integer;
  public
    { Public declarations }
    fAppFolderName, fLogFolderName, ScriptFolder1: string;
    sConn: string;
    {ExportType,} PromptLogin, AuthType, LoggedActive: boolean;
    procedure ThreadsImportDone(Sender: TObject);
    procedure ThreadsExportDone(Sender: TObject);
    procedure ThreadsUpdatePriceDone(Sender: TObject);
    procedure ThreadsExpDataByRouteDone(Sender: TObject);
    procedure ThreadsReferencesDone(Sender: TObject);
    procedure ThreadsDZDone(Sender: TObject);
    procedure ThreadsReturnsDone(Sender: TObject);
    procedure ThreadsDocumentsDone(Sender: TObject);
    procedure ThreadsRestartServiceDone(Sender: TObject);
    procedure timerfired(Sender: TObject);
    procedure StartTask(Operation:byte;FileName:string);
    Procedure TimersUp;
    Procedure TimersDown;
    procedure TrimWorkingSet;
  end;

var
  fMain: TfMain;
  CS: TRTLCriticalSection;
  // ��� ����������� ��������� ���������� ������� � ����� �������� �� ���������� ��� ������� ������ �� ����������  � ������ �������������� ��������
  WorkRoute:boolean;PointWorkRoute:Pointer;
  WorkReference:boolean;PointWorkReference:Pointer;
  WorkDZ:boolean;PointWorkDZ:Pointer;
  WorkReturns:boolean;PointWorkReturns:Pointer;
  WorkDocuments:boolean;PointWorkDocuments:Pointer;
  WorkRestartService:boolean;PointWorkRestartService:Pointer;
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  fAppSettingsFileName: string;
  tSettingFile: TSettingsFile;
  TimersList:TList;
  GlobDay:byte;
  Antifreez:boolean;  // �������� ��� ����������� ��������� ���������

implementation

uses ConstUnit, DataModuleUnit, FunctionsUnit, SettingsConnectFormUnit,
  SettingsFolderFormUnit, ThreadImportUnit, SettingsSheduleFormUnit,
  ExportTypeFormUnits, ThreadExportUnit, LogViewFormUnit, TSheduleTimerUnit,
  TTaskTimer, Unit_PriceTable, Unit_AutoUpdatePrice, ThAutoUpdatePrice,
  Unit_ExpAllShed, TExpDataByRoute, ThReferences, ThDZ, ThReturns, Unit_Mustok,
  TExportDocumentsUnit, TRestartServiceUnit;

{$R *.dfm}


procedure TfMain.StartTask(Operation:byte;FileName:string);
var
Descriptor: THandle;
begin
case Operation of
0:begin Descriptor := CreateMutex(nil, False, nil); thImport.Create(False,Descriptor); end;
1:begin Descriptor := CreateMutex(nil, False, nil); thExport.Create(False,True,Descriptor); end;
2:begin Descriptor := CreateMutex(nil, False, nil); PointWorkDocuments:=TExportDocument.Create(false,false,tSettingFile.GetStringValue('Folders','LogFolder')+'\LogExport'+CurrentDateTimeToString+'.logs',sConn,'workot',tSettingFile.GetStringValue('Folders', 'WorkFolder'),Descriptor); WorkDocuments:=true; end;
{2:begin Descriptor := CreateMutex(nil, False, nil); thExport.Create(False,False,Descriptor); end;}
3:begin Descriptor := CreateMutex(nil, False, nil); TAutoUpdatePrice.Create(false,tSettingFile.GetStringValue('Folders', 'LogFolder')+'\LogPriceEdit'+CurrentDateTimeToString+'.logs',changeDBname(sConn,'workot'),'workot',Descriptor); end;
4:begin Descriptor := CreateMutex(nil, False, nil); PointWorkRoute:=ThExpDataByRoute.Create(false,FileName,tSettingfile.GetStringValue('Folders', 'LogFolder')+'\LogGeneration'+CurrentDateTimeToString+'.logs',changeDBname(sConn,'chicago_n1'),'chicago_n1',Descriptor,Time,false); WorkRoute:=true; end;
5:begin Descriptor := CreateMutex(nil, False, nil); PointWorkReference:=THRegerences.Create(false,tSettingFile.GetStringValue('Folders','LogFolder')+'\LogReferences'+CurrentDateTimeToString+'.logs',changeDBname(sConn,'workot'),'workot',Descriptor,tSettingFile.GetStringValue('Folders', 'WorkFolder')); WorkReference:=true; end;
6:begin Descriptor := CreateMutex(nil, False, nil); PointWorkDZ:=TDZ.Create(false,tSettingFile.GetStringValue('Folders','LogFolder')+'\LogDZ'+CurrentDateTimeToString+'.logs',changeDBname(sConn,'workot'),'workot',Descriptor,tSettingFile.GetStringValue('Folders', 'WorkFolder')); WorkDZ:=true; end;
7:begin Descriptor := CreateMutex(nil, False, nil); PointWorkReturns:=TReturns.Create(false,tSettingFile.GetStringValue('Folders','LogFolder')+'\LogReturns'+CurrentDateTimeToString+'.logs',changeDBname(sConn,'workot'),'workot',Descriptor,tSettingFile.GetStringValue('Folders', 'WorkFolder')); WorkReturns:=true; end;
8:begin Descriptor := CreateMutex(nil, False, nil); PointWorkRestartService:=ThRestartService.Create(false,strtoint(copy(FileName,1,1)),tSettingFile.GetStringValue('Folders','LogFolder')+'\LogRestartService'+CurrentDateTimeToString+'.logs',copy(FileName,3,length(FileName)-2),Descriptor); WorkRestartService:=true; end;
end;
end;

procedure TfMain.timerfired(Sender: TObject);
var
  i, n: integer;
begin
  n := 0;
  for i := 0 to TimersList.Count - 1 do
    if (Sender as TWaitThread).ThreadID = TWaitThread(TimersList[i]).ThreadID then
      n := i;
  TimersList.Delete(n);
  case (Sender as TWaitThread).FOperation of
  0:ViewLog(4,'�����������','������ "������ ������ ������ � ���" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  1:ViewLog(4,'�����������','������ "������� ������ �������� ������" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  2:ViewLog(4,'�����������','������ "������� ������ ��������� ���������" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  3:ViewLog(4,'�����������','������ "�������� �� ������� ����� ������� � ��" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  4:ViewLog(4,'�����������','������ "������������ ������ ��� ���" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  5:ViewLog(4,'�����������','������ "������������ ������������" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  6:ViewLog(4,'�����������','������ "������������ ���������" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  7:ViewLog(4,'�����������','������ "������������ ��������" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  8:ViewLog(4,'�����������','������ "������� ������" ('+inttostr((Sender as TWaitThread).FidTask)+') ��������� ���� ������, � ��������� �������� '+inttostr(TimersList.Count)+' �����');
  end;
end;

Procedure TfMain.TimersUp;
var
  i, j, TaskCount: Integer;
  ListParam:TStrings;
  Operation,TypeStart,Days,TimeStart,Period,TimeEnd,tmpS,FileName:string;
begin
 try
   TaskCount:=tSettingFile.GetIntegerValue('Sheduler','TaskNameCount');
    ListParam:=TStringList.Create;
    for i:=0 to TaskCount-1 do      {���������� �����}
     begin
      Operation:=tSettingFile.GetNoCrypt_sValue('Sheduler', 'TaskName' + IntToStr(i));
      if Operation='������ ������ (������ � ���)' then Operation:='0';
      if Operation='������� ������ (�������� ������)' then Operation:='1';
      if Operation='������� ������ (��������� ���������)' then Operation:='2';
      if Operation='�������� �� ������� ����� ������� � ��' then Operation:='3';
      if Operation='������������ ������ ��� ���' then Operation:='4';
      if Operation='������������ ������������' then Operation:='5';
      if Operation='������������ ���������' then Operation:='6';
      if Operation='������������ ��������' then Operation:='7';
      if Operation='������� ������' then Operation:='8';
      tSettingFile.Get_Section('TaskName' + IntToStr(i),ListParam);
       for j := 0 to ListParam.Count -1 do  { ���������� ���������� � ������ }
        begin
         tmpS:=tSettingFile.GetNoCrypt_sValue('TaskName' + IntToStr(i),ListParam.Strings[j]);
         case j of
         0:begin if tmpS='����������' then TypeStart:='0'; if tmpS='�� ���������' then TypeStart:='1'; end;
         1:begin Days:=tmpS; end;
         2:begin if tmpS='--:--' then TimeStart:=DateTimeToStr(Now) else TimeStart:=DateToStr(Date)+' '+tmpS+':'+inttostr(random(49)+10); end;
         3:begin if tmpS='--:--' then Period:='1' else Period:=inttostr(strtoint(copy(tmpS,1,2))*60+strtoint(copy(tmpS,4,2))) end;
         4:begin if tmpS='--:--' then TimeEnd:=DateTimeToStr(Now) else TimeEnd:=DateToStr(Date)+' '+tmpS+':'+inttostr(random(49)+10); end;
         5:begin FileName:=tmpS; end;
         end;
        end;
      TimersList.Add(TWaitThread.Create(false,inttostr(i),Operation,TypeStart,Days,TimeStart,Period,TimeEnd,FileName));
     end;
    ViewLog(4,'�����������',inttostr(TimersList.Count)+' ����� ����� ���� ��������');
 finally
  FreeAndNil(ListParam);
 end;
end;

Procedure TfMain.TimersDown;
var
i:integer;
begin
if TimersList.Count>0 then
ViewLog(4,'�����������','������� ������...');
for i:=0 to TimersList.Count-1 do
TWaitThread(TimersList[i]).Terminate;
end;

procedure TfMain.TrimWorkingSet;
var
MainHandle: THandle;
begin
if Win32Platform = VER_PLATFORM_WIN32_NT then
begin
MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
SetProcessWorkingSetSize(MainHandle, DWORD(-1), DWORD(-1));
CloseHandle(MainHandle);
end;
end;

procedure TfMain.aExitExecute(Sender: TObject);
begin
  if Application.MessageBox(PChar('��������� ������ ���������?'),
    PChar(AppNAme), MB_YESNO + MB_ICONQUESTION) = mrYes then
  begin
    FreeAndNil(tSettingFile);
    JvTrayIcon1.Active := False;

    TimersDown;
    while TimersList.Count>0 do
    Application.ProcessMessages;

    if WorkRoute then
     ThExpDataByRoute(PointWorkRoute).Fstop:=true;
    ViewLog(3,'���������� ������','������� ������������ ������ ��� ��� ...');
    while WorkRoute do
    Application.ProcessMessages;

    if WorkReference then
     THRegerences(PointWorkReference).Fstop:=true;
    ViewLog(3,'���������� ������','������� ������������ ������������ ...');
    while WorkReference do
    Application.ProcessMessages;

    if WorkDZ then
     TDZ(PointWorkDZ).Fstop:=true;
    ViewLog(3,'���������� ������','������� ������������ ��������� ...');
    while WorkDZ do
    Application.ProcessMessages;

    if WorkReturns then
     TReturns(PointWorkReturns).Fstop:=true;
    ViewLog(3,'���������� ������','������� ������������ �������� ...');
    while WorkReturns do
    Application.ProcessMessages;

    if WorkDocuments then
     TExportDocument(PointWorkDocuments).Fstop:=true;
    ViewLog(3,'���������� ������','������� ������������ ���������� �� �� ...');
    while WorkDocuments do
    Application.ProcessMessages;

    if WorkRestartService then
     TExportDocument(PointWorkRestartService).Fstop:=true;
    ViewLog(3,'���������� ������','������� ������� ������ ...');
    while WorkRestartService do
    Application.ProcessMessages;

    FreeAndNil(TimersList);
    DeleteCriticalSection(CS);
    Application.ProcessMessages;
    Application.Terminate;
  end;
end;


procedure TfMain.aExportDataExecute(Sender: TObject);
var
  Descriptor: THandle;
  fExpTYpe: TfExportType;
LogFile:string;
exppath:string;
begin
  {����� ���� ��������� ��� ��������}
  try
    fExpType := TfExportType.Create(Self);
    fExpType.ShowModal;
    if fExpType.ModalResult = mrOk then
    begin
      if fExpType.RadioButton1.Checked then //��������
      begin
       { ExportType := False;}
        // thExport.Create(False,False,Descriptor);
       Descriptor := CreateMutex(nil, False, nil);
       LogFile:=tSettingFile.GetStringValue('Folders','LogFolder')+'\LogExport'+CurrentDateTimeToString+'.logs';
       exppath:=tSettingFile.GetStringValue('Folders', 'WorkFolder');
       PointWorkDocuments:=TExportDocument.Create(false,false,LogFile,sConn,'workot',exppath,Descriptor);
       WorkDocuments:=true;
      end
      else
      begin //��������
        Descriptor := CreateMutex(nil, False, nil);
        {ExportType := True;}
        thExport.Create(False,True,Descriptor);
      end;
    end;
  finally
    FreeAndNil(fExpType);
  end;
end;

procedure TfMain.aImportDataExecute(Sender: TObject);
var
Descriptor: THandle;
begin
  (* ������ ������ *)
  Descriptor := CreateMutex(nil, False, nil);
  thImport.Create(False,Descriptor);
end;


procedure TfMain.aLogShowExecute(Sender: TObject);
var
  fLogView: TfViewLog;
begin
  try
    fLogView := TfViewLog.Create(Self);
    fLogView.ShowModal;
  finally
    FreeandNil(fLogView);
  end;
end;

procedure TfMain.aSettingsAppExecute(Sender: TObject);
var
  fConSett: TfSettingsConnect;
begin
  (* ��������� ����������� *)
  try
    fConSett := TfSettingsConnect.Create(Self);
    fConSett.cmbSQLServer.Clear;
    fConSett.cmbDBName.Clear;
    fConSett.edtUID.Clear;
    fConSett.edtPswrd.Clear;
    fConSett.cmbSQLServer.Text := tSettingFile.GetStringValue('Connection',
      'SQLServer');
    fConSett.cmbDBName.Text := tSettingFile.GetStringValue('Connection', 'DBName');
    case tSettingFile.GetBooleanValue('Connection', 'AuthType') of
      False:
        fConSett.rbWinAuth.Checked := True;
      True:
        begin
          fConSett.rbMSSQLAuth.Checked := True;
          fConSett.edtUID.Text := tSettingFile.GetStringValue('Connection',
            'DBLogin');
          fConSett.edtPswrd.Text := tSettingFile.GetStringValue('Connection',
            'DBPswrd');
        end;
    end;
    (* ���������� *)
    fConSett.chRunAs.Checked := GetApplicationRun;
    (* ����������� *)
    fConSett.chLogged.Checked := LoggedActive;
    (* ����� ����� *)
    fConSett.ShowModal;
    if fConSett.ModalResult = mrOk then
    begin
      fMain.sConn := fConSett.sConn;
      tSettingFile.SetStringNoCryptValue('Connection', 'sCon', fConSett.sConn);
      tSettingFile.SetStringValue('Connection', 'SQLServer',
        fConSett.cmbSQLServer.Text);
      tSettingFile.SetStringValue('Connection', 'DBName', fConSett.cmbDBName.Text);
      if fConSett.rbWinAuth.Checked then
        tSettingFile.SetBooleanValue('Connection', 'AuthType', False);
      if fConSett.rbMSSQLAuth.Checked then
      begin
        tSettingFile.SetBooleanValue('Connection', 'AuthType', True);
        tSettingFile.SetStringValue('Connection', 'DBLogin', fConSett.edtUID.Text);
        if fConSett.chSavePassword.Checked then
        begin
          tSettingFile.SetBooleanValue('Connection', 'Enabled', True);
          tSettingFile.SetStringValue('Connection', 'DBPswrd', fConSett.edtPswrd.Text);
          mData.Connection.LoginPrompt := False;
        end
        else
          mData.Connection.LoginPrompt := True;
      end;
      (* ���������� *)
      SetApplicationRun(fConSett.chRunAs.Checked, Application.ExeName);
      (* ����������� *)
      tSettingFile.SetBooleanValue('Logged', 'Active', fConSett.chLogged.Checked);
      LoggedActive := tSettingFile.GetBooleanValue('Logged', 'Active');
    end;
  finally
    FreeAndNil(fConSett);
  end;
end;

procedure TfMain.aSettingsFoldersExecute(Sender: TObject);
var
  fFolderSett: TfSettingsFolders;
begin
  (* ��������� ��������� *)
  try
    fFolderSett := TfSettingsFolders.Create(Self);
    if tSettingFile.GetStringValue('Folders', 'LogFolder') = '' then
      fFolderSett.edtLogDirectory.Text := fAppFolderName
    else
      fFolderSett.edtLogDirectory.Text := tSettingFile.GetStringValue('Folders', 'LogFolder');
    if tSettingFile.GetStringValue('Folders', 'WorkFolder') = '' then
      fFolderSett.edtWorkDirectory.Text := ExtractFilePath(Application.ExeName)
    else
      fFolderSett.edtWorkDirectory.Text := tSettingFile.GetStringValue('Folders', 'WorkFolder');
    fFolderSett.ShowModal;
    if fFolderSett.ModalResult = mrOk then
    begin
      tSettingFile.SetStringValue('Folders', 'LogFolder', fFolderSett.edtLogDirectory.Text);
      tSettingFile.SetStringValue('Folders', 'WorkFolder', fFolderSett.edtWorkDirectory.Text);
    end;
  finally
    FreeAndNil(fFolderSett);
  end;
end;

procedure TfMain.aSettingsSheduleExecute(Sender: TObject);
var
  fShSett: TfSheduleSett;
  i, j, TaskCount: Integer;
  ListParam:TStrings;
begin
  (* ��������� ���������� *)
  try
    fShSett := TfSheduleSett.Create(Self);
    fShSett.chSheduleActive.Checked := RunType;
     (* ��������� ������ ����� *)
    fShSett.chSheduleActive.Checked:=tSettingFile.GetBooleanValue('Sheduler', 'Active');
    TaskCount:=tSettingFile.GetIntegerValue('Sheduler','TaskNameCount');
    ListParam:=TStringList.Create;
    for i:=0 to TaskCount-1 do     (* ���������� �����*)
     begin
      fShSett.wListShedule.Items.Add.SubItems.Add(tSettingFile.GetNoCrypt_sValue('Sheduler', 'TaskName' + IntToStr(i)));
      tSettingFile.Get_Section('TaskName' + IntToStr(i),ListParam);
       for j := 0 to ListParam.Count -1 do  (* ���������� ���������� � ������*)
        begin
         fShSett.wListShedule.Items[i].SubItems.Add(tSettingFile.GetNoCrypt_sValue('TaskName' + IntToStr(i),ListParam.Strings[j]));
        end;
     end;

    fShSett.ShowModal;
    if fShSett.ModalResult = mrOk then
    begin //���������� ����������
      for i:=0 to TaskCount-1 do     (* ������ ������ ����� ����������� *)
       begin
       tSettingFile.Erase_Param('Sheduler', 'TaskName' + IntToStr(i));
       tSettingFile.Erase_Section('TaskName' + IntToStr(i));
       end;
      tSettingFile.SetBooleanValue('Sheduler', 'Active', fShSett.chSheduleActive.Checked);
      tSettingFile.SetIntegerValue('Sheduler', 'TaskNameCount',fShSett.wListShedule.Items.Count);(* ���������� �����*)
      for i := 0 to fShSett.wListShedule.Items.Count - 1 do
      begin
       tSettingFile.SetStringNoCryptValue('Sheduler', 'TaskName' + IntToStr(i),fShSett.wListShedule.Items.Item[i].SubItems.Strings[0]);
        for j := 1 to fShSett.wListShedule.Items.Item[i].SubItems.Count-1 do
        begin
          tSettingFile.SetStringNoCryptValue('TaskName' + IntToStr(i),
            fShSett.wListShedule.Columns.Items[j+1].Caption, fShSett.wListShedule.Items.Item[i].SubItems.Strings[j]);
        end;
      end;
  TimersDown;
  while TimersList.Count>0 do
  Application.ProcessMessages;
  if fShSett.chSheduleActive.Checked then
   begin
    TimersUp;
   end;
    end;
  finally
    FreeAndNil(fShSett);
    FreeAndNil(ListParam);
  end;
TrimWorkingSet;
end;

function Encrypt(const Value: string): string;
var
  I: Byte;
  Key: Word;
  ls: string;
begin
  Key := 1674;
  SetLength(ls, Length(Value));
  Result := '';
  for I := 1 to Length(Value) do
  begin
    ls[I] := Char(byte(Value[I]) xor (Key shr 8));
    Result := Result + IntToHex(byte(ls[I]), 2);
    Key := (byte(ls[I]) + Key) * C1 + C2;
  end;
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
CanClose:=false;
aExitExecute(self);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
GlobDay:=DayOfTheWeek(Now);
TimersList:=TList.Create;
  JvTrayIcon1.Hint := AppName;
  JvTrayIcon1.Active := True;
  Caption := AppName;
  fAppFolderName := GetLocalAppDataFolder(False) + '\SDT5';
  if not DirectoryExists(fAppFolderName) then
   CreateDir(fAppFolderName);
  tSettingFile := TSettingsFile.Create(fAppFolderName + '\config.cfg');
  sConn := tSettingFile.GetNoCrypt_sValue('Connection', 'sCon');
  InitializeCriticalSection(CS);
  if tSettingFile.GetBooleanValue('Connection', 'AuthType') = True then
    AuthType := True
  else
    AuthType := False;
  LoggedActive := tSettingFile.GetBooleanValue('Logged', 'Active');
  RunType := tSettingFile.GetBooleanValue('Sheduler', 'Active');
  case RunType of
    True:
      begin
       TimersUp;
      end;
  end;
  if not DirectoryExists(fAppFolderName) then
  begin
    CreateDir(fAppFolderName);
  end;
 fMain.PromptLogin:=false;
 WorkRoute:=false;
 WorkReference:=false;
 WorkDZ:=false;
 Timer1.Enabled:=true;
  ViewLog(3,'����� ���������','������ ��� ������� ��������');
end;

function TfMain.GetHours: Integer;
var
  s: string;
  h: Integer;
begin
  h := 0;
  s := TimeToStr(Time); //������� ����� � ������
  case Length(s) of
    7: begin
      h := StrToInt(s[1])
    end;
    8: begin
      h := StrToInt(s[1] + s[2]);
    end;
  end;
  Result := h;
end;

function TfMain.GetInterval(const Value: string): Integer;
begin
  Result := MinuteOf(StrToTime(Value));
end;

function TfMain.GetMinutes: Integer;
var
  s: string;
  h: Integer;
begin
  h := 0;
  s := TimeToStr(Time); //������� ����� � ������
  case Length(s) of
    7: begin
      if s[4] = ':' then
        h := StrToInt(s[4])
      else
        h := StrToInt(s[3] + s[4]);
    end;
    8: begin
      if s[5] = ':' then
        h := StrToInt(s[4])
      else
        h := StrToInt(s[4] + s[5]);
    end;
  end;
  Result := h;
end;

procedure TfMain.N10Click(Sender: TObject);
begin
  vLogList.Refresh;
end;

procedure TfMain.N11Click(Sender: TObject);
begin
  vLogList.Clear;
end;

procedure TfMain.N14Click(Sender: TObject);
begin
mData.ADOConn.LoginPrompt:=false;
mData.ADOConn.ConnectionString:=sConn;
mData.ADOConn.Connected:=true;
mData.ADOTable_refPriceType.Active:=true;
Form_PriceTable.Show;
end;

procedure TfMain.N17Click(Sender: TObject);
var
Descriptor:THandle;
begin
Descriptor := CreateMutex(nil, False, nil);
TAutoUpdatePrice.Create(false,tSettingFile.GetStringValue('Folders', 'LogFolder')+'\LogPriceEdit'+CurrentDateTimeToString+'.logs',sConn,'workot',Descriptor);
end;

procedure TfMain.N18Click(Sender: TObject);
begin
ShellExecute(Handle,'OPEN',pchar(tSettingfile.GetStringValue('Folders', 'LogFolder')),nil,pchar(tSettingfile.GetStringValue('Folders', 'LogFolder')),SW_NORMAL);
end;

procedure TfMain.N19Click(Sender: TObject);
var
Descriptor:THandle;
LogFile:string;
begin
Descriptor := CreateMutex(nil, False, nil);
LogFile:=tSettingFile.GetStringValue('Folders','LogFolder')+'\LogDZ'+CurrentDateTimeToString+'.logs';
PointWorkDZ:=TDZ.Create(false,LogFile,sConn,'workot',Descriptor,tSettingFile.GetStringValue('Folders', 'WorkFolder'));
WorkDZ:=true;
end;

procedure TfMain.N20Click(Sender: TObject);
var
Descriptor:THandle;
LogFile:string;
begin
Descriptor := CreateMutex(nil, False, nil);
LogFile:=tSettingFile.GetStringValue('Folders','LogFolder')+'\LogReturns'+CurrentDateTimeToString+'.logs';
PointWorkReturns:=TReturns.Create(false,LogFile,sConn,'workot',Descriptor,tSettingFile.GetStringValue('Folders', 'WorkFolder'));
WorkReturns:=true;
end;

procedure TfMain.Referencesxml1Click(Sender: TObject);
var
Descriptor:THandle;
LogFile:string;
begin
Descriptor := CreateMutex(nil, False, nil);
LogFile:=tSettingFile.GetStringValue('Folders','LogFolder')+'\LogReferences'+CurrentDateTimeToString+'.logs';
PointWorkReference:=THRegerences.Create(false,LogFile,sConn,'workot',Descriptor,tSettingFile.GetStringValue('Folders', 'WorkFolder'));
WorkReference:=true;
end;

procedure TfMain.ThreadsImportDone(Sender: TObject);
begin
  CloseHandle((Sender as thImport).FDescriptor);
end;

procedure TfMain.Timer1Timer(Sender: TObject);
begin
if GlobDay<>DayOfTheWeek(Now) then
begin
TimersDown;
while TimersList.Count>0 do
begin Application.ProcessMessages; end;
if RunType then
begin
 TimersUp;
end;
Application.ProcessMessages;
GlobDay:=DayOfTheWeek(Now);
TrimWorkingSet;
end;
end;

procedure TfMain.ThreadsExportDone(Sender: TObject);
begin
  CloseHandle((Sender as thExport).FDescriptor);
end;

procedure TfMain.ThreadsUpdatePriceDone(Sender: TObject);
begin
  CloseHandle((Sender as thExport).FDescriptor);
end;

procedure TfMain.ThreadsExpDataByRouteDone(Sender: TObject);
begin
  CloseHandle((Sender as ThExpDataByRoute).FDescriptor);
  WorkRoute:=false;
end;

procedure TfMain.ThreadsReferencesDone(Sender: TObject);
begin
  CloseHandle((Sender as THRegerences).FDescriptor);
  WorkReference:=false;
end;

procedure TfMain.ThreadsDZDone(Sender: TObject);
begin
  CloseHandle((Sender as TDZ).FDescriptor);
  WorkDZ:=false;
end;

procedure TfMain.ThreadsReturnsDone(Sender: TObject);
begin
  CloseHandle((Sender as TReturns).FDescriptor);
  WorkReturns:=false;
end;

procedure TfMain.ThreadsDocumentsDone(Sender: TObject);
begin
  CloseHandle((Sender as TExportDocument).FDescriptor);
  WorkDocuments:=false;
end;

procedure TfMain.ThreadsRestartServiceDone(Sender: TObject);
begin
  CloseHandle((Sender as ThRestartService).FDescriptor);
  WorkRestartService:=false;
end;

end.
