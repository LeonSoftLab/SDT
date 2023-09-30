unit TExportDocumentsUnit;

interface

uses classes, windows, sysutils, Variants, ADODB, JvSimpleXML, JclStreams;

type
  TExportDocument = class(TThread)
  public
    constructor Create(CreateSuspennded, ExpType: Boolean; LogFile, sConn,
      DataBase, ExpPath: string; Descriptor: THandle);
    destructor Destroy; override;
    procedure Execute; override;

  var
    Fstop: Boolean;
    FileNameLog: string;
    ConnectString: string;
    DataBaseName: string;
    ExportPath: string;
    ExportType: Boolean;
    FDescriptor: THandle;
    _FileLogParcer: TJvSimpleXML;
    _FileLogDataNode:TJvSimpleXMLElem;
    _FileLogNode:TJvSimpleXMLElem;
    ADOConnect: TADOConnection;
    TADOStoredProc_UpdateDataDocumentsToBD: TADOStoredProc;
    ADOQuery_SaveDocumentsToXML: TADOQuery;
  end;

var
  AOwner: TComponent;

implementation

uses MainFormUnit, FunctionsUnit, ActiveX, DataModuleUnit, ConstUnit;

constructor TExportDocument.Create(CreateSuspennded, ExpType: Boolean;
  LogFile, sConn, DataBase, ExpPath: string; Descriptor: THandle);
begin
  FileNameLog := LogFile;
  ConnectString := sConn;
  DataBaseName := DataBase;
  FDescriptor := Descriptor;
  ExportPath := ExpPath;
  ExportType := ExpType;
  inherited Create(CreateSuspennded);
end;

destructor TExportDocument.Destroy;
begin
  inherited;
end;

procedure TExportDocument.Execute;
var
  i, i1: integer;
  E: Error;
  f: textfile;
  filenames: string;
begin

  if ExportType = false then
  begin
    try
      try
        AssignFile(f, FileNameLog);
        Rewrite(f);
        Writeln(f, timetostr(time) +
            ' =====> СТАРТ формирования документов по отгрузкам ...');
        FreeOnTerminate := true;
        OnTerminate := fMain.ThreadsDocumentsDone;
        EnterCriticalSection(CS);
        Writeln(f, timetostr(time) +
            ' занимаем критическую секцию основного приложения');
        CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
        Writeln(f, timetostr(time) + ' инициализация апартамент COM-сервера');
        ViewLog(3, 'Експорт отгрузок', 'Старт формирования документов из УС.');

        ADOConnect := TADOConnection.Create(AOwner);
        ADOConnect.ConnectionString := ConnectString;
        ADOConnect.DefaultDatabase := DataBaseName;
        ADOConnect.CursorLocation := clUseServer;
        ADOConnect.CommandTimeout := 1800;

        TADOStoredProc_UpdateDataDocumentsToBD := TADOStoredProc.Create(AOwner);
        TADOStoredProc_UpdateDataDocumentsToBD.Connection := ADOConnect;
        TADOStoredProc_UpdateDataDocumentsToBD.ProcedureName :=
          mData.spDocuments.ProcedureName;
        TADOStoredProc_UpdateDataDocumentsToBD.Parameters :=
          mData.spDocuments.Parameters;
        TADOStoredProc_UpdateDataDocumentsToBD.CursorLocation := clUseServer;
        TADOStoredProc_UpdateDataDocumentsToBD.CommandTimeout := 900;

        _FileLogParcer:=TJvSimpleXML.Create(AOwner);

        ADOQuery_SaveDocumentsToXML := TADOQuery.Create(AOwner);
        filenames := 'documents' + CurrentDateTimeToString;
        ADOQuery_SaveDocumentsToXML.SQL.Text := ' USE [workot] ' +
          ' DECLARE @result int '+
          ' DECLARE @cmd varchar(150) ' + ' DECLARE @DD datetime ' +
          ' DECLARE @NameDoc nvarchar(50) ' +
          ' DECLARE @WorkPath nvarchar(150) ' + ' SET @WorkPath = ''' +
          ExportPath + '\client\''' + ' SET @NameDoc = ''' + filenames + '.xml''' +
          ' SET @cmd = ''BCP "EXEC [workot].[dbo].spExportDocuments50" queryout "'' + @WorkPath+@NameDoc + ''" -N -C OEM -w -r -t -T''' + ' EXEC @result = master..xp_cmdshell @cmd';
        ADOQuery_SaveDocumentsToXML.Connection := ADOConnect;
        ADOQuery_SaveDocumentsToXML.CursorLocation := clUseServer;
        ADOQuery_SaveDocumentsToXML.CommandTimeout := 600;
        Writeln(f, timetostr(time) +
            ' компоненты для работы с БД созданы и настроены');
        if Fstop then
          Terminate;

        ADOConnect.LoginPrompt := false;
        ADOConnect.Connected := true;
        ViewLog(0, 'Експорт отгрузок', 'Подключение активно');
        Writeln(f, timetostr(time) + ' подключение активированно');
        try
          Writeln(f, timetostr(time) + ' ------------------ >>');
          Writeln(f, timetostr(time) +
              ' приступаю к обновлению данных выполняя [workot].[dbo].spExportDocuments50; ...');
          ViewLog(2, 'Експорт отгрузок', 'Обновляю данные по отгрузкам ...');

          Self.TADOStoredProc_UpdateDataDocumentsToBD.ExecProc;

          Writeln(f, timetostr(time) + '    OLEDBPROVIDER :');
          for i1 := 0 to ADOConnect.Errors.Count - 1 do
            Writeln(f, timetostr(time) + ' ###' + Self.ADOConnect.Errors.Item[i1]
                .Description);
          Writeln(f, timetostr(time) +
              ' Обновление данных в БД workot по фактическим отгрузкам из УС.');
          Writeln(f, timetostr(time) + ' <<------------------');
          if Fstop then
            Terminate;
          Writeln(f, timetostr(time) + ' ------------------ >>');
          Writeln(f, timetostr(time) + ' Приступаю к выгрузке данных в файл ' +
              ExportPath + '\client\' + filenames + '.xml   ...');
          ViewLog(2, 'Експорт отгрузок',
            'Начинаю выгрузку документов в файл' + Self.ExportPath + '\client\' + filenames +
              '.xml   ...');
          ADOQuery_SaveDocumentsToXML.Close;
          ADOQuery_SaveDocumentsToXML.ExecSQL;
          Writeln(f, timetostr(time) + '    OLEDBPROVIDER :');
          for i1 := 0 to ADOConnect.Errors.Count - 1 do
            Writeln(f, timetostr(time) + ' ###' + ADOConnect.Errors.Item[i1]
                .Description);
          Writeln(f, timetostr(time) + ' Данные выгружены в файл.');
          Writeln(f, timetostr(time) + ' <<------------------');



  if FileExists(ExportPath + '\filelog.xml') then
  begin
    Self._FileLogParcer.LoadFromFile(ExportPath + '\filelog.xml');
    Self._FileLogDataNode := Self._FileLogParcer.Root.Items.ItemNamed['client'];
  end
  else
  begin
    Self._FileLogNode := Self._FileLogParcer.Root.Items.Add('filelog');
    Self._FileLogDataNode := Self._FileLogNode.Items.Add('client');
  end;
  Self._FileLogDataNode.Items.Add(filenames);
  Self._FileLogDataNode.Items.ItemNamed[filenames].Properties.Add('status', 'false');
  Self._FileLogParcer.SaveToFile(ExportPath + '\filelog.xml', seutf8, 65001);



        except
          on E: exception do
          begin
            Writeln(f, timetostr(time) + ' ===> ОШИБКА при формировании');
            Writeln(f, timetostr(time) + E.Message);
            ViewLog(3, 'Експорт отгрузок', 'Ошибка формирования ...');
          end;
        end;
      except
        on E: exception do
        begin
          Writeln(f, timetostr(time) + ' ===> ОШИБКА подготовки ...');
          ViewLog(3, 'Експорт отгрузок', 'Ошибка подготовки ...');
        end;
      end;
    finally
      ADOConnect.Connected := false;
      ViewLog(1, 'Експорт отгрузок', 'Отсоединение');
      Writeln(f, timetostr(time) + ' подключение деактивированно');
      FreeAndNil(_FileLogParcer);
      FreeAndNil(ADOQuery_SaveDocumentsToXML);
      FreeAndNil(TADOStoredProc_UpdateDataDocumentsToBD);
      FreeAndNil(ADOConnect);
      Writeln(f, timetostr(time) + ' освободили занимаемую память.');
      CoUninitialize;
      Writeln(f, timetostr(time) + ' деинициалицая аппартамент СОМ-сервера.');
      ReleaseMutex(FDescriptor);
      LeaveCriticalSection(CS);
      Writeln(f, timetostr(time) + ' критическая секция освобождена.');
      Writeln(f, timetostr(time) + ' ===> Формирование завершено.');
      ViewLog(3, 'Експорт отгрузок', 'Формирование завершено.');
      CloseFile(f);
    end;
  end;

  //
  if ExportType = true then
  begin

  end;
end;

end.
