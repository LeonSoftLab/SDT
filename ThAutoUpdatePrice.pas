unit ThAutoUpdatePrice;

interface

uses classes, windows, sysutils, Variants, ADODB, dateutils;

type
  TAutoUpdatePrice = class(TThread)
  public
    constructor Create(CreateSuspennded: Boolean;LogFile,sConn,DataBase:string;Descriptor:THandle);
    destructor Destroy; override;
    procedure Execute; override;
  var
   FileNameLog:string;
   ConnectString:string;
   DataBaseName:string;
   FDescriptor:THandle;
   ADOConnect:TADOConnection;
   ADODataSet_GetPriceFromOT:TADODataSet;
   ADODataSet_ExistsPriceType:TADODataSet;
   ADODataSet_ActualPrice:TADOQuery;
   ADOStoredProc_InsertPriceType:TADOStoredProc;
  end;

  var
  AOwner: TComponent;

implementation

uses MainFormUnit, FunctionsUnit, ActiveX, DataModuleUnit;

constructor TAutoUpdatePrice.Create(CreateSuspennded:Boolean;LogFile,sConn,DataBase:string;Descriptor:THandle);
begin
FileNameLog:=LogFile;
ConnectString:=sConn;
DataBaseName:=DataBase;
FDescriptor:=Descriptor;
inherited Create(CreateSuspennded);
end;

destructor TAutoUpdatePrice.Destroy;
begin
  inherited;
end;

procedure TAutoUpdatePrice.Execute;
var
i,Code:integer;
E:error;
Names,FullNames,Comment,tempDate:string;
Dates:TDate;
xYear,xMonth,xDay,NewPrices:Word;
f:TextFile;
begin
try
FreeOnTerminate:=true;
EnterCriticalSection(CS);
CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
try
 ViewLog(2,'Прайсы',' Проверка прайсов...');
 AssignFile(f,FileNameLog);
 Rewrite(f);
 Writeln(f,timetostr(Time)+' ========= Старт обновления прайсов ========');
 ADOConnect:=TADOConnection.Create(AOwner);
 ADOConnect.ConnectionString:=ConnectString;
 ADODataSet_GetPriceFromOT:=TADODataSet.Create(AOwner);
 ADODataSet_GetPriceFromOT.CommandText:=mData.ADODataSet_GetPriceFromOT.CommandText;
 ADODataSet_GetPriceFromOT.Connection:=ADOConnect;
 ADODataSet_ActualPrice:=TADOQuery.Create(AOwner);
 ADODataSet_ActualPrice.SQL.Text:=' UPDATE [workot].[dbo].[refPriceTypes] '+
 '    SET [IsActive] = gpf.[IsActive] '+
 '       ,[deleted] = 0 '+
 '  from [workot].[dbo].[refPriceTypes] rPT '+
 '  inner join [workot].[dbo].[fnGetPriceFromOT] () gpf on gpf.code=rPT.code '+
 ' UPDATE [workot].[dbo].[refPriceTypes] '+
 '    SET [deleted] = 1 '+
 '  where code not in (SELECT Code FROM [workot].[dbo].[fnGetPriceFromOT] ()) ';
 ADODataSet_ActualPrice.Connection:=ADOConnect;
 ADODataSet_ExistsPriceType:=TADODataSet.Create(AOwner);
 ADODataSet_ExistsPriceType.Connection:=ADOConnect;
 ADOStoredProc_InsertPriceType:=TADOStoredProc.Create(AOwner);
 ADOStoredProc_InsertPriceType.Connection:=ADOConnect;
 ADOStoredProc_InsertPriceType.ProcedureName:=mData.ADOStoredProc_InsertPriceType.ProcedureName;
 ADOStoredProc_InsertPriceType.Parameters:=mData.ADOStoredProc_InsertPriceType.Parameters;
 Writeln(f,timetostr(Time)+' Компоненты подготовленны');
 ADOConnect.LoginPrompt:=false;
 ADOConnect.Connected:=true;
 Writeln(f,timetostr(Time)+' Подключение активно');
try
 ADOConnect.BeginTrans;
 NewPrices:=0;
 ADODataSet_GetPriceFromOT.Close;
 ADODataSet_GetPriceFromOT.Open;
 ADODataSet_GetPriceFromOT.First;
for i:=1 to ADODataSet_GetPriceFromOT.RecordCount do
 begin
  Code:=ADODataSet_GetPriceFromOT.FieldByName('Code').AsInteger;
  ADODataSet_ExistsPriceType.Close;
  ADODataSet_ExistsPriceType.CommandText:='SELECT ['+ADOConnect.DefaultDatabase+'].[dbo].[ExistsPriceType] ('+IntToStr(Code)+') [Result]';
  ADODataSet_ExistsPriceType.Open;
  if ADODataSet_ExistsPriceType.RecordCount <>0 then
   begin
    ADODataSet_ExistsPriceType.First;
    if ADODataSet_ExistsPriceType.FieldByName('Result').AsBoolean=False then  { не существует}
     begin
      FullNames:=ADODataSet_GetPriceFromOT.FieldByName('Name').AsString;
      Code:=ADODataSet_GetPriceFromOT.FieldByName('Code').AsInteger;
      Comment:=ADODataSet_GetPriceFromOT.FieldByName('Comment').AsString;
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
      Writeln(f,'');
      Writeln(f,timetostr(Time)+' ==> Добавляю в БД новый прайс: '+inttostr(Code)+'  ...  <==');
      Writeln(f,'           '+Names);
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@Name']:=Names;
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@idBasePriceType']:=0;
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@idCurrency']:=1;
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@CrDate']:=Date;
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@IsActive']:=True;
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@Code']:=inttostr(Code);
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@deleted']:=False;
      ADOStoredProc_InsertPriceType.Parameters.ParamValues['@isedit']:=0;
      ADOStoredProc_InsertPriceType.ExecProc;
      Writeln(f,timetostr(Time)+' Успешно.');
      Writeln(f,'');
      NewPrices:=NewPrices+1;
     end
    else
     begin
     if ADODataSet_ExistsPriceType.FieldByName('Result').AsBoolean=True then
      Writeln(f,'Прайс '+IntToStr(Code)+' существует.');
      //Result='1' (существует)
     end;
   end;
  ADODataSet_GetPriceFromOT.Next;
 end;
Writeln(f,timetostr(Time)+' ======== Добавление прайсов успешно завершено ========');
Writeln(f,timetostr(Time)+' В базу было добавлено '+IntToStr(NewPrices)+' новых прайсов.');
ADODataSet_ActualPrice.ExecSQL;
Writeln(f,timetostr(Time)+' Актуализация прасов произведена успешно.');
ADOConnect.CommitTrans;
except
 on E:Exception do
  begin
   ADOConnect.RollbackTrans;
   Writeln(f,timetostr(Time)+' ======= Добавление прайсов завершено с ошибками =======');
   Writeln(f,timetostr(Time)+' В базу было добавлено '+IntToStr(NewPrices)+' новых прайсов.');
  end;
end;
finally
if NewPrices>0 then
begin
 ViewLog(3,'Прайсы','Прайсы обновлены, было добавлено '+inttostr(NewPrices)+' новых прайсов');
end
else
 begin
  ViewLog(3,'Прайсы','Проверка окончена, новых прайсов нет.');
  //DeleteFile(FileNameLog);
 end;
end;
 finally
  CloseFile(f);
  FreeAndNil(ADOStoredProc_InsertPriceType);
  FreeAndNil(ADODataSet_ExistsPriceType);
  FreeAndNil(ADODataSet_GetPriceFromOT);
  FreeAndNil(ADODataSet_ActualPrice);
  FreeAndNil(ADOConnect);
  CoUninitialize;
  ReleaseMutex(FDescriptor);
  LeaveCriticalSection(CS);
 end;
end;



end.
