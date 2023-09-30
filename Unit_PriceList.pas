unit Unit_PriceList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ADODB, Menus;

type
  TForm_PriceList = class(TForm)
    DBGrid1: TDBGrid;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_PriceList: TForm_PriceList;

implementation

uses Unit_RowPriceInfo, DataModuleUnit;

{$R *.dfm}

procedure TForm_PriceList.DBGrid1DblClick(Sender: TObject);
var
E:Error;
begin
try
Cursor:=crHourGlass;
mData.ADOQuery_Info.Close;
mData.ADOQuery_Info.SQL.Text:='SELECT [id],[Name] FROM ['+mData.ADOConn.DefaultDatabase+'].[dbo].[refGoods] WHERE [id]='+mData.ADOQuery_refPriceList.FieldByName('idGoods').AsString;
mData.ADOQuery_Info.Open;
mData.ADOQuery_Info.First;
Form_RowPriceInfo.Edit1.Text:=mData.ADOQuery_Info.FieldByName('Name').AsString;

Form_RowPriceInfo.Edit2.Text:=mData.ADOTable_refPriceType.FieldByName('Name').AsString;

mData.ADOQuery_Info.Close;
mData.ADOQuery_Info.SQL.Text:='SELECT [id],[Name] FROM ['+mData.ADOConn.DefaultDatabase+'].[dbo].[refUnits] WHERE [id]='+mData.ADOQuery_refPriceList.FieldByName('idUnit').AsString;
mData.ADOQuery_Info.Open;
mData.ADOQuery_Info.First;
Form_RowPriceInfo.Edit3.Text:=mData.ADOQuery_Info.FieldByName('Name').AsString;

mData.ADOQuery_Info.Close;
mData.ADOQuery_Info.SQL.Text:='SELECT [id],[Name] FROM ['+mData.ADOConn.DefaultDatabase+'].[dbo].[refPayTypes] WHERE [id]='+mData.ADOQuery_refPriceList.FieldByName('idPayType').AsString;
mData.ADOQuery_Info.Open;
mData.ADOQuery_Info.First;
Form_RowPriceInfo.Edit4.Text:=mData.ADOQuery_Info.FieldByName('Name').AsString;

Form_RowPriceInfo.Edit5.Text:=mData.ADOQuery_refPriceList.FieldByName('Price').AsString;

Form_RowPriceInfo.Edit6.Text:=mData.ADOQuery_refPriceList.FieldByName('deleted').AsString;

Form_RowPriceInfo.Show;
except
 on E:Exception do
  begin
   Cursor:=crDefault;
   MessageBox(Handle,pchar('Возникла ошибка при получении информации: '+#13+e.Message),'Ошибка',16);
  end;
end;
Cursor:=crDefault;
end;

end.
