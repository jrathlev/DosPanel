(* Delphi Dialog
   Anzeige eines Hilfefenster für HTML-Hilfe (Web-Browser)
   =======================================================
    
   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   Sep. 2001
   last modified: Nov. 2021
   *)

unit WebBrowser;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.OleCtrls, SHDocVw,
  Vcl.ComCtrls, Vcl.ActnList, Vcl.ImgList, Vcl.ToolWin, Winapi.Messages,
  System.Actions, System.ImageList;

type
  TDownloadEvent = procedure(Sender: TObject; const URL : string; var Done : boolean) of object;
  TRefreshEvent = procedure(Sender: TObject; var Title,URL,Org: string) of object;

  TWebBrowserWin = class(TForm)
    paTop: TPanel;
    edURL: TEdit;
    btnSize1: TButton;
    btnSize2: TButton;
    btnSize3: TButton;
    ActionList: TActionList;
    ActionEdit: TAction;
    ImageList: TImageList;
    paTopLeft: TPanel;
    paTopRight: TPanel;
    tbButtons: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ActionRefresh: TAction;
    ActionHome: TAction;
    ActionBack: TAction;
    ActionFwd: TAction;
    ActionCancel: TAction;
    ToolButton7: TToolButton;
    tbOk: TToolButton;
    ActionExit: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSize1Click(Sender: TObject);
    procedure btnSize2Click(Sender: TObject);
    procedure btnSize3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edURLKeyPress(Sender: TObject; var Key: Char);
    procedure edURLKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure ActionEditExecute(Sender: TObject);
    procedure ActionCancelExecute(Sender: TObject);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure ActionHomeExecute(Sender: TObject);
    procedure ActionBackExecute(Sender: TObject);
    procedure ActionFwdExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActionExitExecute(Sender: TObject);
    procedure ExtraKey(var Msg: TMessage); message WM_APPCOMMAND;
  private
    { Private declarations }
    FIniName,FSection : string;
    FCaller    : TControl;
    WebBrowser : TWebBrowser;
    NewWin     : TWebBrowserWin;
    Available  : boolean;
    Home,FOrg  : string;
    WSt        : TWindowState;
    HForm      : TRect;
    FOnDownload : TDownloadEvent;
    FOnRefresh  : TRefreshEvent;
    procedure SetOnDownload(Value : TDownloadEvent);
    procedure SetOnRefresh (Value : TRefreshEvent);
    procedure InitBrowser(URL,Org : string);
    procedure BeforeNavigate (Sender: TObject; const pDisp: IDispatch;
                              const URL: OleVariant; const Flags: OleVariant;
                              const TargetFrameName: OleVariant; const PostData: OleVariant;
                              const Headers: OleVariant; var Cancel: WordBool);
    procedure NavigateComplete (Sender: TObject; const pDisp: IDispatch;
                                const URL: OleVariant);
    procedure NewWindow(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
  public
    { Public declarations }
    procedure LoadFromIni (AIniname,ASection : string);
    function Execute (ACaller : TControl; Title,URL,Org : string; ShowOk : boolean; ShCut : TShortCut) : boolean;
    procedure GotoHomePage;
    property OnDownload: TDownloadEvent read FOnDownload write SetOnDownload;
    property OnRefresh: TRefreshEvent read FOnRefresh write SetOnRefresh;
    end;

var
  WebBrowserWin: TWebBrowserWin;

implementation

{$R *.DFM}

uses System.IniFiles, Web.HTTPApp, Vcl.Menus, WinUtils, GnuGetText;

{ ------------------------------------------------------------------- }
const
  IniLeft= 'Left';
  IniTop = 'Top';
  IniWidth = 'Width';
  IniHeight = 'Height';
  IniState = 'State';

procedure TWebBrowserWin.LoadFromIni (AIniname,ASection : string);
begin
  FIniName:=AIniname; FSection:=ASection;
  with TIniFile.Create(FIniName) do begin
    with HForm do begin
      Left:=ReadInteger (FSection,IniLeft,10);
      Top:=ReadInteger (FSection,IniTop,10);
      Right:=ReadInteger (FSection,IniWidth,600);
      Bottom:=ReadInteger (FSection,IniHeight,450);
      end;
    WSt:=TWindowState(ReadInteger(FSection,IniState,Ord(wsNormal)));
    Free;
    end;
  Left:=HForm.Left; Top:=HForm.Top;
  Width:=HForm.Right; Height:=HForm.Bottom;
  WindowState:=WSt;
  end;

{ ------------------------------------------------------------------- }
procedure TWebBrowserWin.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs');
  FIniName:=''; FSection:='';
  Home:=''; FOrg:='';
  Available:=true;
  NewWin:=nil; WebBrowser:=nil;
  FCaller:=nil;
  FOnRefresh:=nil; FOnDownload:=nil;
  ActionCancel.ShortCut:=ShortCut(VK_ESCAPE,[]);
  ActionExit.ShortCut:=ShortCut(VK_RETURN,[]);
  ActionBack.ShortCut:=ShortCut(VK_LEFT,[ssAlt]);
  ActionFwd.ShortCut:=ShortCut(VK_RIGHT,[ssAlt]);
  end;

procedure TWebBrowserWin.FormDestroy(Sender: TObject);
begin
  if (length(FIniname)>0) and (length(FSection)>0) then begin
    with TIniFile.Create(FIniName) do begin
      if WindowState=wsNormal then begin
        WriteInteger (FSection,IniLeft,Left);
        WriteInteger (FSection,IniTop,Top);
        WriteInteger (FSection,IniWidth,Width);
        WriteInteger (FSection,IniHeight,Height);
        end;
      WriteInteger (FSection,IniState,ord(WindowState));
      Free;
      end;
    end;
  if assigned(NewWin) then NewWin.Free;
  if assigned(WebBrowser) then WebBrowser.Free;
  end;

procedure TWebBrowserWin.FormActivate(Sender: TObject);
var
  Title,URL,Org : string;
begin
  if Available and assigned(FOnRefresh) then begin
    FOnRefresh(self,Title,URL,Org);
    if length(URL)>0 then begin
      if AnsiCompareText(Org,FOrg)<>0 then InitBrowser(URL,Org)
      else ActionRefreshExecute(self);
      Caption:=Title;
      end;
    end;
  FOrg:=Org;
  end;

procedure TWebBrowserWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FOrg:='';
  end;

procedure TWebBrowserWin.ExtraKey(var Msg: TMessage);
begin
  with Msg do case GET_APPCOMMAND_LPARAM(LParam) of
  APPCOMMAND_BROWSER_BACKWARD : begin    // $80010000
      ActionBackExecute(self);
      Result:=1;
      end;
  APPCOMMAND_BROWSER_FORWARD : begin     // $80020000
      ActionFwdExecute(self);
      Result:=1;
      end;
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TWebBrowserWin.GotoHomePage;
begin
  WebBrowser.Navigate(Home);
  end;

procedure TWebBrowserWin.BeforeNavigate (Sender: TObject; const pDisp: IDispatch;
                          const URL: OleVariant; const Flags: OleVariant;
                          const TargetFrameName: OleVariant; const PostData: OleVariant;
                          const Headers: OleVariant; var Cancel: WordBool);
var
  Done : boolean;
  s    : string;
begin
  if assigned(FOnDownload) then begin
    s:=Headers;
    FOnDownload(Sender,URL,Done);
    BringToFront;
    end
  else Done:=false;
  Cancel:=Done;
  end;

procedure TWebBrowserWin.NewWindow(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
begin
  if assigned(FOnDownload) then begin   // nur für Downloads
    NewWin:=TWebBrowserWin.Create(Application.MainForm);
    with NewWin do begin
      WebBrowser:=TWebBrowser.Create(WebBrowserWin);
      FOnDownload:=WebBrowserWin.FOnDownload;
      with WebBrowser do begin
  //      ManualDock (self,nil,alNone);
  //      Align:=alClient;
        RegisterAsBrowser:=true;
        RegisterAsDropTarget:=false;
        OnBeforeNavigate2:=BeforeNavigate;
        OnNavigateComplete2:=NavigateComplete;
        end;
      ppDisp:=WebBrowser.DefaultDispatch;
      end;
    end;
  end;

procedure TWebBrowserWin.NavigateComplete (Sender: TObject; const pDisp: IDispatch;
                                           const URL: OleVariant);
begin
  edURL.Text:=WebBrowser.LocationURL;
  end;

procedure TWebBrowserWin.SetOnDownload(Value : TDownloadEvent);
begin
  FOnDownload:=Value;
  end;

procedure TWebBrowserWin.SetOnRefresh (Value : TRefreshEvent);
begin
  FOnRefresh:=Value;
  end;

procedure TWebBrowserWin.edURLKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then WebBrowser.Navigate (edURL.Text);
  end;

procedure TWebBrowserWin.edURLKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Key:=#0;
  end;

procedure TWebBrowserWin.InitBrowser(URL,Org : string);
begin
  Home:=URL;
  edURL.Text:=URL;
  WebBrowser.Navigate (URL);
  end;

procedure TWebBrowserWin.ActionEditExecute(Sender: TObject);
begin
  if assigned(FCaller) then FCaller.BringToFront;
  end;

{ ------------------------------------------------------------------- }
procedure TWebBrowserWin.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult=mrNone then Modalresult:=mrCancel;
  end;

procedure TWebBrowserWin.ActionExitExecute(Sender: TObject);
begin
  ModalResult:=mrOK;
  end;

procedure TWebBrowserWin.ActionCancelExecute(Sender: TObject);
begin
  Close;
  end;

procedure TWebBrowserWin.ActionRefreshExecute(Sender: TObject);
var
  Level: OleVariant;
begin
  Level:=REFRESH_NORMAL;
  if assigned(WebBrowser) and (length(WebBrowser.LocationURL)>0) then WebBrowser.Refresh2(Level);
  end;

procedure TWebBrowserWin.ActionHomeExecute(Sender: TObject);
begin
  WebBrowser.Navigate(Home);
  end;

procedure TWebBrowserWin.ActionBackExecute(Sender: TObject);
begin
  try
    with WebBrowser do begin
      GoBack;
      end;
  except
    end;
  end;

procedure TWebBrowserWin.ActionFwdExecute(Sender: TObject);
begin
  try
    with WebBrowser do begin
      GoForward;
      end;
  except
    end;
  end;

procedure TWebBrowserWin.btnSize1Click(Sender: TObject);
begin
  ClientWidth:=640; ClientHeight:=480+paTop.Height;
  WindowState:=wsNormal;
  end;

procedure TWebBrowserWin.btnSize2Click(Sender: TObject);
begin
  ClientWidth:=800; ClientHeight:=600+paTop.Height;
  WindowState:=wsNormal;
  end;

procedure TWebBrowserWin.btnSize3Click(Sender: TObject);
begin
  ClientWidth:=1024; ClientHeight:=768+paTop.Height;
  WindowState:=wsNormal;
  end;

{ ------------------------------------------------------------------- }
function TWebBrowserWin.Execute (ACaller : TControl; Title,URL,Org  : string;
                                 ShowOk : boolean; ShCut : TShortCut) : boolean;
var
  Modal,New  : boolean;
begin
  Result:=false;
  FCaller:=ACaller;
  if Pos('://',URL)=0 then URL:='file:///'+DosPathToUnixPath(URL);
  New:=true;
  Modal:=ShCut=0;
  ActionExit.Visible:=Modal and ShowOk;
  ActionEdit.Visible:=not Modal;
  ActionEdit.ShortCut:=ShCut;
  if Visible then begin
    if assigned(WebBrowser) then New:=WideCompareText(WebBrowser.LocationURL,URL)<>0
    else New:=AnsiCompareText(Org,FOrg)<>0;
    end;
  if New then begin
//    FreeAndNil(WebBrowser);
    if not assigned(WebBrowser) then begin
      try
        WebBrowser:=TWebBrowser.Create(self);
        with WebBrowser do begin
          ManualDock (self,nil,alNone);
          Align:=alClient;
          RegisterAsBrowser:=true;
          RegisterAsDropTarget:=false;
          OnBeforeNavigate2:=BeforeNavigate;
          OnNavigateComplete2:=NavigateComplete;
          OnNewWindow2:=NewWindow;
          end;
      except
        Available:=false;
        end;
      end;
    if Available then begin
      Caption:=Title;
      InitBrowser(URL,Org);
      if Modal then Result:=ShowModal=mrOK
      else Show;
      end
    else ErrorDialog (CenterPos,dgettext('dialogs','The integrated web browser is not available on your system'+sLineBreak+
                'You need to install Internet Explorer Vers. 4 or newer.'));
    end
  else if AVailable then begin
//    WebBrowser.Refresh;
    BringToFront;
    end;
  end;

end.
