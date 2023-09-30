unit Unit_Add_Goods;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls;

type
  TForm_Add_Goods = class(TForm)
    DBGrid1: TDBGrid;
    Label1: TLabel;
    DBGrid2: TDBGrid;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_Add_Goods: TForm_Add_Goods;

implementation

uses DataModuleUnit;

{$R *.dfm}

procedure TForm_Add_Goods.Button1Click(Sender: TObject);
begin
mData.ADOQuery_Goods.Close;
mData.ADOQuery_Goods.SQL.Text:=Edit1.Text;
mData.ADOQuery_Goods.Open;
end;

procedure TForm_Add_Goods.Button2Click(Sender: TObject);
begin
mData.ADOQuery_Goods_Type.Close;
mData.ADOQuery_Goods_Type.SQL.Text:=Edit2.Text;
mData.ADOQuery_Goods_Type.Open;
end;

procedure TForm_Add_Goods.Button3Click(Sender: TObject);
var
CodeGood:Int64;
IDtype:Int64;
begin
CodeGood:=mData.ADOQuery_Goods.FieldByName('Code').AsInteger;
IDtype:=mData.ADOTable_Mustok_Type.FieldByName('ID').AsInteger;
mData.ADOTable_Mustok_Row.Insert;
mData.ADOTable_Mustok_Row.FieldByName('idType').AsInteger:=IDtype;
mData.ADOTable_Mustok_Row.FieldByName('CodeGood').AsInteger:=CodeGood;
mData.ADOTable_Mustok_Row.FieldByName('IsActive').AsBoolean:=true;
mData.ADOTable_Mustok_Row.Post;
end;

procedure TForm_Add_Goods.Button4Click(Sender: TObject);
var
CodeGood:Int64;
CodeGroup:int64;
i:integer;
begin
CodeGroup:=mData.ADOQuery_Goods_Type.FieldByName('id').AsInteger;
Edit1.Text:='USE workot SELECT * FROM [workot].[dbo].[refGoods] WHERE deleted=0 and idgroup='+inttostr(CodeGroup);
Button1.Click;
end;

end.
