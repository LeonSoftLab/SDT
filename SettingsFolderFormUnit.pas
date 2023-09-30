unit SettingsFolderFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, JvExMask, JvToolEdit, ImgList;

type
  TfSettingsFolders = class(TForm)
    edtWorkDirectory: TJvDirectoryEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtLogDirectory: TJvDirectoryEdit;
    btnSave: TButton;
    btnCancel: TButton;
    ImageList_SettingsFolders: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSettingsFolders: TfSettingsFolders;

implementation

{$R *.dfm}

end.
