unit ThreadExportUnit;

interface

uses
  Windows, Forms, Classes, sysutils, TExportObjectsUnit;

type
  thExport = class(TThread)
  private
    { Private declarations }
  var
   FExportType:boolean;
  protected
    procedure Execute; override;
    procedure ConnectedProcess;
    procedure DisconnectedProcess;
    procedure StartExportProcess;
    procedure EndExportProcess;
    destructor Destroy; override;
 public
   FDescriptor: THandle;
   constructor Create(CreateSuspennded,ExportType:Boolean;Descriptor:THandle);
  end;

implementation

uses DataModuleUnit, ActiveX, TSettingsObjectUnit, FunctionsUnit, MainFormUnit;

{ thExport }

constructor thExport.Create(CreateSuspennded,ExportType:Boolean;Descriptor:THandle);
begin
FExportType:=ExportType;
FDescriptor:=Descriptor;
inherited Create(CreateSuspennded);
end;

destructor thExport.Destroy;
begin
  inherited;
end;

procedure thExport.ConnectedProcess;
begin
  ViewLog(0, 'Експорт документов', ' Подключение к серверу');
  fMain.mMenu.Items.Enabled := False;
end;

procedure thExport.DisconnectedProcess;
begin
  ViewLog(1,'Експорт документов', 'Отключен от сервера БД');
  fMain.mMenu.Items.Enabled := True;
end;

procedure thExport.EndExportProcess;
begin
  ViewLog(3, 'Експорт документов', 'Экспорт документов завершен');
end;

procedure thExport.Execute;
var
  fFileLogName: string;
  cDocuments: TExportObject;
begin
  try
    FreeOnTerminate := True;
    EnterCriticalSection(CS);
    OnTerminate := fMain.ThreadsExportDone;
    CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    if WaitForSingleObject(FDescriptor, 1000) = WAIT_OBJECT_0 then
    begin
      fFileLogName := tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogExport' + CurrentDateTimeToString +'.logs';
      cDocuments := nil;
      try
        cDocuments := TExportObject.Create;
        cDocuments.Connection.Connected := False;
        cDocuments.Connection := mData.Connection;
        cDocuments.ConnectionString := tSettingFile.GetNoCrypt_sValue('Connection', 'sCon');
        cDocuments.Connection.Connected := True;
        Synchronize(ConnectedProcess);
        if fMain.LoggedActive = True then
        begin
          cDocuments.SetLogFileName(fFileLogName);
          cDocuments.StartLogging;
        end;
        if FExportType = False then
          cDocuments.SetMessage('Експорт документов', 'Начат процесс экспорта данных по отгрузкам')
        else
          cDocuments.SetMessage('Експорт документов', 'Начат процесс экспорта данных по возвратам');
        cDocuments.WorkPath := tSettingFile.GetStringValue('Folders', 'WorkFolder');
        Synchronize(StartExportProcess);
        cDocuments.ExportData(FExportType);
      finally
        if FExportType = False then
          cDocuments.SetMessage('Експорт документов', 'Процесс экспорта данных по отгрузкам завершен')
        else
          cDocuments.SetMessage('Експорт документов', 'Процесс экспорта данных по возвратам завершен');
        cDocuments.StopLogging;
        Synchronize(EndExportProcess);
        cDocuments.Connection.Connected := False;
        Synchronize(DisconnectedProcess);
      end;
    end;
  finally
    //FreeAndNil(cDocuments);
    CoUninitialize;
    ReleaseMutex(FDescriptor);
    LeaveCriticalSection(CS);
  end;
end;

procedure thExport.StartExportProcess;
begin
  ViewLog(2, 'Експорт документов', 'Начат экспорт документов');
end;

end.
