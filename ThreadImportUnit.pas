unit ThreadImportUnit;

interface

uses
  Windows, Classes, TConfirmationObjectsUnit, TImportObjectsUnit, SysUtils;

type
  thImport = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure ConnectedProcess;
    procedure DisconnectedProcess;
    procedure StartImportProcess;
    procedure EndImportProcess;
    procedure StartConfirmationProcess;
    procedure EndConfirmationProcess;
    destructor Destroy; override;
 public
   FDescriptor: THandle;
   constructor Create(CreateSuspennded:Boolean;Descriptor:THandle);
  end;

implementation

uses DataModuleUnit, ActiveX, TSettingsObjectUnit, FunctionsUnit, MainFormUnit;

{ thImport }

constructor thImport.Create(CreateSuspennded:Boolean;Descriptor:THandle);
begin
FDescriptor:=Descriptor;
inherited Create(CreateSuspennded);
end;

destructor thImport.Destroy;
begin
  inherited;
end;

procedure thImport.ConnectedProcess;
begin
  ViewLog(0, '������ ����������', ' ����������� � �������');
  fMain.aImportData.Enabled := False;
end;

procedure thImport.DisconnectedProcess;
begin
  ViewLog(1,'������ ����������', '�������� �� ������� ��');
    fMain.aImportData.Enabled := True;
end;

procedure thImport.EndConfirmationProcess;
begin
  ViewLog(3, '������ ����������', '��������� ������ ������������� ���������');
end;

procedure thImport.EndImportProcess;
begin
  ViewLog(3, '������ ����������', '������ ������� ��������');
end;

procedure thImport.Execute;
var
  cConfirmations: tConfirmationsFiles;
  cOrders: TImportObject;
  fFileLogName: string;
begin
  try
    FreeOnTerminate := True;
    EnterCriticalSection(CS);
    Sleep(1500);
    OnTerminate := fMain.ThreadsImportDone;
    CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    if WaitForSingleObject(FDescriptor, 1000) = WAIT_OBJECT_0 then
    begin
      (* ��������� ������ ������������� *)
      fFileLogName := tSettingfile.GetStringValue('Folders', 'LogFolder') + '\LogImport' + CurrentDateTimeToString +'.logs';
      cConfirmations := nil;
      cOrders := nil;
      try
        cConfirmations := tConfirmationsFiles.Create;
        cConfirmations.Connection := mData.Connection;
//        cConfirmations.StoredProc := mData.spConfirmation;//���������� �� � ������ ������
        cConfirmations.ConnectionString := tSettingFile.GetNoCrypt_sValue('Connection', 'sCon');
        cConfirmations.Connection.DefaultDatabase:='workot';
        cConfirmations.Connection.Connected := True;
        Synchronize(ConnectedProcess);
        if fMain.LoggedActive = True then
        begin
          cConfirmations.SetLogFileName(fFileLogName);
          cConfirmations.StartLogging;
        end;
        cConfirmations.WorkPath := tSettingFile.GetStringValue('Folders', 'WorkFolder');
        cConfirmations.FileName := cConfirmations.WorkPath +'\confirmationslog.xml';
        cConfirmations.SetMessage('������ ����������', '��������� ������ �������������');
        cConfirmations.StartParcings;
        Synchronize(StartConfirmationProcess);
      finally
        cConfirmations.SetMessage('������ ����������', '����� ������������ ����������');
        cConfirmations.StopLogging;
        Synchronize(EndConfirmationProcess);
        cConfirmations.Connection.Connected := False;
        Synchronize(DisconnectedProcess);
      end;
      try
        (* ��������� ������ ������� *)
        cOrders := TImportObject.Create;
        cOrders.Connection.Connected := False;
        cOrders.Connection.ConnectionString := tSettingFile.GetNoCrypt_sValue('Connection', 'sCon');
        cOrders.Connection.Connected := True;
        Synchronize(ConnectedProcess);
        if fmain.LoggedActive = True then
        begin
          cOrders.SetLogFileName(fFileLogName);
          cOrders.StartLogging;
        end;
        cOrders.SetMessage('������ ����������', '����� ������� ������� �������');
        cOrders.WorkPath := tSettingFile.GetStringValue('Folders', 'WorkFolder');
        cOrders.FileName := cOrders.WorkPath + '\filelog.xml';
        Synchronize(StartImportProcess);
        cOrders.StartParcings;
      finally
        cOrders.SetMessage('������ ����������','������� ������� ������� ��������');
        cOrders.StopLogging;
        Synchronize(EndImportProcess);
        cOrders.Connection.Connected := False;
        Synchronize(DisconnectedProcess);
      end;
    end;
  finally
   // FreeAndNil(cConfirmations);
    FreeAndNil(cOrders);
    CoUninitialize;
    ReleaseMutex(FDescriptor);
    Sleep(1000);
    LeaveCriticalSection(CS);
  end;
end;

procedure thImport.StartConfirmationProcess;
begin
  ViewLog(2, '������ ����������', '������ ��������� ������ �������������');
end;

procedure thImport.StartImportProcess;
begin
  ViewLog(2, '������ ����������', '����� ������ �������');
end;

end.
