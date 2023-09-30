unit Unit_AutoUpdatePrice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ToolWin, ComCtrls, Buttons, ExtCtrls, ADODB;

type
  TForm_AutoUpdatePrice = class(TForm)
    Memo1: TMemo;
    ToolBar1: TToolBar;
    BitBtn_Ok: TBitBtn;
    BitBtn_Cancel: TBitBtn;
    Shape1: TShape;
    Shape2: TShape;
    BitBtn_Clear: TBitBtn;
    procedure BitBtn_OkClick(Sender: TObject);
    procedure BitBtn_CancelClick(Sender: TObject);
    procedure BitBtn_ClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_AutoUpdatePrice: TForm_AutoUpdatePrice;

implementation

uses DataModuleUnit, MainFormUnit, FunctionsUnit, ThAutoUpdatePrice;

{$R *.dfm}

procedure TForm_AutoUpdatePrice.BitBtn_CancelClick(Sender: TObject);
begin
Close;
end;

procedure TForm_AutoUpdatePrice.BitBtn_ClearClick(Sender: TObject);
begin
Memo1.Lines.Clear;
end;

procedure TForm_AutoUpdatePrice.BitBtn_OkClick(Sender: TObject);
var
Descriptor:THandle;
begin
Descriptor := CreateMutex(nil, False, nil); TAutoUpdatePrice.Create(false,tSettingFile.GetStringValue('Folders', 'LogFolder')+'\LogPriceEdit'+CurrentDateTimeToString+'.logs',fMain.sConn,mData.Connection.DefaultDatabase,Descriptor);
end;

end.
