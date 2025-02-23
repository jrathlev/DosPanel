(* DosPanel - Windows GUI for DOSBox
   =================================
   Main program unit
   -----------------

   � J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   J. Rathlev, Dec. 2011
   last modified: December 2023
   *)

unit DosPanelMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ActnList,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, System.Contnrs,
  Vcl.CategoryButtons, LangUtils, Vcl.ImgList, Vcl.Imaging.pngimage, System.ImageList,
  Vcl.ExtCtrls, System.Actions, Settings, AppSettings, WebBrowser;

const
  ProgName = 'DOS Panel';
  Vers = ' - Vers. 1.7';
  CopRgt = '� 2018-2025 - Dr. J. Rathlev, D-24222 Schwentinental';
  EMailAdr = 'kontakt(a)rathlev-home.de';

  ConfName = 'dospanel.conf';

  defSubPath = 'DOSBox\';
  defConf = 'dosbox-%s.conf';
  defLang = 'german-%s.lang';
  defMap  = 'mapper-%s.map';

type
  TConfigList = class(TStringList)
  private
    FFilename : string;
  public
    constructor Create (const AFilename : string);
    procedure AddSection (const ASection : string);
    procedure AddValue (const AKey,AValue : string); overload;
    procedure AddValue (const AKey : string; AValue : integer); overload;
    procedure Save;
    end;

  TfrmMain = class(TForm)
    MainMenu: TMainMenu;
    itmGlobal: TMenuItem;
    itmExit: TMenuItem;
    itmSettings: TMenuItem;
    itmEntries: TMenuItem;
    View1: TMenuItem;
    itmAdd: TMenuItem;
    itmEdit: TMenuItem;
    itmRemove: TMenuItem;
    itmRun: TMenuItem;
    itmSmallIcons: TMenuItem;
    itmLargeicons: TMenuItem;
    itmList: TMenuItem;
    itmDetails: TMenuItem;
    itmApplication: TMenuItem;
    itmDosBox: TMenuItem;
    itmHelp: TMenuItem;
    itmAbout: TMenuItem;
    ActionList: TActionList;
    StatusBar: TStatusBar;
    lvApps: TListView;
    actExit: TAction;
    itmUsermanual: TMenuItem;
    N1: TMenuItem;
    actNewProgram: TAction;
    actEditProgram: TAction;
    actRemProgram: TAction;
    actLargeIcons: TAction;
    actSmallIcons: TAction;
    actList: TAction;
    actDetails: TAction;
    actSettings: TAction;
    actRun: TAction;
    actShowMan: TAction;
    actDosBox: TAction;
    tbMain: TToolBar;
    tbNew: TToolButton;
    tbEdit: TToolButton;
    tbRemove: TToolButton;
    ToolButton1: TToolButton;
    tbRun: TToolButton;
    ToolButton2: TToolButton;
    tbLarge: TToolButton;
    tbSmall: TToolButton;
    tbList: TToolButton;
    tbDetails: TToolButton;
    ilActions: TImageList;
    ilLarge: TImageList;
    ilSmall: TImageList;
    imgSmall: TImage;
    imgLarge: TImage;
    tcCats: TTabControl;
    actInfo: TAction;
    PopupMenu: TPopupMenu;
    piRun: TMenuItem;
    piEdit: TMenuItem;
    piRemove: TMenuItem;
    piManual: TMenuItem;
    itmLanguage: TMenuItem;
    N2: TMenuItem;
    itmConvert: TMenuItem;
    actConvertText: TAction;
    ToolButton3: TToolButton;
    tbMan: TToolButton;
    tbDosBox: TToolButton;
    piMapper: TMenuItem;
    actMapper: TAction;
    N3: TMenuItem;
    itmMapper: TMenuItem;
    N4: TMenuItem;
    itmDuplicate: TMenuItem;
    piDuplicate: TMenuItem;
    actDuplicate: TAction;
    itmHelpFile: TMenuItem;
    N5: TMenuItem;
    actHelpFile: TAction;
    tbSettings: TToolButton;
    tbExit: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actExitExecute(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
    procedure actNewProgramExecute(Sender: TObject);
    procedure actEditProgramExecute(Sender: TObject);
    procedure actRemProgramExecute(Sender: TObject);
    procedure actLargeIconsExecute(Sender: TObject);
    procedure actSmallIconsExecute(Sender: TObject);
    procedure actListExecute(Sender: TObject);
    procedure actDetailsExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvAppsResize(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure lvAppsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tcCatsChange(Sender: TObject);
    procedure lvAppsClick(Sender: TObject);
    procedure lvAppsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actInfoExecute(Sender: TObject);
    procedure actDosBoxExecute(Sender: TObject);
    procedure actShowManExecute(Sender: TObject);
    procedure SetLanguageClick(Sender : TObject; Language : TLangCodeString);
    procedure actConvertTextExecute(Sender: TObject);
    procedure lvAppsDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actMapperExecute(Sender: TObject);
    procedure piDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actHelpFileExecute(Sender: TObject);
  private
    { Private-Deklarationen }
    ProgVersName,
    ProgVersDate,
    IniName,
    CurApp           : string;
    HtManWin         : TWebBrowserWin;
    Languages        : TLanguageList;
    lvViewStyle      : TViewStyle;
    Apps             : TObjectList;
    procedure SaveToIni;
    procedure SetViewStyle (AViewStyle : TViewStyle);
    procedure UpdateView (const NAppName : string);
    procedure UpdateAutoStart;
    function CurrentAppIndex : integer;
  public
    { Public-Deklarationen }
    UserPath,ProgPath,
    AppDataPath,LocPath  : string;
    BasicSettings    : TBasicSettings;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses Winapi.ShellApi, Winapi.ShlObj, System.StrUtils, System.Win.Registry,
  GnuGetText, InitProg, IniFileUtils, WinUtils, ListUtils,
  FileCopy, MsgDialogs, StringUtils, PathUtils, WinShell, WinExecute, NumberUtils,
  ShowMemo, TxtConvertDlg;

{ ------------------------------------------------------------------- }
constructor TConfigList.Create (const AFilename : string);
begin
  inherited Create;
  FFilename:=AFilename;
  end;

procedure TConfigList.Save;
begin
  SaveToFile(FFilename);
  end;

procedure TConfigList.AddSection (const ASection : string);
begin
  Add('['+ASection+']');
  end;

procedure TConfigList.AddValue (const AKey,AValue : string);
begin
  Add(AKey+'='+AValue);
  end;

procedure TConfigList.AddValue (const AKey : string; AValue : integer);
begin
  Add(AKey+'='+IntToStr(AValue));
  end;

{ ------------------------------------------------------------------- }
const
  IniExt = 'ini';

  CfGSekt    = 'Config';
  AppSekt    = 'App';
  HtSekt     = 'HtmlManual';

  iniTop    = 'Top';
  iniLeft   = 'Left';
  iniHeight = 'Height';
  iniWidth  = 'Width';
  iniPath   = 'DosBoxPath';
  iniRoot   = 'RootPath';
  iniConf   = 'ConfFile';
  iniLang   = 'LangFile';
  iniMap    = 'MapperFile';
  iniKeyb   = 'KeyboardLayout';
  iniCon    = 'HideConsole';
  iniACount = 'AppCount';
  iniLApp   = 'LastApp';
  iniMSize  = 'MemSize';
  iniCdPage = 'Codepage';
  iniAStart = 'AutoStart';
  iniEdt    = 'Editor';

  iniAName  = 'AppName';
  iniCat    = 'Category';
  iniApp    = 'Executable';
  iniMount  = 'MountCD';
  iniCdPath = 'CdPath';
  iniHd     = 'HardDrive';
  iniCD     = 'CdRomDrive';
  iniIso    = 'IsoImage';
  iniPar    = 'Parameters';
  iniCmd    = 'Commands';
  iniIcon   = 'IconFile';
  iniMan    = 'Manual';
  iniDesc   = 'Description';
  iniMixer  = 'Mixer';
  iniAppCfg = 'AppConfig';
  iniFull   = 'FullScreen';
  iniAuto   = 'AutoEnd';
  iniClose  = 'AutoClose';
  iniCycles = 'Cycles';

procedure TfrmMain.FormCreate(Sender: TObject);

  procedure ReadOptions;
  var
    s   : string;
    i   : integer;
  begin
    if ParamCount>0 then begin
      for i:=1 to ParamCount do begin
        s:=ParamStr(i);
        if (s[1]='/') or (s[1]='-') then begin
          delete (s,1,1);
          if ReadOptionValue(s,siAltIni) then  // anderer Ort f�r Ini-Datei
            IniName:=Erweiter(AppDataPath,s,IniExt);
          end
        end;
      end;
    end;

begin
  TranslateComponent(self);
  InitPaths(AppDataPath,UserPath,ProgPath);
  InitVersion(ProgName,Vers,CopRgt,3,3,ProgVersName,ProgVersDate);
  IniName:=Erweiter(AppDataPath,PrgName,IniExt);
  Languages:=TLanguageList.Create(PrgPath,LangName);
  ReadOptions;
  with Languages do begin
    Menu:=itmLanguage;
    LoadLanguageNames(SelectedLanguage);
    OnLanguageItemClick:=SetLanguageClick;
    end;
  HtManWin:=TWebBrowserWin.Create(Application);
  end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Apps.Free; Languages.Free;
  end;

{ ------------------------------------------------------------------- }
procedure TfrmMain.lvAppsResize(Sender: TObject);
begin
  lvApps.Arrange(arDefault);
  end;

{ ------------------------------------------------------------------- }
procedure TfrmMain.UpdateView (const NAppName : string);
var
  i,n : integer;
  sc  : string;
begin
  lvApps.Clear;
  with tcCats do begin
    Visible:=Tabs.Count>0;
    if Visible then sc:=Tabs[TabIndex] else sc:=MiscName;
    end;
  ilLarge.Clear; ilSmall.Clear;
  with Apps do for i:=0 to Count-1 do with (Items[i] as TDosBoxApp) do
      if (AnsiSameText(Category,sc))
      or (length(Category)=0) and AnsiSameText(sc,MiscName) then begin
    with Icons do begin
      if ImgType=imIco then n:=ilLarge.AddIcon(Icon)
      else begin
        try n:=ilLarge.AddMasked(ScaleBitmap(Bitmap,32,32),Bitmap.TransparentColor);
        except n:=ilLarge.AddIcon(imgLarge.Picture.Icon);
          end;
        end;
      ilSmall.AddMasked(Small,Small.TransparentColor);
      end;
    with lvApps.Items.Add do begin
      Caption:=AppName;
      Data:=pointer(i);
      ImgIndex:=n;
      ImageIndex:=ImgIndex;
      SubItems.Add(AppPath);
      SubItems.Add(AppFile);
      SubItems.Add(Parameters);
      SubItems.Add(CdPath);
      SubItems.Add(ManFile);
      SubItems.Add(Description);
      end;
    end;
  n:=GetListViewIndex(lvApps,NAppName);
  with lvApps do begin
    if n<0 then begin
      if (Items.Count>0) then ItemIndex:=0;
      CurApp:='';
      end
    else begin
      ItemIndex:=n;
      CurApp:=Items[n].Caption;
      end;
    end;
  end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  i,n,k    : integer;
  sp,sc,si,
  sec,s,sv : string;
  na       : TDosBoxApp;
  DirInfo    : TSearchRec;
  Findresult : integer;

  (* Windows-Verzeichnisse *)
  function WindowsDirectory : string;
  var
    p : pchar;
  begin
    p:=StrAlloc(MAX_PATH+1);
    GetWindowsDirectory (p,MAX_PATH+1);
    Result:=p;
    Strdispose(p);
    end;

  // check text editor
  procedure CheckTextEditor(var TextEditor : string);
  var
    s : string;
  begin
    if (length(TextEditor)=0) or not FileExists(TextEditor) then begin
      with TRegistry.Create do begin
        Access:=KEY_READ;
        RootKey:=HKEY_CLASSES_ROOT;
        s:='';
        try
          if OpenKey('.txt',false) then begin
            s:=ReadString('');
            CloseKey;
            if OpenKey(s+'\shell\open\Command',false) then s:=ReadString('')
            else s:='';
            s:=AnsiReplaceText(ReadNxtQuotedStr(s,#32,'"'),'%SystemRoot%',WindowsDirectory);
            end;
        finally
          Free;
          end;
        end;
      if (length(s)>0) and FileExists(s) then TextEditor:=s;
      end;
    end;

begin
  s:='';
  FindResult:=FindFirst(SetDirName(ProgPath)+'dosbox-*',faDirectory,DirInfo);
  if (FindResult=0) then begin
    sv:=DirInfo.Name;
    ReadNxtStr(sv,'-');
    sp:=SetDirName(ProgPath)+DirInfo.Name;
    end;
  FindClose(DirInfo);
  LocPath:=SetDirName(SetDirName(GetDesktopFolder(CSIDL_LOCAL_APPDATA)));
  Caption:=_('Run DOSBox applications')+' ('+VersInfo.Comments+')';
  Apps:=TObjectList.Create;
  Apps.OwnsObjects:=true;
  if FileExists(IniName) then si:=IniName
  else begin
    si:=PrgPath+ExtractFileName(IniName);    // try in DosPanel.exe path
    if not FileExists(si) then si:=IniName;
    end;
  with TUnicodeIniFile.CreateForRead(IniName) do begin
    Left:=ReadInteger (CfgSekt,IniLeft,50);
    Top:=ReadInteger (CfgSekt,IniTop,50);
    Height:=ReadInteger(CfgSekt,iniHeight,Height);
    Width:=ReadInteger(CfgSekt,iniWidth,Width);
    with BasicSettings do begin
      DosBoxPath:=ReadString(CfgSekt,iniPath,sp);
      if length(DosBoxPath)=0 then DosBoxPath:=sp;
      if not DirectoryExists(DosBoxPath) then begin
        ConfFile:='';
        LangFile:='';
        MapperFile:='';
        end
      else begin
        LocPath:=LocPath+defSubPath;
        s:=LocPath+Format(defConf,[sv]);
        ConfFile:=ReadString(CfgSekt,iniConf,s);
        if length(ConfFile)=0 then ConfFile:=s;
        s:=LocPath+Format(defLang,[sv]);
        LangFile:=ReadString(CfgSekt,iniLang,s);
        if length(LangFile)=0 then LangFile:=s;
        s:=LocPath+Format(defMap,[sv]);
        MapperFile:=ReadString(CfgSekt,iniMap,'');
        if length(MapperFile)=0 then MapperFile:=s;
        end;
      TextEditor:=ReadString(CfgSekt,iniEdt,'');
      CheckTextEditor(TextEditor);
      RootPath:=ReadString(CfgSekt,iniRoot,UserPath);
      if not DirectoryExists(RootPath) then RootPath:=UserPath;
      KeyLayout:=ReadString(CfgSekt,iniKeyb,'');
      Codepage:=ReadInteger(CfgSekt,iniCdPage,GetCodePage);
      if CodePage=0 then CodePage:=GetCodePage;
      HideCon:=ReadBool(CfgSekt,iniCon,false);
      AutoStart:=ReadBool(CfgSekt,iniAStart,false);
      end;
    CurApp:=ReadString(CfgSekt,iniLApp,'');
    n:=ReadInteger(CfgSekt,iniACount,0);
    sc:='';
    for i:=1 to n do begin
      na:=TDosBoxApp.Create(BasicSettings.ConfFile,imgLarge.Picture,imgSmall.Picture,BasicSettings.CodePage);
      with na do begin
        sec:=AppSekt+ZStrInt(i,3);
        AppName:=ReadString(sec,iniAName,'');
        Category:=ReadString(sec,iniCat,'');
        if length(Category)=0 then s:=MiscName
        else s:=Category;
        if (length(sc)=0) and AnsiSameText(AppName,CurApp) then sc:=s;
        AppPath:=ReadString(sec,iniRoot,'');
        MountCd:=ReadBool(sec,iniMount,MountCd);
        CdPath:=ReadString(sec,iniCdPath,'');
        IsoImage:=ReadBool(sec,iniIso,true);
        HardDrv:=ReadString(sec,iniHd,'C')[1];
        CdDrv:=ReadString(sec,iniCD,'D')[1];
        AppFile:=ReadString(sec,iniApp,'');
        Parameters:=ReadString(sec,iniPar,'');
        Commands:=AnsiDequotedStr(ReadString(sec,iniCmd,UpCase(HardDrv)+':;"CD \"'),'#');
        IconFile:=ReadString(sec,iniIcon,'');
        LoadIcons(IconFile);
        ManFile:=ReadString(sec,iniMan,'');
        CodePage:=ReadInteger(sec,iniCdPage,CodePage);
        Description:=ReadString(sec,iniDesc,'');
        MixerChannels:=AnsiDequotedStr(ReadString(sec,iniMixer,''),'#');;
        AppConfig:=ReadBool(sec,iniAppCfg,AppConfig);
        AppMapper:=ReadString(sec,iniMap,AppMapper);
        if (length(AppMapper)>0) and not FileExists(AppMapper) then
          AppMapper:=MakeAbsolutePath(ExtractFilePath(BasicSettings.ConfFile),BasicSettings.MapperFile);
        FullScreen:=ReadBool(sec,iniFull,FullScreen);
        AutoEnd:=ReadBool(sec,iniAuto,true);
        AutoClose:=ReadBool(sec,iniClose,false);
        MemSize:=ReadInteger(sec,iniMSize,MemSize);
        Speed:=ReadInteger(sec,iniCycles,Speed);
        end;
      Apps.Add(na);
      with tcCats.Tabs do begin
        k:=IndexOf(s);
        if k<0 then AddObject(s,pointer(1))
        else Objects[k]:=pointer(integer(Objects[k])+1);
        end;
      end;
    Free;
    end;
  HtManWin.LoadFromIni(IniName,HtSekt);
  actRun.Enabled:=false;
  with tcCats do if Tabs.Count>0 then begin
    n:=Tabs.IndexOf(sc);
    if n<0 then TabIndex:=0 else TabIndex:=n;
    end
  else begin
//    TabIndex:=Tabs.AddObject(MiscName,pointer(1));
    end;
  if not DirectoryExists(BasicSettings.DosBoxPath) then begin
    DosBoxSetDialog.Execute(BasicSettings);
    end;
  SetViewStyle(vsIcon);
  UpdateView(CurApp);
  end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UpdateAutoStart;
  with HtManWin do begin
    if Visible then Close;
    Release;
    end;
  end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SaveToIni;
  end;

procedure TfrmMain.SaveToIni;
var
  i   : integer;
  sec : string;
begin
  with TUnicodeIniFile.CreateForWrite(IniName) do begin
    WriteInteger (CfgSekt,IniLeft,Left);
    WriteInteger (CfgSekt,IniTop,Top);
    WriteInteger(CfgSekt,iniHeight,Height);
    WriteInteger(CfgSekt,iniWidth,Width);
    with BasicSettings do begin
      WriteString(CfgSekt,iniPath,DosBoxPath);
      WriteString(CfgSekt,iniRoot,RootPath);
      WriteString(CfgSekt,iniConf,ConfFile);
      WriteString(CfgSekt,iniLang,LangFile);
      WriteString(CfgSekt,iniMap,MapperFile);
      WriteString(CfgSekt,iniKeyb,KeyLayout);
      WriteInteger(CfgSekt,iniCdPage,Codepage);
      WriteBool(CfgSekt,iniCon,HideCon);
      WriteBool(CfgSekt,iniAStart,AutoStart);
      end;
    WriteString(CfgSekt,iniLApp,CurApp);
    with Apps do begin
      WriteInteger(CfgSekt,iniACount,Count);
      for i:=0 to Count-1 do with (Items[i] as TDosBoxApp) do begin
        sec:=AppSekt+ZStrInt(i+1,3);
        WriteString(sec,iniAName,AppName);
        WriteString(sec,iniCat,Category);
        WriteString(sec,iniRoot,AppPath);
        WriteBool(sec,iniMount,MountCd);
        WriteString(sec,iniCdPath,CdPath);
        WriteString(sec,iniHd,HardDrv);
        WriteString(sec,iniCD,CdDrv);
        WriteBool(sec,iniIso,IsoImage);
        WriteString(sec,iniApp,AppFile);
        WriteString(sec,iniPar,Parameters);
        WriteString(sec,iniCmd,AnsiQuotedStr(Commands,'#'));
        WriteString(sec,iniIcon,IconFile);
        WriteString(sec,iniMan,ManFile);
        WriteInteger(sec,iniCdPage,CodePage);
        WriteString(sec,iniDesc,Description);
        WriteString(sec,iniMixer,AnsiQuotedStr(MixerChannels,'#'));
        WriteBool(sec,iniAppCfg,AppConfig);
        WriteString(sec,iniMap,AppMapper);
        WriteBool(sec,iniFull,FullScreen);
        WriteBool(sec,iniAuto,AutoEnd);
        WriteBool(sec,iniClose,AutoClose);
        WriteInteger(sec,iniMSize,MemSize);
        WriteInteger(sec,iniCycles,Speed);
        end;
      end;
    Free;
    end;
  end;

procedure TfrmMain.UpdateAutoStart;
var
  s : string;
begin
  // insert entry to startup folder
  s:=GetDesktopFolder(CSIDL_Startup);
  if length(s)>0 then begin
    s:=Erweiter(s,PrgName,'lnk');
    if FileExists(s) then DeleteFile(s);
    if BasicSettings.AutoStart then begin
      MakeLink (s,Application.ExeName,'',PrgPath,ProgVersName);
      end;
    end;
  end;

procedure TfrmMain.SetViewStyle (AViewStyle : TViewStyle);
begin
  lvViewStyle:=AViewStyle;
  lvApps.ViewStyle:=AViewStyle;
  lvApps.Scroll(0,0);
  end;

procedure TfrmMain.tcCatsChange(Sender: TObject);
begin
  UpdateView(CurApp);
  end;

procedure TfrmMain.SetLanguageClick(Sender : TObject; Language : TLangCodeString);
var
  s : string;
  n : integer;
begin
  if not AnsiSameStr(SelectedLanguage,Language) then begin
    s:=MiscName;
    Languages.SelectedLanguageCode:=Language;
    ChangeLanguage(Language);
    Languages.LoadLanguageNames(SelectedLanguage);
    Caption:=_('Run DOSBox applications')+' ('+VersInfo.Comments+')';
    with tcCats do with Tabs do begin
      n:=IndexOf(s);
      if n>=0 then Strings[n]:=MiscName;
      end;
    end;
  end;

procedure TfrmMain.lvAppsClick(Sender: TObject);
begin
  with lvApps do if assigned(Selected) then CurApp:=Selected.Caption
  else UpdateView(CurApp);
  end;

procedure TfrmMain.lvAppsDblClick(Sender: TObject);
begin
  with lvApps do if assigned(Selected) then begin
    CurApp:=Selected.Caption;
    actRunExecute(Sender);
    end
  else UpdateView(CurApp);
  end;

procedure TfrmMain.lvAppsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  li : TListItem;
begin
  li:=lvApps.GetItemAt(X,Y);
  with StatusBar do if assigned(li) then
    Simpletext:=(Apps[integer(li.Data)] as TDosBoxApp).Description
  else Simpletext:='';
  end;

procedure TfrmMain.lvAppsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  actRun.Enabled:=assigned(lvApps.Selected);
  actEditProgram.Enabled:=actRun.Enabled;
  actRemProgram.Enabled:=actRun.Enabled;
  actShowMan.Enabled:=actRun.Enabled;
  actMapper.Enabled:=actRun.Enabled;
  end;

procedure TfrmMain.piDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
begin
  with ((Sender as TMenuItem).Action as TAction) do begin
    ACanvas.TextRect(ARect,Arect.Left+30,ARect.Top+4,DelChar(Caption,'&'));
    with ARect do ilActions.Draw(ACanvas,Left+1,Top+1,ImageIndex);
    end;
  end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
  end;

procedure TfrmMain.actInfoExecute(Sender: TObject);
begin
  InfoDialog(ProgName,ProgVersName+' - '+ProgVersDate+#13+
           VersInfo.CopyRight+#13+'E-Mail: '+EmailAdr);
  end;

procedure TfrmMain.actHelpFileExecute(Sender: TObject);
var
  s : string;
begin
  s:=PrgPath+_('dospanel-en.chm');
  if FileExists(s) then begin
    try
      HtmlHelp(GetDesktopWindow,pchar(s),HH_DISPLAY_TOPIC,0);
    except
      ErrorDialog (CursorPos,_('Help not available on this system!'));
      end;
    end
  else ErrorDialog (CursorPos,_('Help file not found!'));
  end;

procedure TfrmMain.actSettingsExecute(Sender: TObject);
var
  n : integer;
begin
  if DosBoxSetDialog.Execute(BasicSettings) then begin
    n:=CurrentAppIndex;
    if n>=0 then (Apps[n] as TDosBoxApp).CodePage:=BasicSettings.Codepage;
    UpdateAutoStart;
    end;
  end;

procedure TfrmMain.actNewProgramExecute(Sender: TObject);
var
  NewApp : TDosBoxApp;
  k      : integer;
  s      : string;
begin
  NewApp:=TDosBoxApp.Create(BasicSettings.ConfFile,imgLarge.Picture,imgSmall.Picture,BasicSettings.Codepage);
  if AppSettingsDialog.Execute(tcCats.Tabs,NewApp) then begin
    with NewApp do if length(Category)=0 then s:=MiscName else s:=Category;
    with tcCats,Tabs do begin
      k:=IndexOf(s);
      if k<0 then k:=AddObject(s,pointer(1))
      else Objects[k]:=pointer(integer(Objects[k])+1);
      TabIndex:=k;
      end;
    Apps.Add(NewApp);
    UpdateView(NewApp.AppName);
    SaveToIni;
    end
  else NewApp.Free;
  end;

function TfrmMain.CurrentAppIndex : integer;
begin
  with lvApps do if assigned(Selected) then Result:=integer(Selected.Data)
  else Result:=-1;
  end;

procedure TfrmMain.actDuplicateExecute(Sender: TObject);
var
  NewApp : TDosBoxApp;
  k,n    : integer;
  s,t    : string;
begin
  n:=CurrentAppIndex;
  if (n>=0) then begin
    NewApp:=TDosBoxApp.Create(BasicSettings.ConfFile,imgLarge.Picture,imgSmall.Picture,BasicSettings.Codepage);
    with NewApp do begin
      Assign(Apps[n] as TDosBoxApp);
      if length(Category)=0 then s:=MiscName else s:=Category;
      end;
    if AppSettingsDialog.Execute(tcCats.Tabs,NewApp) then begin
      with NewApp do if length(Category)=0 then t:=MiscName else t:=Category;
      if not AnsiSameText(s,t) then with tcCats,Tabs do begin // change category
        k:=IndexOf(s);  // old category
        if k>=0 then begin
          Objects[k]:=pointer(integer(Objects[k])-1);
          if integer(Objects[k])=0 then Delete(k);
          end;
        k:=IndexOf(t);  // new category
        if k<0 then k:=AddObject(t,pointer(1))
        else Objects[k]:=pointer(integer(Objects[k])+1);
        TabIndex:=k;
        end;
      Apps.Add(NewApp);
      UpdateView(NewApp.AppName);
      SaveToIni;
      end
    else NewApp.Free;
    end;
  end;

procedure TfrmMain.actEditProgramExecute(Sender: TObject);
var
  n,k : integer;
  s,t : string;
  sa  : TDosBoxApp;
begin
  n:=CurrentAppIndex;
  if (n>=0) then begin
    sa:=Apps[n] as TDosBoxApp;
    with sa do if length(Category)=0 then s:=MiscName
    else s:=Category;
    if AppSettingsDialog.Execute(tcCats.Tabs,sa) then begin
      with sa do if length(Category)=0 then t:=MiscName
      else t:=Category;
      if not AnsiSameText(s,t) then with tcCats,Tabs do begin // change category
        k:=IndexOf(s);  // old category
        if k>=0 then begin
          Objects[k]:=pointer(integer(Objects[k])-1);
          if integer(Objects[k])=0 then Delete(k);
          end;
        k:=IndexOf(t);  // new category
        if k<0 then k:=AddObject(t,pointer(1))
        else Objects[k]:=pointer(integer(Objects[k])+1);
        TabIndex:=k;
        end;
      UpdateView(sa.AppName);
      SaveToIni;
      end;
    end;
  end;

procedure TfrmMain.actRemProgramExecute(Sender: TObject);
var
  n,k  : integer;
  s    : string;
begin
  with lvApps do if assigned(Selected) then with Selected do begin
    s:=Caption; n:=integer(Data);
    end
  else n:=-1;
  if (n>=0) and ConfirmDialog(SafeFormat(_('Remove application "%s" from panel?'),[s])) then begin
    with Apps[n] as TDosBoxApp do if length(Category)=0 then s:=MiscName
    else s:=Category;
    with tcCats,Tabs do begin
      k:=IndexOf(s);  // category index
      if k>=0 then begin
        Objects[k]:=pointer(integer(Objects[k])-1);
        if integer(Objects[k])=0 then begin
          TabIndex:=0; Delete(k);
          end;
        end;
      end;
    Apps.Delete(n);
    UpdateView('');
    SaveToIni;
    end;
  end;

procedure TfrmMain.actLargeIconsExecute(Sender: TObject);
begin
  SetViewStyle(vsIcon);
  end;

procedure TfrmMain.actSmallIconsExecute(Sender: TObject);
begin
  SetViewStyle(vsSmallIcon);
  lvApps.Arrange(arDefault);
  end;

procedure TfrmMain.actListExecute(Sender: TObject);
begin
  SetViewStyle(vsList);
  end;

procedure TfrmMain.actDetailsExecute(Sender: TObject);
begin
  SetViewStyle(vsReport);
  end;

procedure TfrmMain.actRunExecute(Sender: TObject);
var
  sa,sc,s : string;
  n       : integer;
  cl      : TConfigList;
  ok      : boolean;
begin
  n:=CurrentAppIndex;
  if (n>=0) then with Apps[n] as TDosBoxApp do begin
  // check for basic configuration (local or global)
    ok:=(AppConfig and FileExists(AddPath(AppPath,sConfig))) or FileExists(BasicSettings.ConfFile);
    if not ok and not ConfirmDialog(_('Basic configuration file not found! Start application anyway?')) then Exit;
  // write overlay conf file
    if DirectoryExists(AppPath) then begin
      sc:=AddPath(AppPath,ConfName);
      cl:=TConfigList.Create(sc);
      cl.AddSection(secSdl);
      cl.AddValue(cfgFull,LowerCase((BoolToStr(FullScreen,true))));
      if FileExists(AppMapper) then cl.AddValue(cfgMapF,AppMapper)
      else begin
        if length(AppMapper)>0 then AppMapper:='';
        with BasicSettings do if FileExists(MapperFile) then cl.AddValue(cfgMapF,MapperFile);
        end;
      cl.AddSection(secDBox);
      with BasicSettings do if FileExists(LangFile) then cl.AddValue(cfgLang,LangFile);
      if MemSize<>0 then cl.AddValue(cfgMSz,MemSize);
      cl.AddSection(secCPU);
      if Speed>=0 then begin
        case Speed of
        0         : s:=sAuto;
        maxCycles : s:=sMax;
        else s:=sFixed+' '+IntToStr(Speed);
          end;
        cl.AddValue(cfgCycl,s);
        end;
      cl.AddSection(secDos);
      with BasicSettings do if length(KeyLayout)=0 then s:=sAuto else s:=KeyLayout;
      cl.AddValue(cfgKeyb,s);
      cl.AddSection(secExec);
      cl.Add(cfgMount+Space+HardDrv+Space+MakeQuotedStr(AppPath));
      if MountCd then begin
        if IsoImage then begin
          if FileExists(CdPath) then begin
            s:=CfgImgMt+Space+CdDrv+Space+MakeQuotedStr(CdPath)+' -t cdrom';
            cl.Add(s);
            end;
          end
        else cl.Add(CfgMount+Space+CdDrv+Space+CdPath+' -t cdrom');
        end;
      if length(MixerChannels)>0 then begin
        s:=MixerChannels;
        while length(s)>0 do cl.Add('MIXER '+ReadNxtQuotedStr(s,Semicolon,Quote));
        end;
      s:=Commands;
      while length(s)>0 do cl.Add(ReadNxtQuotedStr(s,Semicolon,Quote));
      if length(AppFile)>0 then begin
        if AnsiSameText(GetExt(AppFile),'bat') then s:='CALL '+AppFile else s:=AppFile;
        cl.Add(s+Space+Parameters);
        end;
      if AutoEnd then cl.Add(cfgExit);
      with cl do begin
        Save; Free;
        end;
    // start DosBox
      sa:=AddPath(BasicSettings.DosBoxPath,sDosBox);
      if FileExists(sa) then begin
        s:=MakeQuotedStr(sa);
        if BasicSettings.HideCon then s:=s+' -noconsole';
        if AppConfig then sa:=AddPath(AppPath,sConfig)
        else sa:=BasicSettings.ConfFile;
        if FileExists(sa) then s:=s+' -conf '+MakeQuotedStr(sa);
        s:=s+' -conf '+MakeQuotedStr(sc); // overlay conf file
  //    if length(AppFile)>0 then s:=s+Space+SetDirName(RootPath)+AppFile;
  //    if AutoEnd then s:=s+' -exit';
        StartProcess(s,AppPath);
        if AutoClose then Close;
        end
      else ErrorDialog(SafeFormat(_('%s not found! Please adjust your global settings!'),[sDosBox]));
      end
    else ErrorDialog(SafeFormat(_('Application path not found:'+sLineBreak+'%s'),[AppPath]));
    end;
  end;

procedure TfrmMain.actShowManExecute(Sender: TObject);
var
  n : integer;
  se,st : string;
begin
  n:=CurrentAppIndex;
  if (n>=0) then with Apps[n] as TDosBoxApp do begin
    if FileExists(ManFile) then begin
      st:=_('Manual for ')+AppName;
      se:=GetExt(ManFile);
      if AnsiSameText(se,'htm') or AnsiSameText(se,'html') then with HtManWin do begin
        if Visible then BringToFront else Execute (self,st,ManFile,'',false,TextToShortCut('F1'));
        end
      else if AnsiSameText(se,'txt') then
        ShowTextDialog.Execute (st,ManFile,'','','','','','',_('All')+'|*.*',
          Point(Left+20,Top+20),1,stShow,[sbPrint,sbSearch,sbCodepage],BasicSettings.Codepage)
      else ShellExecute(0,'open',pchar(ManFile),nil,pchar(ExtractFilePath(ManFile)),SW_SHOWNORMAL)
      end
    else ErrorDialog(SafeFormat(_('Manual not found (%s)!'),[AppName]));
    end;
  end;

procedure TfrmMain.actConvertTextExecute(Sender: TObject);
begin
  with BasicSettings do TxtConvertDialog.Execute(RootPath,Codepage);
  end;

procedure TfrmMain.actMapperExecute(Sender: TObject);
var
  sCfg,
  sc,s,sa : string;
  n       : integer;
  cl      : TConfigList;
begin
  n:=CurrentAppIndex;
  if (n>=0) then with Apps[n] as TDosBoxApp do begin
  // check for basic configuration (local or global)
    if AppConfig then sCfg:=AddPath(AppPath,sConfig) else sCfg:=BasicSettings.ConfFile;
    if not FileExists(sCfg) and not ConfirmDialog(_('Basic configuration file not found! Start application anyway?')) then Exit;
  // write overlay conf file
    sc:=SetDirName(AppPath)+ConfName;
    cl:=TConfigList.Create(sc);
    cl.AddSection(secSdl);
    sa:=MakeAbsolutePath(ExtractFilePath(BasicSettings.ConfFile),BasicSettings.MapperFile);
    if (length(AppMapper)=0) or (SameFileName(sa,AppMapper)) then begin // new keymapper
      AppMapper:=AddPath(AppPath,sMapper);
      if FileExists(sa) then CopyFileTS(sa,AppMapper);
      end;
    cl.AddValue(cfgMapF,AppMapper);
    with BasicSettings do begin
      cl.AddSection(secDBox);
      if FileExists(LangFile) then cl.AddValue(cfgLang,LangFile);
      cl.AddSection(secDos);
      if length(KeyLayout)=0 then s:='auto' else s:=KeyLayout;
      cl.AddValue(cfgKeyb,s);
      end;
    cl.AddSection(secExec);
    if DirectoryExists(AppPath) then cl.Add(cfgMount+Space+HardDrv+
         Space+MakeQuotedStr(AppPath));
    cl.Add(cfgExit);   // auto end
    with cl do begin
      Save; Free;
      end;
    // start DosBox and enter keymapper
    sa:=AddPath(BasicSettings.DosBoxPath,sDosBox);
    if FileExists(sa) then begin
      s:=MakeQuotedStr(sa)+' -startmapper';
      if FileExists(sCfg) then s:=s+' -conf '+MakeQuotedStr(sCfg);
      s:=s+' -conf '+MakeQuotedStr(sc);
      StartProcess(s,AppPath)
      end
    else ErrorDialog(SafeFormat(_('%s not found! Please adjust your global settings!'),[sDosBox]));
    end;
  end;

procedure TfrmMain.actDosBoxExecute(Sender: TObject);
var
  sc : string;
begin
  // start DosBox
  sc:=AddPath(BasicSettings.DosBoxPath,sDosBox);
  if FileExists(sc) then with BasicSettings do begin
    sc:=MakeQuotedStr(sc);
    if FileExists(LangFile) then sc:=sc+' -lang '+MakeQuotedStr(LangFile);
    if FileExists(ConfFile) then sc:=sc+' -conf '+MakeQuotedStr(ConfFile);
    if length(KeyLayout)> 0 then sc:=sc+' -c '+MakeQuotedStr('KEYB '+KeyLayout);
    StartProcess(sc,RootPath)
    end
  else ErrorDialog(SafeFormat(_('%s not found! Please adjust your global settings!'),[sDosBox]));
  end;

end.
