(* Delphi Komponente
   Eingabe von Zahlen
   ==================
   - TNumberEdit     : Integer (dezimal oder hex)
   - TRangeEdit      : Integer mit Bereichs¸berpr¸fung
   - TFloatEdit      : Flieﬂkomma
   - TFloatRangeEdit : Flieﬂkomma mit Bereichs¸berpr¸fung
   - TDegreeEdit     : Eingabefeld f¸r Winkelgrade
   - TNumUpDown      : wie TUpDown f¸r o.g. Komponenten
   - TFloatComboBox  : Combobox f¸r Flieﬂkommazahlen
   - TDegreeComboBox : Combobox f¸r Winkelgrade

   neue Flieﬂkommaformate:
   - ffNormalized    : Flieﬂkommazahl mit durch 3 teilbarem Exp. (wiss. Format)
   - ffPrefix        : Flieﬂkommazahl mit angef¸gten Einheitenpr‰fix:
                       f (femto), p (pico), n (nano),µ (mikro), m (milli),
                       k (kilo), M (Mega), G (Giga), T (Tera)

   Winkelgradformate:
   - afDecDegree     : Winkel als Grade mit Dezimalunterteilung
   - afDecMinutes    : Winkel als Grade und Minuten mit Dezimalunterteilung
   - afSeconds       : Winkel als Grade, Minuten und Sekunden mit Dezimalunterteilung

   © J. Rathlev 24222 Schwentinental
     Web:  www.rathlev-home.de
     Mail: kontakt(a)rathlev-home.de

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Sep. 1998
         1.1 - Okt. 2001
         1.2 - Juni 2005  : verbesserte Bereichs¸berpr¸fung
         1.3 - Mai  2006  : AddValue-Routinen
         1.4 - Apr. 2007  : Darstellung als Bin. Oktal, Dezimal und Hex
         2.0 - Mai  2015  : neues TNumUpDown, ffPrefix und div. weitere Umstruktierungen
         2.1 - Juli 2019  : TDegreeEdit hinzugef¸gt

   last changed: Dez. 2019
   *)

unit NumberEd;

interface

uses
  System.SysUtils, Winapi.Windows, Winapi.Messages, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Buttons, Winapi.CommCtrl, Vcl.ComCtrls, Vcl.Dialogs,
  Vcl.Menus, Vcl.Forms, Vcl.StdCtrls, NumberUtils;

// Definiere CompPalPage (siehe Register)
{$Include UserComps.pas }

type
  TNumFloatFormat = (ffGeneral, ffExponent, ffFixed, ffNumber, ffCurrency,
                     ffNormalized, ffPrefix);

const
  NumBase : array[TNumMode] of word = (10,16,8,2,10);
  ByteDigits : array[TNumMode] of word = (3,2,3,8,3);    // Stellen pro Byte

  WM_UpdateText = WM_User + 1;

type
  TNumUpDown= class(TCustomControl)
  private
    FAssociate: TWinControl;
    FIncrement : integer;
    FUpState,FDownState : TButtonState;
    rUp,rDown : TRect;
    FMouseInControl : Boolean;
    FAlignButton: TUDAlignButton;
    FOnUpClick,FOnDownClick : TNotifyEvent;
    procedure AlignButtons;
    procedure RecalcSize;
    function IsInUpBtn (x,y : integer) : boolean;
    procedure SetAssociate(Value: TWinControl);
    procedure SetIncrement(Value: Integer);
    procedure SetAlignButton(Value: TUDAlignButton);
    procedure UpdateTracking;
    procedure UpClick;
    procedure DownClick;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMGotFocus); message CM_EXIT;
    procedure CMEnabledChange (var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
  protected
    FState: TButtonState;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AlignButton: TUDAlignButton read FAlignButton write SetAlignButton default udRight;
    property Associate: TWinControl read FAssociate write SetAssociate;
    property Anchors;
    property Constraints;
    property Enabled;
    property Hint;
    property Increment: Integer read FIncrement write SetIncrement default 1;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    end;

  TCustomNumEdit = class(TCustomEdit)
  private
    FAlignment   : TAlignment;
    procedure SetAlignment(Value: TAlignment);
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMKey(var Message: TWMKey); message WM_CHAR;
    procedure WMPaste(var Message: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Message: TWMCut);   message WM_CUT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function IsValidChar(Key: Char): Boolean; virtual;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
  public
    procedure IncrementValue (Delta : integer); virtual;
    end;

  TNumberEdit = class(TCustomNumEdit)
  private
    FValue       : int64;
    FBits,                   // Anzahl der Bits
    FDigits,                 // Anzahl der Anzeigestellen
    FGroupDigits : word;     // Gruppieren der Stellen
    FConvertError,           // Fehler beim Einlesen der Zahl
    FPrefix      : boolean;  // Prefix ! = bin, % = Oktal, $ = hex
    FBytes       : boolean;  // Gruppe
    FInpNumMd,
    FNumMode     : TNumMode;
    procedure SetBits(Value : word);
    procedure SetDigits(Value: word);
    procedure SetNumMode(Value: TNumMode);
    function GetValueFromInput : int64;
    procedure SetValue(Value : int64); virtual;
    procedure SetPrefix (Value : boolean);
    procedure SetBytes(Value : boolean);
    procedure SetGroupDigits(Value : word);
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure CMExit(var Message: TCMGotFocus); message CM_EXIT;
  protected
    function IsValidChar(Key: Char): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure IncrementValue (Delta : integer); override;
    function CheckError : boolean;
  published
    { Standard-Eigenschaften f¸r TEDIT verˆffentlichen }
    property Anchors;
    property AutoSelect;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    { Eigenschaften von NumberEdit }
    property Alignment;
    property Bits : word read FBits write SetBits default 32;
    property Digits : word read FDigits write SetDigits default 0;
    property Prefix : boolean read FPrefix write SetPrefix default true;
    property Bytes : boolean read FBytes write SetBytes default false;
    property GroupDigits : word read FGroupDigits write SetGroupDigits default 0;
    property NumMode : TNumMode read FNumMode write SetNumMode default nmDecimal;
    property Value : int64 read GetValueFromInput write SetValue;
  end;

  TRangeEdit = class (TNumberEdit)
  private
    FMinValue,
    FMaxValue   : int64;
    FRangeError,
    FRangeCheck : boolean;
    procedure SetValue(NewValue : int64); override;
    procedure SetMinValue(NewValue : int64);
    procedure SetMaxValue(NewValue : int64);
    function CheckValue (NewValue : int64): boolean;
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  public
    constructor Create(AOwner: TComponent); override;
    property RangeError : boolean read FRangeError;
  published
    { Published declarations }
    property MinValue : int64 read FMinValue write SetMinValue;
    property MaxValue : int64 read FMaxValue write SetMaxValue;
    property RangeCheck : boolean read FRangeCheck write FRangeCheck default true;
  end;

  TFloatEdit = class(TCustomNumEdit)
  private
    FDigits,FDecimal  : word;
    FMult,
    FValue            : extended;
    FFloatFormat      : TNumFloatFormat;
    FThSep      : char;
    procedure SetDigits(Value: word);
    procedure SetDecimal(Value: word);
    procedure SetThSep(Value: Char);
    procedure SetFloatFormat(Value: TNumFloatFormat);
    function GetValueFromInput : extended; virtual;
    procedure SetValue(Value : extended); virtual;
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure CMExit(var Message: TCMGotFocus); message CM_EXIT;
  protected
    function IsValidChar(Key: Char): Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure IncrementValue (Delta : integer);  override;
  published
    { Standard-Eigenschaften f¸r TEDIT verˆffentlichen }
    property Alignment;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property CharCase;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    { neue Eigenschaften von FloatEdit }
    property Digits : word read FDigits write SetDigits default 0;
    property Decimal: word read FDecimal write SetDecimal default 2;
    property FloatFormat : TNumFloatFormat read FFloatFormat write SetFloatFormat default ffFixed;
    property ThSeparator : char read FThSep write SetThSep default #0;
    property StepMultiplier : extended read FMult write FMult;
    property Value : extended read GetValueFromInput write SetValue;
  end;

  TFloatRangeEdit = class (TFloatEdit)
  private
    FMinValue,
    FMaxValue   : extended;
    FRangeError,
    FRangeCheck : boolean;
//    function GetValue : extended;
    procedure SetValue(NewValue : extended); override;
    procedure SetMinValue(NewValue : extended);
    procedure SetMaxValue(NewValue : extended);
    function CheckValue (NewValue: extended): boolean;
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure CMExit(var Message: TCMExit);   message CM_EXIT;
  public
    constructor Create(AOwner: TComponent); override;
    property RangeError : boolean read FRangeError;
  published
    { Published declarations }
    property MinValue : extended read FMinValue write SetMinValue;
    property MaxValue : extended read FMaxValue write SetMaxValue;
    property RangeCheck : boolean read FRangeCheck write FRangeCheck default true;
  end;

  TDegreeEdit = class (TFloatEdit)
  private
    FFormat : TAngleFormat;
    procedure SetFormat(Value: TAngleFormat);
  protected
    function IsValidChar(Key: Char): Boolean; override;
  public
    function GetValueFromInput : extended; override;
    procedure SetValue(Value : extended); override;
  published
    property Digits;
    property Decimal default 4;
    property Format : TAngleFormat read FFormat write SetFormat default afDecDegree;
    property Value;
    end;

  TCustomFloatComboBox = class(TCustomComboBox)
  private
    FDigits,FDecimal  : word;
    FFloatFormat      : TNumFloatFormat;
    procedure SetDigits(Value: word);
    procedure SetDecimal(Value: word);
    procedure SetFloatFormat(Value: TNumFloatFormat);
    function GetValueFromInput : extended;
    procedure SetValue(NewValue : extended);
    function GetValue(Index : integer) : extended;
    procedure WMUpdateText(var Message: TMessage); message WM_UpdateText;
    procedure WMKey(var Message: TWMKey); message WM_CHAR;
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CMExit(var Message: TCMGotFocus); message CM_EXIT;
  protected
    FValue       : extended;
    function IsValidChar(Key: Char): Boolean; virtual;
    { neue Eigenschaften von FloatComboBox }
    property Digits : word read FDigits write SetDigits default 0;
    property Decimal: word read FDecimal write SetDecimal default 2;
    property FloatFormat : TNumFloatFormat read FFloatFormat write SetFloatFormat default ffFixed;
    property Value : extended read FValue write SetValue;
  public
    constructor Create(AOwner: TComponent); override;
    function StrToVal (const s : string) : extended; virtual;
    function ValToStr(AValue : extended) : string; virtual;
    procedure AddValue (AValue : extended);
    procedure AddCurrentValue;
    property Values[Index : integer] : extended read GetValue;
  published
    property Anchors;
    property Color;
    property Ctl3D;
    property DragMode;
    property DragCursor;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    end;

  TFloatComboBox = class(TCustomFloatComboBox)
  published
    property Digits;
    property Decimal;
    property FloatFormat;
    property Value;
    end;

  TDegreeComboBox = class(TCustomFloatComboBox)
  private
    FFormat : TAngleFormat;
    procedure SetFormat(Value: TAngleFormat);
  protected
    function IsValidChar(Key: Char): Boolean; override;
  public
    function StrToVal (const s : string) : extended; override;
    function ValToStr(AValue : extended) : string; override;
  published
    property Digits;
    property Decimal default 4;
    property Format : TAngleFormat read FFormat write SetFormat default afDecDegree;
    property Value;
  end;

  EUserRangeError = class (EIntError)
  public
    constructor Create (Min,Max : longint;
                        NumMode : TNumMode);
  end;

  EUserFloatRangeError = class (EIntError)
  public
    constructor Create (Min,Max        : extended;
                        FloatFormat    : TNumFloatFormat;
                        Digits,Decimal : word);
  end;

function FloatToStrF(Value: Extended; Format: TNumFloatFormat;
  Precision, Digits: Integer): string; overload;

procedure Register;

(* ----------------------------------------------------------------------- *)
implementation

uses System.SysConst, Vcl.ComStrs, System.Types, System.Math, StringUtils, MathUtils;

{------------------------------------------------------------------}
function FloatToStrF(Value: Extended; Format: TNumFloatFormat;
  Precision, Digits: Integer): string;
begin
  if Format=ffNormalized then Result:=FloatToStrE(Value,Precision,Formatsettings.DecimalSeparator)
  else if Format=ffPrefix then Result:=FloatToPrefixStr(Value,Precision,' ',Formatsettings.DecimalSeparator)
  else Result:=System.SysUtils.FloatToStrF(Value,TFloatFormat(Format),Precision,Digits);
  end;

function ReadNxtStr (var s   : String;
                     Del     : char) : string;
var
  i : integer;
begin
  if length(s)>0 then begin
    i:=pos (Del,s);
    if i=0 then i:=succ(length(s));
    Result:=copy(s,1,pred(i));
    delete(s,1,i);
    end
  else Result:='';
  end;

{------------------------------------------------------------------}
(* Fehlermeldungen generieren *)
constructor EUserRangeError.Create (Min,Max : longint;
                                    NumMode : TNumMode);
var
  s : string;
begin
  case NumMode of
  nmHex   : s:='$'+IntToHex(Min,1)+' .. $'+IntToHex(Max,1)+')';
  nmOctal : s:='%'+IntToOctal(Min,1,0)+' .. %'+IntToOctal(Max,1,0)+')';
  nmBin   : s:='!'+IntToBin(Min,1,0)+' .. !'+IntToBin(Max,1,0)+')';
    else s:=IntToStr(Min)+' .. '+IntToStr(Max)+')';
    end;
  inherited Create (SRangeError+' ('+s);
  end;

constructor EUserFloatRangeError.Create (Min,Max        : extended;
                                         FloatFormat    : TNumFloatFormat;
                                         Digits,Decimal : word);
var
  s : string;
begin
  if FloatFormat=ffNormalized then
    s:=FloatToStrE(Min,Digits,Formatsettings.DecimalSeparator)+
                       ' .. '+FloatToStrE(Max,Digits,Formatsettings.DecimalSeparator)+')'
  else if FloatFormat=ffPrefix then
    s:=FloatToPrefixStr(Min,Digits,' ',Formatsettings.DecimalSeparator)+
                       ' .. '+FloatToPrefixStr(Max,Digits,' ',Formatsettings.DecimalSeparator)+')'
  else s:=FloatToStrF(Min,TFloatFormat(FloatFormat),Digits,Decimal)+' .. '+
     FloatToStrF(Max,TFloatFormat(FloatFormat),Digits,Decimal)+')';
  inherited Create (SRangeError+' ('+s);
  end;

(* ----------------------------------------------------------------------- *)
constructor TNumUpDown.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width:=16; Height:=21;
  FUpState:=bsUp;
  FDownState:=bsUp;
  FIncrement:=1;
  FAlignButton:=udRight;
  FOnUpClick:=nil; FOnDownClick:=nil;
  FMouseInControl:=false;
  end;

procedure TNumUpDown.RecalcSize;
begin
  rUp:=ClientRect;
  with rUp do Bottom:=Bottom div 2 +1;
  rDown:=ClientRect;
  with rDown do Top:=Bottom div 2;
  end;

function TNumUpDown.IsInUpBtn (x,y : integer) : boolean;
begin
  Result:=PtInRect(rUp,Point(x,y));
  end;

procedure TNumUpDown.SetAssociate(Value: TWinControl);
var
  I: Integer;
begin
  if Value <> nil then
    for I := 0 to Parent.ControlCount - 1 do // is control already associated
      if (Parent.Controls[I] is TNumUpDown) and (Parent.Controls[I] <> Self) then
        if TNumUpDown(Parent.Controls[I]).Associate = Value then
          raise Exception.CreateResFmt(@sUDAssociated,
            [Value.Name, Parent.Controls[I].Name]);
  FAssociate:=nil;
  if (Value<>nil) and (Value.Parent=Self.Parent) and (Value is TCustomNumEdit) then begin
    FAssociate:=Value;
    AlignButtons;
    Invalidate;
    end;
  end;

procedure TNumUpDown.AlignButtons;
begin
  if Assigned(FAssociate) then with FAssociate as TCustomNumEdit do begin
    self.Width:=16;
    if FAlignButton=udRight then self.Left:=Left+Width
    else self.Left:=Left-self.Width;
    self.Top:=Top;
    self.Height:=Height;
    end;
  end;

procedure TNumUpDown.SetIncrement(Value: Integer);
begin
  if Value <> FIncrement then begin
    FIncrement:=Value;
    end;
  end;

procedure TNumUpDown.SetAlignButton(Value: TUDAlignButton);
begin
  if Value<>FAlignButton then begin
    FAlignButton:=Value;
    AlignButtons;
    end;
  end;

procedure TNumUpDown.CMEnter(var Message: TCMEnter);
begin
  Canvas.DrawFocusRect(ClientRect);
  inherited;
  end;

procedure TNumUpDown.CMExit(var Message: TCMGotFocus);
begin
  Canvas.DrawFocusRect(ClientRect);
  inherited;
  end;

procedure TNumUpDown.CMEnabledChange (var Message: TMessage);
begin
  inherited;
  invalidate;
  end;

procedure TNumUpDown.WMSize(var Message: TWMSize);
begin
  inherited;
  invalidate;
  end;

procedure TNumUpDown.WMKeyDown(var Message: TWMKeyDown);
begin
  case Message.CharCode of
    VK_OEM_PLUS,VK_ADD : UpClick;
    VK_OEM_MINUS,VK_SUBTRACT : DownClick;
    end;
  inherited;
  end;

procedure TNumUpDown.Paint;
var
  df : integer;
begin
  RecalcSize;
  with Canvas do begin
    Font := Self.Font;
    InflateRect(rUp,1,1);
    InflateRect(rDown,1,1);
    df:=DFCS_SCROLLUP or DFCS_FLAT or DFCS_ADJUSTRECT;
    if not Enabled then df:=df or DFCS_INACTIVE
    else if FUpState=bsDown then df:=df or DFCS_PUSHED;
    DrawFrameControl(Handle,rUp,DFC_SCROLL,df);
    df:=DFCS_SCROLLDOWN or DFCS_FLAT or DFCS_ADJUSTRECT;
    if not Enabled then df:=df or DFCS_INACTIVE
    else if FDownState=bsDown then df:=df or DFCS_PUSHED;
    DrawFrameControl(Handle,rDown,DFC_SCROLL,df);
    if Enabled then Brush.Color:=clBtnShadow
    else Brush.Color:=clActiveBorder;
//    if FUpState=bsDown then df:=BDR_SUNKENINNER else df:=BDR_RAISEDINNER;
//    DrawEdge(Handle,rUp,df,BF_RECT);
    FrameRect(rUp);
    FrameRect(rDown);
    end;
  end;

procedure TNumUpDown.UpClick;
begin
  if Assigned(Associate) then (Associate as TCustomNumEdit).IncrementValue(FIncrement);
  if Assigned(FOnUpClick) then FOnUpClick(Self);
  end;

procedure TNumUpDown.DownClick;
begin
  if Assigned(Associate) then (Associate as TCustomNumEdit).IncrementValue(-FIncrement);
  if Assigned(FOnDownClick) then FOnDownClick(Self);
  end;

procedure TNumUpDown.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then begin
    if IsInUpBtn(x,y) then FUpState:=bsDown else FDownState:=bsDown;
    Invalidate;
    end;
  end;

procedure TNumUpDown.UpdateTracking;
var
  P: TPoint;
begin
  if Enabled then begin
    GetCursorPos(P);
    FMouseInControl:=not (FindDragTarget(P, True) = Self);
    if FMouseInControl then Perform(CM_MOUSELEAVE, 0, 0)
    else Perform(CM_MOUSEENTER, 0, 0);
    end;
  end;

procedure TNumUpDown.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if not FMouseInControl then UpdateTracking;
  end;

procedure TNumUpDown.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then begin
    if IsInUpBtn(x,y) then begin
      if FUpState=bsDown then UpClick;
      FUpState:=bsUp;
      end
    else begin
      if FDownState=bsDown then DownClick;
      FDownState:=bsUp;
      end;
    Invalidate;
    UpdateTracking;
    end;
  end;

(* ----------------------------------------------------------------------- *)
procedure TCustomNumEdit.CreateParams(var Params: TCreateParams);
const
  Alignments: array[Boolean, TAlignment] of DWORD =
    ((ES_LEFT, ES_RIGHT, ES_CENTER),(ES_RIGHT, ES_LEFT, ES_CENTER));
begin
  inherited CreateParams(Params);
  CreateSubClass(Params, 'EDIT');
  with Params do begin
    Style := Style or Alignments[UseRightToLeftAlignment, FAlignment];
    end;
  end;

procedure TCustomNumEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    RecreateWnd;
    end;
  end;

procedure TCustomNumEdit.CNCommand(var Message: TWMCommand);
begin
  if (Message.NotifyCode = EN_CHANGE) and
    not ((csDesigning in Componentstate) or (csLoading in ComponentState)) then Change;
  end;

procedure TCustomNumEdit.CMTextChanged(var Message: TMessage);
begin
  if not (csLoading in ComponentState) then inherited;
  end;

procedure TCustomNumEdit.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then SelectAll;
  inherited;
  end;

procedure TCustomNumEdit.WMKey(var Message: TWMKey);
begin
  with Message do if not IsValidChar(char(CharCode)) then begin
    CharCode:=0;
    Result:=0;
    end;
  inherited;
  end;

procedure TCustomNumEdit.WMPaste(var Message: TWMPaste);
begin
  if ReadOnly then Exit;
  inherited;
  end;

procedure TCustomNumEdit.WMCut(var Message: TWMPaste);
begin
  if ReadOnly then Exit;
  inherited;
  end;

function TCustomNumEdit.IsValidChar(Key: Char): Boolean;
begin
  Result:=true;
  end;

procedure TCustomNumEdit.IncrementValue (Delta : integer);
begin
  end;

(* ----------------------------------------------------------------------- *)
(* Integerzahl eingeben und anzeigen (dezimal oder hex) *)
constructor TNumberEdit.Create (AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNumMode:=nmDecimal; FInpNumMd:=FNumMode;
  FDigits:=0;
  FBits:=32; FPrefix:=true; FGroupDigits:=0;
  FBytes:=false; FValue:=0;
  Alignment:=taLeftJustify;
  Text:='0';
  end;

procedure TNumberEdit.SetBits(Value : word);
begin
  if Value=0 then Value:=32;
  if FBits<>Value then begin
    FBits:= Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TNumberEdit.SetDigits(Value: word);
begin
  if FDigits<>Value then begin
    FDigits := Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TNumberEdit.SetPrefix (Value : boolean);
begin
  if FPrefix<>Value then begin
    FPrefix:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TNumberEdit.SetBytes (Value : boolean);
begin
  if FBytes<>Value then begin
    FBytes:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TNumberEdit.SetGroupDigits(Value : word);
begin
  if FGroupDigits<>Value then begin
    FGroupDigits:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TNumberEdit.SetNumMode(Value: TNumMode);
begin
  if FNumMode<>Value then begin
    FNumMode:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  FInpNumMd:=FNumMode;
  end;

procedure TNumberEdit.WMKeyUp(var Message: TWMKeyDown);
begin
  FValue:=GetValueFromInput;
  inherited;
  end;

procedure TNumberEdit.CMExit(var Message: TCMGotFocus);
begin
  SetValue(GetValueFromInput);
  inherited;
  end;

procedure TNumberEdit.IncrementValue (Delta : integer);
begin
  SetValue(FValue+Delta);
  end;

function TNumberEdit.CheckError : boolean;
begin
  Result:=FConvertError;
  end;

function TNumberEdit.GetValueFromInput : int64;
var
  s,t : string;
  v   : int64;
  nm : TNumMode;
begin
  t:=Trim(Text);
  if (length(t)=1) and ((t[1]='+') or (t[1]='-')) then t:='';
  if (length(t)>0) then begin
    if FPrefix then begin
      if t[1]='$' then nm:=nmHex
      else if t[1]='%' then nm:=nmOctal
      else if t[1]='!' then nm:=nmBin
      else nm:=nmDecimal;
      end
    else nm:=FInpNumMd;
    Result:=0; FConvertError:=false;
    repeat
      s:=ReadNxtStr(t,'_');
      try
        case nm of
        nmHex   : v:=HexStrToInt(s);
        nmOctal : v:=OctalStrToInt(s);
        nmBin   : v:=BinStrToInt(s);
          else v:=StrToInt(RemoveSpaces(s));
          end;
      except
        on EConvertError do begin
          v:=0;
          MessageBeep(MB_ICONERROR);
          FConvertError:=true;
          end;
        end;
      Result:=256*Result+v;
      until length(t)=0;
    end
  else Result:=0;
  end;

procedure TNumberEdit.SetValue(Value : int64);
var
  i,n,m : integer;
  x   : extended;
  s   : string;
  md  : boolean;

  function IntToVal (v : int64; n : word) : string;
  begin
    case FNumMode of
    nmHex   : begin
              Result:=IntToHexStr(v,n,FGroupDigits);
              if FPrefix then Result:='$'+Result;
              end;
    nmOctal : begin
              Result:=IntToOctal(v,n,FGroupDigits);
              if FPrefix then Result:='%'+Result;
              end;
    nmBin   : begin
              Result:=IntToBin(v,n,FGroupDigits);
              if FPrefix then Result:='!'+Result;
              end;
    nmZeroDec : Result:=IntToDecimal(v,n,FGroupDigits,true);
      else Result:=IntToDecimal(v,n,FGroupDigits,false);
      end;
    end;

begin
  if FValue<>Value then begin
    FValue:=Value; md:=true;
    end
  else md:=false;
  if (FNumMode<>nmDecimal) and (FDigits=0) then begin
    x:=pwr2(FBits);
    n:=round(ln(x)/ln(NumBase[FNumMode])+0.5);
    end
  else n:=FDigits;
  if FBytes then begin
    m:=(FBits-1) div 8+1; // Anzahl Bytes
    s:='';
    for i:=1 to m do begin
      if (i>1) then s:='_'+s;
      s:=IntToVal(Value and $FF,ByteDigits[FNumMode])+s;
      Value:=Value div 256;
      end;
    end
  else s:=IntToVal(Value,n);
  Text:=s;
  SelStart:=length(Text); SelLength:=0;
  if md then Modified:=true;
//  FValue:=GetValue;
  end;

function TNumberEdit.IsValidChar(Key: Char): Boolean;
var
  ch : char;
  s : string;
begin
  s:=Trim(Text);
  if (length(s)>0) and (SelLength<>length(Text)) then ch:=s[1] else ch:=Key;
  if FPrefix then begin
    if ch='$' then FInpNumMd:=nmHex
    else if ch='%' then FInpNumMd:=nmOctal
    else if ch='!' then FInpNumMd:=nmBin
    else FInpNumMd:=nmDecimal;
    end;
  case FInpNumMd of
  nmHex   : Result:=CharInSet(Key,['$','0'..'9','A'..'F','a'..'f']);
  nmOctal : Result:=CharInSet(Key,['%','0'..'7']);
  nmBin   : Result:=CharInSet (Key,['!','0','1']);
    else Result:=CharInSet(Key,['+','-',' ','0'..'9']);
    end;
//  Result:=CharInSet(Key,['$','%','!','+','-','0'..'9','A'..'F','a'..'f']);
  Result:= Result or (Key<=#32); // and (Key <> Chr(VK_RETURN)));
  if not Result then MessageBeep(MB_ICONERROR);
  end;

(* ----------------------------------------------------------------------- *)
(* Integerzahl in einem vorgegebenen Bereich (MinValue, MaxValue) eingeben
   und anzeigen (dezimal oder hex) *)
constructor TRangeEdit.Create (AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinValue:=0; FMaxValue:=100;
  FRangeCheck:=true; FRangeError:=false;
  end;

procedure TRangeEdit.SetMinValue(NewValue : int64);
begin
  FMinValue:=NewValue;
  SetValue(FValue);
  end;

procedure TRangeEdit.SetMaxValue(NewValue : int64);
begin
  FMaxValue:=NewValue;
  SetValue(FValue);
  end;

procedure TRangeEdit.SetValue(NewValue : int64);
begin
  if not (csDesigning in Componentstate)  // not (csLoading in Componentstate) and
      and (FMaxValue<>FMinValue) then begin
    if NewValue<FMinValue then NewValue:=FMinValue
    else if NewValue>FMaxValue then NewValue:=FMaxValue;
    end;
//  FValue:=NewValue;
  inherited SetValue(NewValue);
  end;

function TRangeEdit.CheckValue (NewValue: int64): boolean;
begin
  Result:=true;
  if not (csDesigning in Componentstate) and (FMaxValue<>FMinValue) then begin
    if NewValue<FMinValue then Result:=false
    else if NewValue>FMaxValue then Result:=false;
    end;
  FRangeError:=not Result;
  end;

procedure TRangeEdit.WMKeyUp(var Message: TWMKeyDown);
begin
//  FValue:=GetValueFromInput;
//  if FRangeCheck then CheckValue(FValue);
  inherited;
  end;

procedure TRangeEdit.CMExit(var Message: TCMExit);
begin
  FValue:=GetValueFromInput;
  if FRangeCheck then CheckValue(FValue);
  if FRangeCheck and FRangeError then begin
    MessageBeep(MB_ICONERROR);
    SetFocus;
    raise EUserRangeError.Create (FMinValue,FMaxValue,FNumMode);
    end
  else begin
    SetValue(FValue);
    inherited;
    end;
  end;

(* ----------------------------------------------------------------------- *)
(* Flieﬂkommazahl eingeben und anzeigen *)
constructor TFloatEdit.Create (AOwner: TComponent);
begin
  inherited Create(AOwner);
  FloatFormat:=ffFixed;
  Digits:=10; Decimal:=2; FThSep:=#0;
  Alignment:=taLeftJustify;
  FValue:=0; FMult:=1;
  end;

procedure TFloatEdit.SetDigits(Value: word);
begin
  if FDigits <> Value then begin
    FDigits := Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TFloatEdit.SetDecimal(Value: word);
begin
  if FDecimal <> Value then begin
    FDecimal := Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TFloatEdit.SetThSep(Value: Char);
begin
  if FThSep<> Value then begin
    FThSep:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TFloatEdit.SetFloatFormat(Value: TNumFloatFormat);
begin
  if FFloatFormat<> Value then begin
    FFloatFormat:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TFloatEdit.WMKeyUp(var Message: TWMKeyDown);
begin
  FValue:=GetValueFromInput;
  inherited;
  end;

procedure TFloatEdit.CMExit(var Message: TCMGotFocus);
begin
  SetValue(GetValueFromInput);
  inherited;
  end;

procedure TFloatEdit.IncrementValue (Delta : integer);
begin
  SetValue(FValue+FMult*Delta);
  end;

function TFloatEdit.GetValueFromInput : extended;
begin
  Result:=FValue;
  if (length(Text)=1) and CharInset(Text[1],[#32,'-','+']) then Exit;
  if (length(Text)>0) then begin
    if FloatFormat=ffPrefix then begin
      if not PrefixStrToVal(Text,Result) then raise EConvertError.CreateResFmt(@SInvalidFloat,[Text]);
      end
    else begin
      if not TryStrToFloat(RemoveSpaces(Text),Result) then
        raise EConvertError.CreateResFmt(@SInvalidFloat,[Text]);
      end;
    end
  end;

procedure TFloatEdit.SetValue(Value : extended);
var
  s : string;
  md : boolean;
begin
  if FValue<>Value then begin
    FValue:=Value; md:=true;
    end
  else md:=false;
  if FloatFormat=ffNormalized then s:=FloatToStrE(Value,FDigits,FormatSettings.DecimalSeparator)
  else if FloatFormat=ffPrefix then s:=FloatToPrefixStr(Value,FDigits,' ',FormatSettings.DecimalSeparator)
  else s:=FloatToStrF(Value,TFloatFormat(FFloatFormat),FDigits,FDecimal);
  Text:=InsertThousandSeparators(s,FThSep);
  if md then Modified:=true;
  end;

function TFloatEdit.IsValidChar(Key: Char): Boolean;
begin
  Result:=CharInSet(Key,[FormatSettings.DecimalSeparator,'+','-','0'..'9','E','e']);
  Result:= Result or (Key<=#32); // and (Key <> Chr(VK_RETURN)));
  if not Result then MessageBeep(MB_ICONERROR);
  end;

(* ----------------------------------------------------------------------- *)
(* Flieﬂkommazahl in einem vorgegebenen Bereich (MinValue, MaxValue) eingeben
   und anzeigen *)
constructor TFloatRangeEdit.Create (AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinValue:=0; FMaxValue:=100;
  RangeCheck:=true; FRangeError:=false
  end;

procedure TFloatRangeEdit.SetMinValue(NewValue : extended);
begin
  FMinValue:=NewValue;
  SetValue(FValue);
  end;

procedure TFloatRangeEdit.SetMaxValue(NewValue : extended);
begin
  FMaxValue:=NewValue;
  SetValue(FValue);
  end;

procedure TFloatRangeEdit.SetValue(NewValue : extended);
begin
  if not (csDesigning in Componentstate) // not (csLoading in Componentstate) and
      and (FMaxValue<>FMinValue) then begin
    if CompareValue(NewValue,FMinValue)=LessThanValue then NewValue:=FMinValue
    else if CompareValue(NewValue,FMaxValue)=GreaterThanValue then NewValue:=FMaxValue;
    end;
//  FValue:=NewValue;
  inherited SetValue(NewValue);
  end;

function TFloatRangeEdit.CheckValue (NewValue: extended): boolean;
begin
  Result:=true;
  if not (csDesigning in Componentstate) and (FMaxValue<>FMinValue) then begin
    if CompareValue(NewValue,FMinValue)=LessThanValue then Result:=false
    else if CompareValue(NewValue,FMaxValue)=GreaterThanValue then Result:=false;
    end;
  FRangeError:=not Result;
  end;

procedure TFloatRangeEdit.WMKeyUp(var Message: TWMKeyDown);
begin
//  FValue:=GetValueFromInput;
//  if FRangeCheck then CheckValue(FValue);
  inherited;
  end;

procedure TFloatRangeEdit.CMExit(var Message: TCMExit);
begin
  FValue:=GetValueFromInput;
  if FRangeCheck then CheckValue(FValue);
  if FRangeCheck and FRangeError then begin
    MessageBeep(MB_ICONERROR);
    SetFocus;
    raise EUserFloatRangeError.Create (FMinValue,FMaxValue,FFloatFormat,FDigits,FDecimal);
    end
  else begin
    SetValue(GetValueFromInput);
    inherited;
    end;
  end;

(* ----------------------------------------------------------------------- *)
// Gradzahl eingeben und anzeigen *)
procedure TDegreeEdit.SetFormat(Value: TAngleFormat);
begin
  if FFormat<> Value then begin
    FFormat:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

function TDegreeEdit.GetValueFromInput : extended;
begin
  Result:=FValue;
  if (length(Text)=1) and CharInset(Text[1],[#32,'-','+']) then Exit;
  if (length(Text)>0) then begin
    if StrToDeg (Trim(Text),Result) then begin
      if not Focused then Text:=DegToStr(Result,FFormat,FDigits,FDecimal,FormatSettings.DecimalSeparator)
      end
    else raise EConvertError.CreateResFmt(@SInvalidFloat,[Text]);
    end;
  end;

procedure TDegreeEdit.SetValue(Value : extended);
var
  s : string;
  md : boolean;
begin
  if FValue<>Value then begin
    FValue:=Value; md:=true;
    end
  else md:=false;
  Text:=DegToStr(Value,FFormat,FDigits,FDecimal,FormatSettings.DecimalSeparator);
  if md then Modified:=true;
  end;

function TDegreeEdit.IsValidChar(Key: Char): Boolean;
begin
  Result:=CharInSet(Key,[FormatSettings.DecimalSeparator,'+','-','0'..'9',':','/','∞',#$27,'"']);
  Result:= Result or (Key<=#32); // and (Key <> Chr(VK_RETURN)));
  if not Result then MessageBeep(MB_ICONERROR);
  end;


(* ----------------------------------------------------------------------- *)
(* Flieﬂkommazahl in ComboBox eingeben und anzeigen *)
constructor TCustomFloatComboBox.Create (AOwner: TComponent);
begin
  inherited Create(AOwner);
  FloatFormat:=ffFixed;
  Digits:=10; Decimal:=2;
  Value:=0;
  end;

procedure TCustomFloatComboBox.SetDigits(Value: word);
begin
  if FDigits <> Value then begin
    FDigits := Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TCustomFloatComboBox.SetDecimal(Value: word);
begin
  if FDecimal <> Value then begin
    FDecimal := Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

procedure TCustomFloatComboBox.SetFloatFormat(Value: TNumFloatFormat);
begin
  if FFloatFormat<>Value then begin
    FFloatFormat:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

function TCustomFloatComboBox.StrToVal (const s : string) : extended;
var
  x : extended;
begin
  if length(s)>0 then begin
    if FloatFormat=ffPrefix then begin
      if not PrefixStrToVal(s,x) then raise EConvertError.CreateResFmt(@SInvalidFloat,[s]);
      end
    else begin
      if not TryStrToFloat(RemoveSpaces(s),x) then raise EConvertError.CreateResFmt(@SInvalidFloat,[s]);
      end;
    Result:=x;
    end
  else Result:=FValue;
  end;

function TCustomFloatComboBox.ValToStr(AValue : extended) : string;
begin
  if FloatFormat=ffNormalized then Result:=FloatToStrE(AValue,FDigits,FormatSettings.DecimalSeparator)
  else if FloatFormat=ffPrefix then Result:=FloatToPrefixStr(AValue,FDigits,' ',FormatSettings.DecimalSeparator)
  else Result:=FloatToStrF(AValue,TFloatFormat(FFloatFormat),FDigits,FDecimal);
  end;

function TCustomFloatComboBox.GetValueFromInput : extended;
begin
  FValue:=StrToVal(Text);
  Result:=FValue;
  end;

procedure TCustomFloatComboBox.SetValue(NewValue : extended);
begin
  FValue:=NewValue;
  Text:=ValToStr(NewValue);
  end;

procedure TCustomFloatComboBox.AddValue (AValue : extended);
var
  s : string;
begin
  s:=ValToStr(AValue);
  if Items.IndexOf(s)<0 then Items.Add(s);
  end;

procedure TCustomFloatComboBox.AddCurrentValue;
begin
  AddValue(Value);
  end;

function TCustomFloatComboBox.GetValue(Index : integer) : extended;
begin
  Result:=StrToVal(Items[Index]);
  end;

function TCustomFloatComboBox.IsValidChar(Key: Char): Boolean;
var
  AllowedKeys : TSysCharSet;
  i           : integer;
begin
  AllowedKeys:=[FormatSettings.DecimalSeparator,'+','-','0'..'9'];
  if FloatFormat=ffPrefix then begin
    for i:=0 to High(Prefixes) do Include(AllowedKeys,Prefixes[i]);
    Result:=CharInSet(Key,AllowedKeys);
    end
  else Result:=CharInSet(Key,AllowedKeys+['E','e']);
  Result:= Result or (Key<=#32); // and (Key <> Chr(VK_RETURN)));
  if not Result then MessageBeep(MB_ICONERROR);
  end;

procedure TCustomFloatComboBox.WMUpdateText(var Message: TMessage);
begin
  Text:=ValToStr(FValue);
  SelectAll;
  end;

procedure TCustomFloatComboBox.WMKey(var Message: TWMKey);
begin
  with Message do if not IsValidChar(char(CharCode)) then begin
    CharCode:=0;
    Result:=0;
    end;
  inherited;
  end;

procedure TCustomFloatComboBox.WMKeyUp(var Message: TWMKeyDown);
begin
  FValue:=GetValueFromInput;
  end;

procedure TCustomFloatComboBox.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode=CBN_SELCHANGE then begin
    if ItemIndex<>-1 then begin
      FValue:=StrToVal(Items[ItemIndex]);
      PostMessage(Handle,WM_UpdateText,0,0);
      Click;
      Select;
      end;
    end
  else if (Message.NotifyCode = EN_CHANGE) and
    not ((csDesigning in Componentstate) or (csLoading in ComponentState)) then Change
  else inherited;
  end;

procedure TCustomFloatComboBox.CMExit(var Message: TCMGotFocus);
begin
  SetValue(GetValueFromInput);
  inherited;
  end;

(* ----------------------------------------------------------------------- *)
(* Gradzahl in ComboBox eingeben und anzeigen *)
procedure TDegreeComboBox.SetFormat(Value: TAngleFormat);
begin
  if FFormat<> Value then begin
    FFormat:=Value;
    SetValue(FValue);
    RecreateWnd;
    end;
  end;

function TDegreeComboBox.StrToVal (const s : string) : extended;
var
  val : extended;
begin
  if StrToDeg (s,val) then begin
    Result:=Val;
    Text:=DegToStr(val,FFormat,FDigits,FDecimal,FormatSettings.DecimalSeparator);
    end
  else begin
    MessageDlg (SInvalidInput,mtError,[mbOK],0);
    Result:=0;
    end;
  end;

function TDegreeComboBox.ValToStr(AValue : extended) : string;
begin
  Result:=DegToStr(AValue,FFormat,FDigits,FDecimal,FormatSettings.DecimalSeparator);
  end;

function TDegreeComboBox.IsValidChar(Key: Char): Boolean;
begin
  Result:=CharInSet(Key,[FormatSettings.DecimalSeparator,'+','-','0'..'9',':','/','∞',#$27,'"']);
  Result:= Result or (Key<=#32); // and (Key <> Chr(VK_RETURN)));
  if not Result then MessageBeep(MB_ICONERROR);
  end;

{ ---------------------------------------------------------------- }
procedure Register;
begin
  RegisterComponents(CompPalPage, [TNumUpDown,TNumberEdit,TRangeEdit]);
  RegisterComponents(CompPalPage, [TFloatEdit,TFloatRangeEdit,TDegreeEdit]);
  RegisterComponents(CompPalPage, [TFloatComboBox,TDegreeComboBox]);
  end;

end.
