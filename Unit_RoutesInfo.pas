unit Unit_RoutesInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm_RoutesInfo = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
// id, Name, Deleted, Code, IsOffice, IdLandStore(refStores.Id), refStores.Name , idPosition(refPositions.Id), refPositions.Name
var
  Form_RoutesInfo: TForm_RoutesInfo;

implementation

uses Unit_ExpAllShed;

{$R *.dfm}

end.
