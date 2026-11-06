program DosPanel;

{$R 'Languages.res' 'Languages.rc'}

uses
  GnuGetText in '..\..\..\Bibliotheken\Units\GnuGetText.pas',
  LangUtils in '..\..\..\Bibliotheken\Units\LangUtils.pas',
  Forms,
  Graphics,
  DosPanelMain in 'DosPanelMain.pas' {frmMain},
  Settings in 'Settings.pas' {DosBoxSetDialog},
  ShellDirDlg in 'dialogs\ShellDirDlg.pas' {ShellDirDialog},
  AppSettings in 'AppSettings.pas' {AppSettingsDialog},
  SelectFromListDlg in 'dialogs\SelectFromListDlg.pas' {SelectFromListDialog},
  ShowMemo in 'dialogs\ShowMemo.pas' {ShowTextDialog},
  TxtConvertDlg in 'TxtConvertDlg.pas' {TxtConvertDialog},
  FileCopy in '..\..\..\Bibliotheken\Units\FileCopy.pas';

{$R *.res}

begin
  TP_GlobalIgnoreClass(TFont);
  InitTranslation(['delphi10','units']);
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TDosBoxSetDialog, DosBoxSetDialog);
  Application.CreateForm(TShellDirDialog, ShellDirDialog);
  Application.CreateForm(TAppSettingsDialog, AppSettingsDialog);
  Application.CreateForm(TSelectFromListDialog, SelectFromListDialog);
  Application.CreateForm(TShowTextDialog, ShowTextDialog);
  Application.CreateForm(TTxtConvertDialog, TxtConvertDialog);
  Application.Run;
end.
