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

  Result := (Mutex = 0) or // ���� ������� �� ������� �������
  (GetLastError = ERROR_ALREADY_EXISTS); // ���� ������� ��� ����������
end;

procedure ShowErrMsg;
const
  PROGRAM_ALREADY_RUN = '��������� ��� ��������, ��������� ����� ���������.';
begin
  MessageBox(0,PROGRAM_ALREADY_RUN,pchar('SERVICE_DATAEXCHANGE_ALEF_VINAL'), MB_ICONSTOP or MB_OK);
end;

initialization
  if StopLoading then
  begin
    ShowErrMsg;
    // ��� ��� ������� ������������� ��� �� �������������, ��
    // �������� ���������� ��� ���������� ��������� Halt -
    // finalization ��� ����� ����������
    halt;
  end;
finalization
  if Mutex <> 0 then
    CloseHandle(Mutex);
end.
