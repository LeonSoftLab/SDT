unit SettingsConnectFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, JvExMask, JvToolEdit, AdvCombo, ActnList, ImgList,
  Buttons, AdvEdit, AdvGroupBox, AdvOfficeButtons, JvExStdCtrls, JvButton,
  JvCtrls, JvFooter, ExtCtrls, JvExExtCtrls, JvExtComponent, ComCtrls,
  JvExComCtrls, JvComCtrls, JvSpin;

type
  TfSettingsConnect = class(TForm)
    ImageList1: TImageList;
    JvFooter1: TJvFooter;
    JvFooterBtn2: TJvFooterBtn;
    JvFooterBtn3: TJvFooterBtn;
    JvPageControl1: TJvPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    chRunAs: TCheckBox;
    GroupBox1: TGroupBox;
    cmbSQLServer: TAdvComboBox;
    SpeedButton1: TSpeedButton;
    GroupBox2: TGroupBox;
    rbMSSQLAuth: TAdvOfficeRadioButton;
    rbWinAuth: TAdvOfficeRadioButton;
    edtUID: TAdvEdit;
    edtPswrd: TAdvEdit;
    chSavePassword: TCheckBox;
    GroupBox3: TGroupBox;
    cmbDBName: TAdvComboBox;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    chLogged: TCheckBox;
    ActionList1: TActionList;
    aSQLServerRefresh: TAction;
    aDatabaseRefresh: TAction;
    aTestConnection: TAction;
    procedure aSQLServerRefreshExecute(Sender: TObject);
    procedure rbMSSQLAuthClick(Sender: TObject);
    procedure rbWinAuthClick(Sender: TObject);
    procedure aDatabaseRefreshExecute(Sender: TObject);
    procedure aTestConnectionExecute(Sender: TObject);
    procedure cmbDBNameDropDown(Sender: TObject);
    procedure cmbSQLServerDropDown(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sConn: string;
  end;

var
  fSettingsConnect: TfSettingsConnect;

implementation

uses DataModuleUnit, FunctionsUnit, MainFormUnit;

{$R *.dfm}

procedure TfSettingsConnect.aDatabaseRefreshExecute(Sender: TObject);
begin
  {Обновление списка БД}
  try
    Screen.Cursor := crSQLWait;
    try
      cmbDBName.Clear;
      mData.Connection.Close;
      if rbWinAuth.Checked then
        sConn := 'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=True'+
        ';Initial Catalog= master;Data Source=' + cmbSQLServer.Text;
      if rbMSSQLAuth.Checked then
        sConn := 'Provider=SQLOLEDB.1;Password=' + edtPswrd.Text +
          ';Persist Security Info=True;User ID=' + edtUID.Text +
          ';Initial Catalog=master;Data Source=' + cmbSQLServer.Text;
      if chSavePassword.Checked = False then
        mData.Connection.LoginPrompt := True
      else
        mData.Connection.LoginPrompt := False;
      fMain.PromptLogin:=false;
      mData.Connection.LoginPrompt := False;
      mData.Connection.ConnectionString := sConn;
      mData.Connection.Open;
      mData.dsDatabases.Open;
      mData.dsDatabases.First;
      while not mData.dsDatabases.Eof do
      begin
        cmbDBName.Items.Add(mData.dsDatabases.FieldValues['database_name']);
        mData.dsDatabases.Next;
      end;
      mData.dsDatabases.Close;
      cmbDBName.ItemIndex := 0;
    except
      Application.MessageBox(PChar('Не удалось получить список баз с сервера: ' +
        cmbSQLServer.Text + #13 + 'Свяжитесь с администратором сервера и повторите попытку'),
        PChar('Обновление списка баз данных'), MB_OK + MB_ICONERROR);
    end;
  finally
    mData.Connection.Close;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfSettingsConnect.aSQLServerRefreshExecute(Sender: TObject);
var
  OldSQLServer: string;
begin
  OldSQLServer := cmbSQLServer.Text;
  cmbSQLServer.Clear;
  GetMSSQLServerNamesList(cmbSQLServer.Items);
  if OldSQLServer = '' then
    cmbSQLServer.ItemIndex := 0
  else
    cmbSQLServer.ItemIndex := cmbSQLServer.Items.IndexOf(OldSQLServer);
end;

procedure TfSettingsConnect.aTestConnectionExecute(Sender: TObject);
begin
  Screen.Cursor := crSQLWait;
  try
    mData.Connection.Connected := False;
    if rbWinAuth.Checked then
      sConn := 'Provider=SQLNCLI10.1;Integrated Security=SSPI;Persist Security Info=True'+
      ';Initial Catalog=' + cmbDBName.Text + ';Data Source=' + cmbSQLServer.Text
    else
      sConn := 'Provider=SQLNCLI10.1;Password=' + edtPswrd.Text +
        ';Persist Security Info=True;User ID=' + edtUID.Text +
        ';Initial Catalog=' + cmbDBName.Text + ';Data Source=' + cmbSQLServer.Text;
    mData.Connection.ConnectionString := sConn;
    if chSavePassword.Checked = False then
        mData.Connection.LoginPrompt := True
      else
        mData.Connection.LoginPrompt := False;
     fMain.PromptLogin:=false;
     mData.Connection.LoginPrompt := False;
    try
      mData.Connection.Open;
      Application.MessageBox(PChar('Подключение к серверу "' + cmbSQLServer.Text + '" успешно выполнено.'),
      PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
      sConn:=mData.Connection.ConnectionString;
    except
      mData.Connection.Close;
      Application.MessageBox(PChar('Не удалось проверить подключение к серверу "' + cmbSQLServer.Text + '".'
      + #13 + 'Свяжитесь с администратором сервера для получения настроек и повторите попытку'),
      PChar(Application.Title), MB_OK + MB_ICONERROR);
    end;
  finally
      mData.Connection.Close;
  end;
  Screen.Cursor := crDefault;
end;

procedure TfSettingsConnect.cmbDBNameDropDown(Sender: TObject);
var
  OldDBName: string;
begin
  OldDBName := '';
  if cmbDBName.Text <> '' then OldDBName := cmbDBName.Text;
  aDataBaseRefresh.Execute;
  if OldDBName <> '' then cmbDBName.ItemIndex := cmbDBName.Items.IndexOf(OldDBName);
end;

procedure TfSettingsConnect.cmbSQLServerDropDown(Sender: TObject);
var
  OldSQLServer: string;
begin
  OldSQLServer := '';
  if cmbSQLServer.Text <> '' then OldSQLServer := cmbSQLServer.Text;
  aSQLServerRefresh.Execute;
  if OldSQLServer <> '' then cmbSQLServer.ItemIndex := cmbSQLServer.Items.IndexOf(OldSQLServer);
end;

procedure TfSettingsConnect.rbMSSQLAuthClick(Sender: TObject);
begin
  if rbMSSQLAuth.Checked = True then
  begin
    edtUID.Enabled := True;
    edtPswrd.Enabled := True;
    chSavePassword.Enabled := True;
  end;
end;

procedure TfSettingsConnect.rbWinAuthClick(Sender: TObject);
begin
  if rbWinAuth.Checked = True then
  begin
    edtUID.Enabled := False;
    edtPswrd.Enabled := False;
    chSavePassword.Enabled := False;
  end;
end;

end.
