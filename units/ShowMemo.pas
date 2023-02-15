(* Delphi Dialog
   Display of a text file
   ======================
   eg. log file from  Personal Backup
   using: TMemo
   search function for spec. text parts
   printing of whole file or selected text

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   Vers. 1 - Sep. 2004
   Vers. 2 - July 2022: define compiler switch "ACCESSIBLE" to make dialog
                        messages accessible to screenreaders
   last modified: December 2022
   *)


unit ShowMemo;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Printers, Vcl.ComCtrls, System.Math;

const
  defTopMargin = 150;  // Angaben in 1/10 mm
  defBottomMargin = 150;
  defLeftMargin = 200;
  defRightMargin= 100;
  defFontName = 'Courier New';
  defFontSize = 10;
  defOrientation = poPortrait;

type
  TPrinterSettings = record
    PrtName  : string;
    Margins  : TRect;     // in 1/10 mm
    Feed     : integer;   // in 1/10 mm
    FontName : string;
    FontSize : integer;
    FontStyle : TFontStyles;
    Orientation : TPrinterOrientation;
    procedure Init;
    end;

  TShowDlgBtn = (sbOpen,sbErase,sbPrint,sbSearch,sbSection,sbError,sbFont);
  TShowDlgButtons = set of TShowDlgBtn;

  TShowDlgType = (stShow,stModal);

  TShowTextDialog = class(TForm)
    pnTop: TPanel;
    EndeBtn: TBitBtn;
    PrintBtn: TBitBtn;
    PrintDialog: TPrintDialog;
    DeleteBtn: TBitBtn;
    FindDialog: TFindDialog;
    SearchBtn: TBitBtn;
    NextSectBtn: TBitBtn;
    PrevErrBtn: TBitBtn;
    PrevSectBtn: TBitBtn;
    NextErrBtn: TBitBtn;
    StatusBar: TStatusBar;
    Memo: TMemo;
    OpenBtn: TBitBtn;
    OpenDialog: TOpenDialog;
    UpdateBtn: TBitBtn;
    FontBtn: TBitBtn;
    FontDialog: TFontDialog;
    procedure FormCreate(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PrintBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MemoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure MemoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FindDialogFind(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NextSectBtnClick(Sender: TObject);
    procedure PrevErrBtnClick(Sender: TObject);
    procedure PrevSectBtnClick(Sender: TObject);
    procedure NextErrBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure EndeBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FontBtnClick(Sender: TObject);
  private
    { Private-Deklarationen }
    LPos             : integer;
    FIniName,
    FTitle,FFilter,
    SectText,ErrText : string;
    PosFromIni : boolean;
    FDlgType : TShowDlgType;
    LWidth,
    FCodePage  : integer;
    procedure Print (NoPrompt,SelectedLines : boolean);
    function LoadText (const FName : string) : boolean;
    procedure InitView (const FName : string);
  public
    { Public-Deklarationen }
    TextName : string;
    PrinterSettings : TPrinterSettings;
{$IFDEF HDPI}   // scale glyphs and images for High DPI
    procedure AfterConstruction; override;
{$EndIf}
    procedure LoadViewSettings(AIniName : string);
    procedure ReloadText;
    procedure Execute (const Title,TextDatei,
                       PrevCap1,NextCap1,SrchText1,
                       PrevCap2,NextCap2,SrchText2,
                       Filter                   : string;
                       APos      : TPoint;
                       Line      : integer;
                       DlgType   : TShowDlgType;
                       Buttons   : TShowDlgButtons;
                       CodePage  : integer = 0); overload;
    procedure Execute (const Title,TextDatei,
                       PrevCap1,NextCap1,SrchText1,
                       PrevCap2,NextCap2,SrchText2,
                       Filter                   : string;
                       APos      : TPoint;
                       Line      : integer;
                       DlgType   : TShowDlgType;
                       Buttons   : TShowDlgButtons;
                       PrtSettings : TPrinterSettings;
                       CodePage  : integer = 0); overload;
    end;

function LoadPrinterSettings(const AIniName,ASection : string) : TPrinterSettings;
procedure SavePrinterSettings(const AIniName,ASection : string; const ASettings : TPrinterSettings);

procedure PrintTextFile (const TextDatei: string; PrtSettings : TPrinterSettings; CodePage : integer = 0);

procedure ShowTextFile (const Title,TextDatei,
                     PrevCap1,NextCap1,SrchText1,
                     PrevCap2,NextCap2,SrchText2,
                     Filter                   : string;
                     APos      : TPoint;
                     Line      : integer;
                     DlgType   : TShowDlgType;
                     Buttons   : TShowDlgButtons;
                     CodePage  : integer = 0); overload;

procedure ShowTextFile (const Title,TextDatei,
                     PrevCap1,NextCap1,SrchText1,
                     PrevCap2,NextCap2,SrchText2,
                     Filter                   : string;
                     APos      : TPoint;
                     Line      : integer;
                     DlgType   : TShowDlgType;
                     Buttons   : TShowDlgButtons;
                     PrtSettings : TPrinterSettings;
                     CodePage  : integer = 0); overload;

procedure ShowTextFile (const Title,TextDatei : string;
                     APos      : TPoint;
                     DlgType   : TShowDlgType;
                     Buttons   : TShowDlgButtons;
                     PrtSettings : TPrinterSettings;
                     CodePage  : integer = 0); overload;
var
  ShowTextDialog : TShowTextDialog;

implementation

{$R *.DFM}

uses GnuGetText, PathUtils, System.IniFiles, System.StrUtils, WinUtils,
  {$IFDEF ACCESSIBLE} ShowMessageDlg {$ELSE} MsgDialogs {$ENDIF};

var
  IniFileName  : string;

{------------------------------------------------------------------- }
const
  ViewSect = 'View';
  iniTop = 'Top';
  iniLeft = 'Left';
  iniHeight = 'Height';
  iniWidth = 'Width';

  IniPrtName = 'Printer';
  IniLeftMarg = 'LeftMargin';
  IniRightMarg = 'RightMargin';
  IniTopMarg = 'TopMargin';
  IniBottomMarg = 'BottomMargin';
  IniFontName = 'FontName';
  IniFontSize = 'FontSize';
  IniFontStyle = 'FontStyle';
  IniOrientation = 'Orientation';

{------------------------------------------------------------------- }
// Ersatz für Bibliotheksfunktion, da dort nur 16-bit-Werte verarbeitet werden
function GetCaretPos (Memo : TMemo) : TPoint;
var
  CPos : integer;
begin
  with Memo do begin
    Result.X := SendMessage(Handle, EM_GETSEL, WParam(@CPos), 0);
    Result.Y := SendMessage(Handle, EM_LINEFROMCHAR, CPos, 0);
    Result.X := CPos - SendMessage(Handle, EM_LINEINDEX, -1, 0);
    end;
  end;

{ ------------------------------------------------------------------- }
function FindOptionsToSearchOptions (FOptions : TFindOptions) : TStringSearchOptions;
begin
  Result:=[];
  if frDown in FOptions then Include(Result,soDown);
  if frMatchCase in FOptions then Include(Result,soMatchCase);
  if frWholeWord in FOptions then Include(Result,soWholeWord);
  end;

function SearchMemo(Memo: TMemo; SearchDown : boolean;
                    const SearchString: String;
                    Options: TFindOptions): Boolean;
var
  Buffer, P : PChar;
  Size      : integer;
begin
  Result := False;
  if (Length(SearchString) = 0) then Exit;
  Size := Memo.GetTextLen;
  if (Size = 0) then Exit;
  Buffer := StrAlloc(Size + 1);
  try
    Memo.GetTextBuf(Buffer, Size + 1);
    P := SearchBuf(Buffer, Size, Memo.SelStart, Memo.SelLength, SearchString, FindOptionsToSearchOptions(Options));
    if P <> nil then with memo do begin
      SelStart:= P - Buffer;     // Number of line has to be subtracted to get right value for SelStart ???
      SelLength := Length(SearchString);
      Perform(EM_SCROLLCARET,0,0);
      if SearchDown and (Perform(EM_GETFIRSTVISIBLELINE,0,0)<Perform(EM_LINEFROMCHAR,SelStart,0)) then begin
        Perform(EM_SCROLL,SB_LINEDOWN,0); Perform(EM_SCROLL,SB_LINEDOWN,0);
        end;
      Result := True;
    end;
  finally
    StrDispose(Buffer);
  end;
end;

{ ------------------------------------------------------------------- }
procedure TShowTextDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs');
  Memo.Clear;
  PosFromIni:=false;
  PrinterSettings.Init;
  LWidth:=Width;
  end;

{$IFDEF HDPI}   // scale glyphs and images for High DPI
procedure TShowTextDialog.AfterConstruction;
begin
  inherited;
  if Application.Tag=0 then
    ScaleButtonGlyphs(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;
{$EndIf}

procedure TShowTextDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LWidth:=Width;
  end;

procedure TShowTextDialog.FormDestroy(Sender: TObject);
var
  fc : TFontStyleToByte;
begin
  if FileExists(FIniName) then begin
    with TIniFile.Create(FIniName) do begin
      WriteInteger(ViewSect,iniTop,Top);
      WriteInteger(ViewSect,iniLeft,Left);
      WriteInteger(ViewSect,iniHeight,Height);
      WriteInteger(ViewSect,iniWidth,Width);
      with Memo.Font do begin
        WriteString(ViewSect,IniFontName,Name);
        WriteInteger(ViewSect,IniFontSize,Size);
        fc.Style:=Style;
        WriteInteger(ViewSect,IniFontStyle,fc.Value);
        end;
      Free;
      end;
    end;
  end;

procedure TShowTextDialog.FormShow(Sender: TObject);
begin
  with Printer,PrinterSettings do begin
    if Printers.Count>0 then begin
      try
        PrinterIndex:=Printers.IndexOf(PrtName);
        PrtName:=Printers[PrinterIndex];
      except
        PrtName:='';   // kein Standarddrucker
        end;
      end
    else PrtName:='';
    PrintBtn.Enabled:=length(PrtName)>0;
    end;
  Width:=LWidth;
  FitToScreen(Screen,self);
  InitView(TextName);
  BringToFront;
  end;

{ ---------------------------------------------------------------- }
(* Cursorposition anzeigen *)
procedure TShowTextDialog.MemoChange(Sender: TObject);
var
  pt : TPoint;
begin
  pt:=GetCaretPos(Memo);
  StatusBar.Panels[0].Text:=SafeFormat(dgettext('dialogs',' Line: %u of %u'),[pt.y+1,Memo.Lines.Count+1]);
  end;

procedure TShowTextDialog.InitView (const FName : string);
var
  LineNr : integer;
begin
  LoadText(FName);
  with Memo do begin
    if (LPos<=0) or (LPos>=Lines.Count) then begin
      LineNr:=Lines.Count;
      Perform(WM_VSCROLL,SB_BOTTOM,0);
      end
    else begin
      LineNr:=LPos-1;
      Perform(EM_SCROLLCARET,0,0);
      end;
    SelStart:=Perform(EM_LINEINDEX,LineNr,0);
    SelLength:=0;
//    if LineNr=Lines.Count then SelLength:=0 else SelLength:=Perform(EM_LINEINDEX,LineNr+1,0)-SelStart;
    StatusBar.Panels[0].Text:=SafeFormat(dgettext('dialogs',' Line: %u of %u'),[LineNr+1,Lines.Count+1]);
    end;
  with FindDialog do Options:=Options -[frDown];
  end;

procedure TShowTextDialog.FormPaint(Sender: TObject);
begin
  MemoChange(Sender);
  end;

procedure TShowTextDialog.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then ModalResult:=mrCancel;
  end;

procedure TShowTextDialog.MemoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[ssCtrl]) and (Key=ord('F')) then SearchBtnClick(Sender);
  if (Shift=[]) and (Key=VK_F3) then FindDialogFind(Sender);
  if (Key=VK_DELETE)  and (Memo.SelLength>0) then begin
    if ConfirmDialog (Point(Left+200,Top+100),
                      dgettext('dialogs','Delete selected text?')) then begin
      with Memo do begin
        ReadOnly:=false;
        ClearSelection;
        Lines.SaveToFile(TextName);
        ReadOnly:=true;
        end;
      end;
    end;
  MemoChange(Sender);
  end;

procedure TShowTextDialog.FormActivate(Sender: TObject);
begin
  Memo.SetFocus;
  end;

{ ------------------------------------------------------------------- }
type
  TCharRange = record
    cpMin: Longint;
    cpMax: LongInt;
    end;

procedure TShowTextDialog.Print (NoPrompt,SelectedLines : boolean);
var
  w,v        : TSize;
  i,j,k,lh,
  n1,n2,
  y,lp,hp    : integer;
  txt,s,t,sc : string;
  Selection  : TCharRange;
  f          : double;

const
  PtToCm = 0.0353;   (* 1 Pt in cm *)
  EM_EXGETSEL = WM_USER + 52;

  procedure CheckForNewPage;
  var
    sf : string;
  begin
    with Printer,Canvas do begin
      if y>=lp then begin
        y:=PrinterSettings.Margins.Top;
        newpage;
        end;
      if y=PrinterSettings.Margins.Top then begin   // Kopfzeile erzeugen
        font.style:=[fsbold];
        sf:=SafeFormat(dgettext('dialogs','Page: %u'),[pagenumber]);
//        textout(PrinterSettings.Margins.Left,y,StripPath(Caption,72));
        textout(PrinterSettings.Margins.Left,y,FTitle);
        textout(hp-TextWidth(sf),y,sf);
        inc(y,lh+3);
        sf:=dgettext('dialogs','File: ');
        textout(PrinterSettings.Margins.Left,y,sf+StripPath(TextName,80-length(sf)));
        inc(y,lh+3);
        moveto (PrinterSettings.Margins.Left,y); lineto (hp,y);
        font.style:=[];
        inc(y,20);
        end;
      end;
    end;

  procedure CopyCharacters;
  begin
    repeat
      t:=copy(txt,1,1);
      if Printer.Canvas.TextWidth(sc+s+t)<hp-PrinterSettings.Margins.Left then begin
        s:=s+t; delete(txt,1,1); t:='';
        end;
      until length(t)>0;
    end;

begin
  if NoPrompt or PrintDialog.Execute then begin
    Screen.Cursor:=crHourglass;
    with Printer do begin
      Orientation:=PrinterSettings.Orientation;
      lp:=GetDeviceCaps (Handle,VERTSIZE);
      if lp<=0 then lp:=2900 else lp:=10*lp;  // Seitenhöhe in 1/10 mm
      hp:=GetDeviceCaps (Handle,HORZSIZE);
      if hp<=0 then hp:=2000 else hp:=10*hp;  // Seitenbreite in 1/10 mm
      Title:=Caption;
      Begindoc;
      with Canvas do begin
        setmapmode(handle,mm_lometric);     // 1/10 mm aber Y geht nach oben
        GetWindowExtEx(handle,w);           // Auflösung ermitteln
        GetViewportExtEx(handle,v);
        setmapmode(handle,MM_ANISOTROPIC);         // neuer Abb.-Modus
        SetWindowExtEX(handle,w.cx,w.cy,nil);      // Skalierung ...
        SetViewPortExtEx(handle,v.cx,-v.cy,nil);
        f:=PtToCm*100*PrinterSettings.FontSize;    (* Punkte in 0,1 mm umrechnen *)
        lh:=round(f);
        with Font do begin
          Name:=PrinterSettings.FontName;
          Style:=PrinterSettings.FontStyle;
//          Size:=PrinterSettings.FontSize;
          Height:=lh;
          end;
        Brush.Color := clwhite;   // Hintergrundfarbe
        lp:=lp-PrinterSettings.Margins.Bottom;
        hp:=hp-PrinterSettings.Margins.Right;
        y:=PrinterSettings.Margins.Top;
        with Memo do begin
          if SelectedLines then begin
            (* Zeilennummern des selektierten Bereichs ermitteln *)
            Perform(EM_EXGETSEL,0,longint(@Selection));
            with Selection do begin
              n1:=Perform(EM_LINEFROMCHAR,cpMin,0);
              n2:=Perform(EM_LINEFROMCHAR,cpMax,0);
              end;
            end
          else begin
            n1:=0; n2:=Lines.Count-1;
            end;
          end;
        for i:=n1 to n2 do begin
          CheckForNewPage;
          txt:=Memo.Lines[i];
          sc:='';
          while TextWidth(sc+txt)>=hp-PrinterSettings.Margins.Left do begin
            s:='';
            repeat
              k:=Pos(' ',txt); j:=Pos('\',txt);
              if k=0 then k:=j else k:=Min(k,j);
              j:=Pos('}',txt);
              if j>0 then begin
                if k=0 then k:=j else k:=Min(k,j);
                end;
              if k>0 then begin
                t:=copy(txt,1,k);
                if TextWidth(sc+s+t)<hp-PrinterSettings.Margins.Left then begin
                  s:=s+t; delete(txt,1,k); t:='';
                  end
                else if length(s)=0 then CopyCharacters;
                end
              else if length(s)=0 then CopyCharacters
              else t:='x';
              until length(t)>0;
            textout(PrinterSettings.Margins.Left,y,sc+s);
            sc:='* ';
            inc(y,lh+3);
            CheckForNewPage;
            end;
          textout(PrinterSettings.Margins.Left,y,sc+txt);
          inc(y,lh+3);
          end;
        end;
      EndDoc;
      end;
    Screen.Cursor:=crDefault;
    end;
  end;

procedure TShowTextDialog.PrintBtnClick(Sender: TObject);
var
  sel      : boolean;
begin
  if not Printer.Printing then begin
    if Memo.SelLength>0 then sel:=ConfirmDialog(dgettext('dialogs','Print selected lines?'))
    else sel:=false;
    Print(false,sel);
    Memo.SetFocus;
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TShowTextDialog.FontBtnClick(Sender: TObject);
begin
  with FontDialog do begin
    with Font do begin
      Name:=Memo.Font.Name; Size:=Memo.Font.Size; Style:=Memo.Font.Style;
      end;
    if Execute then with Font do begin
      Memo.Font.Name:=Name; Memo.Font.Size:=Size; Memo.Font.Style:=Style;
      end;
    end;
  end;

procedure TShowTextDialog.DeleteBtnClick(Sender: TObject);
begin
  if Memo.SelLength>0 then begin
    if ConfirmDialog (Point(Left+200,Top+100),dgettext('dialogs','Delete selected text?')) then begin
      with Memo do begin
        ReadOnly:=false;
        ClearSelection;
        Lines.SaveToFile(TextName,TEncoding.UTF8);
        ReadOnly:=true;
        end;
      end;
    end
  else begin
    if ConfirmDialog (Point(Left+200,Top+100),SafeFormat(dgettext('dialogs','Delete file "%s"?'),[TextName])) then begin
      DeleteFile(TextName);
      Memo.Clear;
      end;
    ModalResult:=mrCancel;
    end;
  end;

procedure TShowTextDialog.MemoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MemoChange(Sender);
  end;

procedure TShowTextDialog.FindDialogFind(Sender: TObject);
begin
  with FindDialog do
    if not SearchMemo(Memo,false,FindText,Options) then
      ShowMessage(SafeFormat(dgettext('dialogs','"%s" not found!'),[FindText]))
    else MemoChange(Sender);
  end;

procedure TShowTextDialog.SearchBtnClick(Sender: TObject);
begin
  FindDialog.Execute;
  end;

procedure TShowTextDialog.UpdateBtnClick(Sender: TObject);
begin
  InitView(TextName);
  end;

procedure TShowTextDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key=ord('F')) then FindDialog.Execute
  else if (Shift=[]) and (Key=VK_F3) then FindDialogFind(Sender)
{$IFDEF ACCESSIBLE}
  else if (Key=VK_F11) then begin
    with ActiveControl do if length(Hint)>0 then ShowHintInfo(Hint);
    end
{$ENDIF}
  else if (Key=VK_ESCAPE) and (FDlgType=stShow) then Close;
  end;

procedure TShowTextDialog.PrevSectBtnClick(Sender: TObject);
begin
  with FindDialog do begin
    FindText:=SectText; Options:=Options-[frDown];
    if not SearchMemo(Memo,false,FindText,Options) then begin
      Memo.SelStart:=0;
      StatusBar.Panels[1].Text:=dgettext('dialogs','No further sections!');
      end
    else StatusBar.Panels[1].Text:='';
    MemoChange(Sender);
    end;
  end;

procedure TShowTextDialog.NextSectBtnClick(Sender: TObject);
var
  pt : TPoint;
begin
  with FindDialog do begin
    FindText:=SectText; Options:=Options+[frDown];
    if not SearchMemo(Memo,true,FindText,Options) then with Memo do begin
      pt.x:=0; pt.y:=Lines.Count; CaretPos:=pt;
      Perform(EM_SCROLLCARET,0,0);
      StatusBar.Panels[1].Text:=dgettext('dialogs','No further sections!');
      end
    else StatusBar.Panels[1].Text:='';
    MemoChange(Sender);
    end;
  end;

function TShowTextDialog.LoadText (const FName : string) : boolean;
var
  fs : TStream;

  procedure LoadFromStream;
  var
    Size,i,j: Integer;
    Buffer: TBytes;
    Enc: TEncoding;
  begin
    with Memo.Lines do begin
      BeginUpdate;
      try
        Size := fs.Size - fs.Position;
        SetLength(Buffer, Size);
        fs.Read(Buffer, 0, Size);
        // remove zero bytes
        i:=0; j:=0;
        while i<Size do begin
          while (i<Size) and (Buffer[i]=0) do inc(i);
          if (i<Size) and (j<i) then Buffer[j]:=Buffer[i];
          inc(i); inc(j);
          end;
        SetLength(Buffer,j);
        if FCodePage>0 then Enc:=TEncoding.GetEncoding(FCodePage) else Enc:=nil;
        Size := TEncoding.GetBufferEncoding(Buffer, Enc, DefaultEncoding);
        try
          Text:=Enc.GetString(Buffer, Size, Length(Buffer) - Size);
        except
          on EEncodingError do Text:=TEncoding.ANSI.GetString(Buffer, Size, Length(Buffer) - Size);
          end;
      finally
        EndUpdate;
        end;
      end;
    end;

begin
  TextName:=FName;
  Result:=false;
  with Memo do begin
    fs:= TFileStream.Create(FName,fmOpenRead or fmShareDenyNone);
    try
      LoadFromStream;
//      if FCodePage>0 then Lines.LoadFromStream(fs,TEncoding.GetEncoding(FCodePage))
//      else Lines.LoadFromStream(fs);
      Result:=true;
    finally
      fs.Free;
      end;
    end;
  end;

procedure TShowTextDialog.OpenBtnClick(Sender: TObject);
begin
  with OpenDialog do begin
    if length(TextName)>0 then InitialDir:=ExtractFilePath(TextName)
    else InitialDir:='';
    Title:=FTitle;
    Filter:=FFilter;
    Filename:='';
    if Execute then begin
      LoadText(Filename);
      Caption:=FTitle+' ['+TextName+']';
      end;
    end;
  end;

procedure TShowTextDialog.PrevErrBtnClick(Sender: TObject);
begin
  with FindDialog do begin
    FindText:=ErrText; Options:=Options-[frDown];
    if not SearchMemo(Memo,false,FindText,Options) then begin
      Memo.SelStart:=0;
      StatusBar.Panels[1].Text:=dgettext('dialogs','No further errors!');
      end
    else StatusBar.Panels[1].Text:='';
    MemoChange(Sender);
    end;
  end;

procedure TShowTextDialog.NextErrBtnClick(Sender: TObject);
var
  pt : TPoint;
begin
  with FindDialog do begin
    FindText:=ErrText; Options:=Options+[frDown];
    if not SearchMemo(Memo,true,FindText,Options) then with Memo do begin
      pt.x:=0; pt.y:=Lines.Count; CaretPos:=pt;
      StatusBar.Panels[1].Text:=dgettext('dialogs','No further errors!');
      end
    else StatusBar.Panels[1].Text:='';
    MemoChange(Sender);
    end;
  end;

procedure TShowTextDialog.EndeBtnClick(Sender: TObject);
begin
  if FDlgType=stShow then Close;
  end;

{ ------------------------------------------------------------------- }
(* Text anzeigen *)
procedure TShowTextDialog.LoadViewSettings(AIniName : string);
var
  fc : TFontStyleToByte;
begin
  if FileExists(AIniName) then begin
    FIniName:=AIniName; PosFromIni:=true;
    with TIniFile.Create(FIniName) do begin
      Top:=ReadInteger(ViewSect,iniTop,Top);
      Left:=ReadInteger(ViewSect,iniLeft,Left);
      Height:=ReadInteger(ViewSect,iniHeight,Height);
      Width:=ReadInteger(ViewSect,iniWidth,Width);
      LWidth:=Width;
      with Memo.Font do begin
        Name:=ReadString(ViewSect,IniFontName,Name);
        Size:=ReadInteger(ViewSect,IniFontSize,Size);
        fc.Value:=ReadInteger(ViewSect,IniFontStyle,0);
        Style:=fc.Style;
        end;
      Free;
      end;
    end;
  end;

procedure TShowTextDialog.ReloadText;
begin
  if Visible then InitView(TextName);
  end;

procedure TShowTextDialog.Execute (const Title,TextDatei,
                                   PrevCap1,NextCap1,SrchText1,
                                   PrevCap2,NextCap2,SrchText2,
                                   Filter                   : string;
                                   APos      : TPoint;
                                   Line      : integer;
                                   DlgType   : TShowDlgType;
                                   Buttons   : TShowDlgButtons;
                                   CodePage  : integer = 0);
var
  x  : integer;
begin
  if Visible then begin
    if FileExists (TextDatei) then InitView(TextDatei);
    BringToFront;
    end
  else begin
    if not PosFromIni then AdjustFormPosition(Screen,self,APos);
    FTitle:=Title;
    Caption:=Title+' ['+TextDatei+']';
    FFilter:=Filter;
    LPos:=Line;
    x:=2;
    with OpenBtn do if sbOpen in Buttons then begin
      Visible:=true; Left:=x; x:=x+Width-1;
      end
    else Visible:=false;
    with UpdateBtn do if sbOpen in Buttons then begin
      Visible:=true; Left:=x; x:=x+Width-1;
      end
    else Visible:=false;
    with FontBtn do if sbFont in Buttons then begin
      Visible:=true; Left:=x; x:=x+Width-1;
      end
    else Visible:=false;
    with PrintBtn do if sbPrint in Buttons then begin
      Visible:=true; Left:=x; x:=x+Width-1;
      end
    else Visible:=false;
    with DeleteBtn do if sbErase in Buttons then begin
      Visible:=true; Left:=x; x:=x+Width-1;
      end
    else Visible:=false;
    with SearchBtn do if sbSearch in Buttons then begin
      Visible:=true; Left:=x; x:=x+Width-1;
      end
    else Visible:=false;
    if sbSection in Buttons then begin
      SectText:=SrchText1;
      with PrevSectBtn do begin
        Visible:=true; Left:=x; x:=x+Width-1;
        Hint:=PrevCap1;
        end;
      with NextSectBtn do begin
        Visible:=true; Left:=x; x:=x+Width-1;
        Hint:=NextCap1;
        end;
      end
    else begin
      PrevSectBtn.Visible:=false;
      NextSectBtn.Visible:=false;
      end;
    if sbError in Buttons then begin
      ErrText:=SrchText2;
      with PrevErrBtn do begin
        Visible:=true; Left:=x; x:=x+Width-1;
        Hint:=PrevCap2;
        end;
      with NextErrBtn do begin
        Visible:=true; Left:=x;
        Hint:=NextCap2;
        end;
      end
    else begin
      PrevErrBtn.Visible:=false;
      NextErrBtn.Visible:=false;
      end;
    FCodePage:=CodePage;
    FDlgType:=DlgType;
    if FileExists (TextDatei) then begin
      TextName:=TextDatei;
      if DlgType=stModal then ShowModal else Show;
      end
    else ErrorDialog (dgettext('dialogs','File: ')+SafeFormat(dgettext('dialogs','"%s" not found!'),[TextDatei]));
    end;
  end;

procedure TShowTextDialog.Execute (const Title,TextDatei,
                                   PrevCap1,NextCap1,SrchText1,
                                   PrevCap2,NextCap2,SrchText2,
                                   Filter                   : string;
                                   APos      : TPoint;
                                   Line      : integer;
                                   DlgType   : TShowDlgType;
                                   Buttons   : TShowDlgButtons;
                                   PrtSettings : TPrinterSettings;
                                   CodePage  : integer = 0);
begin
  PrinterSettings:=PrtSettings;
  Execute(Title,TextDatei,PrevCap1,NextCap1,SrchText1,PrevCap2,
    NextCap2,SrchText2,Filter,APos,Line,DlgType,Buttons,CodePage);
  end;

{ ------------------------------------------------------------------- }
procedure TPrinterSettings.Init;
begin
  PrtName:='';
  with Margins do begin
    Top:=defTopMargin;
    Bottom:=defBottomMargin;
    Left:=defLeftMargin;
    Right:=defRightMargin;
    end;
  FontName:=defFontName;
  FontSize:=defFontSize;
  FontStyle:=[];
  Orientation:=defOrientation;
  end;

function LoadPrinterSettings(const AIniName,ASection : string) : TPrinterSettings;
var
  n : integer;
  fc : TFontStyleToByte;
begin
  IniFileName:=AIniName;
  if (length(IniFileName)>0) and (length(ASection)>0) then
      with TIniFile.Create(IniFileName),Result do begin
    PrtName:=ReadString (ASection,IniPrtName,'');
    with Margins do begin
      Top:=ReadInteger(ASection,IniTopMarg,defTopMargin);
      Bottom:=ReadInteger(ASection,IniBottomMarg,defBottomMargin);
      Left:=ReadInteger(ASection,IniLeftMarg,defLeftMargin);
      Right:=ReadInteger(ASection,IniRightMarg,defRightMargin);
      end;
    FontName:=ReadString(ASection,IniFontName,defFontName);
    FontSize:=ReadInteger(ASection,IniFontSize,defFontSize);
    fc.Value:=ReadInteger(ASection,IniFontStyle,0);
    FontStyle:=fc.Style;
    n:=ReadInteger (ASection,IniOrientation,ord(defOrientation));
    if (n<0) or (n>1) then n:=ord(defOrientation);
    Orientation:=TPrinterOrientation(n);
    Free;
    end;
  end;

procedure SavePrinterSettings(const AIniName,ASection : string; const ASettings : TPrinterSettings);
var
  fc : TFontStyleToByte;
begin
  IniFileName:=AIniName;
  if (length(IniFileName)>0) and (length(ASection)>0) then
      with TIniFile.Create(IniFileName),ASettings do begin
    try
      WriteString(ASection,IniPrtName,PrtName);
      with Margins do begin
        WriteInteger(ASection,IniTopMarg,Top);
        WriteInteger(ASection,IniBottomMarg,Bottom);
        WriteInteger(ASection,IniLeftMarg,Left);
        WriteInteger(ASection,IniRightMarg,Right);
        end;
      WriteString(ASection,IniFontName,FontName);
      WriteInteger(ASection,IniFontSize,FontSize);
      fc.Style:=FontStyle;
      WriteInteger(ASection,IniFontStyle,fc.Value);
      WriteInteger (ASection,IniOrientation,ord(Orientation));
    finally
      Free;
      end;
    end;
  end;

procedure ShowTextFile (const Title,TextDatei,PrevCap1,NextCap1,SrchText1,PrevCap2,
                    NextCap2,SrchText2,Filter : string;
                    APos    : TPoint; Line : integer;
                    DlgType : TShowDlgType; Buttons : TShowDlgButtons;
                    PrtSettings : TPrinterSettings;
                    CodePage : integer = 0);
begin
  if not assigned(ShowTextDialog) then begin
    ShowtextDialog:=TShowtextDialog.Create(Application);
    ShowtextDialog.LoadViewSettings(IniFileName);
    end;
  ShowtextDialog.Execute(Title,TextDatei,PrevCap1,NextCap1,SrchText1,PrevCap2,
    NextCap2,SrchText2,Filter,APos,Line,DlgType,Buttons,PrtSettings,CodePage);
  if DlgType=stModal then FreeAndNil(ShowTextDialog);
  end;

procedure ShowTextFile (const Title,TextDatei,PrevCap1,NextCap1,SrchText1,PrevCap2,
                    NextCap2,SrchText2,Filter : string;
                    APos    : TPoint; Line : integer;
                    DlgType : TShowDlgType; Buttons : TShowDlgButtons;
                    CodePage : integer = 0);
begin
  if not assigned(ShowTextDialog) then begin
    ShowtextDialog:=TShowtextDialog.Create(Application);
    ShowtextDialog.LoadViewSettings(IniFileName);
    end;
  ShowtextDialog.Execute(Title,TextDatei,PrevCap1,NextCap1,SrchText1,PrevCap2,
    NextCap2,SrchText2,Filter,APos,Line,DlgType,Buttons,CodePage);
  if DlgType=stModal then FreeAndNil(ShowTextDialog);
  end;

procedure ShowTextFile (const Title,TextDatei : string;
                     APos      : TPoint;
                     DlgType   : TShowDlgType;
                     Buttons   : TShowDlgButtons;
                     PrtSettings : TPrinterSettings;
                     CodePage  : integer = 0);
begin
  ShowTextFile(Title,TextDatei,'','','','','','','',APos,1,DlgType,Buttons,PrtSettings,CodePage);
  end;

procedure PrintTextFile (const TextDatei : string; PrtSettings : TPrinterSettings; CodePage : integer = 0);
begin
  if FileExists (TextDatei) then begin
    if not assigned(ShowTextDialog) then ShowtextDialog:=TShowtextDialog.Create(Application);
    with ShowtextDialog do begin
      PrinterSettings:=PrtSettings;
      if CodePage>0 then Memo.Lines.LoadFromFile(TextDatei,TEncoding.GetEncoding(CodePage))
      else Memo.Lines.LoadFromFile(TextDatei);
      Caption:=ExtractFileName(TextDatei);
      Print(true,false);
      end;
    FreeAndNil(ShowTextDialog);
    end;
  end;

initialization
  IniFileName:='';
finalization
end.
