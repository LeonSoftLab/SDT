unit ExportTypeFormUnits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfExportType = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fExportType: TfExportType;

implementation

{$R *.dfm}

end.
