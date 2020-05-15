{*********************************************************}
{                                                         }
{       Borland Delphi Visual Component Library           }
{                                                         }
{       Copyright (c) 1995, 2001-2002 Borland Corporation }
{                                                         }
{*********************************************************}

// Without property editor: J. Rathlev, Feb. 2008
// Last changed: J. Rathlev, Oct. 2015         

unit Vcl.Shell.ShellCtrlsReg platform;

interface

procedure Register;

implementation

uses System.Classes, System.TypInfo, Vcl.Controls, 
  Vcl.Shell.ShellCtrls, Vcl.Shell.ShellConsts;

procedure Register;
begin
  GroupDescendentsWith(TShellChangeNotifier, Vcl.Controls.TControl);
  RegisterComponents(SPalletePage, [TShellTreeView, TShellComboBox, TShellListView,
    TShellChangeNotifier]);
end;

end.
