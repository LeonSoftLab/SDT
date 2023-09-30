program SDT51;

uses
  Windows,
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {fMain},
  ConstUnit in 'units\ConstUnit.pas',
  FunctionsUnit in 'units\FunctionsUnit.pas',
  TImportObjectsUnit in 'units\TImportObjectsUnit.pas',
  TBaseObject in 'units\TBaseObject.pas',
  DataModuleUnit in 'DataModuleUnit.pas' {mData: TDataModule},
  TExportObjectsUnit in 'units\TExportObjectsUnit.pas',
  TConfirmationObjectsUnit in 'units\TConfirmationObjectsUnit.pas',
  TSettingsObjectUnit in 'units\TSettingsObjectUnit.pas',
  SettingsConnectFormUnit in 'SettingsConnectFormUnit.pas' {fSettingsConnect},
  SettingsFolderFormUnit in 'SettingsFolderFormUnit.pas' {fSettingsFolders},
  ThreadExportUnit in 'ThreadExportUnit.pas',
  ThreadImportUnit in 'ThreadImportUnit.pas',
  SettingsSheduleFormUnit in 'SettingsSheduleFormUnit.pas' {fSheduleSett},
  SettingsSheduleDetailsFormUnit in 'SettingsSheduleDetailsFormUnit.pas' {fSheduleTaskDetail},
  TSheduleTimerUnit in 'units\TSheduleTimerUnit.pas',
  ExportTypeFormUnits in 'ExportTypeFormUnits.pas' {fExportType},
  LogViewFormUnit in 'LogViewFormUnit.pas' {fViewLog},
  TTaskTimer in 'units\TTaskTimer.pas',
  Unit_PriceTable in 'Unit_PriceTable.pas' {Form_PriceTable},
  Unit_AutoUpdatePrice in 'Unit_AutoUpdatePrice.pas' {Form_AutoUpdatePrice},
  Unit_PriceList in 'Unit_PriceList.pas' {Form_PriceList},
  Unit_RowPriceInfo in 'Unit_RowPriceInfo.pas' {Form_RowPriceInfo},
  UnitEditPriceType in 'UnitEditPriceType.pas' {Form_EditPriceType},
  ThAutoUpdatePrice in 'ThAutoUpdatePrice.pas',
  TExpDataByRoute in 'TExpDataByRoute.pas',
  Unit_RoutesInfo in 'Unit_RoutesInfo.pas' {Form_RoutesInfo},
  ThReferences in 'ThReferences.pas',
  ThDZ in 'ThDZ.pas',
  ThReturns in 'ThReturns.pas',
  Unit_Add_Goods in 'Unit_Add_Goods.pas' {Form_Add_Goods},
  TExportDocumentsUnit in 'TExportDocumentsUnit.pas',
  TRestartServiceUnit in 'TRestartServiceUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.HintHidePause:=8000;Application.HintPause:=300;Application.HintColor:=65535;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Сервис обмена данными';
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TmData, mData);
  Application.CreateForm(TForm_PriceTable, Form_PriceTable);
  Application.CreateForm(TForm_AutoUpdatePrice, Form_AutoUpdatePrice);
  Application.CreateForm(TForm_PriceList, Form_PriceList);
  Application.CreateForm(TForm_RowPriceInfo, Form_RowPriceInfo);
  Application.CreateForm(TForm_EditPriceType, Form_EditPriceType);
  Application.CreateForm(TForm_RoutesInfo, Form_RoutesInfo);
  Application.CreateForm(TForm_Add_Goods, Form_Add_Goods);
  Application.Run;
end.
