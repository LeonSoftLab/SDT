unit Unit_PriceTable;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, Grids, DBGrids, StdCtrls, Buttons, IniFiles, ADODB,
  Menus, DateUtils;

type
  TForm_PriceTable = class(TForm)
    DBGrid_refPriceTypes: TDBGrid;
    ToolBar1: TToolBar;
    BitBtn_Add: TBitBtn;
    BitBtn_Edit: TBitBtn;
    BitBtn_Delete: TBitBtn;
    BitBtn_Restore: TBitBtn;
    CheckBox_ShowDeleted: TCheckBox;
    Label1: TLabel;
    BitBtn_OpenPriceList: TBitBtn;
    StatusBar1: TStatusBar;
    BitBtn_AutoCheckUpdate: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure CheckBox_ShowDeletedClick(Sender: TObject);
    procedure BitBtn_OpenPriceListClick(Sender: TObject);
    procedure BitBtn_AddClick(Sender: TObject);
    procedure BitBtn_EditClick(Sender: TObject);
    procedure BitBtn_DeleteClick(Sender: TObject);
    procedure BitBtn_RestoreClick(Sender: TObject);
    procedure BitBtn_AutoCheckUpdateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form_PriceTable: TForm_PriceTable;

  ConnectString,ServerName,UserName,Password,DataBaseName:string;
  Autentification,AutoConnect:boolean;


implementation

uses DataModuleUnit, MainFormUnit, Unit_AutoUpdatePrice, Unit_PriceList,
  Unit_RowPriceInfo, UnitEditPriceType, FunctionsUnit;


{$R *.dfm}

procedure TForm_PriceTable.BitBtn_AddClick(Sender: TObject);
begin
Form_EditPriceType.Edit1.Text:='';
Form_EditPriceType.Edit2.Text:='';
Form_EditPriceType.Edit3.Text:='';
Form_EditPriceType.DateTimePicker1.Date:=Date;
Form_EditPriceType.CheckBox1.Checked:=true;
Form_EditPriceType.Edit4.Text:='';
Form_EditPriceType.CheckBox2.Checked:=false;
Form_EditPriceType.isEdit:=false;
Form_EditPriceType.Show;
end;

procedure TForm_PriceTable.BitBtn_AutoCheckUpdateClick(Sender: TObject);
var
i,Code:integer;
E:error;
Names,FullNames,Comment,tempDate:string;
Dates:TDate;
xYear,xMonth,xDay,NewPrices:Word;
begin
try
Form_AutoUpdatePrice.Memo1.Lines.Clear;
Form_AutoUpdatePrice.Memo1.Lines.Add(timetostr(Time)+' ============= Старт проверки прайсов =============');
Cursor:=crHourGlass;
try
Form_AutoUpdatePrice.Show;
Application.ProcessMessages;
NewPrices:=0;
mData.ADODataSet_GetPriceFromOT.Close;
mData.ADODataSet_GetPriceFromOT.Open;
mData.ADODataSet_GetPriceFromOT.First;
for i:=1 to mData.ADODataSet_GetPriceFromOT.RecordCount do
 begin
 try
  Code:=mData.ADODataSet_GetPriceFromOT.FieldByName('Code').AsInteger;
  mData.ADODataSet_ExistsPriceType.Close;
  mData.ADODataSet_ExistsPriceType.CommandText:='SELECT ['+mData.ADOConn.DefaultDatabase+'].[dbo].[ExistsPriceType] ('+IntToStr(Code)+') [Result]';
  mData.ADODataSet_ExistsPriceType.Open;
  if mData.ADODataSet_ExistsPriceType.RecordCount <>0 then
   begin
    mData.ADODataSet_ExistsPriceType.First;
    if mData.ADODataSet_ExistsPriceType.FieldByName('Result').AsBoolean=False then  { не существует}
     begin
      FullNames:=mData.ADODataSet_GetPriceFromOT.FieldByName('Name').AsString;
      Code:=mData.ADODataSet_GetPriceFromOT.FieldByName('Code').AsInteger;
      Comment:=mData.ADODataSet_GetPriceFromOT.FieldByName('Comment').AsString;
      if Pos(')',FullNames)<Length(FullNames)-1 then
        Names:=copy(FullNames,Pos('(',FullNames),pos(',',FullNames)-Pos('(',FullNames))+')'+copy(FullNames,Pos(')',FullNames)+1,length(FullNames)-Pos(')',FullNames))
      else
      Names:=FullNames;
       try
        tempDate:=copy(Comment,pos('.',Comment)-2,length(Comment));
        xDay:=StrToIntDef(copy(tempDate,1,pos('.',tempDate)-1),DayOfTheMonth(now));
        Delete(tempDate,1,pos('.',tempDate));
        xMonth:=StrToIntDef(copy(tempDate,1,pos('.',tempDate)-1),MonthOfTheYear(now));
        Delete(tempDate,1,pos('.',tempDate));
        xYear:=StrToIntDef(copy(tempDate,1,length(tempDate)),YearOf(now));
        Dates:=EncodeDate(xYear,xMonth,xDay);
       except
        Dates:=now;
       end;
      DateTimeToString(tempDate,'DD.MM.YYYY',Dates);
       NewPrices:=NewPrices+1;
       Form_AutoUpdatePrice.Memo1.Lines.Add('------------- Найден Новый прайс: '+inttostr(Code)+'-----------------');
       Form_AutoUpdatePrice.Memo1.Lines.Add('Name in OT:          '+FullNames);
       Form_AutoUpdatePrice.Memo1.Lines.Add('Code in OT:          '+inttostr(Code));
       Form_AutoUpdatePrice.Memo1.Lines.Add('Comment in OT:       '+Comment);
       Form_AutoUpdatePrice.Memo1.Lines.Add('Будет добавлен с такими параметрами:');
       Form_AutoUpdatePrice.Memo1.Lines.Add('Code:            '+inttostr(Code));
       Form_AutoUpdatePrice.Memo1.Lines.Add('Name:            '+Names);
       Form_AutoUpdatePrice.Memo1.Lines.Add('CrDate:          '+DateToStr(Dates));
       Form_AutoUpdatePrice.Memo1.Lines.Add('---------------------------------------------------');
     end
    else
     begin
     if mData.ADODataSet_ExistsPriceType.FieldByName('Result').AsBoolean=True then
      Form_AutoUpdatePrice.Memo1.Lines.Add('Прайс '+IntToStr(Code)+' существует.');
      //Result='1' (существует)
     end;
   end;
 except
  on E:Exception do
   begin
    Form_AutoUpdatePrice.Memo1.Lines.Add('-------- ERROR --------');
    Form_AutoUpdatePrice.Memo1.Lines.Add('Code in OT:   '+inttostr(Code));
    Form_AutoUpdatePrice.Memo1.Lines.Add('Code in OT:   '+inttostr(Code));
    Form_AutoUpdatePrice.Memo1.Lines.Add('Code in OT:   '+inttostr(Code));
   end;
 end;
  mData.ADODataSet_GetPriceFromOT.Next;
 end;
Form_AutoUpdatePrice.Memo1.Lines.Add('================ Проверка прайсов завершена ================');
Form_AutoUpdatePrice.Memo1.Lines.Add('Найдено '+IntToStr(NewPrices)+' новых прайсов.');
except
 on E:Exception do
  begin
   Cursor:=crDefault;
   MessageBox(Handle,pchar('Возникла ошибка при обновлении прайсов: '+#13+e.Message),'Ошибка',16);
  end;
end;
Cursor:=crDefault;
finally
Cursor:=crDefault;
Form_AutoUpdatePrice.Memo1.Lines.SaveToFile(tSettingFile.GetStringValue('Folders', 'LogFolder')+'\LogPriceEdit'+CurrentDateTimeToString+'.logs');
end;
end;

procedure TForm_PriceTable.BitBtn_DeleteClick(Sender: TObject);
var
E:Error;
tmpID:Int64;
f:textfile;
begin
if MessageBox(handle,'Вы действительно хотите пометить запись удалением?','Внимание!',MB_ICONQUESTION+MB_YESNO)=IDYES then
begin
try
AssignFile(f,tSettingFile.GetStringValue('Folders', 'LogFolder')+'\LogPriceEdit'+CurrentDateTimeToString+'.logs');
Rewrite(f);
Cursor:=crHourGlass;
tmpID:=mData.ADOTable_refPriceType.FieldByName('id').AsInteger;
mData.ADOTable_refPriceType.Active:=false;
 try
  mData.ADOConn.BeginTrans;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@ID']:=tmpID;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@deleted']:=true;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@isedit']:=2;
  mData.ADOStoredProc_InsertPriceType.ExecProc;
  mData.ADOConn.CommitTrans;
  Writeln(f,'Прайс ID= '+inttostr(tmpID));
  Writeln(f,'был помечен удалением');
 except
  on E:Exception do
   begin
    mData.ADOConn.RollbackTrans;
    MessageBox(Handle,pchar('Не удалось установить метку "удален" по причине: '+E.Message),'Ошибка',16);
   end;
 end;
mData.ADOTable_refPriceType.Active:=true;
finally
Cursor:=crDefault;
CloseFile(f);
end;
end;
end;

procedure TForm_PriceTable.BitBtn_EditClick(Sender: TObject);
begin
Form_EditPriceType.Edit1.Text:=mData.ADOTable_refPriceType.FieldByName('Name').AsString;
Form_EditPriceType.Edit2.Text:=mData.ADOTable_refPriceType.FieldByName('idBasePriceType').AsString;
Form_EditPriceType.Edit3.Text:=mData.ADOTable_refPriceType.FieldByName('idCurrency').AsString;
Form_EditPriceType.DateTimePicker1.Date:=mData.ADOTable_refPriceType.FieldByName('CrDate').AsDateTime;
Form_EditPriceType.DateTimePicker2.Date:=mData.ADOTable_refPriceType.FieldByName('EndDate').AsDateTime;
Form_EditPriceType.CheckBox1.Checked:=mData.ADOTable_refPriceType.FieldByName('IsActive').AsBoolean;
Form_EditPriceType.Edit4.Text:=mData.ADOTable_refPriceType.FieldByName('Code').AsString;
Form_EditPriceType.CheckBox2.Checked:=mData.ADOTable_refPriceType.FieldByName('deleted').AsBoolean;
Form_EditPriceType.ID:=mData.ADOTable_refPriceType.FieldByName('id').AsInteger;
Form_EditPriceType.isEdit:=true;
Form_EditPriceType.Show;
end;

procedure TForm_PriceTable.BitBtn_OpenPriceListClick(Sender: TObject);
begin
Cursor:=crHourGlass;
mData.ADOQuery_refPriceList.Close;
mData.ADOQuery_refPriceList.SQL.Text:='SELECT [id],[Price],[idGoods],[idPriceType],[idUnit],[idPayType],[deleted] FROM ['+mData.ADOConn.DefaultDatabase+'].[dbo].[refPriceList] WHERE [idPriceType]='+mData.ADOTable_refPriceType.FieldByName('id').AsString;
mData.ADOQuery_refPriceList.Open;
Cursor:=crDefault;
Form_PriceList.Show;
end;

procedure TForm_PriceTable.BitBtn_RestoreClick(Sender: TObject);
var
E:error;
tmpID:Int64;
f:textfile;
begin
try
AssignFile(f,tSettingFile.GetStringValue('Folders', 'LogFolder')+'\LogPriceEdit'+CurrentDateTimeToString+'.logs');
Rewrite(f);
tmpID:=mData.ADOTable_refPriceType.FieldByName('id').AsInteger;
mData.ADOTable_refPriceType.Active:=false;
try
  mData.ADOConn.BeginTrans;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@ID']:=tmpID;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@deleted']:=false;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@isedit']:=2;
  mData.ADOStoredProc_InsertPriceType.ExecProc;
  mData.ADOConn.CommitTrans;
  Writeln(f,'Прайс ID= '+inttostr(tmpID));
  Writeln(f,'был восстановлен');
 except
  on E:Exception do
   begin
    mData.ADOConn.RollbackTrans;
    MessageBox(Handle,pchar('Не удалось снять метку "удален" по причине: '+E.Message),'Ошибка',16);
   end;
end;
mData.ADOTable_refPriceType.Active:=true;
finally
Cursor:=crDefault;
CloseFile(f);
end;
end;

procedure TForm_PriceTable.CheckBox_ShowDeletedClick(Sender: TObject);
begin
mData.ADOTable_refPriceType.Active:=false;
mData.ADOTable_refPriceType.Filtered:= not CheckBox_ShowDeleted.Checked;
mData.ADOTable_refPriceType.Active:=true;
end;

procedure TForm_PriceTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
mData.ADOConn.Connected:=false;
end;

end.
