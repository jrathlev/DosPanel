(* Delphi Dialog
   Abfrage der Angaben für eine Anmeldung (Name + Passwort)
   ========================================================

   © Dr. J. Rathlev, D-24222 Schwentinental (info(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
   
   Vers. 1 - Dez. 2004
   *)

unit LogonDlg;

interface

uses WinApi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, HListBox;

type
  TLogonDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    PwdEdit: TEdit;
    NameEdit: THistoryCombo;
    SkipBtn: TBitBtn;
    laHinweis: TLabel;
    procedure NameEditEnter(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadFromIni(IniName, IniSection : string);
    function Execute(Titel,Hinweis : string;
                     ShowSkip      : boolean;
                     var User,Pwd  : string) : TModalResult;
  end;

function InputUserAccount(Titel,Hinweis : string; ShowSkip : boolean;
                          var User,Pwd  : string) : TModalResult;

var
  LogonDialog: TLogonDialog;

implementation

{$R *.DFM}

uses GnuGetText, FileUtils;

{ ------------------------------------------------------------------- }
procedure TLogonDialog.LoadFromIni(IniName,IniSection : string);
begin
  with NameEdit do begin
    LoadFromIni(IniName,IniSection);
    if Items.Count=0 then Style:=csSimple else Style:=csDropDown;
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TLogonDialog.FormCreate(Sender: TObject);
begin
{$IFDEF Trace}
  WriteDebugLog('Create LogonDlg');
{$EndIf}
  TranslateComponent (self,'dialogs');
  NameEdit.Style:=csSimple;
  end;

procedure TLogonDialog.NameEditEnter(Sender: TObject);
begin
  PwdEdit.Text:='';
  end;

procedure TLogonDialog.FormActivate(Sender: TObject);
begin
  BringToFront;
  if length(NameEdit.Text)=0 then NameEdit.SetFocus
  else PwdEdit.SetFocus;
  end;

{ ------------------------------------------------------------------- }
(* Benutzername und Passwort, Ergebnis: "true" bei "ok" *)
function TLogonDialog.Execute(Titel,Hinweis: string;
                              ShowSkip      : boolean;
                              var User,Pwd  : string) : TModalResult;
var
  mr : TModalResult;
begin
  Caption:=Titel;
  laHinweis.Caption:=Hinweis;
  NameEdit.Text:=User;
  PwdEdit.Text:='';
  SkipBtn.Visible:=ShowSkip;
  mr:=ShowModal;
  if mr=mrOK then begin
    User:=NameEdit.Text; Pwd:=PwdEdit.Text;
    end;
  Result:=mr;
  end;

{ ------------------------------------------------------------------- }
(* Benutzername und Passwort, Ergebnis: "true" bei "ok" *)
function InputUserAccount(Titel,Hinweis : string;
                          ShowSkip      : boolean;
                          var User,Pwd  : string) : TModalResult;
begin
  if not assigned(LogonDialog) then LogonDialog:=TLogonDialog.Create(Application);
  with LogonDialog do begin
    Result:=Execute(Titel,Hinweis,ShowSkip,User,Pwd);
    Release;
    end;
  LogonDialog:=nil;
  end;

end.
