(* Delphi Dialog
   Show text window
   ================

   © Dr. J. Rathlev, D-24222 Schwentinental (info(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   Vers. 1 - Mai 2005
         1.1 - Mrz. 2006  - uses Sleep instead of TWaitTimer
         2 - July 2017
   last modified: October 2024
   *)

unit Show;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfrmShow = class(TForm)
    memShow: TMemo;
    panButtons: TPanel;
    btnOK: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
{$IFDEF HDPI}   // scale glyphs and images for High DPI
    procedure AfterConstruction; override;
{$EndIf}
    procedure Execute (const ATitle,AText : string; Delay : integer = 0);
  end;

procedure ShowText (const ATitle,AText : string; Delay : integer = 0);

var
  frmShow: TfrmShow;

implementation

{$R *.DFM}

uses Vcl.Consts, WinUtils;

{$IFDEF HDPI}   // scale glyphs and images for High DPI
procedure TfrmShow.AfterConstruction;
begin
  inherited;
  if Application.Tag=0 then
    ScaleButtonGlyphs(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;
{$EndIf}

{------------------------------------------------------------------- }
// Fenster mit Text (memShow) anzeigen
// Delay = 0 : Anzeige wartet auf Benutzer
//       > 0 : Anzeige für "Delay" Sekunden
procedure TfrmShow.Execute(const ATitle,AText : string; Delay : integer);
var
  i : integer;
begin
  if length(AText)>0 then begin
    Caption:=ATitle;
    btnOK.Caption:=SOKButton;
    with memShow do begin
      Clear;
      SetSelTextBuf(pchar(AText));
      end;
    if Delay=0 then begin
      panButtons.Show;
      ShowModal;
      end
    else begin
      panButtons.Hide;
      Show; Update;
      for i:=1 to Delay*10 do begin
        Sleep(100);
        Application.ProcessMessages;
        end;
      Close;
      end;
    end;
  end;

procedure ShowText (const ATitle,AText : string; Delay : integer);
begin
  if not assigned(frmShow) then frmShow:=TfrmShow.Create(Application);
  frmShow.Execute(ATitle,AText,Delay);
  FreeAndNil(frmShow);
  end;

end.
