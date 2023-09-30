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
  ViewLog(0, 'Импорт документов', ' Подключение к серверу');
  fMain.aImportData.Enabled := False;
end;

procedure thImport.DisconnectedProcess;
begin
  ViewLog(1,'Импорт документов', 'Отключен от сервера БД');
    fMain.aImportData.Enabled := True;
end;

procedure thImport.EndConfirmationProcess;
begin
  ViewLog(3, 'Импорт документов', 'Обработка файлов подтверждений завершена');
end;

procedure thImport.EndImportProcess;
begin
  ViewLog(3, 'Импорт документов', 'Импорт заказов завершен');
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
      (* Обработка файлов подтверждений *)
      fFileLogName := tSettingfile.GetStringValue('Folders', 'LogFolder') + '\LogImport' + CurrentDateTimeToString +'.logs';
      cConfirmations := nil;
      cOrders := nil;
      try
        cConfirmations := tConfirmationsFiles.Create;
        cConfirmations.Connection := mData.Connection;
//        cConfirmations.StoredProc := mData.spConfirmation;//Присвоение ХП в модуле данных
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
        cConfirmations.SetMessage('Импорт документов', 'Обработка файлов подтверждений');
        cConfirmations.StartParcings;
        Synchronize(StartConfirmationProcess);
      finally
        cConfirmations.SetMessage('Импорт документов', 'Файлы подтерждений обработаны');
        cConfirmations.StopLogging;
        Synchronize(EndConfirmationProcess);
        cConfirmations.Connection.Connected := False;
        Synchronize(DisconnectedProcess);
      end;
      try
        (* Обработка файлов заказов *)
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
        cOrders.SetMessage('Импорт документов', 'Начат процесс импорта заказов');
        cOrders.WorkPath := tSettingFile.GetStringValue('Folders', 'WorkFolder');
        cOrders.FileName := cOrders.WorkPath + '\filelog.xml';
        Synchronize(StartImportProcess);
        cOrders.StartParcings;
      finally
        cOrders.SetMessage('Импорт документов','Процесс импорта заказов завершен');
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
  ViewLog(2, 'Импорт документов', 'Начата обработка файлов подтверждений');
end;

procedure thImport.StartImportProcess;
begin
  ViewLog(2, 'Импорт документов', 'Начат импорт заказов');
end;

end.
