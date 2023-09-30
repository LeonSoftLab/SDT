{
    Name: TSettingsObjectUnit
    Description: Класс настроек
    Create date: 17.08.2010
    Modify date:
    Version: 4.8.0.1

    Modify notes:

    17.08.2010 - Создан класс настроек

}
unit TSettingsObjectUnit;

interface
uses
  Classes, IniFiles, SysUtils;

type
  TSettingsFile = class
  protected
    _CfgFile: TIniFile;
    _FileName: string;
    _Section: string;
    _Parameter: string;
    _StrValue: string;
    _IntValue: string;
    _BoolValue: Boolean;
    _TimeValue: TDateTime;
  private
    function Encrypt(const Value: string): string;
    function Decrypt(const Value: string): string;
  public
    function GetNoCrypt_sValue(const Section, Parameter: string): string;
    function GetStringValue(const Section, Parameter: string): string;
    function GetIntegerValue(const Section, Parameter: string): Integer;
    function GetBooleanValue(const Section, Parameter: string): Boolean;
    function GetTimeValue(const Section, Parameter: string): TDateTime;
    procedure Get_Section(const Section: string; Results: TStrings);
    procedure Get_SectionValues(const Section: string; Results: TStrings);
    procedure Erase_Section(const Section: string);
    procedure Erase_Param(const Section, Parameter: string);
    procedure SetStringNoCryptValue(const Section, Parameter, Value: string);
    procedure SetStringValue(const Section, Parameter, Value: string);
    procedure SetIntegerValue(const Section, Parameter: string; Value: Integer);
    procedure SetBooleanValue(const Section, Parameter: string; Value: Boolean);
    procedure SetTimeValue(const Section, Parameter: string; Value: TDateTime);
    constructor Create(FileName: string);
    destructor Destroy; override;

  end;

const
  C1 = 52845;
  C2 = 11719;

implementation

{ TSettingsFile }

constructor TSettingsFile.Create(FileName: string);
begin
  Self._CfgFile := TIniFile.Create(FileName);
end;

function TSettingsFile.Decrypt(const Value: string): string;
var
  I: Byte;
  Key: Word;
  ls: string;
begin
  Key := 1674;
  SetLength(ls, Length(Value) div 2);
  SetLength(Result, Length(ls));
  for I := 1 to Length(ls) do
  begin
    ls[I] := char(StrToInt('$' + Copy(Value, (I * 2) - 1, 2)));
  end;
  for I := 1 to Length(ls) do
  begin
    Result[I] := Char(byte(ls[I]) xor (Key shr 8));
    Key := (byte(ls[I]) + Key) * C1 + C2;
  end;
end;

destructor TSettingsFile.Destroy;
begin
  FreeAndNil(Self._CfgFile);
  inherited Destroy;
end;

function TSettingsFile.Encrypt(const Value: string): string;
var
  I: Byte;
  Key: Word;
  ls: string;
begin
  Key := 1674;
  SetLength(ls, Length(Value));
  Result := '';
  for I := 1 to Length(Value) do
  begin
    ls[I] := Char(byte(Value[I]) xor (Key shr 8));
    Result := Result + IntToHex(byte(ls[I]), 2);
    Key := (byte(ls[I]) + Key) * C1 + C2;
  end;
end;

procedure TSettingsFile.Erase_Section(const Section: string);
begin
  Self._CfgFile.EraseSection(Section);
end;

procedure TSettingsFile.Erase_Param(const Section, Parameter: string);
begin
  Self._CfgFile.DeleteKey(Section, Parameter);
end;

function TSettingsFile.GetNoCrypt_sValue(const Section,
  Parameter: string): string;
begin
  Result := Self._CfgFile.ReadString(Section, Parameter, '');
end;

function TSettingsFile.GetIntegerValue(const Section, Parameter: string): Integer;
begin
  Result := Self._CfgFile.ReadInteger(Section, Parameter, -1);
end;

function TSettingsFile.GetStringValue(const Section, Parameter: string): string;
begin
  Result := Decrypt(Self._CfgFile.ReadString(Section, Parameter, ''));
end;

function TSettingsFile.GetTimeValue(const Section, Parameter: string): TDateTime;
begin
  Result := Self._CfgFile.ReadTime(Section, Parameter, Now);
end;

function TSettingsFile.GetBooleanValue(const Section, Parameter: string): Boolean;
begin
  Result := Self._CfgFile.ReadBool(Section, Parameter, False);
end;

procedure TSettingsFile.Get_Section(const Section: string; Results: TStrings);
begin
  Self._CfgFile.ReadSection(Section, Results);
end;

procedure TSettingsFile.Get_SectionValues(const Section: string;
  Results: TStrings);
begin
  Self._CfgFile.ReadSectionValues(Section, Results);
end;

procedure TSettingsFile.SetStringNoCryptValue(const Section, Parameter, Value: string);
begin
Self._CfgFile.WriteString(Section, Parameter, Value);
end;

procedure TSettingsFile.SetStringValue(const Section, Parameter, Value: string);
begin
  Self._CfgFile.WriteString(Section, Parameter, Encrypt(Value));
end;

procedure TSettingsFile.SetTimeValue(const Section, Parameter: string;
  Value: TDateTime);
begin
  Self._CfgFile.WriteTime(Section, Parameter, Value);
end;

procedure TSettingsFile.SetBooleanValue(const Section, Parameter: string;
  Value: Boolean);
begin
  Self._CfgFile.WriteBool(Section, Parameter, Value);
end;

procedure TSettingsFile.SetIntegerValue(const Section, Parameter: string;
  Value: Integer);
begin
  Self._CfgFile.WriteInteger(Section, Parameter, Value);
end;

end.
