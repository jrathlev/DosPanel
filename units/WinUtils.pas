(* Delphi-Unit
   Collection of Windows related subroutines
   =========================================

   � Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   New compilation: April 2015
   language dependend strings in UnitConsts
   last modified:  Feb. 2017
   *)

unit WinUtils;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms, Vcl.ComCtrls, Vcl.Printers, System.IniFiles,
  Vcl.Dialogs;

const
  CenterPos : TPoint = (X : -1; Y : -1);
  MaxHist : integer = 50;

  // errors from SHgetFileOperation
  FACILITY_PreWin32 = 128;
  FACILITY_ShellExec = 129;

  // Bildschirm-Aufl�sung bei der Programmentwicklung
  PixelsPerInchOnDesign = 96;
  { "Scaled = true" passt die Formulare automatisch an andere Textgr��en an
    F�r die Berechnung von Spaltenbreiten, o.�. muss dann zus�tzlich folgende
    Umrechnung verwendet werden:
    n:=MulDiv(n(96),Screen.PixelsPerInch,PixelsPerInchOnDesign)
  }

type
  TBoolFunction = function : boolean of object;
  TIntegerFunction = function : integer;

  TFontStyleToByte = record
    case integer of
    1 : (Style : TFontStyles);
    2 : (Value : byte);
    end;

  TArea = record
  case integer of
    0 : (Left,Top,Width,Height: integer);
    1 : (TopLeft,WidthHeight: TPoint);
    end;

  TFPoint = record
    X,Y : double;
    end;

  TFRect = record
    case integer of
    0 : (Left,Top,Right,Bottom : double);
    1 : (TopLeft,BottomRight : TFPoint);
    end;

{ ---------------------------------------------------------------- }
// Anzeige eines Hinweisfenster (THintWindow), das nach einstellbarer Zeit (Delay)
// automatisch verschwindet
  TTimerHint = class (THintWindow)
  private
    FTimer : TTimer;
    FOnTerminate : TNotifyEvent;
    procedure Terminate (Sender : TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create (AOwner: TComponent; Delay : integer);  // Delay in ms
    destructor Destroy; override;
    procedure ShowHint (r : TRect; AHint : string);
    procedure HideHint;
    property OnTerminate : TNotifyEvent read FOnTerminate write FOnTerminate;
    end;

{ ---------------------------------------------------------------- }
// erweiterte Drucker-Angaben (alle Angaben in mm)
function GetPaperWidth (APrinter : TPrinter) : integer;
function GetPaperHeight (APrinter : TPrinter) : integer;
function GetLeftOffset (APrinter : TPrinter) : integer;
function GetTopOffset (APrinter : TPrinter) : integer;
function GetMaxWidth (APrinter : TPrinter) : integer;
function GetMaxHeight (APrinter : TPrinter) : integer;

// Duplex-Druck
function SupportsDuplex (APrinter : TPrinter) : Boolean;
function UsesDuplex (APrinter : TPrinter) : Boolean;
procedure SetToDuplex (APrinter : TPrinter);

{ ---------------------------------------------------------------- }
// Pr�fen, ob ein Fenster auf den Bildschirm passt
procedure CheckScreenBounds (AScreen         : TScreen;
                             var ALeft,ATop : integer;
                             AWidth,AHeight : integer);
procedure FitToScreen (AScreen : TScreen; Control : TControl);

// Position einer Form an den Bildschirm anpassen
procedure AdjustFormPosition (AScreen : TScreen; AForm : TForm;
          APos : TPoint; AtBottom : boolean = false);

// Get position of TopLeft to fit the window on the specified monitor
function FitToMonitor (Mon : TMonitor; BoundsRect : TRect) : TPoint;

// Calculate the maximum text width for multiline text
function MaxTextWidth(const Text : string; Canvas : TCanvas) : integer;

{ ---------------------------------------------------------------- }
// Dateifilter-Index ermitteln (siehe TOpenDialog)
function GetFilterIndex(AFilter,AExtension : string) : integer;

{ ---------------------------------------------------------------- }
// MessageDlg in Bildschirmmitte (X<0) oder an Position X,Y
function MessageDialog(const Title,Msg: string; DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons; DefaultButton : TMsgDlgBtn;
                       Pos : TPoint; Delay : integer;
                       ADefaultMonitor : TDefaultMonitor = dmActiveForm) : integer; overload;
function MessageDialog(const Title,Msg: string; DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons;
                       Pos : TPoint; Delay : integer;
                       ADefaultMonitor : TDefaultMonitor = dmActiveForm) : integer; overload;
function MessageDialog(const Title,Msg: string; DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons) : integer; overload;
function MessageDialog(const Msg: string; DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons) : integer; overload;
function MessageDialog(Pos : TPoint; const Msg: string; DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons) : integer;  overload;

function ConfirmDialog (const Title,Msg : string; Pos : TPoint) : boolean; overload;
function ConfirmDialog (const Title,Msg : string) : boolean; overload;
function ConfirmDialog (const Msg : string; DefaultButton : TMsgDlgBtn = mbYes) : boolean; overload;
function ConfirmDialog (Pos : TPoint; const Msg : string; DefaultButton : TMsgDlgBtn = mbYes;
                        ADefaultMonitor : TDefaultMonitor = dmActiveForm) : boolean; overload;
function ConfirmDialog (Pos : TPoint; const Title,Msg : string; DefaultButton : TMsgDlgBtn = mbYes;
                        ADefaultMonitor : TDefaultMonitor = dmActiveForm) : boolean; overload;

procedure InfoDialog (const Title,Msg : string; Pos : TPoint); overload;
procedure InfoDialog (const Title,Msg : string; Delay : integer); overload;
procedure InfoDialog (const Title,Msg : string); overload;
procedure InfoDialog (const Msg : string); overload;
procedure InfoDialog (Pos : TPoint; const Msg : string); overload;

procedure ErrorDialog (const Title,Msg : string; Pos : TPoint); overload;
procedure ErrorDialog (const Title,Msg : string; x,y : integer); overload;
procedure ErrorDialog (const Title,Msg : string; Delay : integer); overload;
procedure ErrorDialog (const Title,Msg : string); overload;
procedure ErrorDialog (const Msg : string); overload;
procedure ErrorDialog (Pos : TPoint; const Msg : string); overload;

{ ---------------------------------------------------------------- }
// get current cursor position
function CursorPos : TPoint; overload;
function CursorPos (Offset : TPoint): TPoint; overload;
function CursorPos (dx,dy : integer): TPoint; overload;
//function AddOffsetPos(Pos1,Pos2 : TPoint) : TPoint; overload;
//function AddOffsetPos(Pos : TPoint; dx,dy : integer) : TPoint; overload;

// position of component
function TopLeftPos (AControl : TControl) : TPoint; overload;
function TopLeftPos (AControl : TControl; X,Y : integer) : TPoint; overload;
function TopLeftPos (AControl : TControl; Offset : TPoint) : TPoint; overload;
function BottomLeftPos (AControl : TControl) : TPoint; overload;
function BottomLeftPos (AControl : TControl; X,Y : integer) : TPoint; overload;
function BottomLeftPos (AControl : TControl; Offset : TPoint) : TPoint; overload;
function TopRightPos (AControl : TControl) : TPoint; overload;
function TopRightPos (AControl : TControl; X,Y : integer) : TPoint; overload;
function TopRightPos (AControl : TControl; Offset : TPoint) : TPoint; overload;
function BottomRightPos (AControl : TControl) : TPoint; overload;
function BottomRightPos (AControl : TControl; X,Y : integer) : TPoint; overload;
function BottomRightPos (AControl : TControl; Offset : TPoint) : TPoint; overload;

// area of component
function GetRect (AControl : TControl) : TRect;

// adjust size of dialogs if styles are used
procedure AdjustClientSize (AForm : TForm; AControl : TControl; Dist : integer = 5);
procedure AdjustClientWidth (AForm : TForm; AControl : TControl; Dist : integer = 5);

{ ---------------------------------------------------------------- }
// History list management
procedure LoadHistory (IniFile : TIniFile; const Section,Ident : string;
                       History : TStrings; MaxCount : integer); overload;
procedure LoadHistory (IniFile : TIniFile; const Section,Ident : string;
                       History : TStrings); overload;
procedure LoadHistory (const IniName,Section,Ident : string;
                       History : TStrings; MaxCount : integer); overload;
procedure LoadHistory (const IniName,Section,Ident : string;
                       History : TStrings); overload;

procedure SaveHistory (IniFile : TIniFile; const Section,Ident : string;
                       Erase : boolean; History : TStrings; MaxCount : integer); overload;
procedure SaveHistory (IniFile : TIniFile; const Section,Ident : string;
                       Erase : boolean; History : TStrings); overload;
procedure SaveHistory (const IniName,Section,Ident : string;
                       Erase : boolean; History : TStrings; MaxCount : integer); overload;
procedure SaveHistory (const IniName,Section,Ident : string;
                       Erase : boolean; History : TStrings); overload;

procedure AddToHistory (History : TStrings; const hs : string; MaxCount : integer); overload;
procedure AddToHistory (History : TStrings; const hs : string); overload;
procedure RemoveFromHistory (History : TStrings; const hs : string);

{ ---------------------------------------------------------------- }
// Entferne alle Objekte einer String-Liste oder einer ListView-Liste aus dem Speicher
procedure FreeListObjects(Liste : TStrings);
procedure FreeListViewData (Liste : TListItems);

{ ---------------------------------------------------------------- }
// Listview-Index aus Caption ermitteln (wie IndexOf bei TListBox)
function GetListViewIndex (lv : TListView; const ACaption : string): integer;

// Subitem-Index aus der Mausposition ermitteln (nur vsReport)
function GetColumnIndexAt (ListView : TListView; Pos : integer) : integer;

// TopItem auf Index setzen (nur vsReport)
procedure SetListViewTopItem (lv : TListView; AIndex : integer; Select : boolean);

{ ---------------------------------------------------------------- }
(* System herunterfahren *)
function ExitFromWindows (Prompt : string; EwFlags,RsFlags : longword) : boolean;
function ShutDownWindows (Prompt : string; Restart : boolean; RsFlags : longword) : boolean;

{ ---------------------------------------------------------------- }
// Tastaturpuffer l�schen
function ClearKeyboardBuffer : Integer;

{ ---------------------------------------------------------------- }
(* erzeugen einer System-Fehlermeldung *)
function SystemErrorMessage(ASysError : cardinal) : string;
function NoError(ASysError : cardinal) : boolean;
function ThisError(ASysError,ThisError : cardinal) : boolean;
function IsSysError(ASysError : cardinal) : boolean;

{ ---------------------------------------------------------------- }
// Liste der auf dem System vorhandenen Codepages erstellen
function GetCodePageList (sl : TStrings) : boolean;

{ =================================================================== }
implementation

uses WinApi.WinSpool, Winapi.Messages, System.StrUtils, System.Math,
  WinApiUtils, StringUtils, UnitConsts;

const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';

{ ------------------------------------------------------------------- }
// Anzeige eines Hinweisfensters (THintWindow), das nach einstellbarer Zeit (Delay)
// automatisch verschwindet
constructor TTimerHint.Create (AOwner: TComponent; Delay : integer);
begin
  inherited Create(AOwner);
  FTimer:=TTimer.Create(AOwner);
  with FTimer do begin
    Interval:=Delay;
    Enabled:=false;
    OnTimer:=Terminate;
    end;
  FOnTerminate:=nil;
  end;

procedure TTimerHint.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
  end;

destructor TTimerHint.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
  end;

procedure TTimerHint.ShowHint (r : TRect; AHint : string);
begin
  ActivateHint(r,AHint);
  FTimer.Enabled:=true;
  end;

procedure TTimerHint.Terminate (Sender : TObject);
begin
  FTimer.Enabled:=false;
  ReleaseHandle;
  if assigned(FOnTerminate) then FOnTerminate(self);
  end;

procedure TTimerHint.HideHint;
begin
  FTimer.Enabled:=false;
  ReleaseHandle;
  end;

{ ------------------------------------------------------------------- }
(* Erweiterte Druckerangaben *)
(* tats�chliche Papierbreite in mm *)
function GetPaperWidth (APrinter : TPrinter) : integer;
begin
  with APrinter do
    Result:=round(25.4*GetDeviceCaps(Handle,PHYSICALWIDTH)/GetDeviceCaps(Handle,LOGPIXELSX));
  end;

(* tats�chliche Papierh�he in mm *)
function GetPaperHeight (APrinter : TPrinter) : integer;
begin
  with APrinter do
    Result:=round(25.4*GetDeviceCaps(Handle,PHYSICALHEIGHT)/GetDeviceCaps(Handle,LOGPIXELSX));
  end;

(* nichtdruckbarer Bereich am linken Rand in mm *)
function GetLeftOffset (APrinter : TPrinter) : integer;
begin
  with APrinter do
    Result:=round(25.4*GetDeviceCaps(Handle,PHYSICALOFFSETX)/GetDeviceCaps(Handle,LOGPIXELSX));
  end;

(* nichtdruckbarer Bereich am oberen Rand in mm *)
function GetTopOffset (APrinter : TPrinter) : integer;
begin
  with APrinter do
    Result:=round(25.4*GetDeviceCaps(Handle,PHYSICALOFFSETY)/GetDeviceCaps(Handle,LOGPIXELSX));
  end;

(* nutzbare Papierbreite in mm *)
function GetMaxWidth (APrinter : TPrinter) : integer;
begin
  with APrinter do
    Result:=GetDeviceCaps(Handle, HorzSize);
  end;

(* nutzbare Papierh�he in mm *)
function GetMaxHeight (APrinter : TPrinter) : integer;
begin
  with APrinter do Result:=GetDeviceCaps(Handle, VertSize);
  Sleep(100);
  end;

// pr�fe, ob Duplex-Druck unterst�tzt wird
function SupportsDuplex (APrinter : TPrinter) : Boolean;
var
  Device,Driver,Port : array[0..255] of Char;
  hDevMode: THandle;
begin
  APrinter.GetPrinter(Device,Driver,Port,hDevmode);
  Result:=WinApi.WinSpool.DeviceCapabilities(Device,Port,DC_DUPLEX,nil,nil)<>0;
  end;

// pr�fe,ob Duplex-Druck eingestellt ist
function UsesDuplex (APrinter : TPrinter) : Boolean;
var
  Device,Driver,Port : array[0..255] of Char;
  hDevMode: THandle;
  pDevmode: PDeviceMode;
begin
  Result:=false;
  APrinter.GetPrinter(Device,Driver,Port,hDevmode);
  if hDevmode<>0 then begin
     // lock it to get pointer to DEVMODE record
    pDevMode:=GlobalLock(hDevmode);
    if pDevmode<>nil then
      try
        Result:=pDevmode^.dmDuplex<>DMDUP_SIMPLEX;
      finally
        // unlock devmode handle.
        GlobalUnlock(hDevmode);
      end;
    end;
  end;

// Schalte Drucker auf Duplex
procedure SetToDuplex (APrinter : TPrinter);
var
  Device,Driver,Port : array[0..255] of Char;
  hDevMode: THandle;
  pDevmode: PDeviceMode;
begin
  APrinter.GetPrinter(Device,Driver,Port,hDevmode);
  if (hDevmode<>0) and (WinApi.WinSpool.DeviceCapabilities(Device,Port,DC_DUPLEX,nil,nil)<>0) then begin
     // lock it to get pointer to DEVMODE record
    pDevMode:=GlobalLock(hDevmode);
    if pDevmode<>nil then
      try
        with pDevmode^ do begin
          dmDuplex:=DMDUP_VERTICAL;
          dmFields:=dmFields or DM_DUPLEX;
          end;
      finally
        // unlock devmode handle.
        GlobalUnlock(hDevmode);
      end;
    end;
  end;

{ ---------------------------------------------------------------- }
(* Pr�fen, ob ein Fenster auf den Bildschirm passt, bei Bedarf
   Left, und Top anpassen
   an mehrere Monitore angepasst, Mrz. 2011 *)
procedure CheckScreenBounds (AScreen        : TScreen;
                             var ALeft,ATop : integer;
                             AWidth,AHeight : integer);
var
  mo : TMonitor;
begin
  with AScreen do begin
    mo:=MonitorFromPoint(Point(ALeft,ATop));
//    mo:=MonitorFromRect(Rect(ALeft,ATop,ALeft+AWidth,ATop+AHeight));
    with mo.WorkareaRect do begin
      if ALeft+AWidth>Right then ALeft:=Right-AWidth-20;
      if ALeft<Left then ALeft:=Left+20;
      if ATop+AHeight>Bottom then ATop:=Bottom-AHeight-30;
      if ATop<Top then ATop:=Top+20;
      end;
    end;
  end;

procedure FitToScreen (AScreen : TScreen; Control : TControl);
var
  il,it : integer;
begin
  with Control do begin
    il:=Left; it:=Top;
    CheckScreenBounds (AScreen,il,it,Width,Height);
    Left:=il; Top:=it;
    end;
  end;

// Adjust position of form to screen
procedure AdjustFormPosition (AScreen : TScreen; AForm : TForm;
          APos : TPoint; AtBottom : boolean = false);
begin
  with AForm,APos do begin
    if (Y < 0) or (X < 0) then Position:=poScreenCenter
    else begin
      Position:=poDesigned;
      if X<0 then X:=Left;
      if Y<0 then Y:=Top;
      if AtBottom then Y:=Y-Height;
      CheckScreenBounds(AScreen,x,y,Width,Height);  // DefaultMonitor = dmDesktop
      Left:=x; Top:=y;
      end;
    end;
  end;

// Get position of TopLeft to fit the window on the specified monitor
function FitToMonitor (Mon : TMonitor; BoundsRect : TRect) : TPoint;
begin
  with Result,Mon.WorkareaRect do begin
    if BoundsRect.Right>Right then x:=Right-BoundsRect.Width-50
    else x:=BoundsRect.Left;
    if x<=Left then x:=Left+50;
    if BoundsRect.Bottom>Bottom then y:=Bottom-BoundsRect.Height-50
    else y:=BoundsRect.Top;
    if y<=Top then y:=Top+50;
    end;
  end;

// Calculate the maximum text width for multiline text
function MaxTextWidth(const Text : string; Canvas : TCanvas) : integer;
var
  n,k : integer;
begin
  n:=1; Result:=0;
  repeat
    k:=PosEx(sLineBreak,Text,n);
    if k=0 then k:=length(Text)+1;
    Result:=Max(Result,Canvas.TextWidth(copy(Text,n,k-n+1)));
    n:=k+length(sLineBreak);
    until (k=0) or (n>=length(Text));
  end;

{ --------------------------------------------------------------- }
// Dateifilter-Index ermitteln (siehe TOpenDialog)
function GetFilterIndex(AFilter,AExtension : string) : integer;
var
  n : integer;
begin
  Result:=0; n:=0;
  repeat
    inc(n);
    ReadNxtStr(AFilter,'|');  // Beschreibung �berlesen
    if AnsiContainsText(ReadNxtStr(AFilter,'|'),AExtension) then Result:=n;
    until (Result>0) or (length(AFilter)=0);
  if Result=0 then Result:=n;  // letztes Filter (*.*)
  end;

{ ---------------------------------------------------------------- }
// neuer Message-Dialog mit Positionspr�fung
// Delay = 0: ShowModal
//       > 0: Anzeigen und automatisch schlie�en nach "Delay" in s
function MessageDialog(const Title,Msg: string; DlgType: TMsgDlgType;
                Buttons: TMsgDlgButtons; DefaultButton : TMsgDlgBtn;
                Pos : TPoint; Delay : integer;
                ADefaultMonitor : TDefaultMonitor = dmActiveForm) : integer;
var
  w : integer;
begin
  with CreateMessageDialog(Msg,DlgType,Buttons,DefaultButton) do begin
    DefaultMonitor:=ADefaultMonitor;
//    ScaleBy(Screen.PixelsPerInch,PixelsPerInchOnDesign);
    Scaled:=true;
    try
      with Pos do begin
        if (Y < 0) and (X < 0) then Position:=poScreenCenter
        else begin
//          if X<0 then X:=Left;
//          if Y<0 then Y:=Top;
          CheckScreenBounds(Screen,x,y,Width,Height);
          Left:=x; Top:=y;
          end;
        end;
      if length(Title)>0 then begin
        Caption:=Title;
        w:=Canvas.TextWidth(Title)+50;
        if w>ClientWidth then ClientWidth:=w;
        end;
      FormStyle:=fsStayOnTop;
      if Delay<=0 then Result:=ShowModal
      else begin
        Show;
        Delay:=Delay*10;
        repeat
          Application.ProcessMessages;
          Sleep(100);
          dec(Delay);
          until (Delay=0) or (ModalResult<>mrNone);
        if ModalResult=mrNone then begin
          Close;
          Result:=mrOK;
          end
        else Result:=ModalResult;
        end;
    finally
      Free;
      end;
    end;
  end;

function MessageDialog(const Title,Msg: string; DlgType: TMsgDlgType;
                Buttons: TMsgDlgButtons;
                Pos : TPoint; Delay : integer;
                ADefaultMonitor : TDefaultMonitor = dmActiveForm) : integer;
var
  DefaultButton: TMsgDlgBtn;
begin
  if mbOk in Buttons then DefaultButton := mbOk else
    if mbYes in Buttons then DefaultButton := mbYes else
      DefaultButton := mbRetry;
  Result:=MessageDialog(Title,Msg,DlgType,Buttons,DefaultButton,Pos,Delay,ADefaultMonitor);
end;

function MessageDialog(const Title,Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons) : integer;
begin
  Result:=MessageDialog(Title,Msg,DlgType,Buttons,CenterPos,0);
  end;

function MessageDialog(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons) : integer;
begin
  Result:=MessageDialog('',Msg,DlgType,Buttons,CenterPos,0);
  end;

function MessageDialog(Pos : TPoint; const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons) : integer;
begin
  Result:=MessageDialog('',Msg,DlgType,Buttons,Pos,0);
  end;

{ ---------------------------------------------------------------- }
// Best�tigung in Bildschirmmitte (X<0) oder an Position X,Y
function ConfirmDialog (const Title,Msg : string; Pos : TPoint) : boolean;
begin
  Result:=MessageDialog (Title,Msg,mtConfirmation,[mbYes,mbNo],Pos,0)=mrYes;
  end;

// Best�tigung auf einstellbarem Monitor
function ConfirmDialog (Pos : TPoint; const Msg : string; DefaultButton : TMsgDlgBtn = mbYes;
                        ADefaultMonitor : TDefaultMonitor = dmActiveForm) : boolean;
begin
  Result:=MessageDialog ('',Msg,mtConfirmation,[mbYes,mbNo],DefaultButton,Pos,0,ADefaultMonitor)=mrYes;
  end;

function ConfirmDialog (Pos : TPoint; const Title,Msg : string; DefaultButton : TMsgDlgBtn = mbYes;
                        ADefaultMonitor : TDefaultMonitor = dmActiveForm) : boolean;
begin
  Result:=MessageDialog (Title,Msg,mtConfirmation,[mbYes,mbNo],DefaultButton,Pos,0,ADefaultMonitor)=mrYes;
  end;

// Best�tigung in Bildschirmmitte
function ConfirmDialog (const Title,Msg  : string) : boolean;
begin
  Result:=ConfirmDialog(Title,Msg,CenterPos);
  end;

function ConfirmDialog (const Msg : string; DefaultButton : TMsgDlgBtn) : boolean;
begin
  Result:=MessageDialog ('',Msg,mtConfirmation,[mbYes,mbNo],DefaultButton,CenterPos,0)=mrYes;
  end;

// Information an Position ausgeben
procedure InfoDialog (const Title,Msg : string; Pos : TPoint);
begin
  MessageDialog (Title,Msg,mtInformation,[mbOK],Pos,0);
  end;

procedure InfoDialog (Pos : TPoint; const Msg :string);
begin
  InfoDialog('',Msg,Pos);
  end;

// Information in Bildschirmmitte ausgeben
procedure InfoDialog (const Title,Msg :string);
begin
  InfoDialog(Title,Msg,CenterPos);
  end;

// Information in Bildschirmmitte ausgeben und f�r Delay s anzeigen
procedure InfoDialog (const Title,Msg : string; Delay : integer); overload;
begin
  MessageDialog (Title,Msg,mtInformation,[mbOK],CenterPos,Delay);
  end;

procedure InfoDialog (const Msg :string);
begin
  InfoDialog('',Msg,CenterPos);
  end;

// Fehlermeldung an Position ausgeben
procedure ErrorDialog (const Title,Msg : string; Pos : TPoint);
begin
  MessageDialog (Title,Msg,mtError,[mbOK],Pos,0);
  end;

procedure ErrorDialog (const Title,Msg : string; x,y : integer);
begin
  MessageDialog (Title,Msg,mtError,[mbOK],Point(x,y),0);
  end;

procedure ErrorDialog (Pos : TPoint; const Msg : string);
begin
  ErrorDialog('',Msg,Pos);
  end;

// Fehlermeldung in Bildschirmmitte ausgeben und f�r Delay s anzeigen
procedure ErrorDialog (const Title,Msg : string; Delay : integer); overload;
begin
  MessageDialog (Title,Msg,mtError,[mbOK],CenterPos,Delay);
  end;

// Fehlermeldung in Bildschirmmitte ausgeben
procedure ErrorDialog (const Title,Msg : string);
begin
  ErrorDialog(Title,Msg,CenterPos);
  end;

procedure ErrorDialog (const Msg : string);
begin
  ErrorDialog('',Msg,CenterPos);
  end;

{ ------------------------------------------------------------------- }
// get current cursor position
function CursorPos : TPoint;
begin
  GetCursorPos(Result);
  end;

{ ------------------------------------------------------------------- }
// Add offset to point
//function AddOffsetPos(Pos1,Pos2 : TPoint) : TPoint;
//begin
//  with Result do begin
//    x:=Pos1.x+Pos2.x; y:=Pos1.y+Pos2.y;
//    end;
//  end;
//
//function AddOffsetPos(Pos : TPoint; dx,dy : integer) : TPoint;
//begin
//  with Result do begin
//    x:=Pos.x+x; y:=Pos.y+y;
//    end;
//  end;
//
// get current cursor position, add Offset
function CursorPos (Offset : TPoint): TPoint;
begin
  GetCursorPos(Result);
  Result.Offset(Offset);
  end;

function CursorPos (dx,dy : integer): TPoint;
begin
  Result:=CursorPos(Point(dx,dy));
  end;

{ ------------------------------------------------------------------- }
// position of component
function TopLeftPos (AControl : TControl; Offset : TPoint) : TPoint;
begin
  with AControl do if assigned(Parent) then Result:=Parent.ClientToScreen(Point(Left,Top))
  else Result:=Point(Left,Top);
  Result.Offset(Offset);
  end;

function TopLeftPos (AControl : TControl) : TPoint;
begin
  Result:=TopLeftPos (AControl,Point(0,0));
  end;

function TopLeftPos (AControl : TControl; X,Y : integer) : TPoint; overload;
begin
  Result:=TopLeftPos(AControl,Point(X,Y));
  end;

function BottomLeftPos (AControl : TControl; Offset : TPoint) : TPoint;
begin
  with AControl do if assigned(Parent) then Result:=Parent.ClientToScreen(Point(Left,Top+Height))
  else Result:=Point(Left,Top+Height);
  Result.Offset(Offset);
  end;

function BottomLeftPos (AControl : TControl) : TPoint;
begin
  Result:=BottomLeftPos(AControl,Point(0,0));
  end;

function BottomLeftPos (AControl : TControl; X,Y : integer) : TPoint; overload;
begin
  Result:=BottomLeftPos(AControl,Point(X,Y));
  end;

function TopRightPos (AControl : TControl; Offset : TPoint) : TPoint;
begin
  with AControl do if assigned(Parent) then Result:=Parent.ClientToScreen(Point(Left+Width,Top))
  else Result:=Point(Left+Width,Top);
  Result.Offset(Offset);
  end;

function TopRightPos (AControl : TControl) : TPoint;
begin
  Result:=TopRightPos (AControl,Point(0,0));
  end;

function TopRightPos (AControl : TControl; X,Y : integer) : TPoint; overload;
begin
  Result:=TopRightPos(AControl,Point(X,Y));
  end;

function BottomRightPos (AControl : TControl; Offset : TPoint) : TPoint;
begin
  with AControl do if assigned(Parent) then Result:=Parent.ClientToScreen(Point(Left+Width,Top+Height))
  else Result:=Point(Left+Width,Top+Height);
  Result.Offset(Offset);
  end;

function BottomRightPos (AControl : TControl) : TPoint;
begin
  Result:=BottomRightPos (AControl,Point(0,0));
  end;

function BottomRightPos (AControl : TControl; X,Y : integer) : TPoint; overload;
begin
  Result:=BottomRightPos(AControl,Point(X,Y));
  end;

// area of component
function GetRect (AControl : TControl) : TRect;
begin
  with AControl do Result:=Rect(Left,Top,Left+Width,Top+Height);
  end;

{ ------------------------------------------------------------------- }
// adjust size of dialogs if styles are used
procedure AdjustClientSize (AForm : TForm; AControl : TControl; Dist : integer = 5);
var
  w,h : integer;
begin
  with AControl do begin
    w:=Left+Width+Dist;
    h:=Top+Height+Dist;
    end;
  with AForm do begin
    ClientWidth:=w; ClientHeight:=h;
    end;
  end;

procedure AdjustClientWidth (AForm : TForm; AControl : TControl; Dist : integer = 5);
var
  w : integer;
begin
  with AControl do begin
    w:=Left+Width+Dist;
    end;
  AForm.ClientWidth:=w;
  end;

{ ------------------------------------------------------------------- }
// History list management
const
  iniHist = 'History';

procedure LoadHistory (IniFile : TIniFile; const Section,Ident : string;
                       History : TStrings; MaxCount : integer);
var
  i : integer;
  s,si : string;
begin
  with IniFile do begin
    if SectionExists(Section) then begin
      if length(Ident)=0 then si:=iniHist else si:=Ident;
      History.Clear;
      for i:=0 to MaxCount-1 do begin
        s:=ReadString(Section,si+IntToStr(i),'');
        if s<>'' then History.Add(s);
        end;
      end;
    end;
  end;

procedure LoadHistory (IniFile : TIniFile; const Section,Ident : string;
                       History : TStrings);
begin
  LoadHistory(IniFile,Section,Ident,History,MaxHist);
  end;

procedure LoadHistory (const IniName,Section,Ident : string;
                       History : TStrings; MaxCount : integer);
var
  IniFile : TIniFile;
begin
  IniFile:=TIniFile.Create(IniName);
  LoadHistory(IniFile,Section,Ident,History,MaxCount);
  IniFile.Free;
  end;

procedure LoadHistory (const IniName,Section,Ident : string;
                       History : TStrings); overload;
begin
  LoadHistory(IniName,Section,Ident,History,MaxHist);
  end;

procedure SaveHistory (IniFile : TIniFile; const Section,Ident : string;
                       Erase : boolean; History : TStrings; MaxCount : integer);
var
  i,n : integer;
  si  : string;
begin
  with IniFile do begin
    if length(Ident)=0 then si:=iniHist else si:=Ident;
    if Erase then EraseSection (Section);
    with History do begin
      if Count>MaxCount then n:=MaxCount else n:=Count;
      for i:=0 to n-1 do WriteString(Section,si+IntToStr(i),Strings[i]);
      end;
    end;
  end;

procedure SaveHistory (IniFile : TIniFile; const Section,Ident : string;
                       Erase : boolean; History : TStrings);
begin
  SaveHistory(IniFile,Section,Ident,Erase,History,MaxHist);
  end;

procedure SaveHistory (const IniName,Section,Ident : string;
                       Erase : boolean; History : TStrings; MaxCount : integer);
var
  IniFile : TIniFile;
begin
  IniFile:=TIniFile.Create(IniName);
  SaveHistory(IniFile,Section,Ident,Erase,History,MaxHist);
  IniFile.Free;
  end;

procedure SaveHistory (const IniName,Section,Ident : string;
                       Erase : boolean; History : TStrings);
begin
  SaveHistory(IniName,Section,Ident,Erase,History,MaxHist);
  end;

// move or add item "hs" to begin of history list
procedure AddToHistory (History : TStrings; const hs : string; MaxCount : integer);
var
  n : integer;
begin
  if length(hs)>0 then with History do begin
    n:=IndexOf(hs);
    if n<0 then begin
      if Count>=MaxCount then Delete (Count-1);
      Insert (0,hs);
      end
    else if n>0 then Move (n,0);
    end;
  end;

procedure AddToHistory (History : TStrings; const hs : string);
begin
  AddToHistory (History,hs,MaxHist);
  end;

procedure RemoveFromHistory (History : TStrings; const hs : string);
var
  n : integer;
begin
  if length(hs)>0 then with History do begin
    n:=IndexOf(hs);
    if n>=0 then Delete (n);
    end;
  end;

//-----------------------------------------------------------------------------
procedure FreeListObjects (Liste : TStrings);
var
  i : integer;
begin
  with Liste do begin
    for i:=0 to Count-1 do if assigned(Objects[i]) then begin
      Objects[i].Free; Objects[i]:=nil;
      end;
    end;
  end;

procedure FreeListViewData (Liste : TListItems);
var
  i : integer;
begin
  with Liste do for i:=0 to Count-1 do with Item[i] do if Data<>nil then begin
    TObject(Data).Free; Data:=nil;
    end;
  end;

//-----------------------------------------------------------------------------
// Listview-Index aus Caption ermitteln (wie IndexOf bei TListBox)
function GetListViewIndex (lv : TListView; const ACaption : string): integer;
begin
  with lv.Items do for Result:=0 to Count-1 do
    if AnsiSameText(Item[Result].Caption,ACaption) then Exit;
  Result:=-1;
  end;

// Subitem-Index aus der Mausposition ermitteln (nur vsReport)
function GetColumnIndexAt (ListView : TListView; Pos : integer) : integer;
var
  x : integer;
begin
  with ListView.Columns do begin
    x:=0;
    for Result:=0 to Count-1 do with Items[Result] do begin
      if (Pos>=x) and (Pos<x+Width) then Exit;
      x:=x+Width;
      end;
    end;
  Result:=-1;
  end;

// TopItem auf Index setzen (nur vsReport)
procedure SetListViewTopItem (lv : TListView; AIndex : integer; Select : boolean);
var
  n : integer;
begin
  with lv do if (AIndex>=0) and (Items.Count>0) and (AIndex<Items.Count) then begin
    with TopItem.DisplayRect(drBounds)do n:=Top-Bottom;
    Scroll(0,n*(TopItem.Index-AIndex));
    if Select then ItemIndex:=AIndex;
    end;
  end;

{ ---------------------------------------------------------------- }
(* System herunterfahren *)
function ExitFromWindows (Prompt : string; EwFlags,RsFlags : longword) : boolean;
var
  vi     : TOSVersionInfo;
  n      : dword;
  hToken : THandle;
  tkp    : TTokenPrivileges;
begin
  Result:=false;
  if (length(Prompt)>0) and (MessageDlg(Prompt,mtConfirmation,[mbYes,mbNo],0)=mrNo) then exit;
  vi.dwOSVersionInfoSize:=SizeOf(vi);
  GetVersionEx(vi);
  if vi.dwPlatformId>=VER_PLATFORM_WIN32_NT then begin // Windows NT
    // Get a token for this process.
    if OpenProcessToken(GetCurrentProcess,
          TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,hToken) then begin
    // Get the LUID for the shutdown privilege.
      LookupPrivilegeValue(nil,SE_SHUTDOWN_NAME,tkp.Privileges[0].Luid);
      tkp.PrivilegeCount:=1;  // one privilege to set
      tkp.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
    // Get the shutdown privilege for this process.
      AdjustTokenPrivileges(hToken,FALSE,tkp,0,nil,n);
      end;
    end;
  Result:=ExitWindowsEx (EwFlags,RsFlags);
  end;

function ShutDownWindows (Prompt : string; Restart : boolean; RsFlags : longword) : boolean;
var
  vi     : TOSVersionInfo;
  n      : dword;
  hToken : THandle;
  tkp    : TTokenPrivileges;
begin
  Result:=false;
  if (length(Prompt)>0) and (MessageDlg(Prompt,mtConfirmation,[mbYes,mbNo],0)=mrNo) then exit;
  vi.dwOSVersionInfoSize:=SizeOf(vi);
  GetVersionEx(vi);
  if vi.dwPlatformId>=VER_PLATFORM_WIN32_NT then begin // Windows NT
    // Get a token for this process.
    if OpenProcessToken(GetCurrentProcess,
          TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,hToken) then begin
    // Get the LUID for the shutdown privilege.
      LookupPrivilegeValue(nil,SE_SHUTDOWN_NAME,tkp.Privileges[0].Luid);
      tkp.PrivilegeCount:=1;  // one privilege to set
      tkp.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
    // Get the shutdown privilege for this process.
      AdjustTokenPrivileges(hToken,FALSE,tkp,0,nil,n);
      end;
    end;
  Result:=InitiateSystemShutdownEx(nil,nil,0,true,Restart,RsFlags);
  end;

//-----------------------------------------------------------------------------
// Tastaturpuffer l�schen
function ClearKeyboardBuffer : Integer;
var
   Msg: TMsg;
begin
  Result := 0;
  while PeekMessage(Msg,0,WM_KEYFIRST,WM_KEYLAST,PM_REMOVE) do inc(Result);
  end;

{------------------------------------------------------------------}
(* erzeugen einer System-Fehlermeldung *)
function SystemErrorMessage(ASysError : cardinal) : string;
begin
  if Win32MajorVersion<6 then begin
    case LongRec(ASysError).Hi and $7FF of
    FACILITY_NULL,
    FACILITY_WIN32: Result:=SysErrorMessage(ASysError and $FFFF);
    FACILITY_WINDOWS: Result:=rsWindowsError;
    FACILITY_STORAGE: Result:=rsStorageError;
    FACILITY_RPC: Result:=rsRpcError;
  //  FACILITY_ITF: Result:=rsInterfaceError;
    FACILITY_DISPATCH: Result:=rsDispatchError;
    FACILITY_PreWin32: Result:=rsPreWin32Error;
    FACILITY_ShellExec: Result:=rsShellExec;
    else Result:=rsUnknownError;
      end;
    Result:=Result+Format(' (0x%.8x)',[ASysError]);
    end
  else Result:=SysErrorMessage(ASysError)+Format(' (0x%.8x)',[ASysError]);
  end;

function NoError(ASysError : cardinal) : boolean;
begin
  Result:=ASysError and $FFFF =NO_ERROR;
  end;

function ThisError(ASysError,ThisError : cardinal) : boolean;
begin
  Result:=(ASysError and $FFFF) = ThisError;
  end;

function IsSysError(ASysError : cardinal) : boolean;
begin
  Result:=ASysError and $FFFF <>NO_ERROR;
  end;

{------------------------------------------------------------------}
// Liste der auf dem System vorhandenen Codepages erstellen
var
  CodePageList : TStringList;

function CpEnumProc(CodePage : PChar) : Cardinal ; stdcall;
var
   CpInfoEx : TCPInfoEx;
   s : string;
   Cp : cardinal;
begin
  Cp := StrToIntDef(CodePage,0);
  if IsValidCodePage(Cp) then begin
    GetCPInfoEx(Cp, 0, CpInfoEx);
    s:=CpInfoEx.CodePageName;
    ReadNxtStr(s,' ');
    s:=Trim(s);
    s:=RemChar(CutChar(s,')'),'(');
    CodePageList.AddObject(Format('%s - (%u)', [s,CpInfoEx.Codepage]), TObject(Cp));
    end;
  Result := 1;
  end;

function GetCodePageList (sl : TStrings) : boolean;
begin
  CodePageList:=TStringList.Create;
  CodePageList.Sorted:=true;
  Result:=false;
  try
    Result:=EnumSystemCodePages(@CpEnumProc, CP_SUPPORTED);
    if Result then sl.Assign(CodePageList);
  finally
    CodePageList.Free;
    end;
  end;

end.
