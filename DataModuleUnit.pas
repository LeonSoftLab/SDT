unit DataModuleUnit;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TmData = class(TDataModule)
    Connection: TADOConnection;
    dsDatabases: TADODataSet;
    spDocuments: TADOStoredProc;
    dsDocHeaders: TADODataSet;
    dsDocRows: TADODataSet;
    DataSource_refPriceType: TDataSource;
    ADOTable_refPriceType: TADOTable;
    DataSource_refPriceList: TDataSource;
    ADOStoredProc_InsertPriceType: TADOStoredProc;
    ADOQuery_Info: TADOQuery;
    DataSource_Info: TDataSource;
    ADOQuery_refPriceList: TADOQuery;
    ADODataSet_GetPriceFromOT: TADODataSet;
    ADODataSet_ExistsPriceType: TADODataSet;
    ADOConn: TADOConnection;
    ADODataSet_GetInfo: TADODataSet;
    ADOStoredProc_ExpAllShedbyRoute: TADOStoredProc;
    ADOConn_Chicago: TADOConnection;
    DataSource_Mustok_Type: TDataSource;
    DataSource_Mustok: TDataSource;
    DataSource_Mustok_Row: TDataSource;
    ADOTable_Mustok_Type: TADOTable;
    ADOTable_Mustok: TADOTable;
    ADOTable_Mustok_Row: TADOTable;
    ADOQuery_Goods: TADOQuery;
    ADOQuery_Goods_Type: TADOQuery;
    DataSource_Goods: TDataSource;
    DataSource_Goods_Type: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure ADOTable_Mustok_RowAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  mData: TmData;

implementation

uses MainFormUnit, Unit_Mustok;

{$R *.dfm}

procedure TmData.ADOTable_Mustok_RowAfterScroll(DataSet: TDataSet);
var
E:error;
begin
try
if ADOTable_Mustok_Row.Active then
begin
ADOQuery_Info.Close;
ADOQuery_Info.SQL.Text:=' use [workot_UAH] '+
 ' IF EXISTS '+
 ' (SELECT [FullName] AS [GoodName] FROM [workot].[dbo].[refGoods] WHERE [Code]='+ADOTable_Mustok_Row.FieldByName('CodeGood').AsString+') '+
 ' begin '+
 ' SELECT [FullName] AS [GoodName] FROM [workot].[dbo].[refGoods] WHERE [Code]='+ADOTable_Mustok_Row.FieldByName('CodeGood').AsString+
 ' end '+
 ' ELSE '+
 ' begin '+
 ' SELECT TOP 1 ''Не существует!'' AS [GoodName] FROM [workot].[dbo].[refGoods]'+
 ' end';
ADOQuery_Info.Open;
if ADOQuery_Info.Fields.Count>0 then
Form_Mustok.Label_Good_Info.Caption:=ADOQuery_Info.FieldByName('GoodName').AsString;
end;
except
 on E:Exception do
  begin
  end;
end;
end;

procedure TmData.DataModuleCreate(Sender: TObject);
begin
  Connection.Close;
  fMain.PromptLogin:=false;
  Connection.LoginPrompt := fMain.PromptLogin;
  Connection.ConnectionString:=fMain.sConn;
//  Connection.Connected:=true;
  ADOConn.Close;
  ADOConn.ConnectionString:=fMain.sConn;
  ADOConn.LoginPrompt:=false;
  ADOConn_Chicago.Close;
  ADOConn_Chicago.ConnectionString:=fMain.sConn;
  ADOConn_Chicago.LoginPrompt:=false;
end;

end.
