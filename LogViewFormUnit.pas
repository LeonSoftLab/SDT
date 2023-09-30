unit LogViewFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs, ComCtrls, shellapi;

type
  TfViewLog = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListBox_FileList: TListBox;
    Button_ViewByDay: TButton;
    Button_ViewByWeek: TButton;
    RadioButton_LogImort: TRadioButton;
    RadioButton_LogExport: TRadioButton;
    RadioButton_LogPrice: TRadioButton;
    Memo1: TMemo;
    RadioButton_LogGenerate: TRadioButton;
    RadioButton_LogDZ: TRadioButton;
    RadioButton_LogReferences: TRadioButton;
    Button_Arhivator: TButton;
    Button_OpenArhivesFolder: TButton;
    RadioButton_LogReturns: TRadioButton;
    ListBox1: TListBox;
    procedure RadioButton_LogExportClick(Sender: TObject);
    procedure RadioButton_LogPriceClick(Sender: TObject);
    procedure ListBox_FileListClick(Sender: TObject);
    procedure Button_ViewByDayClick(Sender: TObject);
    procedure Button_ViewByWeekClick(Sender: TObject);
    procedure RadioButton_LogImortClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton_LogGenerateClick(Sender: TObject);
    procedure RadioButton_LogDZClick(Sender: TObject);
    procedure RadioButton_LogReferencesClick(Sender: TObject);
    procedure Button_ArhivatorClick(Sender: TObject);
    procedure Button_OpenArhivesFolderClick(Sender: TObject);
    procedure RadioButton_LogReturnsClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure scandir(dir: string; lst: TStrings);
  end;

var
  fViewLog: TfViewLog;

implementation

uses MainFormUnit;
{$R *.dfm}

Procedure TfViewLog.scandir(dir: string; lst: TStrings);
Var
  SearchRec: TSearchRec;
begin
  If FindFirst(dir + '*.logs', faAnyFile, SearchRec) = 0 then
  // сканирование директории на наличие файлов
    repeat
      lst.Add(SearchRec.Name);
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
end;

procedure TfViewLog.Button_ArhivatorClick(Sender: TObject);
var
  i: integer;
  tmplst: TStringList;
  MM,MMtmp:integer;
  del:boolean;
  SearchRec: TSearchRec;
begin
if not DirectoryExists(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\') then
CreateDir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\');
if not DirectoryExists(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\'+copy(FormatDateTime('yyyymmdd', Now), 1, 6)+'\') then
CreateDir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\'+copy(FormatDateTime('yyyymmdd', Now), 1, 6)+'\');
ListBox_FileList.Items.Clear;
  tmplst := TStringList.Create;
  If FindFirst(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\' + '*.logs', faAnyFile, SearchRec) = 0 then
    repeat
      tmplst.Add(SearchRec.Name);
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  for i:=0 to tmplst.Count-1 do
   begin
    del:=false;
    MMtmp:=strtoint(copy(tmplst.Strings[i],length(tmplst.Strings[i])-14,2));
    MM:=strtoint(copy(FormatDateTime('yyyymmdd', Now), 5, 2));
    if MMtmp=MM then
     del:=true;
    MM:=MM-1;
    if MM=0 then MM:=12;
   // if MMtmp=MM then
   //  del:=true;
    if not del then
     begin
      CopyFile(pchar(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\' + tmplst.Strings[i]),
               pchar(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\'+copy(FormatDateTime('yyyymmdd', Now), 1, 6) +'\'+ tmplst.Strings[i]),
      false);
      Application.ProcessMessages;
      DeleteFile(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\' + tmplst.Strings[i]);
     end;
   end;
  Memo1.Lines.Clear;
  Memo1.Lines.Add('все логи старше прошлого месяца были архивированны.');
  FreeAndNil(tmplst);
end;

procedure TfViewLog.Button_OpenArhivesFolderClick(Sender: TObject);
begin
ShellExecute(Handle,'OPEN',pchar(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\'),nil,pchar(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\ARHIVES\'),SW_SHOWNORMAL);
end;

procedure TfViewLog.Button_ViewByDayClick(Sender: TObject);
var
  i: integer;
  tmplst: TStringList;
begin
  if RadioButton_LogImort.Checked then
    RadioButton_LogImortClick(Sender);
  if RadioButton_LogExport.Checked then
    RadioButton_LogExportClick(Sender);
  if RadioButton_LogPrice.Checked then
    RadioButton_LogPriceClick(Sender);
  if RadioButton_LogGenerate.Checked then
    RadioButton_LogGenerateClick(Sender);
  if RadioButton_LogDZ.Checked then
    RadioButton_LogDZClick(Sender);
  if RadioButton_LogReferences.Checked then
    RadioButton_LogReferencesClick(Sender);
  if RadioButton_LogReturns.Checked then
    RadioButton_LogReturnsClick(Sender);
  tmplst := TStringList.Create;
  for i := 0 to ListBox_FileList.Items.Count - 1 do
  begin
    if RadioButton_LogImort.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 10, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogExport.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 10, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogPrice.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 13, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogGenerate.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 14, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogDZ.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 6, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogReferences.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 14, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogReturns.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 1, 8) = copy
        (ListBox_FileList.Items.Strings[i], 11, 8) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
  end;
  ListBox_FileList.Items.Clear;
  ListBox_FileList.Items := tmplst;
  FreeAndNil(tmplst);
end;

procedure TfViewLog.Button_ViewByWeekClick(Sender: TObject);
var
  i: integer;
  tmplst: TStringList;
begin
  if RadioButton_LogImort.Checked then
    RadioButton_LogImortClick(Sender);
  if RadioButton_LogExport.Checked then
    RadioButton_LogExportClick(Sender);
  if RadioButton_LogPrice.Checked then
    RadioButton_LogPriceClick(Sender);
  if RadioButton_LogDZ.Checked then
    RadioButton_LogDZClick(Sender);
  if RadioButton_LogReferences.Checked then
    RadioButton_LogReferencesClick(Sender);
  if RadioButton_LogReturns.Checked then
    RadioButton_LogReturnsClick(Sender);
  tmplst := TStringList.Create;
  for i := 0 to ListBox_FileList.Items.Count - 1 do
  begin
    if RadioButton_LogImort.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 14, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogExport.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 14, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogPrice.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 17, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogGenerate.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 18, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogDZ.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 10, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogReferences.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 18, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
    if RadioButton_LogReturns.Checked then
    begin
      if copy(FormatDateTime('yyyymmdd', Now), 5, 2) = copy
        (ListBox_FileList.Items.Strings[i], 15, 2) then
        tmplst.Add(ListBox_FileList.Items.Strings[i]);
    end;
  end;
  ListBox_FileList.Items.Clear;
  ListBox_FileList.Items := tmplst;
  FreeAndNil(tmplst);
end;

procedure TfViewLog.FormShow(Sender: TObject);
begin
RadioButton_LogExportClick(Sender);
end;

procedure TfViewLog.ListBox1Click(Sender: TObject);
var
ps:integer;
begin
if copy(ListBox1.Items.Strings[ListBox1.ItemIndex],4,length(ListBox1.Items.Strings[ListBox1.ItemIndex])-3)<>'' then
ps:=strtoint(copy(ListBox1.Items.Strings[ListBox1.ItemIndex],4,length(ListBox1.Items.Strings[ListBox1.ItemIndex])-3));
Memo1.SelStart:=ps;
Memo1.SelLength:=8;
end;

procedure TfViewLog.ListBox_FileListClick(Sender: TObject);
var
en:integer;
crc:TCaption;
pscrc:integer;
enyes:boolean;
begin
  Memo1.Lines.LoadFromFile(tSettingFile.GetStringValue('Folders',
      'LogFolder') + '\' + ListBox_FileList.Items.Strings
      [ListBox_FileList.ItemIndex]);
ListBox1.Items.Clear;
crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('ВНИМАНИЕ!!! Превышен Лимит дебиторской задолженности',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('DEZ'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('ВНИМАНИЕ!!! Превышен Лимит дебиторской задолженности',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Дата документа меньше текущей',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('EDT'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Дата документа меньше текущей',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не допустимый или отсутствует код автора документа',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('ECR'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не допустимый или отсутствует код автора документа',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не допустимый или отсутствует код маршрута',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('ERT'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не допустимый или отсутствует код маршрута',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не допустимый  или отсутствует код сотрудника',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('EEM'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не допустимый  или отсутствует код сотрудника',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не указан Код ТРТ',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('EBP'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не указан Код ТРТ',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не допустимый или отсутствует код покупателя',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('EBY'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не допустимый или отсутствует код покупателя',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не допустимый или отсутствует код Форм. покупателя',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('ECA'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не допустимый или отсутствует код Форм. покупателя',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Дата отгрузки должна быть больше или равна текущей дате',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('ECA'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Дата отгрузки должна быть больше или равна текущей дате',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('ОШИБКА',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('ERR'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('ОШИБКА',crc);
 end;

crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Выгрузка маршрута не производилась',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('WRN'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Выгрузка маршрута не производилась',crc);
 end;

 crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Не соответствие критических параметров',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('CRE'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Не соответствие критических параметров',crc);
 end;

  crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Запрещается сохранение документа',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('ID3'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Запрещается сохранение документа',crc);
 end;

  crc:=Memo1.Text;
en:=0; pscrc:=0;
en:=Pos('Предприятие находится в стоп-списке',crc);
while en<>0 do
 begin
  pscrc:=pscrc+en;
  ListBox1.Items.Add('STP'+IntToStr(pscrc));
  crc:=Copy(crc,en+8,length(crc));
  en:=Pos('Предприятие находится в стоп-списке',crc);
 end;

end;

procedure TfViewLog.RadioButton_LogReturnsClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogReturns',
    ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

procedure TfViewLog.RadioButton_LogDZClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogDZ',
    ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

procedure TfViewLog.RadioButton_LogExportClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogExport',
    ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

procedure TfViewLog.RadioButton_LogGenerateClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogGeneration',
    ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

procedure TfViewLog.RadioButton_LogImortClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogImport',
    ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

procedure TfViewLog.RadioButton_LogPriceClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders',
      'LogFolder') + '\LogPriceEdit', ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

procedure TfViewLog.RadioButton_LogReferencesClick(Sender: TObject);
begin
  ListBox_FileList.Items.Clear;
  scandir(tSettingFile.GetStringValue('Folders', 'LogFolder') + '\LogReferences',
    ListBox_FileList.Items);
  Memo1.Lines.Clear;
end;

end.
