{
    Name: TExportObjectUnit
    Description: Класс обработки экспорта документов
    Create date: 17.08.2010
    Modify date:
    Version: 4.8.0.1

    Modify notes:

    17.08.2010 - Создан класс для обработки экспорта документов

}
unit TExportObjectsUnit;

interface

uses
  Classes, SysUtils, DB, ADODB, TBaseObject, JvSimpleXML, JclStreams;

type
  TExportObject = class;

  TExportObject = class(TBases)
  protected
    _FileLogParcer:       TJvSimpleXML;
    _DocParcer:           TJvSimpleXML;
    _FileLogNode:         TJvSimpleXMLElem;
    _FileLogDataNode:     TJvSimpleXMLElem;
    _DocumentHeadersNode: TJvSimpleXMLElem;
    _DocumentNode:        TJvSimpleXMLElem;
    _DocumentHeaderNode:  TJvSimpleXMLElem;
    _DocumentRowsNode:    TJvSimpleXMLElem;
    _DocumentItemNode:    TJvSimpleXMLElem;
    _DocumentRowNode:     TJvSimpleXMLElem;
    _HeaderDataSet:       TADODataSet;
    _RowsDataSet:         TADODataSet;
    _WorkPath:            string;
    _ScriptPath:          string;
    _ConnectionString:    string;
  private
    function GetFileName: string;
    function GetWorkPath: string;
    function GetConnection: TADOConnection;
    function ReadFromFile(FileName: string): string;
    procedure SetFileName(const Value: string);
    procedure SetWorkPath(const Value: string);
    procedure SetConnection(ADOConnection: TADOConnection);
    procedure SetConnectionString(Value: string);
  public
    property FileName: string read GetFileName write SetFileName;
    property WorkPath: string read GetWorkPath write SetWorkPath;
    property Connection: TADOConnection read GetConnection write SetConnection;
    property ConnectionString: string write SetConnectionString;
    procedure ExportData(Operation: boolean);
    constructor Create;
    destructor Destroy; override;
  end;

var
  AOwner: TComponent;

implementation

uses DataModuleUnit, FunctionsUnit;

{ TExportObject }

constructor TExportObject.Create;
begin
  inherited;
  Self._FileLogParcer := TJvSimpleXML.Create(AOwner);
  Self._DocParcer := TJvSimpleXML.Create(AOwner);
  Self._HeaderDataSet := TADODataSet.Create(AOwner);
  Self._HeaderDataSet.Connection := Self._Connection;
  Self._RowsDataSet := TADODataSet.Create(AOwner);
  Self._RowsDataSet.Connection := Self._Connection;
  Self._StoredProc := TADOStoredProc.Create(AOwner);
  Self._StoredProc.Connection := Self._Connection;
end;

destructor TExportObject.Destroy;
begin
  FreeAndNil(Self._RowsDataSet);
  FreeAndNil(Self._StoredProc);
  FreeAndNil(Self._DocParcer);
  FreeAndNil(Self._FileLogParcer);
  inherited Destroy;
end;

procedure TExportObject.ExportData(Operation: boolean);
var
  ResultValue, i, ii, hCode: Integer;
  sFileName: string;
  E:Error;
begin
  (* Импорт документов *)
  Self._DocumentHeadersNode := Self._DocParcer.Root.Items.Add('documents');
  try
  case Operation of
    (* Отгрузки товара *)
    False: begin
      Self.SetMessage('Экспорт', 'Отгрузки товара');
      Self._DocumentNode := Self._DocumentHeadersNode.Items.Add('invoices');
      try
        Self._StoredProc := mData.spDocuments;
          with Self._StoredProc do
          begin
            CommandTimeout := 900;
            Parameters.ParamValues['@op'] := 0;
            ExecProc;
            ResultValue := Parameters.ParamValues['@RETURN_VALUE'];
          end;
          if ResultValue = 0 then
          begin
            Self._HeaderDataSet := mData.dsDocHeaders;
            Self._RowsDataSet := mData.dsDocRows;
            Self._HeaderDataSet.Close;
            Self._HeaderDataSet.CommandText := 'SELECT * FROM [dbo].fn_GetHInv50();';
            Self._HeaderDataSet.Open;
            Self._HeaderDataSet.First;
            Self.SetMessage('Экспорт', 'Данные для экспорта подготовлены');
            Self.SetMessage('Экспорт', 'Начат процесс экспорта');
            while not Self._HeaderDataSet.Eof do
            begin
              Self._DocumentHeaderNode := Self._DocumentNode.Items.Add('invoice');
              for i := 0 to Self._HeaderDataSet.FieldCount - 1 do
              begin
                Self._DocumentHeaderNode.Items.Add(Self._HeaderDataSet.Fields[i].DisplayName, Self._HeaderDataSet.Fields[i].AsString);
              end;
              hCode := StrToInt(Copy(Self._HeaderDataSet.Fields[1].AsString, 3, Length(Self._HeaderDataSet.Fields[1].AsString) - 2));
              Self._DocumentRowsNode := Self._DocumentHeaderNode.Items.Add('body');
              with Self._RowsDataSet do
              begin
                Close;
                CommandText :='SELECT * FROM [dbo].fn_GetRInv50(' + IntToStr(hCode) + ')'; //Self.ReadFromFile(Self._ScriptPath + '\ExportRowsInvoices.sql');
              end;
              Self._RowsDataSet.Open;
              Self._RowsDataSet.First;
              while not Self._RowsDataSet.Eof do
              begin
                Self._DocumentRowNode := Self._DocumentRowsNode.Items.Add('item');
                for ii := 0 to Self._RowsDataSet.FieldCount - 1 do
                begin
                  Self._DocumentRowNode.Items.Add(Self._RowsDataSet.Fields[ii].DisplayName, Self._RowsDataSet.Fields[ii].AsString);
                end;
                Self._RowsDataSet.Next;
              end;
              Self._HeaderDataSet.Next;
            end;
          end;
        finally
          Self._StoredProc.Close;
          Self._HeaderDataSet.Close;
          Self._RowsDataSet.Close;
          Self.SetMessage('Экспорт', 'Экспорт данных завершен');
        end;
     end;
    (* Возвраты товара *)
    True: begin
      Self.SetMessage('Экспорт', 'Возвраты товара');
        Self._DocumentNode := Self._DocumentHeadersNode.Items.Add('skusReturns');
        try
          Self._StoredProc := mData.spDocuments;
          with Self._StoredProc do
          begin
            CommandTimeout := 600;
            Parameters.ParamValues['@op'] := 1;
            ExecProc;
            ResultValue := Parameters.ParamValues['@RETURN_VALUE'];
          end;
          if ResultValue = 0 then
          begin
            Self._HeaderDataSet := mData.dsDocHeaders;
            Self._RowsDataSet := mData.dsDocRows;
            Self._HeaderDataSet.Close;
            Self._HeaderDataSet.CommandText := 'SELECT * FROM [dbo].fn_GetHSRet50();';
            Self._HeaderDataSet.Open;
            Self._HeaderDataSet.First;
            Self.SetMessage('Экспорт', 'Данные для экспорта подготовлены');
            Self.SetMessage('Экспорт', 'Начат процесс экспорта');
            while not Self._HeaderDataSet.Eof do
            begin
              Self._DocumentHeaderNode := Self._DocumentNode.Items.Add('skusreturn');
              for i := 0 to Self._HeaderDataSet.FieldCount - 1 do
              begin
                Self._DocumentHeaderNode.Items.Add(Self._HeaderDataSet.Fields[i].DisplayName, Self._HeaderDataSet.Fields[i].AsString);
              end;
              hCode := StrToInt(Copy(Self._HeaderDataSet.Fields[1].AsString, 3, Length(Self._HeaderDataSet.Fields[1].AsString) - 2));
              Self._DocumentRowsNode := Self._DocumentHeaderNode.Items.Add('body');
              with Self._RowsDataSet do
            begin
              Close;
              CommandText := 'SELECT * FROM [dbo].fn_GetRSRet50(' + IntToStr(hCode) + ');';
            end;
              Self._RowsDataSet.Open;
              Self._RowsDataSet.First;
              while not Self._RowsDataSet.Eof do
              begin
                Self._DocumentRowNode := Self._DocumentRowsNode.Items.Add('item');
                for ii := 0 to Self._RowsDataSet.FieldCount - 1 do
                begin
                  Self._DocumentRowNode.Items.Add(Self._RowsDataSet.Fields[ii].DisplayName, Self._RowsDataSet.Fields[ii].AsString);
                end;
                Self._RowsDataSet.Next;
              end;
              Self._HeaderDataSet.Next;
            end;
          end;
        finally
          Self._StoredProc.Close;
          Self._HeaderDataSet.Close;
          Self._RowsDataSet.Close;
          Self.SetMessage('Экспорт', 'Экспорт данных завершен');
        end;
      end;
  end;
  sFileName := 'documents' + CurrentDateTimeToString;
  Self._DocParcer.SaveToFile(Self._WorkPath + '\client\' + sFilename + '.xml', seutf8, 65001);
  Self.SetMessage('Экспорт', 'Файл данных: ' + sFileName + '.xml');
  if FileExists(Self._WorkPath + '\filelog.xml') then
  begin
    Self._FileLogParcer.LoadFromFile(Self._WorkPath + '\filelog.xml');
    Self._FileLogDataNode := Self._FileLogParcer.Root.Items.ItemNamed['client'];
  end
  else
  begin
    Self._FileLogNode := Self._FileLogParcer.Root.Items.Add('filelog');
    Self._FileLogDataNode := Self._FileLogNode.Items.Add('client');
  end;
  Self._FileLogDataNode.Items.Add(sFileName);
  Self._FileLogDataNode.Items.ItemNamed[sFilename].Properties.Add('status', 'false');
  Self._FileLogParcer.SaveToFile(Self._WorkPath + '\filelog.xml', seutf8, 65001);
  except
   on E:Exception do
    Self.SetMessage('Экспорт', 'Произошла ошибка скорее всего, в БД нет данных или таблица блокированна, текст системы: '+e.Message);
 end;
end;

function TExportObject.GetConnection: TADOConnection;
begin
  Result := Self._Connection;
end;

function TExportObject.GetFileName: string;
begin
  Result := Self._FileName;
end;


function TExportObject.GetWorkPath: string;
begin
  Result := Self._WorkPath;
end;

function TExportObject.ReadFromFile(FileName: string): string;
begin
  with TStringList.Create do
  try
    LoadFromFile(FileName);
    Result := Text;
  finally
    Free;
  end;
end;

procedure TExportObject.SetConnection(ADOConnection: TADOConnection);
begin
  Self._Connection := ADOConnection;
end;

procedure TExportObject.SetConnectionString(Value: string);
begin
  Self._ConnectionString := Value;
end;

procedure TExportObject.SetFileName(const Value: string);
begin
  Self._FileName := Value;
end;


procedure TExportObject.SetWorkPath(const Value: string);
begin
  Self._WorkPath := Value;
end;

end.
