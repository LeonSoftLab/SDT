unit SettingsSheduleDetailsFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, JvExCheckLst, JvCheckListBox, ExtCtrls, Mask,
  JvExMask, JvSpin;

type
  TfSheduleTaskDetail = class(TForm)
    GroupBox1: TGroupBox;
    cmbTaskType: TComboBox;
    GroupBox2: TGroupBox;
    rbRunOne: TRadioButton;
    rbRunPeriod: TRadioButton;
    GroupBox3: TGroupBox;
    chAllDays: TCheckBox;
    chListDays: TJvCheckListBox;
    GroupBox4: TGroupBox;
    JvTimeEdit1: TJvTimeEdit;
    JvTimeEdit2: TJvTimeEdit;
    JvTimeEdit3: TJvTimeEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button_GetFileName: TButton;
    OpenDialog1: TOpenDialog;
    Edit_Param: TEdit;
    procedure chAllDaysClick(Sender: TObject);
    procedure chListDaysClickCheck(Sender: TObject);
    procedure rbRunPeriodClick(Sender: TObject);
    procedure rbRunOneClick(Sender: TObject);
    procedure Button_GetFileNameClick(Sender: TObject);
    procedure cmbTaskTypeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSheduleTaskDetail: TfSheduleTaskDetail;

implementation

uses MainFormUnit;

{$R *.dfm}

procedure TfSheduleTaskDetail.Button_GetFileNameClick(Sender: TObject);
begin
OpenDialog1.DefaultExt:=tSettingfile.GetStringValue('Folders', 'LogFolder');
if OpenDialog1.Execute then
 begin
  Edit_Param.Text:=OpenDialog1.FileName;
 end;
end;

procedure TfSheduleTaskDetail.chAllDaysClick(Sender: TObject);
begin
  if chAllDays.Checked then
  begin
    chListDays.CheckAll;
  end;
end;

procedure TfSheduleTaskDetail.chListDaysClickCheck(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to chListDays.Items.Count - 1 do
  begin
    if chListDays.Checked[i] = False then
      chAllDays.Checked := False;
  end;
end;

procedure TfSheduleTaskDetail.cmbTaskTypeChange(Sender: TObject);
begin
if (cmbTaskType.Text='Формирование данных для кпк') or (cmbTaskType.Text='Рестарт службы') then
 begin Edit_Param.Enabled:=true; Button_GetFileName.Enabled:=true; end
else
 begin Edit_Param.Enabled:=false; Button_GetFileName.Enabled:=false; end
end;

procedure TfSheduleTaskDetail.rbRunOneClick(Sender: TObject);
begin
  if rbRunOne.Checked then
  begin
    JvTimeEdit2.Text := '--:--';
    JvTimeEdit3.Text := '--:--';
    JvTimeEdit2.Enabled := False;
    JvTimeEdit3.Enabled := False;
  end;
end;

procedure TfSheduleTaskDetail.rbRunPeriodClick(Sender: TObject);
begin
  if rbRunPeriod.Checked then
  begin
    JvTimeEdit2.Enabled := True;
    JvTimeEdit3.Enabled := True;
    JvTimeEdit2.Text := '00:01';
    JvTimeEdit3.Text := '20:00';
  end;
end;

end.
