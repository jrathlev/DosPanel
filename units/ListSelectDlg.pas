(* Delphi Dialog
   Show a sorted list of items for selection
   =========================================
   - Selecting an item will trigger the event "OnSelect" and close the window
   - Clicking outside the dialog window will close the window

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Aug. 2018
   last modified: Nov. 2021
   *)

unit ListSelectDlg;

interface

uses WinApi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TOnSelect = procedure(AIndex : integer) of object;

  TListSelectDialog = class(TForm)
    lbSelect: TListBox;
    procedure lbSelectClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbSelectMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
  private
    { Private-Deklarationen }
    FWidth : integer;
    FOnSelect : TOnSelect;
    function GetSorted : boolean;
    procedure SetSorted (Value : boolean);
  public
    { Public-Deklarationen }
    procedure Clear;
    procedure Assign (AItems : TStrings; AIndex : integer = -1);
    procedure AddItem (const AItem : string; AIndex : integer);
    procedure ShowList (APos : TPoint; AHeight : integer = 0);
    property Sorted : boolean read GetSorted write SetSorted;
    property Width : integer read FWidth write FWidth;
    property OnSelect : TOnSelect read FOnSelect write FOnSelect;
  end;

var
  ListSelectDialog: TListSelectDialog;

implementation

{$R *.dfm}

uses WinUtils;

const
  defItemHeight = 17;

procedure TListSelectDialog.FormCreate(Sender: TObject);
begin
  FOnSelect:=nil; FWidth:=0;
  end;

procedure TListSelectDialog.FormDeactivate(Sender: TObject);
begin
  Close;
  end;

function TListSelectDialog.GetSorted : boolean;
begin
  Result:=lbSelect.Sorted;
  end;

procedure TListSelectDialog.SetSorted (Value : boolean);
begin
  with lbSelect do begin
    if Sorted<>Value then Sorted:=Value;
    end;
  end;

procedure TListSelectDialog.Clear;
begin
  lbSelect.Clear;
  end;

procedure TListSelectDialog.Assign (AItems : TStrings; AIndex : integer);
begin
  with lbSelect do begin
    Items.Assign(AItems);
    if AIndex>=0 then ItemIndex:=AIndex;
    end;
  end;

procedure TListSelectDialog.AddItem (const AItem : string; AIndex : integer);
begin
  lbSelect.AddItem(AITem,pointer(AIndex));
  end;

procedure TListSelectDialog.lbSelectClick (Sender: TObject);
begin
  if assigned(FOnSelect) then
    with lbSelect do if ItemIndex>=0 then FOnSelect(integer(Items.Objects[ItemIndex]));
  Close;
  end;

procedure TListSelectDialog.lbSelectMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
   Height:=defItemHeight;
   end;

procedure TListSelectDialog.ShowList (APos : TPoint; AHeight : integer);
var
  i,j,w,h : integer;
begin
  if lbSelect.Count>0 then begin
    w:=0;
    with lbSelect do begin
      for i:=0 to Items.Count-1 do begin
        j:=Canvas.TextWidth(Items[i]);
        if j>w then w:=j;
        end;
      h:=Items.Count*defItemHeight;
      end;
    inc(w,11);
    if w<FWidth then ClientWidth:=FWidth
    else ClientWidth:=w+11;
    if (AHeight=0) or (h<=AHeight) then ClientHeight:=h+(defItemHeight+1) div 3
    else ClientHeight:=AHeight;
    AdjustFormPosition(Screen,self,APos);
    Show;
    end;
  end;

end.

