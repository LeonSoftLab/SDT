unit Unit_RowPriceInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TForm_RowPriceInfo = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BitBtn_OK: TBitBtn;
    procedure BitBtn_OKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_RowPriceInfo: TForm_RowPriceInfo;

implementation

uses DataModuleUnit;


{$R *.dfm}

procedure TForm_RowPriceInfo.BitBtn_OKClick(Sender: TObject);
begin
Close;
end;

end.
