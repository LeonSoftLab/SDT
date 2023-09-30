unit TTaskTimer;

interface

uses classes, windows, sysutils, Variants;

type
  TWaitThread = class(TThread)
  public
    constructor Create(CreateSuspennded: Boolean;TaskID,Operation,TypeOperation,Days,StartTime,Period,EndTime,FileName:string);
    destructor Destroy; override;
    procedure Execute; override;
    function TimeToInt(Value:TDateTime):Integer;
    procedure StartOne;
    procedure StartCycle;
    Procedure GetTask;
    var
    timer: thandle;
    FidTask:integer;
    FWaitUntil: tdatetime;
    Fool:boolean;
    FOperation: byte;
    FTypeOperation: byte;
    FDays: array [1 .. 7] of Boolean;
    FStartTime: TDateTime;
    FPeriod: Word;
    FEndTime: TDateTime;
    FFileName:string;
  end;

implementation

uses MainFormUnit;

//Запуск потока сразу после создания,НомерПП Задания,Вид запуска,Тип задания,Дни недели,Время старта цикла,период в минутах,Время окончания цикла
constructor TWaitThread.Create(CreateSuspennded:Boolean;TaskID,Operation,TypeOperation,Days,StartTime,Period,EndTime,FileName:string);
var
i,n:integer;
begin
Fool:=false;
if TaskID<>'' then
  FidTask:=strtoint(TaskID)
   else
    FidTask:=0;
if Operation<>'' then
  FOperation:=strtoint(Operation)
   else
    FOperation:=0;
if TypeOperation<>'' then
  FTypeOperation:=strtoint(TypeOperation)
   else
    FTypeOperation:=0;
for i:=1 to Length(Days) do
 FDays[i]:=false;
for i:=1 to Length(Days) do
if (copy(Days,i,1)<>'')and(copy(Days,i,1)<>';') then
 begin
  n:=StrToInt(copy(Days,i,1));
  FDays[n]:=true;
 end;
if StartTime<>'' then
  FStartTime:=StrToDateTime(StartTime)
   else
    FStartTime:=Now;
if Period<>'' then
  FPeriod:=StrToInt(Period)
   else
    FPeriod:=0;
if EndTime<>'' then
  FEndTime:=StrToDateTime(EndTime)
   else
    FEndTime:=Now;
FFileName:=FileName;
  inherited Create(CreateSuspennded);
end;

destructor TWaitThread.Destroy;
begin
  inherited;
end;

Procedure TWaitThread.GetTask;
begin
fMain.StartTask(FOperation,FFileName);
end;

procedure TWaitThread.StartOne;
var
  systemtime: tsystemtime;
  filetime, localfiletime: tfiletime;
DayNow,colsec:word;
begin
   DayNow:=DayOfWeek(Now);
   DayNow:=DayNow-1;
   if DayNow=0 then
   DayNow:=7;
   if (FDays[DayNow])and(TimeToInt(FStartTime)>TimeToInt(Now)) then
    begin
     FWaitUntil:=FStartTime;
  timer := createwaitabletimer(nil, false, nil);
  try
    datetimetosystemtime(FWaitUntil, systemtime);
    systemtimetofiletime(systemtime, localfiletime);
    localfiletimetofiletime(localfiletime, filetime);
    setwaitabletimer(timer, tlargeinteger(filetime), 0, nil, nil, false);
    repeat

    until (WaitForSingleObject(timer, 500)=WAIT_OBJECT_0)or(Terminated);
    fool:=false;
    try
    EnterCriticalSection(CS);
    if not Terminated then
    Synchronize(GetTask);
    finally
     LeaveCriticalSection(CS);
    end;
  finally
   CancelWaitableTimer(timer);
   CloseHandle(timer);
  end;
 end
else
  Fool:=true;
end;

procedure TWaitThread.StartCycle;
var
  systemtime: tsystemtime;
  filetime, localfiletime: tfiletime;
DayNow,colsec:word;
begin
   DayNow:=DayOfWeek(Now);
   DayNow:=DayNow-1;
   if DayNow=0 then
   DayNow:=7;
   if (FDays[DayNow])and(TimeToInt(FEndTime)>TimeToInt(Now)) then
   begin
   repeat
  if (TimeToInt(FStartTime)>TimeToInt(Now)) then
   FWaitUntil:=Now+1/24/60/60*(TimeToInt(FStartTime)-TimeToInt(Now))
  else
   FWaitUntil:=Now+1/24/60*FPeriod;
  timer := createwaitabletimer(nil, false, nil);
  try
    datetimetosystemtime(FWaitUntil, systemtime);
    systemtimetofiletime(systemtime, localfiletime);
    localfiletimetofiletime(localfiletime, filetime);
    setwaitabletimer(timer, tlargeinteger(filetime), 0, nil, nil, false);
    repeat

    until (WaitForSingleObject(timer, 500)=WAIT_OBJECT_0)or(Terminated)or(TimeToInt(FEndTime)<TimeToInt(Now));
    fool:=false;
    try
    EnterCriticalSection(CS);
    if not Terminated then
    Synchronize(GetTask);
    finally
     LeaveCriticalSection(CS);
    end;
  finally
   CancelWaitableTimer(timer);
   CloseHandle(timer);
   end;
   until (TimeToInt(FEndTime)<TimeToInt(Now))or(Terminated);
  end
 else
   Fool:=true;
end;

function TWaitThread.TimeToInt(Value:TDateTime):Integer;
var
xYear1,xMonth1,xDay1,xHour1,xMinutes1,xSeconds1,xMilliSeconds1:word;
begin
DecodeTime(Value,xHour1,xMinutes1,xSeconds1,xMilliSeconds1);
Result:=(xHour1*60*60)+(xMinutes1*60)+(xSeconds1);
end;

procedure TWaitThread.Execute;
var
  timer: thandle;
  systemtime: tsystemtime;
  filetime, localfiletime: tfiletime;
DayNow,colsec:word;
begin
  FreeOnTerminate := true;
  OnTerminate := fMain.timerfired;
case FTypeOperation of
0:StartOne;
1:StartCycle;
end;
end;

end.
