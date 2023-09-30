{
    Name: TConfirmationObjectUnit
    Description: Класс обработки файлов подтверждений
    Create date: 17.08.2010
    Modify date:
    Version: 4.8.0.1

    Modify notes:

    17.08.2010 - Создан класс для обработки файлов подтверждений

}
unit TConfirmationObjectsUnit;

interface
uses
  Classes, JvSimpleXML, SysUtils, DB, ADODB, Dialogs, Forms, TBaseObject;

type
  TConfirmationsFiles = class;

  TConfirmationsFiles = class(TBases)
  protected
    _XMLParcer:             TJvSimpleXML;
    _ConfirmationDocParcer: TJvSimpleXML;
    _FileLogName:           string;
    _WorkPath:              string;
    _InnerCode:             string;
    _OuterCode:             string;
    _ConnectionString:      string;
  private
    function GetFileName: string;
    function GetWorkpath: string;
    Function GetConnection: TADOConnection;
    procedure SetFileName(const Value: string);
    procedure SetWorkPath(const Value: string);
    procedure SetConnection(ADOConnection: TADOConnection);
    procedure SetConnectionString(Value: string);
    procedure SetStoredProc(StoredProc: TADOStoredProc);
    procedure GetConfirmationLogData(AnXMLNode: TJvSimpleXMLElem);
    procedure ParsingConfirmDocumentFile(AnXMLNode: TJvSimpleXMLElem);
  public
    property FileName: string read GetFileName write SetFileName;
    property WorkPath: string read GetWorkPath write SetWorkPath;
    property Connection: TADOConnection read GetConnection write SetConnection;
    property ConnectionString: string write SetConnectionString;
    property StoredProc: TAdoStoredProc write SetStoredProc;
    procedure StartParcings; //запуск парсинга файлов
    function GetParcingInfo(Value: string): string;
    constructor Create;
    destructor Destroy; override;
  end;

var
  AOwner: TComponent;

implementation

{ TConfirmationsFiles }

constructor TConfirmationsFiles.Create;
begin
  inherited;
  _ConfirmationDocParcer := TJvSimpleXML.Create(AOwner);
  _XMLParcer := TJvSimpleXML.Create(AOwner);
  Self._StoredProc := TADOStoredProc.Create(AOwner);
  Self._StoredProc.Connection := Self._Connection;
end;

destructor TConfirmationsFiles.Destroy;
begin
  FreeAndNil(_ConfirmationDocParcer);
  FreeAndNil(_XmlParcer);
  FreeAndNil(Self._StoredProc);
  inherited Destroy;
end;

procedure TConfirmationsFiles.GetConfirmationLogData(
  AnXMLNode: TJvSimpleXMLElem);
var
  i, ii, index: Integer;
begin
  if AnXMLNode <> nil then
  begin
    if AnXMLNode.Name = 'chicago' then (* Проверка если ветка "chicago" *)
    begin
      for ii := 0 to AnXMLNode.Items.Count - 1 do  (* Кол-во узлов в ветке *)
      begin
        for index := 0 to AnXMlNode.Items[ii].Properties.Count - 1 do (* Перебор по атрибутам*)
        begin
          if AnXMLNode.Items[ii].Properties.Value('status', 'true') = 'false' then (* Файл не обработан *)
          begin
            (* Проверка наличия файла в заданном каталоге *)
            if FileExists(Self._WorkPath + '\confirmation\' + AnXMLNode.Items[ii].Name +'.xml') then
            begin
              (* При наличии файла - парсим его *)
              try
                Self.SetMessage('Обработка подтверждений', 'Файл: ' + AnXMLNode.Items[ii].Name + '.xml - в обработке.');
                Self._ConfirmationDocParcer.LoadFromFile(Self._WorkPath + '\confirmation\' + AnXMLNode.Items[ii].Name + '.xml');
                Self.ParsingConfirmDocumentFile(Self._ConfirmationDocParcer.Root);
              finally
                AnXMLNode.Items[ii].Properties.ItemNamed['status'].Value := 'true';
                Self._ConfirmationDocParcer.SaveToFile(Self._FileLogName);
                Self.SetMessage('Обработка подтверждений', 'Файл: '+ AnXMLNode.Items[ii].Name + '.xml - обработан.');
              end;
            end
            else
             Self.SetMessage('Обработка подтверждений', 'Файл: ' + AnXMLNode.Items[ii].Name + '.xml - не найден.');
          end
          else
            Self.SetMessage('Обработка подтверждений', 'Файл: '+ AnXMLNode.Items[ii].Name + '.xml - обработан ранее.');
        end;
      end; //for ii
    end; // AnXMLNode.Name = 'chicago'
  end;
  for i := 0 to AnXmlNode.Items.Count - 1 do Self.GetConfirmationLogData(AnXMLNode.Items[i]);
end;

function TConfirmationsFiles.GetConnection: TADOConnection;
begin
  Result := Self._Connection;
end;

function TConfirmationsFiles.GetFileName: string;
begin
  Result := Self._FileLogName;
end;

function TConfirmationsFiles.GetParcingInfo(Value: string): string;
begin
  Result := Value;
end;

function TConfirmationsFiles.GetWorkpath: string;
begin
  Result := Self._WorkPath;
end;

procedure TConfirmationsFiles.ParsingConfirmDocumentFile(
  AnXMLNode: TJvSimpleXMLElem);
var
  i: Integer;
begin
  if AnXMLNode <> nil then
  begin
    (* Обработка записей по документам *)
    if AnXMLNode.Name = 'confirmations' then
    begin
      if AnXMLNode.Name = 'doc' then
      begin
        if AnXMLNode.Name = 'chicagocode' then
          Self._InnerCode := AnXMLNode.Value;
        if AnXMLNode.Name = 'outercode' then
          Self._OuterCode := AnXmlNode.Value;
          (* Запись в БД  - расходные накладные*)
        if Copy(Self._OuterCode, 1, 1) = 'I' then
        begin
          try
            Self._Connection.Connected := True;
            try
              Self._Connection.BeginTrans;
              with Self._StoredProc do
              begin
                Close;
                Parameters.ParamByName('@op').Value := 0;
                Parameters.ParamByName('@InnerCode').Value := Self._InnerCode;
                Parameters.ParamByName('@DocNum').Value := StrToInt(Copy(Self._OuterCode, 3, Length(Self._OuterCode)-2));
                ExecProc;
              end;
              Self._Connection.CommitTrans;
            except
              Self._Connection.RollbackTrans;
            end;
          finally
            Self._StoredProc.Close;
            Self._Connection.Close;
          end;
        end;
        if Copy(Self._OuterCode, 1, 1) = 'R' then
        begin
          try
            Self._Connection.Connected := True;
            try
              Self._Connection.BeginTrans;
              with Self._StoredProc do
              begin
                Close;
                Parameters.ParamByName('@op').Value := 1;
                Parameters.ParamByName('@InnerCode').Value := Self._InnerCode;
                Parameters.ParamByName('@DocNum').Value := StrToInt(Copy(Self._OuterCode, 3, Length(Self._OuterCode)-2));
                ExecProc;
              end;
              Self._Connection.CommitTrans;
            except
              Self._Connection.RollbackTrans;
            end;
          finally
            Self._StoredProc.Close;
            Self._Connection.Close;
          end;
        end;
      end
      else (* Все остальное отсеиваем (подтверждение обработки справочников) *)
      begin
        Self.SetMessage('Обработка подтверждений', 'Подтверждение импорта справочников не обрабатываются');
        Exit;
      end;
    end;
  end;
  for i := 0 to AnXMLNode.Items.Count - 1 do ParsingConfirmDocumentFile(AnXMLNode.Items[i]);
end;

procedure TConfirmationsFiles.SetConnection(ADOConnection: TADOConnection);
begin
  Self._Connection := ADOConnection;
end;

procedure TConfirmationsFiles.SetConnectionString(Value: string);
begin
  Self._ConnectionString := Value;
end;

procedure TConfirmationsFiles.SetFileName(const Value: string);
begin
  Self._FileLogName := Value;
end;

procedure TConfirmationsFiles.SetStoredProc(StoredProc: TADOStoredProc);
begin
  Self._StoredProc := StoredProc;
end;

procedure TConfirmationsFiles.SetWorkPath(const Value: string);
begin
  Self._WorkPath := Value;
end;

procedure TConfirmationsFiles.StartParcings;
begin
  if FileExists(Self._FileLogName) then
  begin
    try
      Self.SetMessage('Обработка подтверждений', 'Начата обработка подтверждений');
      Self._XMLParcer.LoadFromFile(Self._FileLogName);
      Self.GetConfirmationLogData(Self._XMLParcer.Root);
    finally
      Self._XMLParcer.SaveToFile(Self._FileLogName);
      Self.SetMessage('Обработка подтверждений', 'Обработка файлов подтверждений завершена');
    end;
  end;
end;

end.
