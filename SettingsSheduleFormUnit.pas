unit SettingsSheduleFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ImgList, ComCtrls, ToolWin;

type
  TfSheduleSett = class(TForm)
    Button1: TButton;
    ToolBar1: TToolBar;
    tbAdd: TToolButton;
    ImageList1: TImageList;
    tbDel: TToolButton;
    tbEdit: TToolButton;
    chSheduleActive: TCheckBox;
    wListShedule: TListView;
    procedure tbAddClick(Sender: TObject);
    procedure tbEditClick(Sender: TObject);
    procedure tbDelClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetSheduleRec(const index:integer; TaskName, TaskType, Days, TimeStart, Period, TimeEnd, filename: string);
  public
    { Public declarations }
  end;

var
  fSheduleSett: TfSheduleSett;

implementation

uses FunctionsUnit, SettingsSheduleDetailsFormUnit;

{$R *.dfm}

procedure TfSheduleSett.SetSheduleRec(const index:integer; TaskName, TaskType, Days, TimeStart,
  Period, TimeEnd, filename: string);
begin
if index=wListShedule.Items.Count then
  begin
    wListShedule.Items.Add.SubItems.Add(TaskName);
    wListShedule.Items[index].SubItems.Add(TaskType);
    wListShedule.Items[index].SubItems.Add(Days);
    wListShedule.Items[index].SubItems.Add(TimeStart);
    wListShedule.Items[index].SubItems.Add(Period);
    wListShedule.Items[index].SubItems.Add(TimeEnd);
    wListShedule.Items[index].SubItems.Add(filename);
  end
 else
  begin
    wListShedule.Items[index].SubItems[0]:=TaskName;
    wListShedule.Items[index].SubItems[1]:=TaskType;
    wListShedule.Items[index].SubItems[2]:=Days;
    wListShedule.Items[index].SubItems[3]:=TimeStart;
    wListShedule.Items[index].SubItems[4]:=Period;
    wListShedule.Items[index].SubItems[5]:=TimeEnd;
    wListShedule.Items[index].SubItems[6]:=filename;
  end;
end;

procedure TfSheduleSett.tbAddClick(Sender: TObject);
var
  fShDetail: TfSheduleTaskDetail;
  i: Integer;
  RunType, days: string;
begin
  try
    fShDetail := TfSheduleTaskDetail.Create(Self);
    fShDetail.JvTimeEdit1.Time := Time;
    fShDetail.JvTimeEdit2.Time := Time;
    fShDetail.JvTimeEdit3.Time := Time;
    fShDetail.ShowModal;
    if fShDetail.ModalResult = mrOk then
    begin
      if fShDetail.rbRunOne.Checked then   //интервал
        RunType := 'Однократно'
      else
        RunType := 'По интервалу';
     for i := 0 to fShDetail.chListDays.Items.Count - 1 do // дни недели
     begin
       if fShDetail.chListDays.Checked[i] then
       begin
         days := days + IntToStr(i + 1) + ';';
       end;
     end;
     SetSheduleRec(wListShedule.Items.Count, fShDetail.cmbTaskType.Text, RunType, Days, fShDetail.JvTimeEdit1.Text,
      fShDetail.JvTimeEdit2.Text, fShDetail.JvTimeEdit3.Text, fShDetail.Edit_Param.Text);
    end;
  finally
    FreeAndNil(fShDetail);
  end;
end;

procedure TfSheduleSett.tbDelClick(Sender: TObject);
begin
if wListShedule.Items.Count<>0 then
wListShedule.Items.Delete(wListShedule.ItemIndex);
end;

procedure TfSheduleSett.tbEditClick(Sender: TObject);
var
  fShDetail: TfSheduleTaskDetail;
  i: Integer;
  RunType, days, NumberDay: string;
begin
if wListShedule.Items.Count<>0 then
  try
    fShDetail := TfSheduleTaskDetail.Create(Self);
    fShDetail.cmbTaskType.Text:=wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[0];
    fShDetail.cmbTaskType.ItemIndex:=fShDetail.cmbTaskType.Items.IndexOf(wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[0]);
    fShDetail.cmbTaskTypeChange(self);
    fShDetail.rbRunOne.Checked:=wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[1]='Однократно';
    fShDetail.rbRunPeriod.Checked:=wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[1]='По интервалу';
    fShDetail.chAllDays.Checked:=true;
    for i := 0 to fShDetail.chListDays.Items.Count - 1 do
     fShDetail.chListDays.Checked[i]:=false;
    days:=wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[2];
    for i:=1 to Length(days) do
     if (Copy(days,i,1)<>';')and(Copy(days,i,1)<>'') then
      begin
       NumberDay:=Copy(days,i,1);
       fShDetail.chListDays.Checked[strtoint(NumberDay)-1]:=true;
      end;
    for i := 0 to fShDetail.chListDays.Items.Count - 1 do
     if not fShDetail.chListDays.Checked[i] then
      fShDetail.chAllDays.Checked:=false;
    days:='';
    wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[3];
    fShDetail.JvTimeEdit1.Text := wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[3];
    fShDetail.JvTimeEdit2.Text := wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[4];
    fShDetail.JvTimeEdit3.Text := wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[5];
    fShDetail.Edit_Param.Text := wListShedule.Items.Item[wListShedule.ItemIndex].SubItems.Strings[6];
    fShDetail.ShowModal;
    if fShDetail.ModalResult = mrOk then
    begin
      if fShDetail.rbRunOne.Checked then   //интервал
        RunType := 'Однократно'
      else
        RunType := 'По интервалу';
     for i := 0 to fShDetail.chListDays.Items.Count - 1 do // дни недели
     begin
       if fShDetail.chListDays.Checked[i] then
       begin
         days := days + IntToStr(i + 1) + ';';
       end;
     end;
     SetSheduleRec(wListShedule.ItemIndex, fShDetail.cmbTaskType.Text, RunType, Days, fShDetail.JvTimeEdit1.Text,
      fShDetail.JvTimeEdit2.Text, fShDetail.JvTimeEdit3.Text, fShDetail.Edit_Param.Text);
    end;
  finally
    FreeAndNil(fShDetail);
  end;
end;

end.
