unit Unit_Mustok;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, DBGrids, ToolWin, ExtCtrls, DBCtrls, StdCtrls;

type
  TForm_Mustok = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    DBGrid_Mustok_Type: TDBGrid;
    DBGrid_Mustok: TDBGrid;
    DBGrid_Mustok_Rows: TDBGrid;
    ToolBar1: TToolBar;
    DBNavigator_Mustok_Type: TDBNavigator;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    DBNavigator_Mustok: TDBNavigator;
    DBNavigator_Mustok_Rows: TDBNavigator;
    Button_AddGoods: TButton;
    ToolBar4: TToolBar;
    Label_Good_Info: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_AddGoodsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_Mustok: TForm_Mustok;

implementation

uses MainFormUnit, DataModuleUnit, Unit_Add_Goods;

{$R *.dfm}

procedure TForm_Mustok.Button_AddGoodsClick(Sender: TObject);
begin
Form_Add_Goods.Show;
end;

procedure TForm_Mustok.FormClose(Sender: TObject; var Action: TCloseAction);
begin
mData.ADOConn.Connected:=false;
end;

end.
