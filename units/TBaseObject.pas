{
    Name: cBaseObject
    Description: Базовый класс
    Create date: 17.08.2010
    Modify date:
    Version: 4.8.0.1

    Modify notes:

    17.08.2010 - Создан базовый класс.

}
unit TBaseObject;

interface

uses
  Classes, SysUtils, DB, ADODB, JvLogFile;

type
  TBases = class(TObject)
  protected
    _LogFile:     TJvLogFile;
    _Connection:  TADOConnection;
    _StoredProc:  TADOStoredProc;
    _FileName:    string;
    _Message:     string;
    _Size:        integer;
  public
    procedure StartLogging;
    procedure StopLogging;
    procedure SetMessage(const Title, Msg: string);
    procedure SetLogFileName(const Value: string);
    procedure SetTypeLogged(const Value: boolean);
    constructor Create;
    destructor Destroy; override;
  end;
  {TODO: Добавить возможность вклчения/отключения логирования}
var
  AOwner: TComponent;

implementation

{ TBases }

constructor TBases.Create;
begin
  _LogFile := TJvLogFile.Create(AOwner);
  _LogFile.Active := True;
  _LogFile.AutoSave := True;
  _Connection := TADOCOnnection.Create(AOwner);
  _Connection.LoginPrompt:=False;
  _StoredProc := TADOStoredProc.Create(AOwner);
  _StoredProc.Connection := Self._Connection;
end;

destructor TBases.Destroy;
begin
  Self._LogFile.SaveToFile(Self._FileName);
  FreeAndNil(Self._Connection);
  FreeAndNil(Self._StoredProc);
  FreeAndNil(Self._LogFile);
  inherited Destroy;
end;

procedure TBases.SetLogFileName(const Value: string);
begin
  Self._FileName := Value;
end;

procedure TBases.SetMessage(const Title, Msg: string);
begin
  Self._LogFile.Add(DateTimeToStr(Now), Title, Msg);
end;

procedure TBases.SetTypeLogged(const Value: boolean);
begin
  Self.StopLogging;
  case Value of
    False: begin //Write to files
      Self._LogFile.SizeLimit := 0;
    end;
    True: begin //Write to one file
      Self._LogFile.SizeLimit := Self._Size;
    end;
  end;
end;

procedure TBases.StartLogging;
begin
  if FileExists(Self._FileName) then
    Self._LogFile.LoadFromFile(Self._FileName);
end;

procedure TBases.StopLogging;
begin
  Self._LogFile.SaveToFile(Self._FileName);
end;

end.
