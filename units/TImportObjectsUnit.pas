{
    Name: TImportObjectUnit
    Description: Класс импорта документов
    Create date: 17.08.2010
    Modify date:
    Version: 4.8.0.1

    Modify notes:

    17.08.2010 - Создан класс импорта документов

}
unit TImportObjectsUnit;

interface

uses
  Classes, DB, ADODB, SysUtils, StrUtils, Variants, JvSimpleXML, JclStreams,
  TBaseObject, DateUtils, JvLogFile, Messages, Windows,Dialogs,TypInfo,MainFormUnit;

type
 TSKURow = record
  SkuCode : integer;
  UnitCode : integer;
  UnitFactor : Double;
  Quantity : Double;
  Price : Double;
  PriceDiscount : Double;
  PriceTypeCode : Double;
  DiscountAmount : Double;
  Amount : Double;
  VatRate : Double;
  VatAmount : Double;
  RecommendedQuantity : Double;
  ReservedQuantity : Double;
 end;
type
 TErrRow = record
  ErrorTitle:            string;
  ErrorMsg:              string;
 end;

type
  TImportObject = class(TObject)
  protected
    _Connection:                TADOConnection;
    _StoredProcHead:            TADOStoredProc;
    _StoredProcRow:             TADOStoredProc;
    _StoredProcCheck:           TADOStoredProc;
    _CommandInsertMessage:      TADOCommand;
    _LogFile:                   TJvLogFile;
    _Size:                      integer;
    _FileLogParcer:             TJvSimpleXML;
    _DocParcer:                 TJvSimpleXML;
    _ConfirmationLogParcer:     TJvSimpleXML;
    _ConfirmationDocParcer:     TJvSimpleXML;
    _ConfirmationLogNode:       TJvSimpleXMLElem;
    _ConfirmationLogDataNode:   TJvSimpleXMLElem;
    _ConfirmationDocNode:       TJvSimpleXMLElem;
    _ConfirmationDocsNode:      TJvSimpleXMLElem;
    _ConfirmationDocDataNode:   TJvSimpleXMLElem;
    _DataSet:                   TADODataSet;
    _EnableLog:                 Boolean;
    _ErrorCode:                 Integer;
    _ReturnCode:                Integer;
    _CurrentRow:                Integer;
    _CurrentRezRow:             Integer;
    _CreatorCode:               Integer;
    _Delete:                    Integer;
    _FirmCode:                  Integer;
    _RouteCode:                 Integer;
    _EmployeeCode:              Integer;
    _BuyerCode:                 Integer;
    _CAgentCode:                Integer;
    _DeliveryRouteCode:         Integer;
    _CurrencyCode:              Integer;
    _bw:                        Integer;
    _PayTypeCode:               Integer;
    _UseVatRate:                Integer;
    _IncludeVat:                Integer;
    _FormCode:                  Integer; //<usevat - False (2я-форма); True (1я форма)>
    _PDARouteCode:              Integer;
    _StoreCode:                 Integer;
    _PDADocNum:                 Integer;
    _RegNo:                     Integer;
    _RegDocNo:                  Integer;
    _CurrentStore:              Integer;
    _ReservedStore:             Integer;
    _RowNum:                    Integer;
    _ReservedRowNum:            Integer;
    _SkuCode:                   Integer;
    _UnitCode:                  Integer;
    _PriceTypeCode:             Integer;
    _DiscountRate:              Double;
    _UnitFactor:                Double;
    _Quantity:                  Double;
    _Price:                     Double;
    _PriceDiscount:             Double;
    _DiscountAmount:            Double;
    _Amount:                    Double;
    _VatRate:                   Double;
    _VatAmount:                 Double;
    _RecommendedQuantity:       Double;
    _ReservedQuantity:          Double;
    _FileName:                  string;
    _Message:                   string;
    _sFileName:                 string;
    _WorkPath:                  string;
    _FileLogName:               string;
    _InnerCode:                 string;
    _outercode:                 string;
    _ParentInnerCode:           string;
    _Date:                      string;
    _DocNo:                     string;
    _EmployeeName:              string;
    _EmployeeLastName:          string;
    _EmployeeFirstname:         string;
    _EmployeeMiddleName:        string;
    _BuyPointCode:              string;
    _BuypointJurName:           string;
    _BuypointAddress:           string;
    _Comment:                   string;
    _DeliveryDate:              string;
    _DeliveryTimeTo:            string;
    _DeliveryTimeFrom:          string;
    _CreateDate:                string;
    _ListSKUNullRemain: array of TSKURow;
    _ListSKUAction:     array of TSKURow;
    _ListErrMsg:        array of TErrRow;
  private
    function GetFileName: string;
    function GetWorkPath: string;
    function StrReplace(const Str, Str1, Str2: string): string;
    procedure SetFileName(const Value: string);
    procedure SetWorkPath(const Value: string);
    procedure GetXMLFileLogData(AnXMLNode: TJvSimpleXMLElem);
    procedure ParsingDocumentFile(AnXMLNode: TJvSimpleXMLElem);
    procedure ParsingDocumentRows(AnXMLNode: TJvSimpleXMLElem);
    procedure ProcessListSKUNullRemain;
    procedure ProcessListSKUAction;
    procedure ProcessListErrMsg;
    procedure SetDefaultHeaderValues;
    procedure SetDefaultRowsValues;
    function GetConnectionError:string;
  public
    procedure StartLogging;
    procedure StopLogging;
    procedure SetMessage(const Title, Msg: string);
    procedure SetLogFileName(const Value: string);
    procedure SetTypeLogged(const Value: boolean);
    property FileName: string read GetFileName write SetFileName;
    property WorkPath: string read GetWorkPath write SetWorkPath;
    property Connection: TADOConnection read _Connection write _Connection;
    procedure StartParcings; //запуск парсинга файлов
    constructor Create;
    destructor Destroy; override;
  end;

const
 _const_ExistsOrders = 'SELECT [dbo].fn_ExistsDocument(:InnerCode, :ParentInnerCode, :DocNum)';
 _const_OrderComplete = 'SELECT [dbo].fn_CompleteDocument( :InnerCode , :Op)';

var
  AOwner: TComponent;

implementation

uses FunctionsUnit, DataModuleUnit;

{ TImportObject }

constructor TImportObject.Create;
begin
  inherited;
  Self._FileLogParcer := TJvSimpleXML.Create(AOwner);
  Self._DocParcer := TJvSimpleXML.Create(AOwner);
  Self._ConfirmationLogParcer := TJvSimpleXML.Create(AOwner);
  Self._ConfirmationDocParcer := TJvSimpleXML.Create(AOwner);
  Self._Connection := TADOConnection.Create(AOwner);
  Self._Connection.LoginPrompt:=False;
  Self._Connection.ConnectionTimeout := mData.Connection.ConnectionTimeout;
  Self._Connection.CommandTimeout := mData.Connection.CommandTimeout;
  Self._Connection.ConnectionString := mData.Connection.ConnectionString;
  try
   Self._Connection.Connected := True;
  except

  end;
  Self._DataSet := TADODataSet.Create(AOwner);
  Self._DataSet.Connection := Self._Connection;
  Self._DataSet.CommandTimeout := 180;

  Self._StoredProcHead := TADOStoredProc.Create(AOwner);
  Self._StoredProcHead.Connection := Self._Connection;
  Self._StoredProcHead.CommandTimeout := 180;
  Self._StoredProcHead.ProcedureName := 'dbo.wrkHeaderDocument;1';
  Self._StoredProcHead.Parameters.Clear;
  Self._StoredProcHead.Parameters.Refresh;

  Self._StoredProcCheck := TADOStoredProc.Create(AOwner);
  Self._StoredProcCheck.Connection := Self._Connection;
  Self._StoredProcCheck.CommandTimeout := 180;
  Self._StoredProcCheck.ProcedureName := 'dbo.wrkGetReservedActionSKU;1';
  Self._StoredProcCheck.Parameters.Clear;
  Self._StoredProcCheck.Parameters.Refresh;

  Self._StoredProcRow := TADOStoredProc.Create(AOwner);
  Self._StoredProcRow.Connection := Self._Connection;
  Self._StoredProcRow.CommandTimeout := 180;
  Self._StoredProcRow.ProcedureName := 'dbo.wrkRowsDocument;1';
  Self._StoredProcRow.Parameters.Clear;
  Self._StoredProcRow.Parameters.Refresh;

  Self._CommandInsertMessage := TADOCommand.Create(AOwner);
  Self._CommandInsertMessage.Connection := Self._Connection;
  Self._CommandInsertMessage.CommandText := 'INSERT INTO [dbo].[DocJournalMessages] ([idChicago] ,[idOT] ,[Message]) VALUES ( :idChicago , :idOT , :Message )';
  try
   Self._CommandInsertMessage.Parameters.ParseSQL(Self._CommandInsertMessage.CommandText,True);
   Self._CommandInsertMessage.Parameters.ParamByName('idChicago').DataType:=ftLargeint;
   Self._CommandInsertMessage.Parameters.ParamByName('idOT').DataType:=ftInteger;
   Self._CommandInsertMessage.Parameters.ParamByName('Message').DataType:=ftString;
  except

  end;
  _LogFile := TJvLogFile.Create(AOwner);
  _LogFile.Active := True;
  _LogFile.AutoSave := True;
end;

destructor TImportObject.Destroy;
begin
  Self._LogFile.SaveToFile(Self._FileName);
  FreeAndNil(Self._DataSet);
  FreeAndNil(Self._StoredProcHead);
  FreeAndNil(Self._StoredProcCheck);
  FreeAndNil(Self._StoredProcRow);
  FreeAndNil(Self._CommandInsertMessage);
  FreeAndNil(Self._Connection);
  FreeAndNil(Self._DocParcer);
  FreeAndNil(Self._FileLogParcer);
  FreeAndNil(Self._ConfirmationDocParcer);
  FreeAndNil(Self._ConfirmationLogParcer);
  FreeAndNil(Self._LogFile);
  inherited Destroy;
end;


function TImportObject.GetConnectionError:string;
var
  i: Integer;
begin
Result:='ND*';
  for i := 0 to Self._Connection.Errors.Count - 1 do
  begin
    if i = 0 then
    begin
      Self.SetMessage('Ошибка', 'Документ: ' + Self._DocNo + ' обработан с ошибкой');
    end;
    case Self._Connection.Errors[i].NativeError of
      3609: begin
         if Pos(pchar('Лимит дебиторской задолженности'),Self._Connection.Errors[i].Description)<>0 then
          Result:='DZ*';
         if Pos(pchar('Просроченная дебиторская задолженность'),Self._Connection.Errors[i].Description)<>0 then
          Result:='PDZ*';
         if Pos(pchar('Отсутствует договор для данного предприятия'),Self._Connection.Errors[i].Description)<>0 then
          Result:='DG*';
        Self.SetMessage('Ошибка импорта', 'Причина: 3609 -' + Self._Connection.Errors[i].Description);
      end;
       50000: begin
         if Pos(pchar('Лимит дебиторской задолженности'),Self._Connection.Errors[i].Description)<>0 then
          Result:='DZ*';
         if Pos(pchar('Просроченная дебиторская задолженность'),Self._Connection.Errors[i].Description)<>0 then
          Result:='PDZ*';
         if Pos(pchar('Отсутствует договор для данного предприятия'),Self._Connection.Errors[i].Description)<>0 then
          Result:='DG*';
         Self.SetMessage('Ошибка импорта', 'Причина: 50000 -' + Self._Connection.Errors[i].Description);
      end;
       30001: begin   (*Завал по триггеру дебиторки*)
         if Pos(pchar('Лимит дебиторской задолженности'),Self._Connection.Errors[i].Description)<>0 then
          Result:='DZ*';
         if Pos(pchar('Просроченная дебиторская задолженность'),Self._Connection.Errors[i].Description)<>0 then
          Result:='PDZ*';
         if Pos(pchar('Отсутствует договор для данного предприятия'),Self._Connection.Errors[i].Description)<>0 then
          Result:='DG*';
        Self.SetMessage('Ошибка импорта', 'Причина: 30001 -' + Self._Connection.Errors[i].Description);
      end
      else
      begin
        Self.SetMessage('Ошибка импорта','Причина:' + Self._Connection.Errors[i].Description);
      end;
    end;
  end;
  Self._Connection.Errors.Clear;
end;

function TImportObject.GetFileName: string;
begin
  Result := Self._FileLogName;
end;

function TImportObject.GetWorkPath: string;
begin
  Result := Self._WorkPath;
end;
(* Парсинг filelog.xml и запуск обработки заказов *)
procedure TImportObject.GetXMLFileLogData(AnXMLNode: TJvSimpleXMLElem);
var
  i, ii, index: Integer;
begin
  if AnXMLNode <> nil then
  begin
    for ii := 0 to AnXMLNode.Items.Count - 1 do  (* Кол-во узлов в ветке *)
    begin
      for index := 0 to AnXMlNode.Items[ii].Properties.Count - 1 do (* Перебор по атрибутам*)
      begin
        if AnXMLNode.Items[ii].Properties.Value('status', 'true') = 'false' then (* Файл не обработан *)
        begin
          (* Проверка наличия файла в заданном каталоге *)
          if FileExists(Self._WorkPath + '\chicago\' + AnXMLNode.Items[ii].Name +'.xml') then
          begin
            try
              Self.SetMessage('Обработка заказов', 'Файл: ' + AnXMLNode.Items[ii].Name + '.xml - в обработке.');
              Self._DocParcer.LoadFromFile(Self._WorkPath + '\chicago\' + AnXMLNode.Items[ii].Name + '.xml');
              Self.ParsingDocumentFile(Self._DocParcer.Root);
            finally
              AnXMLNode.Items[ii].Properties.ItemNamed['status'].Value := 'true';
              Self._FileLogParcer.SaveToFile(Self._FileLogName);
              Self.SetMessage('Обработка заказов', 'Файл: '+ AnXMLNode.Items[ii].Name + '.xml - обработан.');
            end;
          end
          else
            Self.SetMessage('Обработка заказов', 'Файл: ' + AnXMLNode.Items[ii].Name + '.xml - не найден.');
        end
        else
          Self.SetMessage('Обработка заказов', 'Файл: '+ AnXMLNode.Items[ii].Name + '.xml - обработан ранее.');
      end;
    end;
  end;
  for i := 0 to AnXMLNode.Items.Count - 1 do GetXMLFileLogData(AnXMLNode.Items[i]);
end;

procedure TImportObject.ParsingDocumentFile(AnXMLNode: TJvSimpleXMLElem);
var
  i, ii: Integer;
  DocCount: Integer;
  s,tmpErr:string;
  Settings: TFormatSettings;
  idx:integer;
begin
  Settings.DateSeparator := '-';
  Settings.ShortDateFormat := 'yyyy-mm-dd';
  (* Парсинг документа *)
  if AnXMLNode <> nil then
  begin
    if AnXMLNode.Name = 'preorder' then //пакет заказов
    begin
      //DocCount := -1;
      Self.SetDefaultHeaderValues;
      for ii := 0 to AnXMLNode.Items.Count - 1 do
      begin
        if AnXMLNode.Items[ii].Name = 'innercode' then
        begin
          Self._InnerCode := AnXMLNode.Items[ii].Value;
          Self.SetMessage('Импорт', 'В обработке заказ: ' + Self._InnerCode);
        end;
        if AnXMLNode.Items[ii].Name = 'innerparentcode' then
        begin
          if AnXMLNode.Items[ii].Value<>'' then
           begin
            Self._ParentInnerCode := AnXMLNode.Items[ii].Value;
            if (Self._InnerCode<>'') and (Self._ParentInnerCode<>'0') then
            Self.SetMessage('Импорт', 'Заказ: ' + Self._InnerCode+ ' является измененным заказом: '+Self._ParentInnerCode);
           end;
        end;
        if AnXMLNode.Items[ii].Name = 'date' then
        begin
          if StrToDate(Copy(AnXMLNode.Items[ii].Value, 1, 10),Settings)+_const_OffSet <= Date then
            Self._Date := FormatDateTime('yyyy.mm.dd', Date)
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Дата документа больше текущей - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'EDT*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'docno' then Self._DocNo := Trim(AnXMLNode.Items[ii].Value);
        if AnXMLNode.Items[ii].Name = 'creatorcode' then
        begin
          if (PosEx('*', AnXMLNode.Items[ii].Value, 1) = 0) and (trim(AnXMLNode.Items[ii].Value)<>'') and (AnXMLNode.Items[ii].Value <> null) then
            Self._CreatorCode := AnXMLNode.Items[ii].IntValue
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Не допустимый или отсутствует код автора документа - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'ECR*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'deleted' then
        begin
          if AnXMLNode.Items[ii].Value = 'False' then
            Self._Delete := 0
          else
            Self._Delete := 1;
        end;
        if AnXMLNode.Items[ii].Name = 'firmcode' then
        begin
          if AnXMLNode.Items[ii].Value <> '' then
            Self._FirmCode := AnXMLNode.Items[ii].IntValue
          else
            Exit;
        end;
        if AnXMLNode.Items[ii].Name = 'routecode' then
        begin
          if (PosEx('*', AnXMLNode.Items[ii].Value, 1) = 0) and (trim(AnXMLNode.Items[ii].Value)<>'') and (AnXMLNode.Items[ii].Value <> null) then
            Self._RouteCode := AnXMLNode.Items[ii].IntValue
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Не допустимый или отсутствует код маршрута - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'ERT*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'employeecode' then
        begin
          if (PosEx('*', AnXMLNode.Items[ii].Value, 1) = 0) and (trim(AnXMLNode.Items[ii].Value)<>'') and (AnXMLNode.Items[ii].Value <> null) then
            Self._EmployeeCode := AnXMLNode.Items[ii].IntValue
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Не допустимый  или отсутствует код сотрудника - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'EEM*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'buypointcode' then
        begin
          if AnXMLNode.Items[ii].Value <> null then
            Self._BuyPointCode := AnXMLNode.Items[ii].Value
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Не указан Код ТРТ!');
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'EBP*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'comment' then Self._Comment := AnXMLNode.Items[ii].Value;
        if AnXMLNode.Items[ii].Name = 'buyercode' then
        begin
          if (PosEx('*', AnXMLNode.Items[ii].Value, 1) = 0) and (trim(AnXMLNode.Items[ii].Value)<>'') and (AnXMLNode.Items[ii].Value <> null) then
            Self._BuyerCode := AnXMLNode.Items[ii].IntValue
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Не допустимый или отсутствует код покупателя - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'EBY*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'counteragentcode' then
        begin
          if (PosEx('*', AnXMLNode.Items[ii].Value, 1) = 0) and (trim(AnXMLNode.Items[ii].Value)<>'') and (AnXMLNode.Items[ii].Value <> null) then
            Self._CAgentCode := AnXMLNode.Items[ii].IntValue
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Не допустимый или отсутствует код Форм. покупателя - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'ECA*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'deliverydate' then
        begin
          if StrToDate(Copy(AnXMLNode.Items[ii].Value, 1, 10),Settings)+_const_OffSet <= Date then
            Self._DeliveryDate := FormatDateTime('yyyy.mm.dd', Date)
          else
          if StrToDate(Copy(AnXMLNode.Items[ii].Value, 1, 10),Settings)+_const_OffSet >= Date then
            Self._DeliveryDate := FormatDateTime('yyyy.mm.dd', StrToDate(Copy(AnXMLNode.Items[ii].Value, 1, 10),Settings)+_const_OffSet)
          else
          begin
            Self.SetMessage('Ошибка импорта', 'Дата отгрузки должна быть больше или равна текущей дате - ' + AnXMLNode.Items[ii].Value);
            Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
            Self._ConfirmationDocDataNode.Items.Add('chicagocode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
            Self._ConfirmationDocDataNode.Items.Add('outercode');
            Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'EDD*' + Self._InnerCode;
            Exit;
          end;
        end;
        if AnXMLNode.Items[ii].Name = 'deliverytimefrom' then Self._DeliveryTimeFrom := AnXMLNode.Items[ii].Value;
        if AnXMLNode.Items[ii].Name = 'deliverytimetill' then Self._DeliveryTimeTo := AnXMLNode.Items[ii].Value;
        if AnXMLNode.Items[ii].Name = 'deliveryroutecode' then Self._DeliveryRouteCode := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'currencycode' then Self._CurrencyCode := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'bw' then Self._bw := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'paytypecode' then
         begin
          Self._PayTypeCode := AnXMLNode.Items[ii].IntValue;    // Форма оплаты
          if AnXMLNode.Items[ii].IntValue = 1 then
            Self._FormCode := 2
          else Self._FormCode := 1;
         end;
        if AnXMLNode.Items[ii].Name = 'usevatrate' then
        begin
          Self._UseVatRate := AnXMLNode.Items[ii].IntValue;
        end;
        if AnXMLNode.Items[ii].Name = 'includevat' then
        begin
          Self._IncludeVat := AnXMLNode.Items[ii].IntValue;
        end;
        if AnXMLNode.Items[ii].Name = 'pdadocnum' then Self._PDADocNum := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'crdate' then Self._CreateDate := FormatDateTime('yyyy.mm.dd', (StrToDate(Copy(AnXMLNode.Items[ii].Value, 1, 10),Settings))+_const_OffSet);
        if AnXMLNode.Items[ii].Name = 'pdaroutecode' then
        begin
          if PosEx('*', AnXMLNode.Items[ii].Value, 1) = 0 then
            Self._PDARouteCode := AnXMLNode.Items[ii].IntValue
          else
            Exit;
        end;
        if AnXMLNode.Items[ii].Name = 'usevat' then     // форма оплаты
        begin
          if AnXMLNode.Items[ii].Value = 'True' then
            Self._FormCode := 1
          else Self._FormCode := 2;
        end;
        if AnXMLNode.Items[ii].Name = 'body' then // парсинг строк заказа
        begin
          try
            Self._Connection.Connected := True;
            with Self._DataSet do
            begin
              Close;
              CommandText := _const_ExistsOrders;
              Parameters.ParseSQL(CommandText,True);
              if Parameters.Count>0 then       // если есть параметры, заполняем их
               begin
                Parameters.ParamValues['InnerCode'] := Self._InnerCode;
                Parameters.ParamValues['ParentInnerCode'] := Self._ParentInnerCode;
                Parameters.ParamValues['DocNum'] := Self._DocNo;
               end;
              Active := True;
              if Recordset.RecordCount>0 then
               begin
                Recordset.MoveFirst;
                DocCount := Recordset.Fields.Item[0].Value;
               end
              else
               DocCount := 0;
              Close;
            end;
            if DocCount = 0 then
            begin
              (* Документ в БД не обнаружен/ Начало записи в БД *)
              try
                Self._ErrorCode := 0;
                SetLength(Self._ListErrMsg,0);
                (* Заливка заказа в таблицу "Расходных накладных" *)
                Self._Connection.BeginTrans;
                with Self._StoredProcHead do
                begin
                  Close;
                  Parameters.ParamValues['@op'] := Self._ErrorCode;
                  Parameters.ParamValues['@InnerCode'] := Self._InnerCode;
                  Parameters.ParamValues['@DocDate'] := Self._Date;
                  Parameters.ParamValues['@DocNo'] := Self._DocNo;
                  Parameters.ParamValues['@Deleted'] := Self._Delete;
                  Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
                  Parameters.ParamValues['@RouteCode'] := Self._RouteCode;
                  Parameters.ParamValues['@EmployeeCode'] := Self._EmployeeCode;
                  Parameters.ParamValues['@BuypointCode'] := Self._BuypointCode;
                  Parameters.ParamValues['@Comment'] := Self._Comment + ' ';
                  Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
                  Parameters.ParamValues['@CounteragentCode'] := Self._CAgentCode;
                  Parameters.ParamValues['@DeliveryDate'] := Self._DeliveryDate;
                  Parameters.ParamValues['@DeliveryTimeFrom'] := Self._DeliveryTimeFrom;
                  Parameters.ParamValues['@DeliveryTimeTo'] := Self._DeliveryTimeTo;
                  Parameters.ParamValues['@DeliveryRouteCode'] := Self._DeliveryRouteCode;
                  Parameters.ParamValues['@CurrencyCode'] := Self._CurrencyCode;
                  Parameters.ParamValues['@bw'] := Self._bw;
                  Parameters.ParamValues['@PayTypeCode'] := Self._FormCode;//Self._PayTypeCode;
                  Parameters.ParamValues['@UseVatRate'] := Self._UseVatRate;
                  Parameters.ParamValues['@IncludeVat'] := Self._IncludeVat;
                  Parameters.ParamValues['@PDADocNum'] := Self._PDADocNum;


                 //  Parameters.ParamValues['@UseVat'] := Self._FormCode;
                  ExecProc;

                  Self._RegDocNo := Parameters.ParamValues['@RegDocCode'];
                  if not VarIsNull(Parameters.ParamValues['@StoreCode']) then
                     Self._CurrentStore := Parameters.ParamValues['@StoreCode'];
                  Self._ReturnCode := Parameters.ParamValues['@RETURN_VALUE'];
                  Self._DiscountRate := Parameters.ParamValues['@DiscountRate'];
                 if not VarIsNull(Parameters.ParamValues['@ReservedStoreCode']) then
                    Self._ReservedStore := Parameters.ParamValues['@ReservedStoreCode'];

                end;
                if Self._ReturnCode = 0 then
                begin
                  (* Парсинг строк документа *)
                  Self._RowNum := 1;
                  Self._ReservedRowNum := 1;
                  Self._CurrentRow := 0;
                  Self._CurrentRezRow := 0;
                  ParsingDocumentRows(AnXMLNode.Items[ii]);
                  Self._Connection.CommitTrans;
                  (* Получение №№ документа *)
                  with Self._DataSet do
                  begin
                    Close;
                    CommandText := _const_OrderComplete;
                    Parameters.ParseSQL(CommandText,True);
                    if Parameters.Count>0 then       // если есть параметры, заполняем их
                     begin
                      Parameters.ParamValues['InnerCode'] := Self._InnerCode;
                      Parameters.ParamValues['Op'] := Self._ErrorCode;
                     end;
                    Open;
                    if Recordset.RecordCount>0 then
                     begin
                      Recordset.MoveFirst;
                      Self.SetMessage('Импорт', 'Документ импортирован успешно.');
                      Self.SetMessage('Импорт', '№ в OficeTools: P*' + VarToStr(Recordset.Fields.Item[0].Value));
                      Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
                      Self._outercode:=VarToStr(Recordset.Fields.Item[0].Value);
                      Self._ConfirmationDocDataNode.Items.Add('chicagocode');
                      Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
                      Self._ConfirmationDocDataNode.Items.Add('outercode');
                      Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'P*' + VarToStr(Recordset.Fields.Item[0].Value);
                     end;
                    Close;
                  end; // if Self._ReturnCode = 0 then
                end;
              except
                tmpErr:=GetConnectionError;
                Self._Connection.RollbackTrans;
                Self._ErrorCode := 1;
                (* Заливка заказа в таблицы "Заказ внутренний: Формирование" *)
                try
                  Self._Connection.BeginTrans;
                  (* Заливка заказа в таблицу шапок *)
                  with Self._StoredProcHead do
                  begin
                    Close;
                    Parameters.ParamValues['@op'] := Self._ErrorCode;
                    Parameters.ParamValues['@InnerCode'] := Self._InnerCode;
                    Parameters.ParamValues['@DocDate'] := Self._Date;
                    Parameters.ParamValues['@DocNo'] := Self._DocNo;
                    Parameters.ParamValues['@Deleted'] := Self._Delete;
                    Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
                    Parameters.ParamValues['@RouteCode'] := Self._RouteCode;
                    Parameters.ParamValues['@EmployeeCode'] := Self._EmployeeCode;
                    Parameters.ParamValues['@BuypointCode'] := Self._BuypointCode;
                    Parameters.ParamValues['@Comment'] := Self._Comment + ' ';
                    Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
                    Parameters.ParamValues['@CounteragentCode'] := Self._CAgentCode;
                    Parameters.ParamValues['@DeliveryDate'] := Self._DeliveryDate;
                    Parameters.ParamValues['@DeliveryTimeFrom'] := Self._DeliveryTimeFrom;
                    Parameters.ParamValues['@DeliveryTimeTo'] := Self._DeliveryTimeTo;
                    Parameters.ParamValues['@DeliveryRouteCode'] := Self._DeliveryRouteCode;
                    Parameters.ParamValues['@CurrencyCode'] := Self._CurrencyCode;
                    Parameters.ParamValues['@bw'] := Self._bw;
                    Parameters.ParamValues['@PayTypeCode'] := Self._PayTypeCode;
                    Parameters.ParamValues['@UseVatRate'] := Self._UseVatRate;
                    Parameters.ParamValues['@IncludeVat'] := Self._IncludeVat;
                    Parameters.ParamValues['@PDADocNum'] := Self._PDADocNum;
                 //   Parameters.ParamValues['@UseVat'] := Self._FormCode;
                    ExecProc;


                    Self._RegDocNo := Parameters.ParamValues['@RegDocCode'];

                    Self._CurrentStore := Parameters.ParamValues['@StoreCode'];
                    Self._ReturnCode := Parameters.ParamValues['@RETURN_VALUE'];
                    Self._DiscountRate := Parameters.ParamValues['@DiscountRate'];
                    if not VarIsNull(Parameters.ParamValues['@ReservedStoreCode']) then
                      Self._ReservedStore := Parameters.ParamValues['@ReservedStoreCode'];
                  end;
                  if Self._ReturnCode = 0 then
                  begin
                    Self._RowNum := 1;
                    Self._ReservedRowNum := 1;
                    Self._CurrentRow := 0;
                    Self._CurrentRezRow := 0;
                    ParsingDocumentRows(AnXMLNode.Items[ii]);
                    Self._Connection.CommitTrans;
                    (* Получение №№ документа *)
                    with Self._DataSet do
                    begin
                      Close;
                      CommandText := _const_OrderComplete;
                      Parameters.ParseSQL(CommandText,True);
                      if Parameters.Count>0 then       // если есть параметры, заполняем их
                       begin
                        Parameters.ParamValues['InnerCode'] := Self._InnerCode;
                        Parameters.ParamValues['Op'] := Self._ErrorCode;
                       end;
                      Open;
                      if Recordset.RecordCount>0 then
                      begin
                        Recordset.MoveFirst;
                        Self.SetMessage('Импорт', 'Документ импортирован успешно.');
                        Self.SetMessage('Импорт', '№ в OficeTools: '+tmpErr + VarToStr(Recordset.Fields.Item[0].Value));
                        Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
                        Self._outercode:=VarToStr(Recordset.Fields.Item[0].Value);
                        Self._ConfirmationDocDataNode.Items.Add('chicagocode');
                        Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
                        Self._ConfirmationDocDataNode.Items.Add('outercode');
                        Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := tmpErr + VarToStr(Recordset.Fields.Item[0].Value);
                      end;
                      Close;
                    end;
                  end;
                except
                 on E:Exception do
                 begin
                  Self._Connection.RollbackTrans;
                  Self.SetMessage('Ошибка импорта', 'Не соответствие критических параметров - ' + AnXMLNode.Items[ii].Value + 'Текст системы:' + e.Message);
                  Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
                  Self._outercode:='0';
                  Self._ConfirmationDocDataNode.Items.Add('chicagocode');
                  Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
                  Self._ConfirmationDocDataNode.Items.Add('outercode');
                  Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'CRE*' + Self._InnerCode;
                 end;
                end;
              end;

              (* Обработка товаров без остатка *)
              if Self._ErrorCode = 0 then
              if Length(Self._ListSKUNullRemain)>0 then
               ProcessListSKUNullRemain;

              SetLength(Self._ListSKUNullRemain,0);

              (* Обработка акций *)
              if Length(Self._ListSKUAction)>0 then
               ProcessListSKUAction;

              SetLength(Self._ListSKUAction,0);

              (* Запись ошибок в БД *)
              if Length(Self._ListErrMsg)>0 then
               ProcessListErrMsg;
            end // try Документ в БД не обнаружен/ Начало записи в БД
            else
            begin
              {Выгружен ранее}
              with Self._DataSet do
               begin
                Close;
                CommandText := _const_OrderComplete;
                Parameters.ParseSQL(CommandText,True);
                if Parameters.Count>0 then       // если есть параметры, заполняем их
                 begin
                  Parameters.ParamValues['InnerCode'] := Self._InnerCode;
                  Parameters.ParamByName('Op').DataType := ftInteger;
                  Parameters.ParamValues['Op'] := -1;
                 end;
                Open;
                if Recordset.RecordCount>0 then
                 begin
                  Recordset.MoveFirst;
                  Self.SetMessage('Импорт', 'Документ выгружен ранее.');
                  Self.SetMessage('Импорт', '№ в OficeTools: UP*' + VarToStr(Recordset.Fields.Item[0].Value));
{
                  Self._ConfirmationDocDataNode := Self._ConfirmationDocNode.Items.Add('doc');
                  Self._ConfirmationDocDataNode.Items.Add('chicagocode');
                  Self._ConfirmationDocDataNode.Items.ItemNamed['chicagocode'].Value := Self._InnerCode;
                  Self._ConfirmationDocDataNode.Items.Add('outercode');
                  Self._ConfirmationDocDataNode.Items.ItemNamed['outercode'].Value := 'UP*' + IntToStr(FieldValues['COLUMN1']);
}
                end;
                Close;
              end;
            end;
          finally
            Self._DataSet.Close;
            Self._StoredProcHead.Close;
          end;
        end;
      end;
    end;// for ii
  end;
  for i := 0 to AnXMLNode.Items.Count - 1 do ParsingDocumentFile(AnXMLNode.Items[i]);
end;

procedure TImportObject.ParsingDocumentRows(AnXMLNode: TJvSimpleXMLElem);
var
  i, ii, j: Integer;
  idx: integer;

begin
  if AnXMLNode <> nil then
  begin
    if AnXMLNode.Name = 'item' then
    begin
      SetDefaultRowsValues;
      for ii := 0 to AnXMLNode.Items.Count - 1 do
      begin
        if AnXMLNode.Items[ii].Name = 'SKUcode' then
          Self._SkuCode := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'unitcode' then
          Self._UnitCode := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'unitfactor' then
          Self._UnitFactor := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'quantity' then
          Self._Quantity := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'price' then
          Self._Price := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'pricetypecode' then
          Self._PriceTypeCode := AnXMLNode.Items[ii].IntValue;
        if AnXMLNode.Items[ii].Name = 'discountAmount' then
          Self._DiscountAmount := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'amount' then
          Self._Amount := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'VATRate' then
          Self._VatRate := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'VATAmount' then
          Self._VatAmount := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
        if AnXMLNode.Items[ii].Name = 'recommendedquantity' then
        begin
          if Self._ErrorCode = 0 then
          begin
            Self._RecommendedQuantity := StrToFloat(StrReplace(Trim(AnXMLNode.Items[ii].Value), '.', ','));
            (* Запись строк в документ "Расходная накладная *)

            if (Self._SKUCode<5000)and(Self._SKUCode>0) then // обрабатываем акционные товары
             begin
              j:=Length(Self._ListSKUAction);
              SetLength(Self._ListSKUAction,j+1);
              Self._ListSKUAction[j].SkuCode:=Self._SkuCode;
              Self._ListSKUAction[j].UnitCode:=Self._UnitCode;
              Self._ListSKUAction[j].UnitFactor:=Self._UnitFactor;
              Self._ListSKUAction[j].Quantity:=Self._Quantity;
              Self._ListSKUAction[j].Price:=Self._Price;
              Self._ListSKUAction[j].PriceDiscount:=Self._PriceDiscount;
              Self._ListSKUAction[j].PriceTypeCode:=Self._PriceTypeCode;
              Self._ListSKUAction[j].DiscountAmount:=Self._DiscountAmount;
              Self._ListSKUAction[j].Amount:=Self._Amount;
              Self._ListSKUAction[j].VatRate:=Self._VatRate;
              Self._ListSKUAction[j].VatAmount:=Self._VatAmount;
              Self._ListSKUAction[j].RecommendedQuantity:=Self._RecommendedQuantity;
              Self._ListSKUAction[j].ReservedQuantity:=Self._ReservedQuantity;
             end
            else
            try
              (* Первая форма - безнал *)
              with Self._StoredProcRow do
              begin
                Close;
                Parameters.ParamValues['@op'] := Self._ErrorCode;
                Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
                Parameters.ParamValues['@RegDocCode'] := Self._RegDocNo;
                Parameters.ParamValues['@StoreCode'] := Self._CurrentStore;
                Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
                Parameters.ParamValues['@SKUCode'] := Self._SKUCode;
                Parameters.ParamValues['@Position'] := Self._RowNum;
                Parameters.ParamValues['@UnitCode'] := Self._UnitCode;
                Parameters.ParamValues['@UnitFactor'] := Self._UnitFactor;
                Parameters.ParamValues['@Quantity'] := Self._Quantity;
                Parameters.ParamValues['@PriceDiscount'] := Self._PriceDiscount;
                Parameters.ParamValues['@Price'] := Self._Price;
                Parameters.ParamValues['@PriceTypeCode'] := Self._PriceTypeCode;
                Parameters.ParamValues['@DiscountRate'] := Self._DiscountRate;
                Parameters.ParamValues['@DiscountAmount'] := Self._DiscountAmount;
                Parameters.ParamValues['@Amount'] := Self._Amount;
                Parameters.ParamValues['@VATRate'] := Self._VATRate;
                Parameters.ParamValues['@VATAmount'] := Self._VATAmount;
                Parameters.ParamValues['@RecommendedQuantity'] := Self._RecommendedQuantity;

                ExecProc;
                if VarIsNull(Parameters.ParamValues['@RemainQuantity']) then
                  Self._ReservedQuantity := Self._Quantity
                else
                  Self._ReservedQuantity := Parameters.ParamValues['@RemainQuantity'];
                if not VarIsNull(Parameters.ParamValues['@RowCount']) then
                  Self._CurrentRow := Parameters.ParamValues['@RowCount'];
                Self._RowNum := Self._RowNum + Self._CurrentRow;
              end;
              (* Вторая форма  - нал*)
              if (Self._ReservedStore <> 0) and (Self._ReservedQuantity > 0) and (Self._CurrentRow >= 0) then
              begin
                with Self._StoredProcRow do
                begin
                  Close;
                  Parameters.ParamValues['@op'] := Self._ErrorCode;
                  Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
                  Parameters.ParamValues['@RegDocCode'] := Self._RegDocNo + 1;
                  Parameters.ParamValues['@StoreCode'] := Self._ReservedStore;
                  Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
                  Parameters.ParamValues['@SKUCode'] := Self._SKUCode;
                  Parameters.ParamValues['@Position'] := Self._ReservedRowNum;
                  Parameters.ParamValues['@UnitCode'] := Self._UnitCode;
                  Parameters.ParamValues['@UnitFactor'] := Self._UnitFactor;
                  Parameters.ParamValues['@Quantity'] := Self._ReservedQuantity;
                  Parameters.ParamValues['@PriceDiscount'] := Self._PriceDiscount;
                  Parameters.ParamValues['@Price'] := Self._Price;
                  Parameters.ParamValues['@PriceTypeCode'] := Self._PriceTypeCode;
                  Parameters.ParamValues['@DiscountRate'] := Self._DiscountRate;
                  Parameters.ParamValues['@DiscountAmount'] := Self._DiscountAmount;
                  Parameters.ParamValues['@Amount'] := Self._Amount;
                  Parameters.ParamValues['@VATRate'] := Self._VATRate;
                  Parameters.ParamValues['@VATAmount'] := Self._VATAmount;
                  Parameters.ParamValues['@RecommendedQuantity'] := Self._RecommendedQuantity;
                  ExecProc;
                 
                  if VarIsNull(Parameters.ParamValues['@RemainQuantity']) then
                   Self._ReservedQuantity := Self._Quantity
                  else
                   Self._ReservedQuantity := Parameters.ParamValues['@RemainQuantity'];
                  if not VarIsNull(Parameters.ParamValues['@RowCount']) then
                    Self._CurrentRow := Parameters.ParamValues['@RowCount'];
                  Self._ReservedRowNum := Self._ReservedRowNum + Self._CurrentRow;
                end;
              end;
             if (Self._ReservedStore <> 0) and (Self._ReservedQuantity > 0) then
              begin
               j:=Length(Self._ListSKUNullRemain);
               SetLength(Self._ListSKUNullRemain,j+1);
               Self._ListSKUNullRemain[j].SkuCode:=Self._SkuCode;
               Self._ListSKUNullRemain[j].UnitCode:=Self._UnitCode;
               Self._ListSKUNullRemain[j].UnitFactor:=Self._UnitFactor;
               Self._ListSKUNullRemain[j].Quantity:=Self._Quantity;
               Self._ListSKUNullRemain[j].Price:=Self._Price;
               Self._ListSKUNullRemain[j].PriceDiscount:=Self._PriceDiscount;
               Self._ListSKUNullRemain[j].PriceTypeCode:=Self._PriceTypeCode;
               Self._ListSKUNullRemain[j].DiscountAmount:=Self._DiscountAmount;
               Self._ListSKUNullRemain[j].Amount:=Self._Amount;
               Self._ListSKUNullRemain[j].VatRate:=Self._VatRate;
               Self._ListSKUNullRemain[j].VatAmount:=Self._VatAmount;
               Self._ListSKUNullRemain[j].RecommendedQuantity:=Self._RecommendedQuantity;
               Self._ListSKUNullRemain[j].ReservedQuantity:=Self._ReservedQuantity;
              end;
            finally
              Self._StoredProcRow.Close;
            end;
          end
          else
          if Self._ErrorCode = 1 then
          begin
            { Запись строк документа в "Заказ внутренний: Формирование" }
            if (Self._SKUCode<5000)and(Self._SKUCode>0) then // обрабатываем акционные товары
             begin
              j:=Length(Self._ListSKUAction);
              SetLength(Self._ListSKUAction,j+1);
              Self._ListSKUAction[j].SkuCode:=Self._SkuCode;
              Self._ListSKUAction[j].UnitCode:=Self._UnitCode;
              Self._ListSKUAction[j].UnitFactor:=Self._UnitFactor;
              Self._ListSKUAction[j].Quantity:=Self._Quantity;
              Self._ListSKUAction[j].Price:=Self._Price;
              Self._ListSKUAction[j].PriceDiscount:=Self._PriceDiscount;
              Self._ListSKUAction[j].PriceTypeCode:=Self._PriceTypeCode;
              Self._ListSKUAction[j].DiscountAmount:=Self._DiscountAmount;
              Self._ListSKUAction[j].Amount:=Self._Amount;
              Self._ListSKUAction[j].VatRate:=Self._VatRate;
              Self._ListSKUAction[j].VatAmount:=Self._VatAmount;
              Self._ListSKUAction[j].RecommendedQuantity:=Self._RecommendedQuantity;
              Self._ListSKUAction[j].ReservedQuantity:=Self._ReservedQuantity;
             end
            else
            try
              (* Первая форма - безнал *)
              with Self._StoredProcRow do
              begin
                Close;
                Parameters.ParamValues['@op'] := Self._ErrorCode;
                Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
                Parameters.ParamValues['@RegDocCode'] := Self._RegDocNo;
                Parameters.ParamValues['@StoreCode'] := Self._CurrentStore;
                Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
                Parameters.ParamValues['@SKUCode'] := Self._SKUCode;
                Parameters.ParamValues['@Position'] := Self._RowNum;
                Parameters.ParamValues['@UnitCode'] := Self._UnitCode;
                Parameters.ParamValues['@UnitFactor'] := Self._UnitFactor;
                Parameters.ParamValues['@Quantity'] := Self._Quantity;
                Parameters.ParamValues['@PriceDiscount'] := Self._PriceDiscount;
                Parameters.ParamValues['@Price'] := Self._Price;
                Parameters.ParamValues['@PriceTypeCode'] := Self._PriceTypeCode;
                Parameters.ParamValues['@DiscountRate'] := Self._DiscountRate;
                Parameters.ParamValues['@DiscountAmount'] := Self._DiscountAmount;
                Parameters.ParamValues['@Amount'] := Self._Amount;
                Parameters.ParamValues['@VATRate'] := Self._VATRate;
                Parameters.ParamValues['@VATAmount'] := Self._VATAmount;
                Parameters.ParamValues['@RecommendedQuantity'] := Self._RecommendedQuantity;
                ExecProc;

                if VarIsNull(Parameters.ParamValues['@RemainQuantity']) then
                  Self._ReservedQuantity := Self._Quantity
                else
                  Self._ReservedQuantity := Parameters.ParamValues['@RemainQuantity'];
                if not VarIsNull(Parameters.ParamValues['@RowCount']) then
                  Self._CurrentRezRow := Parameters.ParamValues['@RowCount'];
                Self._RowNum := Self._RowNum + Self._CurrentRezRow;
              end;
              (* Вторая форма - нал*)
              if (Self._ReservedStore <> 0) and (Self._ReservedQuantity > 0) and (Self._CurrentRezRow >= 0) then
              begin
                with Self._StoredProcRow do
                begin
                  Close;
                  Parameters.ParamValues['@op'] := Self._ErrorCode;
                  Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
                  Parameters.ParamValues['@RegDocCode'] := Self._RegDocNo + 1;
                  Parameters.ParamValues['@StoreCode'] := Self._ReservedStore;
                  Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
                  Parameters.ParamValues['@SKUCode'] := Self._SKUCode;
                  Parameters.ParamValues['@Position'] := Self._ReservedRowNum;
                  Parameters.ParamValues['@UnitCode'] := Self._UnitCode;
                  Parameters.ParamValues['@UnitFactor'] := Self._UnitFactor;
                  Parameters.ParamValues['@Quantity'] := Self._ReservedQuantity;
                  Parameters.ParamValues['@PriceDiscount'] := Self._PriceDiscount;
                  Parameters.ParamValues['@Price'] := Self._Price;
                  Parameters.ParamValues['@PriceTypeCode'] := Self._PriceTypeCode;
                  Parameters.ParamValues['@DiscountRate'] := Self._DiscountRate;
                  Parameters.ParamValues['@DiscountAmount'] := Self._DiscountAmount;
                  Parameters.ParamValues['@Amount'] := Self._Amount;
                  Parameters.ParamValues['@VATRate'] := Self._VATRate;
                  Parameters.ParamValues['@VATAmount'] := Self._VATAmount;
                  Parameters.ParamValues['@RecommendedQuantity'] := Self._RecommendedQuantity;
                  ExecProc;

                  if VarIsNull(Parameters.ParamValues['@RemainQuantity']) then
                   Self._ReservedQuantity := Self._Quantity
                  else
                   Self._ReservedQuantity := Parameters.ParamValues['@RemainQuantity'];
                  if not VarIsNull(Parameters.ParamValues['@RowCount']) then
                    Self._CurrentRezRow := Parameters.ParamValues['@RowCount'];
                  Self._ReservedRowNum := Self._ReservedRowNum + Self._CurrentRezRow;
                end;
              end;
            finally
              Self._StoredProcRow.Close;
            end;
          end;
        end;
      end;
    end;
  end;
  for i := 0 to AnXMLNode.Items.Count - 1 do ParsingDocumentRows(AnXMLNode.Items[i]);
end;

procedure TImportObject.ProcessListErrMsg;
var
 i,l:integer;
begin
l:=Length(Self._ListErrMsg);
 for I := 0 to L - 1 do
  begin
   try
    Self._CommandInsertMessage.Parameters.ParamValues['idChicago']:=StrToInt64Def(Self._InnerCode,0);
    Self._CommandInsertMessage.Parameters.ParamValues['idOT']:=StrToIntDef(Self._outercode,0);
    Self._CommandInsertMessage.Parameters.ParamValues['Message']:=Self._ListErrMsg[i].ErrorMsg;
    Self._CommandInsertMessage.Execute;
   except

   end;
  end;
end;

procedure TImportObject.ProcessListSKUAction;
var
 i,l,Ret,Fact,FactFilial,PlanFilial:integer;
 tmpErr,tmpMess:string;
 actInfo:string;
 i1:integer;
begin
l:=Length(Self._ListSKUAction);
for I := 0 to L - 1 do
if Self._ListSKUAction[i].Quantity > 0 then
  try
    (* Заливка шапки в акции *)
     Ret := 0;
     Fact := 0;
    with Self._StoredProcCheck do
    begin
     Close;
     Parameters.ParamValues['@Act'] :=Self._ListSKUAction[i].SkuCode;
     Parameters.ParamValues['@Route'] := Self._RouteCode;
     Parameters.ParamValues['@Comp'] := Self._BuyerCode;
     Parameters.ParamValues['@TRT'] :=Self._BuypointCode;
     Parameters.ParamValues['@Qty'] := Self._ListSKUAction[i].Quantity;
     Parameters.ParamValues['@Ret'] := 0;
     Parameters.ParamValues['@Fact'] := 0;
     Parameters.ParamValues['@PlanFilial'] := 0;
     Parameters.ParamValues['@FactFilial'] := 0;
     Parameters.ParamValues['@Message'] := ' ';
     ExecProc;
     //
    {if not VarIsNull(Parameters.ParamValues['@Ret']) then
      Ret := Parameters.ParamValues['@Ret']
     else
      Ret := 0;
     if not VarIsNull(Parameters.ParamValues['@Fact']) then
      Fact := Parameters.ParamValues['@Fact']
     else
      Fact := 0;
     if not VarIsNull(Parameters.ParamValues['@PlanFilial']) then
      PlanFilial := Parameters.ParamValues['@PlanFilial']
     else
      PlanFilial := 0;
     if not VarIsNull(Parameters.ParamValues['@FactFilial']) then
      FactFilial := Parameters.ParamValues['@FactFilial']
     else
      FactFilial := 0;
     if not VarIsNull(Parameters.ParamValues['@Message']) then
      tmpMess := Parameters.ParamValues['@Message']
     else
      tmpMess := '';   }
    end;
  {  if Ret<=0 then
     begin
    //  Self.SetMessage('Ошибка импорта', 'Импорт акции отменен!. Уже отгружено по ТРТ: '+IntToStr(Fact)+', план/факт по филиалу: '+IntToStr(PlanFilial)+'/'+IntToStr(FactFilial)+'. Текст причина: '+tmpMess);
      Continue;
     end;    }

//    Self._Connection.BeginTrans;
    with Self._StoredProcHead do
    begin
     Close;
     Parameters.ParamValues['@op'] := 2;
     Parameters.ParamValues['@InnerCode'] := Self._InnerCode;
     Parameters.ParamValues['@DocDate'] := Self._Date;
     Parameters.ParamValues['@DocNo'] := Self._DocNo;
     Parameters.ParamValues['@Deleted'] := Self._Delete;
     Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
     Parameters.ParamValues['@RouteCode'] := Self._RouteCode;
     Parameters.ParamValues['@EmployeeCode'] := Self._EmployeeCode;
     Parameters.ParamValues['@BuypointCode'] := Self._BuypointCode;
     Parameters.ParamValues['@Comment'] := Self._Comment;
     Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
     Parameters.ParamValues['@CounteragentCode'] := Self._CAgentCode;
     Parameters.ParamValues['@DeliveryDate'] := Self._DeliveryDate;
     Parameters.ParamValues['@DeliveryTimeFrom'] := Self._DeliveryTimeFrom;
     Parameters.ParamValues['@DeliveryTimeTo'] := Self._DeliveryTimeTo;
     Parameters.ParamValues['@DeliveryRouteCode'] := Self._DeliveryRouteCode;
     Parameters.ParamValues['@CurrencyCode'] := Self._CurrencyCode;
     Parameters.ParamValues['@bw'] := Self._bw;
     Parameters.ParamValues['@PayTypeCode'] := Self._PayTypeCode;
     Parameters.ParamValues['@UseVatRate'] := Self._UseVatRate;
     Parameters.ParamValues['@IncludeVat'] := Self._IncludeVat;
     Parameters.ParamValues['@PDADocNum'] := Self._ListSKUAction[i].SkuCode;
  //   Parameters.ParamValues['@UseVat'] := Self._FormCode;
     ExecProc;
   //  Self._RegDocNo := Parameters.ParamValues['@RegDocCode'];
     Self._CurrentStore := Parameters.ParamValues['@StoreCode'];
     Self._ReturnCode := Parameters.ParamValues['@RETURN_VALUE'];
   //  Self._DiscountRate := Parameters.ParamValues['@DiscountRate'];
//     if not VarIsNull(Parameters.ParamValues['@ReservedStoreCode']) then
  //    Self._ReservedStore := Parameters.ParamValues['@ReservedStoreCode'];
  Self._CurrentStore:=  Self._CurrentStore
    end;
    if Self._ReturnCode = 0 then
    begin
     (* Парсинг строк документа *)
      Self._RowNum := 1;
      Self._ReservedRowNum := 1;
      Self._CurrentRow := 0;
      Self._CurrentRezRow := 0;
      with Self._StoredProcRow do
       begin
        Close;
        Parameters.ParamValues['@op'] := 2;
        Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
        Parameters.ParamValues['@RegDocCode'] := Self._RegDocNo;
        Parameters.ParamValues['@StoreCode'] := Self._CurrentStore;
        Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
        Parameters.ParamValues['@SKUCode'] := Self._ListSKUAction[i].SkuCode;
        Parameters.ParamValues['@Position'] := Self._RowNum;
        Parameters.ParamValues['@UnitCode'] := Self._ListSKUAction[i].UnitCode;
        Parameters.ParamValues['@UnitFactor'] := Self._ListSKUAction[i].UnitFactor;
        if Self._ListSKUAction[i].Quantity<Ret then
         Ret := strtoint(floattostr(Self._ListSKUAction[i].Quantity));
        Parameters.ParamValues['@Quantity'] := Ret;
        Parameters.ParamValues['@PriceDiscount'] := Self._ListSKUAction[i].PriceDiscount;
        Parameters.ParamValues['@Price'] := Self._ListSKUAction[i].Price;
        Parameters.ParamValues['@PriceTypeCode'] := Self._ListSKUAction[i].PriceTypeCode;
        Parameters.ParamValues['@DiscountRate'] := 0;
        Parameters.ParamValues['@DiscountAmount'] := Self._ListSKUAction[i].DiscountAmount;
        Parameters.ParamValues['@Amount'] := Ret*Self._ListSKUAction[i].Price;
        Parameters.ParamValues['@VATRate'] := Self._ListSKUAction[i].VATRate;
        Parameters.ParamValues['@VATAmount'] := Self._ListSKUAction[i].VATAmount;
        Parameters.ParamValues['@RecommendedQuantity'] := Self._ListSKUAction[i].RecommendedQuantity;
        ExecProc;
        if not VarIsNull(Parameters.ParamValues['@RowCount']) then
         Self._CurrentRow := Parameters.ParamValues['@RowCount'];
        Self._RowNum := Self._RowNum + Self._CurrentRow;
       end;
    end;
//   Self._Connection.CommitTrans;
   (* Получение №№ документа *)
   with Self._DataSet do
    begin
     Close;
     CommandText := _const_OrderComplete;
     Parameters.ParseSQL(CommandText,True);
     if Parameters.Count>0 then       // если есть параметры, заполняем их
      begin
       Parameters.ParamValues['InnerCode'] := Self._InnerCode;
       Parameters.ParamValues['Op'] := 2;
      end;
     Open;
     if Recordset.RecordCount>0 then
      begin
       Recordset.MoveFirst;
       Self.SetMessage('Импорт', 'Документ импортирован успешно.');
       Self.SetMessage('Импорт', '№ в OficeTools: P*'+VarToStr(Recordset.Fields.Item[0].Value));
      end;
     Close;
    end;
  except
   on E:Exception do
    begin
     tmpErr:=GetConnectionError;
//     Self._Connection.RollbackTrans;
     Self._outercode:='0';
     Self.SetMessage('Ошибка импорта', 'Ошибка импорта акции: '+tmpErr + Self._InnerCode);
    end;
  end;
end;

procedure TImportObject.ProcessListSKUNullRemain;
var
 i,l:integer;
begin
l:=Length(Self._ListSKUNullRemain);
  try
    (* Заливка шапки во внутр. формирование *)
//    Self._Connection.BeginTrans;
    with Self._StoredProcHead do
    begin
     Close;
     Parameters.ParamValues['@op'] := 1;
     Parameters.ParamValues['@InnerCode'] := Self._InnerCode;
     Parameters.ParamValues['@DocDate'] := Self._Date;
     Parameters.ParamValues['@DocNo'] := Self._DocNo;
     Parameters.ParamValues['@Deleted'] := Self._Delete;
     Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
     Parameters.ParamValues['@RouteCode'] := Self._RouteCode;
     Parameters.ParamValues['@EmployeeCode'] := Self._EmployeeCode;
     Parameters.ParamValues['@BuypointCode'] := Self._BuypointCode;
     Parameters.ParamValues['@Comment'] := Self._Comment + ' - НЕДОСТАЧА ТОВАРА';
     Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
     Parameters.ParamValues['@CounteragentCode'] := Self._CAgentCode;
     Parameters.ParamValues['@DeliveryDate'] := Self._DeliveryDate;
     Parameters.ParamValues['@DeliveryTimeFrom'] := Self._DeliveryTimeFrom;
     Parameters.ParamValues['@DeliveryTimeTo'] := Self._DeliveryTimeTo;
     Parameters.ParamValues['@DeliveryRouteCode'] := Self._DeliveryRouteCode;
     Parameters.ParamValues['@CurrencyCode'] := Self._CurrencyCode;
     Parameters.ParamValues['@bw'] := Self._bw;
     Parameters.ParamValues['@PayTypeCode'] := Self._PayTypeCode;
     Parameters.ParamValues['@UseVatRate'] := Self._UseVatRate;
     Parameters.ParamValues['@IncludeVat'] := Self._IncludeVat;
     Parameters.ParamValues['@PDADocNum'] := Self._PDADocNum;
    // Parameters.ParamValues['@UseVat'] := Self._FormCode;
     ExecProc;
     Self._RegDocNo := Parameters.ParamValues['@RegDocCode'];
    // Self._CurrentStore := Parameters.ParamValues['@StoreCode'];
     Self._ReturnCode := Parameters.ParamValues['@RETURN_VALUE'];
     Self._DiscountRate := Parameters.ParamValues['@DiscountRate'];
    // if not VarIsNull(Parameters.ParamValues['@ReservedStoreCode']) then
     // Self._ReservedStore := Parameters.ParamValues['@ReservedStoreCode'];
       Self._ReservedStore := Self._CurrentStore;
    end;
    if Self._ReturnCode = 0 then
    begin
     (* Парсинг строк документа *)
      Self._RowNum := 1;
      Self._ReservedRowNum := 1;
      Self._CurrentRow := 0;
      Self._CurrentRezRow := 0;
      for I := 0 to L - 1 do
      if Self._ListSKUNullRemain[i].ReservedQuantity > 0 then
      with Self._StoredProcRow do
       begin
        Close;
        Parameters.ParamValues['@op'] := 1;
        Parameters.ParamValues['@BuyerCode'] := Self._BuyerCode;
        Parameters.ParamValues['@RegDocCode'] := Self._RegDocNo;
        Parameters.ParamValues['@StoreCode'] := Self._CurrentStore;
        Parameters.ParamValues['@FirmCode'] := Self._FirmCode;
        Parameters.ParamValues['@SKUCode'] := Self._ListSKUNullRemain[i].SkuCode;
        Parameters.ParamValues['@Position'] := Self._RowNum;
        Parameters.ParamValues['@UnitCode'] := Self._ListSKUNullRemain[i].UnitCode;
        Parameters.ParamValues['@UnitFactor'] := Self._ListSKUNullRemain[i].UnitFactor;
        Parameters.ParamValues['@Quantity'] := Self._ListSKUNullRemain[i].ReservedQuantity;
        Parameters.ParamValues['@PriceDiscount'] := Self._ListSKUNullRemain[i].PriceDiscount;
        Parameters.ParamValues['@Price'] := Self._ListSKUNullRemain[i].Price;
        Parameters.ParamValues['@PriceTypeCode'] := Self._ListSKUNullRemain[i].PriceTypeCode;
        Parameters.ParamValues['@DiscountRate'] := 0;
        Parameters.ParamValues['@DiscountAmount'] := Self._ListSKUNullRemain[i].DiscountAmount;
        Parameters.ParamValues['@Amount'] := Self._ListSKUNullRemain[i].ReservedQuantity*Self._ListSKUNullRemain[i].Price;
        Parameters.ParamValues['@VATRate'] := Self._ListSKUNullRemain[i].VATRate;
        Parameters.ParamValues['@VATAmount'] := Self._ListSKUNullRemain[i].VATAmount;
        Parameters.ParamValues['@RecommendedQuantity'] := Self._ListSKUNullRemain[i].RecommendedQuantity;
        ExecProc;
        if not VarIsNull(Parameters.ParamValues['@RowCount']) then
         Self._CurrentRow := Parameters.ParamValues['@RowCount'];
        Self._RowNum := Self._RowNum + Self._CurrentRow;
       end;
    end;
//   Self._Connection.CommitTrans;
  except
   on E:Exception do
    begin
//     Self._Connection.RollbackTrans;
    end;
  end;
end;

procedure TImportObject.SetDefaultHeaderValues;
begin
  Self._InnerCode := '';
  Self._outercode:='0';
  Self._Date := '';
  Self._DocNo := '';
  Self._CreatorCode := 0;
  Self._Delete:= 0;
  Self._FirmCode := 0;
  Self._RouteCode := 0;
  Self._EmployeeCode := 0;
  Self._BuyPointCode := ' ';
  Self._Comment := '';
  Self._BuyerCode := 0;
  Self._CAgentCode := 0;
  Self._DeliveryDate := '';
  Self._DeliveryTimeTo := '';
  Self._DeliveryTimeFrom := '';
  Self._DeliveryRouteCode := 0;
  Self._CurrencyCode := 0;
  Self._bw := 0;
  Self._PayTypeCode := 0;
  Self._DiscountRate := 0;
  Self._UseVatRate := 0;
  Self._IncludeVat := 0;
  Self._FormCode := 0;
  Self._PDARouteCode := 0;
  Self._PDADocNum := 0;
  Self._CreateDate := '';
  Self._RegNo := 0;
  Self._RegDocNo := 0;
  Self._CurrentStore := 0;
  Self._ReservedStore := 0;
end;

procedure TImportObject.SetDefaultRowsValues;
begin
  Self._SkuCode := 0;
  Self._UnitCode := 0;
  Self._UnitFactor := 0;
  Self._Quantity := 0;
  Self._Price := 0;
  Self._PriceDiscount := 0;
  Self._PriceTypeCode := 0;
  Self._DiscountAmount := 0;
  Self._Amount := 0;
  Self._VatRate := 0;
  Self._VatAmount := 0;
  Self._RecommendedQuantity := 0;
  Self._ReservedQuantity := -1;
end;


procedure TImportObject.SetFileName(const Value: string);
begin
  Self._FileLogName := Value;
end;

procedure TImportObject.SetLogFileName(const Value: string);
begin
  Self._FileName := Value;
end;

procedure TImportObject.SetMessage(const Title, Msg: string);
var
 j:integer;
begin
  Self._LogFile.Add(DateTimeToStr(Now), Title, Msg);
  if Title='Ошибка импорта' then
   begin
    j:=Length(Self._ListErrMsg);
    SetLength(Self._ListErrMsg,j+1);
    Self._ListErrMsg[j].ErrorTitle:=Title;
    Self._ListErrMsg[j].ErrorMsg:=Msg;
   end;
end;

procedure TImportObject.SetTypeLogged(const Value: boolean);
begin
  Self.StopLogging;
  case Value of
    False: begin //Write to files
      Self._LogFile.SizeLimit := 0;
    end;
    True: begin //Write to one file
      Self._LogFile.SizeLimit := Self._Size;
    end;
  end;
end;

procedure TImportObject.SetWorkPath(const Value: string);
begin
  Self._WorkPath := Value;
end;

procedure TImportObject.StartLogging;
begin
  if FileExists(Self._FileName) then
    Self._LogFile.LoadFromFile(Self._FileName);
end;

procedure TImportObject.StartParcings;
begin
  if FileExists(Self._FileLogName) then
  begin
    try
      Self.SetMessage('Обработка заказов', 'Начата обработка заказов.');
      Self._FileLogParcer.LoadFromFile(Self._FileLogName);
      if FileExists(Self._WorkPath + '\confirmationslog.xml') then
      begin
        Self._ConfirmationLogParcer.LoadFromFile(Self._WorkPath + '\confirmationslog.xml');
        Self._ConfirmationLogDataNode := Self._ConfirmationLogParcer.Root.Items.ItemNamed['confirmations'];
      end
      else
      begin
        Self._ConfirmationLogNode := Self._ConfirmationLogParcer.Root.Items.Add('confirmationslog');
        Self._ConfirmationLogDataNode := Self._ConfirmationLogNode.Items.Add('confirmations');
      end;
      Self._ConfirmationDocsNode := Self._ConfirmationDocParcer.Root.Items.Add('confirmations');
      Self._ConfirmationDocNode := Self._ConfirmationDocsNode.Items.Add('confirmations');
      Self.GetXMLFileLogData(Self._FileLogParcer.Root);
    finally
      (* Saved confirmations document *)
      _sFileName := 'confirmation' + CurrentDateTimeToString;
      Self._ConfirmationDocParcer.SaveToFile(Self._WorkPath + '\confirmation\' + _sFileName + '.xml',seutf8, 65001);
      (* Saved confirmationslog.xml *)
      Self._ConfirmationLogDataNode.Items.Add(_sFileName);
      Self._ConfirmationLogDataNode.Items.ItemNamed[_sFilename].Properties.Add('status', 'false');
      Self._ConfirmationLogParcer.SaveToFile(Self._WorkPath + '\confirmationslog.xml', seutf8, 65001);
      Self._FileLogParcer.SaveToFile(Self._FileLogName);
      Self.SetMessage('Обработка заказов', 'Обработка заказов завершена.');
    end;
  end
  else
   Self.SetMessage('Обработка заказов', 'Файл не найден!');
end;

procedure TImportObject.StopLogging;
begin
  Self._LogFile.SaveToFile(Self._FileName);
end;

function TImportObject.StrReplace(const Str, Str1, Str2: string): string;
var
  P, L: Integer;
begin
  Result := str;
  L := Length(Str1);
  repeat
    P := Pos(Str1, Result);
    if P > 0 then
    begin
      Delete(Result, P, L);
      Insert(Str2, Result, P);
    end;
  until P = 0;
end;

end.
