unit TSheduleTimerUnit;

interface
uses
  Classes, Windows, SysUtils, SyncObjs;
type
  TSheduleTimer = class(TSynchroObject)
    protected
      FHandle: THandle;
      FPeriod: Longint;
      FDueTime: TDateTime;
      FLastError: Integer;
      fLongTime: Int64;
      FIdTask: integer;
    public
      constructor Create(ManualReset: Boolean; TimerAttributes: PSecurityAttributes; TaskId:integer; const Name: string);
      destructor Destroy; override;
      procedure Start;
      procedure Stop;
      function Wait(TimeOut:Longint): TWaitResult;
      property Handle: THandle read FHandle;
      property LastError: Integer read FLastError;
      property Period: Integer read FPeriod write FPeriod;
      property Time: TDateTime read FDueTime write FDueTime;
      property LongTime: Int64 read FLongTime write FLongTime;
      property IdTask: Integer read FIdTask write FIdTask;
  end;
implementation

{ TShedileTimer }

{ TSheduleTimer }

constructor TSheduleTimer.Create(ManualReset: Boolean;
  TimerAttributes: PSecurityAttributes; TaskId:integer; const Name: string);
var
  pName: PChar;
begin
  inherited Create;
  if name = '' then
    pName := nil
  else
    pName := PChar(Name);

  FHandle := CreateWaitableTimer(TimerAttributes, ManualReset, PName);
end;

destructor TSheduleTimer.Destroy;
begin
  CloseHandle(FHandle);
  inherited Destroy;
end;

procedure TSheduleTimer.Start;
var
  SysTime: TSystemTime;
  LocalTime, UTCTime: FileTime;
  Value: Int64 absolute UTCTime;
begin
  if FLongTime = 0 then
  begin
    DateTimeToSystemTime(FDueTime, SysTime);
    SystemTimeToFileTime(SysTime, LocalTime);
    LocalFileTimeToFileTime(LocalTime, UTCTime);
  end
  else
    Value := FLongTime;
  SetWaitableTimer(FHandle,Value, FPeriod, nil, nil, False);
end;

procedure TSheduleTimer.Stop;
begin
  CancelWaitableTimer(FHandle);
end;

function TSheduleTimer.Wait(TimeOut: Integer): TWaitResult;
begin
  case WaitForSingleObjectEx(Handle, TimeOut, Bool(1)) of
    WAIT_ABANDONED: Result := wrAbandoned;
    WAIT_OBJECT_0: Result := wrSignaled;
    WAIT_TIMEOUT: Result := wrTimeout;
    WAIT_FAILED: begin
        Result := wrError;
        FLastError := GetLastError;
    end
    else
      Result := wrError;
  end;
end;

end.
