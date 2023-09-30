unit UnitEditPriceType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, ADODB;

type
  TForm_EditPriceType = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Edit3: TEdit;
    Label3: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label4: TLabel;
    Label5: TLabel;
    DateTimePicker2: TDateTimePicker;
    CheckBox1: TCheckBox;
    Edit4: TEdit;
    Label6: TLabel;
    CheckBox2: TCheckBox;
    BitBtn_Save: TBitBtn;
    BitBtn_Cancel: TBitBtn;
    procedure BitBtn_CancelClick(Sender: TObject);
    procedure BitBtn_SaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    isEdit:boolean;
    ID:Int64;
  end;

var
  Form_EditPriceType: TForm_EditPriceType;


implementation

uses DataModuleUnit, MainFormUnit, FunctionsUnit;


{$R *.dfm}

procedure TForm_EditPriceType.BitBtn_CancelClick(Sender: TObject);
begin
Close;
end;

procedure TForm_EditPriceType.BitBtn_SaveClick(Sender: TObject);
var
E:error;
f:TextFile;
begin
try
AssignFile(f,tSettingFile.GetStringValue('Folders', 'LogFolder')+'\PriceEdit'+CurrentDateTimeToString+'.logs');
Rewrite(f);
if isEdit then
 begin
 try
  mData.ADOConn.BeginTrans;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@Name']:=Edit1.Text;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@idBasePriceType']:=strtoint(Edit2.Text);
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@idCurrency']:=strtoint(Edit3.Text);
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@CrDate']:=DateTimePicker1.Date;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@EndDate']:=DateTimePicker2.Date;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@IsActive']:=CheckBox1.Checked;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@Code']:=Edit4.Text;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@deleted']:=CheckBox2.Checked;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@ID']:=ID;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@isedit']:=1;
  mData.ADOStoredProc_InsertPriceType.ExecProc;
  mData.ADOConn.CommitTrans;
  Writeln(f,'Изменен прайс:');
  Writeln(f,'[@Name]= '+Edit1.Text);
  Writeln(f,'[@idBasePriceType]= '+Edit2.Text);
  Writeln(f,'[@idCurrency]= '+Edit3.Text);
  Writeln(f,'[@CrDate]= '+datetostr(DateTimePicker1.Date));
  Writeln(f,'[@EndDate]= '+datetostr(DateTimePicker2.Date));
  Writeln(f,'[@IsActive]= '+BoolToStr(CheckBox1.Checked));
  Writeln(f,'[@Code]= '+Edit4.Text);
  Writeln(f,'[@deleted]= '+BoolToStr(CheckBox2.Checked));
  Writeln(f,'[@ID]= '+inttostr(ID));
  Writeln(f,'[@isedit]= 1');
 except
  on E:Exception do
   begin
    mData.ADOConn.RollbackTrans;
    MessageBox(Handle,pchar('Возникла ошибка при изменении типа прайса: '+e.Message+#13+'Транзакция будет отменена!'),'Ошибка',16);
   end;
 end;
 end
else
 begin
 try
  mData.ADOConn.BeginTrans;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@Name']:=Edit1.Text;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@idBasePriceType']:=strtoint(Edit2.Text);
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@idCurrency']:=strtoint(Edit3.Text);
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@CrDate']:=DateTimePicker1.Date;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@EndDate']:=DateTimePicker2.Date;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@IsActive']:=CheckBox1.Checked;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@Code']:=Edit4.Text;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@deleted']:=CheckBox2.Checked;
  mData.ADOStoredProc_InsertPriceType.Parameters.ParamValues['@isedit']:=0;
  mData.ADOStoredProc_InsertPriceType.ExecProc;
  mData.ADOConn.CommitTrans;
  Writeln(f,'Добавлен прайс:');
  Writeln(f,'[@Name]= '+Edit1.Text);
  Writeln(f,'[@idBasePriceType]= '+Edit2.Text);
  Writeln(f,'[@idCurrency]= '+Edit3.Text);
  Writeln(f,'[@CrDate]= '+datetostr(DateTimePicker1.Date));
  Writeln(f,'[@EndDate]= '+datetostr(DateTimePicker2.Date));
  Writeln(f,'[@IsActive]= '+BoolToStr(CheckBox1.Checked));
  Writeln(f,'[@Code]= '+Edit4.Text);
  Writeln(f,'[@deleted]= '+BoolToStr(CheckBox2.Checked));
  Writeln(f,'[@isedit]= 1');
 except
  on E:Exception do
   begin
    mData.ADOConn.RollbackTrans;
    MessageBox(Handle,pchar('Возникла ошибка при дабавлении типа прайса: '+e.Message+#13+'транзакция будет отменена!'),'Ошибка',16);
   end;
 end;
 end;
finally
CloseFile(f);
close;
end;
end;

end.
