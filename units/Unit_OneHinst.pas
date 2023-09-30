unit Unit_OneHinst;
interface

implementation
uses
  Windows;
var
  Mutex : THandle;

function StopLoading : boolean;
begin
  Mutex := CreateMutex(nil,false,pchar('SERVICE_DATAEXCHANGE_ALEF_VINAL'));

  Result := (Mutex = 0) or // Если мьютекс не удалось создать
  (GetLastError = ERROR_ALREADY_EXISTS); // Если мьютекс уже существует
end;

procedure ShowErrMsg;
const
  PROGRAM_ALREADY_RUN = 'Программа уже работает, завершите копию программы.';
begin
  MessageBox(0,PROGRAM_ALREADY_RUN,pchar('SERVICE_DATAEXCHANGE_ALEF_VINAL'), MB_ICONSTOP or MB_OK);
end;

initialization
  if StopLoading then
  begin
    ShowErrMsg;
    // Так как никаких инициализаций еще не производилось, то
    // спокойно используем для завершения программы Halt -
    // finalization все равно выполнится
    halt;
  end;
finalization
  if Mutex <> 0 then
    CloseHandle(Mutex);
end.
