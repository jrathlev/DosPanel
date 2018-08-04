(* Delphi Dialog
   Auswahl und Bearbeiten von Listeneinträgen
   ==========================================
   
   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   Vers. 1 - Apr. 2005
   letzte Änderung: Juli 2018
    *)
    
unit SelectFromListDlg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, StringUtils;

type
  TCheckEntry = function (const AText : string) : boolean of object;

  TSelectFromListDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    lbxStringList: TListBox;
    gbxEdit: TGroupBox;
    btnInsert: TBitBtn;
    btnDelete: TBitBtn;
    btnEdit: TBitBtn;
    gbxMove: TGroupBox;
    UpBtn: TSpeedButton;
    DownBtn: TSpeedButton;
    lbDesc: TLabel;
    btnDefault: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    lbHint: TLabel;
    procedure btnInsertClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure lbxStringListDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpBtnClick(Sender: TObject);
    procedure DownBtnClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
  private
    { Private declarations }
    FEdit : boolean;
    hp : integer;
    DefDelimitedText : string;
    FCheckEntry : TCheckEntry;
    function DialogPos(Sender: TObject) : TPoint;
  public
    { Public declarations }
  function Execute (APos : TPoint; Titel,Desc,Hint : string;
                    Edit,Order,Multi : boolean; ACols : integer;
                    Convert : TTextChange; const Default : string;
                    SList : TStrings; var AText : string;
                    ShowCancel : boolean = true; CheckEntry : TCheckEntry = nil) : boolean;  overload;
  function Execute (APos : TPoint; Titel,Desc,Hint : string;
                    Edit,Order,Multi : boolean; ACols : integer;
                    Convert : TTextChange; const Default : string;
                    var ListText : string;
                    ADel : Char = ','; AQuote : Char ='"') : boolean; overload;
  procedure Show (APos : TPoint; Titel,Desc,Hint : string;
                  ACols : integer; SList : TStrings);
  end;

function EditList (APos : TPoint; Titel,Desc,Hint : string;
                   Edit,Order,Multi : boolean; ACols : integer;
                   Convert : TTextChange; const Default : string;
                   SList : TStrings; var AText  : string) : boolean;

function SelectFromList (APos : TPoint; Titel,Desc,Hint : string;
                    SList : TStrings; var AText  : string) : boolean;

var
  SelectFromListDialog: TSelectFromListDialog;

implementation

{$R *.DFM}

uses InpText, GnuGetText, ExtSysUtils, WinUtils;

{------------------------------------------------------------------- }
procedure TSelectFromListDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs');
  hp:=lbHint.Top; FCheckEntry:=nil;
  end;

function TSelectFromListDialog.DialogPos(Sender: TObject) : TPoint;
begin
  Result:=BottomLeftPos((Sender as TControl),Point(-100,10));
  end;

procedure TSelectFromListDialog.btnInsertClick(Sender: TObject);
var
  s  : string;
  ok : boolean;
begin
  s:='';
  if InputText(DialogPos(Sender),dgettext('dialogs','Add item'),lbDesc.Caption,false,'',nil,false,0,s) then begin
    if assigned(FCheckEntry) then ok:=FCheckEntry(s) else ok:=true;
    if ok then with lbxStringList do ItemIndex:=Items.Add(s)
    else ErrorDialog(CursorPos,TryFormat(dgettext('dialogs','Invalid entry: "%s"'),[s]));
    end;
  end;

procedure TSelectFromListDialog.btnDeleteClick(Sender: TObject);
var
  s : string;
  n : integer;
begin
  with lbxStringList do if Multiselect then begin
    if ConfirmDialog (Caption,dgettext('dialogs','Remove all selected items?'),DialogPos(Sender)) then begin
      for n:=Items.Count-1 downto 0 do if Selected[n] then Items.Delete(n);
      end
    else if ItemIndex>=0 then begin
      s:=Items[ItemIndex];
      if ConfirmDialog (Caption,TryFormat(dgettext('dialogs','Remove item: "%s"?'),[s]),DialogPos(Sender)) then begin
        n:=ItemIndex;
        Items.Delete(ItemIndex);
        if n>Items.Count then ItemIndex:=Items.Count-1 else ItemIndex:=n;
        end;
      end;
    end
  end;

procedure TSelectFromListDialog.btnEditClick(Sender: TObject);
var
  s  : string;
  ok : boolean;
begin
  with lbxStringList do if ItemIndex>=0 then begin
    s:=Items[ItemIndex];
    if InputText(DialogPos(Sender),dgettext('dialogs','Edit item'),lbDesc.Caption,false,'',nil,false,0,s) then begin
      if assigned(FCheckEntry) then ok:=FCheckEntry(s) else ok:=true;
      if ok then Items[ItemIndex]:=s
      else ErrorDialog(CursorPos,TryFormat(dgettext('dialogs','Invalid entry: "%s"'),[s]));
      end;
    end;
  end;

procedure TSelectFromListDialog.btnDefaultClick(Sender: TObject);
begin
  if ConfirmDialog(Caption,dgettext('dialogs','Reset to default values?'),DialogPos(Sender)) then with lbxStringList do begin
    Clear;
    Items.DelimitedText:=DefDelimitedText;
    end;
  end;

procedure TSelectFromListDialog.lbxStringListDblClick(Sender: TObject);
var
  s : string;
begin
  if FEdit then begin
    with lbxStringList do if ItemIndex>=0 then begin
      s:=Items[ItemIndex];
      if InputText(CursorPos(Point(-20,20)),dgettext('dialogs','Edit item'),lbDesc.Caption,false,'',nil,false,0,s) then Items[ItemIndex]:=s;
      end
    end
  else ModalResult:=mrOK;
  end;

{------------------------------------------------------------------- }
procedure TSelectFromListDialog.UpBtnClick(Sender: TObject);
var
  n : integer;
begin
  with lbxStringList,Items do if (Count>0) and (ItemIndex>0) then begin
    n:=ItemIndex;
    Exchange(n,n-1);
    ItemIndex:=n-1;
    end;
  end;

procedure TSelectFromListDialog.DownBtnClick(Sender: TObject);
var
  n : integer;
begin
  with lbxStringList,Items do if (Count>0) and (ItemIndex<Count-1) then begin
    n:=ItemIndex;
    Exchange(n,n+1);
    ItemIndex:=n+1;
    end;
  end;

{------------------------------------------------------------------- }
function TSelectFromListDialog.Execute (APos : TPoint; Titel,Desc,Hint : string;
                    Edit,Order,Multi : boolean; ACols : integer;
                    Convert : TTextChange; const Default : string;
                    SList : TStrings; var AText : string;
                    ShowCancel : boolean = true; CheckEntry : TCheckEntry = nil) : boolean;
var
  i : integer;
begin
  with APos do begin
    if (Y < 0) or (X < 0) then Position:=poScreenCenter
    else begin
      Position:=poDesigned;
      if X<0 then X:=Left;
      if Y<0 then Y:=Top;
      CheckScreenBounds(Screen,x,y,Width,Height);
      Left:=x; Top:=y;
      end;
    end;
  Caption:=Titel;
  CancelBtn.Visible:=ShowCancel;
  FCheckEntry:=CheckEntry;
  lbDesc.Caption:=Desc;
  lbHint.Caption:=Hint;
  gbxEdit.Visible:=Edit;
  gbxMove.Visible:=Order;
  if not Order then with lbHint do begin
    Top:=hp-27; Height:=54;
    end;
  if length(Default)>0 then begin
    btnDefault.Show;
    with btnDefault do gbxEdit.Height:=Top+Height+10;
    end
  else begin
    btnDefault.Hide;
    with btnEdit do gbxEdit.Height:=Top+Height+10;
    end;
  DefDelimitedText:=Default;
  FEdit:=Edit;
  with lbxStringList do begin
    Items.Delimiter:=SList.Delimiter;
    Items.QuoteChar:=SList.QuoteChar;
    Items:=SList;
    Columns:=ACols;
    ExtendedSelect:=Multi;
    MultiSelect:=Multi;
    ItemIndex:=Items.IndexOf(AText);
    end;
  if ShowModal=mrOK then with lbxStringList do begin
    if Convert<>tcNone then with Items do begin
      for i:=0 to Count-1 do Strings[i]:=TextChangeCase(Strings[i],Convert);
      end;
    if Edit then SList.DelimitedText:=Items.DelimitedText;
    if ItemIndex>=0 then begin
      if Multi then begin
        AText:='';
        for i:=0 to Items.Count-1 do if Selected[i] then AText:=AText+Items[i]+'|';
        delete(AText,length(Atext),1);
        end
      else AText:=Items[ItemIndex]
      end
    else AText:='';
    Result:=true;
    end
  else Result:=false;
  end;

function TSelectFromListDialog.Execute (APos : TPoint; Titel,Desc,Hint : string;
                    Edit,Order,Multi : boolean; ACols : integer;
                    Convert : TTextChange; const Default : string;
                    var ListText : string;
                    ADel : Char = ','; AQuote : Char ='"') : boolean;
var
  sl : TStringList;
  s  : string;
begin
  sl:=TStringList.Create;
  with sl do begin
    Sorted:=true; Delimiter:=ADel; QuoteChar:=AQuote;
    DelimitedText:=ListText;
    end;
  Result:=Execute(APos,Titel,Desc,Hint,false,false,false,ACols,tcNone,'',sl,s,true);
  ListText:=sl.DelimitedText;
  sl.Free;
  end;

procedure TSelectFromListDialog.Show (APos : TPoint; Titel,Desc,Hint : string;
                                      ACols : integer; SList : TStrings);
var
  s : string;
begin
  Execute(APos,Titel,Desc,Hint,false,false,false,ACols,tcNone,'',SList,s,false);
  end;

{------------------------------------------------------------------- }
function EditList (APos : TPoint; Titel,Desc,Hint : string;
                   Edit,Order,Multi : boolean; ACols : integer;
                   Convert : TTextChange; const Default : string;
                   SList : TStrings; var AText  : string) : boolean;
begin
  if not assigned(SelectFromListDialog) then
    SelectFromListDialog:=TSelectFromListDialog.Create(Application);
  Result:=SelectFromListDialog.Execute(APos,Titel,Desc,Hint,Edit,Order,Multi,ACols,
                                       Convert,Default,SList,AText);
  FreeAndNil(SelectFromListDialog)
  end;

function SelectFromList (APos : TPoint; Titel,Desc,Hint : string;
                    SList : TStrings; var AText  : string) : boolean;
begin
  if not assigned(SelectFromListDialog) then
    SelectFromListDialog:=TSelectFromListDialog.Create(Application);
  Result:=SelectFromListDialog.Execute(APos,Titel,Desc,Hint,false,false,false,0,
                                       tcNone,'',SList,AText);
  FreeAndNil(SelectFromListDialog)
  end;

end.
