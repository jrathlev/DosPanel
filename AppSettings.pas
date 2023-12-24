(* DosPanel - Windows GUI for DOSBox
   =================================
   Application specific settings
   -----------------------------

   © J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   J. Rathlev, Dec. 2011
   last modified: Dec. 2023
   *)

unit AppSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Imaging.pngimage, CheckBoxes;

const
  defCycles = 4000;
  maxCycles = 1000000;

type
  TImgType = (imNone,imIco,imBmp,imPng);

const
  ImageExt : array[TImgType] of string = ('','ico','bmp','png');
  ChannelCount = 7;
  MixerChannels : array[0..ChannelCount-1] of string = ('MASTER','DISNEY','SPKR','GUS','SB','FM','CDAUDIO');

  // Conf file parameter
  secSdl  = 'sdl';
  cfgFull = 'fullscreen';
  cfgMapF = 'mapperfile';
  cfgOutp = 'output';               //*
  cfgScan = 'usescancodes';         //'

  secDBox = 'dosbox';
  cfgLang = 'language';
  cfgMSz  = 'memsize';

  secRender = 'render';
  cfgScaler = 'scaler';           //*

  secCPU  = 'cpu';
  cfgCycl = 'cycles';

  secDos  = 'dos]';
  cfgKeyb = 'keyboardlayout';

  secExec  = 'autoexec';
  cfgMount = 'MOUNT';
  cfgImgMt = 'IMGMOUNT';
  cfgExit  = 'EXIT';

  sAuto = 'auto';
  sMax  = 'max';
  sFixed = 'fixed';
  sConfig = 'dosbox.conf';
  sMapper = 'appmapper.map';
  sDosBox = 'DosBox.exe';

type
  TAppIcons = class(TPicture)
  private
    FImgType : TImgType;
    DefLImg,DefSImg   : TPicture;
    function GetSmallImage (Img : TPicture): TBitmap; overload;
    function GetSmallImage (Img : TIcon): TBitmap; overload;
  public
    Small    : TBitmap;
    constructor Create (AImgType : TImgType; DefLargeImg,DefSmallImg : TPicture);
    constructor CreateFrom (Icons : TAppIcons);
    destructor Destroy; override;
    procedure Assign (Icons : TAppIcons);
    procedure AssignIcon (Icon : TIcon);
    procedure LoadFromFile (const Filename : string);
    property ImgType : TImgType read FImgType write FImgType;
    end;

  TDosBoxApp = class(TObject)
  private
    DefLImg,DefSImg   : TPicture;
    FConfigFile       : string;
    procedure InitIcons;
  public
    AppName,Category,
    AppPath,CdPath,
    AppFile,Parameters,
    Commands,AppMapper,
    IconFile,ManFile,
    Description,
    MixerChannels     : string;
    HardDrv,CdDrv     : Char;
    MountCd,
    IsoImage,
    FullScreen,
    AutoEnd,
    AppConfig         : boolean;
    CodePage,
    ImgIndex,
    MemSize,
    Speed             : integer;
    Icons             : TAppIcons;
    constructor Create (const AConfigFile : string; DefLargeImg,DefSmallImg : TPicture; DefCodePage : integer);
    destructor Destroy; override;
    procedure Assign (ADosBoxApp : TDosBoxApp);
    procedure LoadIcons (const Filename : string);
    procedure LoadConfig (AConfigFile : string = '');
    procedure CopyConfig (const AConfigFile : string);
    end;

  TAppSettingsDialog = class(TForm)
    btbCancel: TBitBtn;
    btbOK: TBitBtn;
    Label1: TLabel;
    cbCategory: TComboBox;
    edAppName: TLabeledEdit;
    edIconFile: TLabeledEdit;
    edManFile: TLabeledEdit;
    OpenDialog: TOpenDialog;
    btExeFile: TSpeedButton;
    btIconFile: TSpeedButton;
    btManFile: TSpeedButton;
    imgIcon: TImage;
    edDescription: TLabeledEdit;
    cxFullScreen: TCheckBox;
    edParam: TLabeledEdit;
    gbOptions: TGroupBox;
    cxAutoEnd: TCheckBox;
    edExeFile: TLabeledEdit;
    btPath: TSpeedButton;
    edCommands: TLabeledEdit;
    btCommands: TSpeedButton;
    cbHardDrive: TComboBox;
    cbCdRomDrive: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    edAppPath: TEdit;
    edIsoFile: TEdit;
    Label6: TLabel;
    cbMemSize: TComboBox;
    rbDrive: TRadioButton;
    rbIsoIMage: TRadioButton;
    btIsoFile: TSpeedButton;
    cbDrive: TComboBox;
    gbHardDrive: TGroupBox;
    pnIsoFile: TPanel;
    edMapperFile: TLabeledEdit;
    btMapper: TSpeedButton;
    rgConfig: TRadioGroup;
    paSettings: TPanel;
    gbCdDrive: TCheckGroupBox;
    bbEditConfig: TBitBtn;
    bbReset: TBitBtn;
    Label2: TLabel;
    cbCycles: TComboBox;
    pcSettings: TPageControl;
    tsGeneral: TTabSheet;
    tsAudio: TTabSheet;
    paAudio: TPanel;
    cbChannels: TComboBox;
    Label3: TLabel;
    tbRight: TTrackBar;
    tbLeft: TTrackBar;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    bbAddMixer: TBitBtn;
    bbRemMixer: TBitBtn;
    bbClearMixer: TBitBtn;
    lbMixerSettings: TListBox;
    cbConnect: TCheckBox;
    Label12: TLabel;
    Label13: TLabel;
    gbVolume: TGroupBox;
    bbUp: TBitBtn;
    bbDown: TBitBtn;
    btRebuild: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btPathClick(Sender: TObject);
    procedure btExeFileClick(Sender: TObject);
    procedure btIsoFileClick(Sender: TObject);
    procedure btIconFileClick(Sender: TObject);
    procedure btManFileClick(Sender: TObject);
    procedure edAppPathChange(Sender: TObject);
    procedure btCommandsClick(Sender: TObject);
    procedure cbHardDriveCloseUp(Sender: TObject);
    procedure rbDriveClick(Sender: TObject);
    procedure rbIsoIMageClick(Sender: TObject);
    procedure btMapperClick(Sender: TObject);
    procedure rgConfigClick(Sender: TObject);
    procedure bbEditConfigClick(Sender: TObject);
    procedure bbResetClick(Sender: TObject);
    procedure tbLeftChange(Sender: TObject);
    procedure tbRightChange(Sender: TObject);
    procedure bbAddMixerClick(Sender: TObject);
    procedure bbRemMixerClick(Sender: TObject);
    procedure bbClearMixerClick(Sender: TObject);
    procedure lbMixerSettingsClick(Sender: TObject);
    procedure bbUpClick(Sender: TObject);
    procedure bbDownClick(Sender: TObject);
    procedure btRebuildClick(Sender: TObject);
  private
    { Private-Deklarationen }
    NewIcons   : TAppIcons;
    FDosBoxApp : TDosBoxApp;
    LastDrive : string;
    procedure GetCdDrives;
    procedure ChangeCdRom (IsIso : boolean);
    procedure ShowMixerChannel (AIndex : integer);
    procedure ShowConfig;
  public
    { Public-Deklarationen }
    function Execute (Categories : TStrings;
                      var DosBoxApp : TDosBoxApp) : boolean;
  end;

function MiscName : string;
function ScaleBitmap(ABitmap: TBitmap; AWidth,AHeight : integer) : TBitMap;

var
  AppSettingsDialog: TAppSettingsDialog;

implementation

{$R *.dfm}

uses Winapi.ShellApi, System.StrUtils, System.IniFiles,
  DosPanelMain, GnuGetText, WinUtils, MsgDialogs, FileCopy,
  PathUtils, ShellDirDlg, SelectFromListDlg, WinDevUtils, StringUtils;

const
  MemSizeList : array [0..4] of word = (8,16,32,48,64);

{ ------------------------------------------------------------------- }
function MiscName : string;
begin
  Result:=_('Miscellaneous');
  end;

function ScaleBitmap(ABitmap: TBitmap; AWidth,AHeight : integer) : TBitMap;
begin
  ABitmap.Transparent:=true;
  Result:=TBitmap.Create;
  with Result do begin
    SetSize(AWidth,AHeight);
    TransparentMode:=tmAuto;
    Canvas.StretchDraw(Rect(0,0,AWidth,AHeight),ABitmap);  // scale
    Transparent:=true;
    end;
  end;

{ ------------------------------------------------------------------- }
constructor TAppIcons.Create (AImgType : TImgType; DefLargeImg,DefSmallImg : TPicture);
begin
  inherited Create;
  FImgType:=AImgType;
  DefLImg:=DefLargeImg; DefSImg:=DefSmallImg;
  AssignIcon(DefLargeImg.Icon);
  Small:=GetSmallImage(DefSmallImg);
  end;

constructor TAppIcons.CreateFrom (Icons : TAppIcons);
begin
  inherited Create;
  Assign(Icons);
  end;

procedure TAppIcons.Assign (Icons : TAppIcons);
begin
  FImgType:=Icons.ImgType;
  DefLImg:=Icons.DefLImg;
  DefSImg:=Icons.DefSImg;
  inherited Assign(Icons.Graphic);
  Small:=TBitmap.Create;
  Small.Assign(Icons.Small);
  end;

procedure TAppIcons.AssignIcon (Icon : TIcon);
begin
  ImgType:=imIco;
  inherited Assign(Icon);
  end;

destructor TAppIcons.Destroy;
begin
  if assigned(Small) then Small.Free;
  inherited Destroy;
  end;

function TAppIcons.GetSmallImage (Img : TPicture): TBitmap;
begin
  Result:=TBitmap.Create;
  with Result do begin
    SetSize(Img.Width,Img.Height);
    TransparentMode:=tmAuto; Transparent:=true;
    Canvas.Draw(0,0,Img.Graphic);
    end;
  end;

function TAppIcons.GetSmallImage (Img : TIcon): TBitmap;
begin
  Result:=TBitmap.Create;
  with Result do begin
    SetSize(Img.Width,Img.Height);
    TransparentMode:=tmAuto; Transparent:=true;
    Canvas.Draw(0,0,Img);
    end;
  end;

procedure TAppIcons.LoadFromFile (const Filename : string);
var
  ic : TIcon;
  bj : TPicture;

  function GetFileIcon(const FileName: string; const Small: Boolean): TIcon;
  var
    FI: TSHFileInfo;
    Attributes: DWORD;
    Flags: Word;
  begin
    Attributes := 0;
    Flags := SHGFI_ICON;
    if Small then Flags:=Flags or SHGFI_SMALLICON else Flags:=Flags or SHGFI_LARGEICON;
    if SHGetFileInfo(PChar(FileName), Attributes, FI, SizeOf(FI), Flags) <> 0 then begin
      Result := TIcon.Create;
      Result.Handle := FI.hIcon;
      end
    else Result:=nil;
    end;

  function ScalePng(APng: TGraphic; AWidth,AHeight : integer) : TBitMap;
  var
    bm : TBitMap;
  begin
    bm:=TBitmap.Create;
    bm.PixelFormat:=pf16Bit;
    (APng as TPngImage).AssignTo(bm);
    Result:=ScaleBitmap(bm,AWidth,AHeight);
    bm.Free;
    end;

  function ScaleIcon (AIcon : TIcon; AWidth,AHeight : integer) : TBitMap;
  var
    bm : TBitMap;
  begin
    bm:=TBitmap.Create;
    with bm do begin
      SetSize(AIcon.Width,AIcon.Height);
      TransparentMode:=tmFixed;
      TransparentColor:=clWhite;
      Transparent:=true;
      with Canvas do begin
        Brush.Color:=clWhite;          // background
        Draw(0,0,AIcon);               // copy to bitmap
        end;
      Transparent:=TransparentColor=clWhite;
      end;
    Result:=TBitmap.Create;
    with Result do begin
      SetSize(AWidth,AHeight);
      TransparentMode:=tmFixed;
      Canvas.StretchDraw(Rect(0,0,AWidth,AHeight),bm);  // scale
      Transparent:=bm.Transparent;
      end;
    bm.Free;
    end;

  function GeTImgType (const Filename : string) : TImgType;
  var
    ext : string;
    it  : TImgType;
  begin
    ext:=GetExt(Filename);
    Result:=imNone;
    for it:=imIco to High(TImgType) do if AnsiSameText(ext,ImageExt[it]) then begin
      Result:=it; Break;
      end;
    end;

begin
  if FileExists(Filename) then begin
    ImgType:=GetImgType(Filename);
    if ImgType=imNone then begin
      ic:=GetFileIcon(Filename,false);
      if assigned(ic) then begin
        AssignIcon(ic); ic.Free;
        ic:=GetFileIcon(Filename,true);
        if assigned(ic) then begin
          Small:=GetSmallImage(ic); ic.Free;
          end
        else Small:=ScaleIcon(Icon,16,16);
        end
      else begin
        AssignIcon(DefLImg.Icon);
        Small:=GetSmallImage(DefSImg);
        end;
      end
    else if ImgType=imPng then begin
      bj:=TPicture.Create;
      bj.LoadFromFile(Filename);
      Bitmap.PixelFormat:=pf16Bit;
      (bj.Graphic as TPngImage).AssignTo(Bitmap);
      Small:=ScaleBitmap(Bitmap,16,16);
      bj.Free;
      end
    else begin
      inherited LoadFromFile(Filename);
      if ImgType=imIco then Small:=ScaleIcon(Icon,16,16)
      else Small:=ScaleBitmap(Bitmap,16,16)
      end;
    end
  else begin
    ImgType:=imIco;
    AssignIcon(DefLImg.Icon);
    Small:=GetSmallImage(DefSImg);
    end;
  end;

{ ------------------------------------------------------------------- }
constructor TDosBoxApp.Create(const AConfigFile : string; DefLargeImg,DefSmallImg : TPicture; DefCodePage : integer);
begin
  inherited Create;
  FConfigFile:=AConfigFile;
  AppName:=''; Category:='';
  AppPath:=''; CdPath:='';
  HardDrv:='C'; CdDrv:='D';
  AppFile:=''; Parameters:='';
  IconFile:=''; ManFile:='';
  Commands:=HardDrv+':;"CD \"';
  Description:=''; MixerChannels:='';
  MountCd:=true; IsoImage:=true;
  LoadConfig;
  AutoEnd:=true; AppMapper:='';
  AppConfig:=false; ImgIndex:=-1; CodePage:=DefCodePage;
  DefLImg:=DefLargeImg; DefSImg:=DefSmallImg;
  InitIcons;
  end;

destructor TDosBoxApp.Destroy;
begin
  if assigned(Icons) then Icons.Free;
  inherited Destroy;
  end;

procedure TDosBoxApp.LoadConfig (AConfigFile : string);
var
  s : string;
begin
  if length(AConfigFile)=0 then AConfigFile:=FConfigFile;
  with TIniFile.Create(AConfigFile) do begin
    FullScreen:=ReadBool(secSdl,cfgFull,false);
    s:=ReadString(secSdl,cfgMapF,'');
    AppMapper:=MakeAbsolutePath(ExtractFilePath(AConfigFile),s);
    if (length(AppMapper)>0) and not FileExists(AppMapper) then
      AppMapper:=MakeAbsolutePath(ExtractFilePath(FConfigFile),s);
    MemSize:=ReadInteger(secDBox,cfgMSz,16);
    s:=ReadString(secCPU,cfgCycl,sAuto);
    if AnsiStartsText(s,sAuto) then Speed:=0
    else if AnsiStartsText(s,sMax) then Speed:=maxCycles
    else Speed:=-1;
    Free;
    end;
  end;

procedure TDosBoxApp.CopyConfig (const AConfigFile : string);
begin
  CopyFileTs(FConfigFile,AConfigFile);
  end;

procedure TDosBoxApp.Assign (ADosBoxApp : TDosBoxApp);
begin
  AppName:=ADosBoxApp.AppName;
  Category:=ADosBoxApp.Category;
  AppPath:=ADosBoxApp.AppPath;
  CdPath:=ADosBoxApp.CdPath;
  HardDrv:=ADosBoxApp.HardDrv;
  CdDrv:=ADosBoxApp.CdDrv;
  AppFile:=ADosBoxApp.AppFile;
  Parameters:=ADosBoxApp.Parameters;
  IconFile:=ADosBoxApp.IconFile;
  ManFile:=ADosBoxApp.ManFile;
  CodePage:=ADosBoxApp.CodePage;
  AppMapper:=ADosBoxApp.AppMapper;
  Commands:=ADosBoxApp.Commands;
  Description:=ADosBoxApp.Description;
  MixerChannels:=ADosBoxApp.MixerChannels;
  MountCd:=ADosBoxApp.MountCd;
  IsoImage:=ADosBoxApp.IsoImage;
  AppConfig:=ADosBoxApp.AppConfig;
  FullScreen:=ADosBoxApp.FullScreen;
  AutoEnd:=ADosBoxApp.AutoEnd;
  Speed:=ADosBoxApp.Speed;
  ImgIndex:=ADosBoxApp.ImgIndex;
  DefLImg:=ADosBoxApp.DefLImg;
  DefSImg:=ADosBoxApp.DefSImg;
  Icons.Assign(ADosBoxApp.Icons);
  end;

procedure TDosBoxApp.InitIcons;
begin
  Icons:=TAppIcons.Create(imIco,DefLImg,DefSImg);
  end;

procedure TDosBoxApp.LoadIcons(const Filename : string);
begin
  Icons.LoadFromFile(Filename);
  end;

{ ------------------------------------------------------------------- }
procedure TAppSettingsDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
  GetCdDrives;
  LastDrive:='';
  with lbMixerSettings.Items do begin
    QuoteChar:=Quote; Delimiter:=Semicolon;
    end;
  end;

procedure TAppSettingsDialog.GetCdDrives;
var
  dl : TStringList;
  i  : integer;
begin
  dl:=TStringList.Create;
  BuildDriveList(dl,[dtCdRom]);
  cbDrive.Clear;
  with dl do begin
    for i:=0 to Count-1 do cbDrive.Items.Add(Strings[i]+' ('+(Objects[i] as TDriveProperties).DriveName+')');
    end;
  with cbDrive do if Items.Count>0 then ItemIndex:=0;
  FreeListObjects(dl);
  dl.Free;
  end;

procedure TAppSettingsDialog.ChangeCdRom (IsIso : boolean);
begin
  if not IsIso then begin
    if (cbDrive.Items.Count>0) then begin
      cbDrive.Visible:=true;
      pnIsoFile.Visible:=false;
      rbDrive.Checked:=true;
      end
    else begin
      ErrorDialog(_('No physical CD drives available!'));
      IsIso:=true;
      end;
    end;
  if IsIso then begin
    cbDrive.Visible:=false;
    pnIsoFile.Visible:=true;
    rbIsoIMage.Checked:=true;
    end;
  end;

procedure TAppSettingsDialog.ShowMixerChannel (AIndex : integer);
var
  s,sc : string;
  i,nl,nr : integer;
begin
  with lbMixerSettings do if (AIndex>=0) and (AIndex<Count) then begin
    s:=Items[AIndex];
    sc:=Trim(ReadNxtStr(s,Space));
    for i:=0 to ChannelCount-1 do if AnsiSameText(sc,MixerChannels[i]) then Break;
    if i>=ChannelCount then i:=ChannelCount-1;
    cbChannels.ItemIndex:=i;
    nl:=ReadNxtInt(s,Colon,100); nr:=ReadNxtInt(s,Colon,100);
    cbConnect.Checked:=nl=nr;
    tbLeft.Position:=nl; tbRight.Position:=nr;
    end
  else begin
    cbChannels.ItemIndex:=ChannelCount-1; cbConnect.Checked:=true;
    tbLeft.Position:=50; tbRight.Position:=50;
    end;
  lbMixerSettings.ItemIndex:=AIndex;
  end;

procedure TAppSettingsDialog.tbLeftChange(Sender: TObject);
begin
  if cbConnect.Checked then tbRight.Position:=tbLeft.Position;
  end;

procedure TAppSettingsDialog.tbRightChange(Sender: TObject);
begin
  if cbConnect.Checked then tbLeft.Position:=tbRight.Position;
  end;

procedure TAppSettingsDialog.lbMixerSettingsClick(Sender: TObject);
begin
  ShowMixerChannel(lbMixerSettings.ItemIndex);
  end;

procedure TAppSettingsDialog.bbAddMixerClick(Sender: TObject);

  function IntRoundTo (val,n : integer) : integer;
  begin
    Result:=((val+n div 2) div n)*n;
    end;

begin
  with lbMixerSettings do ItemIndex:=Items.Add(MixerChannels[cbChannels.ItemIndex]
    +Space+IntToStr(IntRoundTo(tbLeft.Position,5))+Colon+IntToStr(IntRoundTo(tbRight.Position,5)));
  end;

procedure TAppSettingsDialog.bbRemMixerClick(Sender: TObject);
var
  n : integer;
begin
  with lbMixerSettings do begin
    n:=ItemIndex;
    Items.Delete(ItemIndex);
    if n>Items.Count then ItemIndex:=Items.Count-1 else ItemIndex:=n;
    ShowMixerChannel(ItemIndex);
    end;
  end;

procedure TAppSettingsDialog.bbClearMixerClick(Sender: TObject);
begin
  if ConfirmDialog (_('Remove all mixer settings?')) then begin
    lbMixerSettings.Clear;
    ShowMixerChannel(-1);
    end;
  end;

procedure TAppSettingsDialog.bbUpClick(Sender: TObject);
var
  n : integer;
begin
  with lbMixerSettings,Items do if (Count>0) and (ItemIndex>0) then begin
    n:=ItemIndex;
    Exchange(n,n-1);
    ItemIndex:=n-1;
    end;
  end;

procedure TAppSettingsDialog.bbDownClick(Sender: TObject);
var
  n : integer;
begin
  with lbMixerSettings,Items do if (Count>0) and (ItemIndex<Count-1) then begin
    n:=ItemIndex;
    Exchange(n,n+1);
    ItemIndex:=n+1;
    end;
  end;

procedure TAppSettingsDialog.ShowConfig;
var
  i : integer;
begin
  with FDosBoxApp do begin
    cxFullScreen.Checked:=FullScreen;
    cxAutoEnd.Checked:=AuToEnd;
    edMapperFile.Text:=AppMapper;
    for i:=0 to High(MemSizeList) do if MemSize<=MemSizeList[i] then Break;
    with cbMemSize do if i>High(MemSizeList) then Itemindex:=1 else Itemindex:=i;
    with cbCycles do begin
      case Speed of
      0 : ItemIndex:=0;
      maxCycles: ItemIndex:=1;
      5000  : ItemIndex:=2;
      10000 : ItemIndex:=3;
      25000 : ItemIndex:=4;
      50000 : ItemIndex:=5;
      else ItemIndex:=6;
        end;
      end;
    end;
  end;

procedure TAppSettingsDialog.rbDriveClick(Sender: TObject);
begin
  if Visible then ChangeCdRom(false);
  end;

procedure TAppSettingsDialog.rbIsoIMageClick(Sender: TObject);
begin
  if Visible then ChangeCdRom(true);
  end;

procedure TAppSettingsDialog.rgConfigClick(Sender: TObject);
var
  sc : string;
begin
  if not Visible then Exit;
  if rgConfig.ItemIndex=1 then begin
    bbEditConfig.Enabled:=true;
    if DirectoryExists(edAppPath.Text) then begin
      sc:=AddPath(edAppPath.Text,sConfig);
      if FileExists(sc) then begin
        FDosBoxApp.LoadConfig(sc);
        ShowConfig;
        end
      else with FDosBoxApp do begin
        CopyConfig(sc); LoadConfig(sc);
        ShowConfig;
        end;
      end;
    end
  else begin
    bbEditConfig.Enabled:=false;
    FDosBoxApp.LoadConfig;
    ShowConfig;
    end;
  end;

procedure TAppSettingsDialog.btIconFileClick(Sender: TObject);
begin
  with OpenDialog do begin
    if length(edIconFile.Text)>0 then InitialDir:=GetExistingParentPath(edIconFile.Text,frmMain.BasicSettings.RootPath)
    else InitialDir:=edAppPath.Text;
    DefaultExt:='ico';
    Filename:='';
    Filter:=_('Image')+'|*.ico;*.bmp;*.png|'+_('Executables')+'|*.exe;*.dll|'+_('All')+'|*.*';
    Title:=_('Select file with icon for this application');
    if Execute then begin
      edIconFile.Text:=Filename;
      NewIcons.LoadFromFile(Filename);
      imgIcon.Picture.Assign(NewIcons);
      end;
    end;
  end;

procedure TAppSettingsDialog.btIsoFileClick(Sender: TObject);
begin
  with OpenDialog do begin
    if length(edIsoFile.Text)>0 then InitialDir:=ExtractFilePath(edIsoFile.Text)
    else InitialDir:=edAppPath.Text;
    DefaultExt:='iso';
    Filename:='';
    Filter:=_('ISO images')+'|*.iso;*.cue';
    Title:=SafeFormat(_('Select iso image to be mounted as drive %s'),[cbCdRomDrive.Text]);
    if Execute then edIsoFile.Text:=Filename;
    end;
  end;

procedure TAppSettingsDialog.btManFileClick(Sender: TObject);
begin
  with OpenDialog do begin
    if length(edManFile.Text)>0 then InitialDir:=ExtractFilePath(edManFile.Text)
    else InitialDir:=edAppPath.Text;
    DefaultExt:='txt';
    Filename:='';
    Filter:=_('Text files')+'|*.txt|'+_('HTML files')+'|*.htm;*.html|'+
            _('PDF files')+'|*.pdf|'+_('All')+'|*.*';
    Title:=_('Select manual for this application');
    if Execute then edManFile.Text:=Filename;
    end;
  end;

procedure TAppSettingsDialog.btMapperClick(Sender: TObject);
var
  sp,sc : string;
begin
  with OpenDialog do begin
    if rgConfig.ItemIndex=0 then sc:=ExtractFilePath(FDosBoxApp.FConfigFile)
    else sc:=edAppPath.Text;
    sp:=ExtractFilePath(edMapperFile.Text);
    if length(sp)>0 then InitialDir:=sp else InitialDir:=sc;
    DefaultExt:='map';
    Filename:='';
    Filter:=_('DOSBox key mapper files')+'|*.map;*.txt|'+_('All')+'|*.*';
    Title:=_('Select key mapper file');
    if Execute then edMapperFile.Text:=Filename;
//      if AnsiSameText(ExtractFilePath(Filename),sc) then edMapperFile.Text:=ExtractFileName(Filename)
//      else edMapperFile.Text:=Filename;
//      end;
    end;
  end;

procedure TAppSettingsDialog.bbEditConfigClick(Sender: TObject);
var
  sc : string;
  ok : boolean;
begin
  sc:=AddPath(edAppPath.Text,sConfig);
  ok:=FileExists(sc);
  if not ok then begin
    if ConfirmDialog(_('No application specific configuration found!'+sLineBreak+
        'Copy global configuration to application path?')) then begin
      FDosBoxApp.CopyConfig(sc);
      ok:=true;
      end
    else ok:=false;
    end;
  if ok then begin
    if succeeded(ShellExecute (Application.Handle,'open',PChar(MakeQuotedStr(frmMain.BasicSettings.TextEditor,[' '])),
        PChar(MakeQuotedStr(sc,[' '])),nil,SW_RESTORE)) then begin
      FDosBoxApp.LoadConfig(AddPath(edAppPath.Text,sConfig));
      ShowConfig;
      end;
    end;
  end;

procedure TAppSettingsDialog.bbResetClick(Sender: TObject);
var
  s : string;
begin
  if rgConfig.ItemIndex=1 then s:=AddPath(edAppPath.Text,sConfig) else s:='';
  with FDosBoxApp do begin
    LoadConfig(s);
    AutoEnd:=true;
    end;
  ShowConfig;
  end;

procedure TAppSettingsDialog.btCommandsClick(Sender: TObject);
var
  sl : TStringList;
  s  : string;
begin
  sl:=TStringList.Create;
  with sl do begin
    QuoteChar:=Quote; Delimiter:=Semicolon;
    DelimitedText:=edCommands.Text;
    end;
  if SelectFromListDialog.Execute(CursorPos,_('Edit startup commands'),_('List of commands'),'',
              [soEdit,soOrder],1,tcNone,'',sl,s)=mrOK then edCommands.Text:=sl.DelimitedText;
  sl.Free;
  end;

procedure TAppSettingsDialog.btExeFileClick(Sender: TObject);
begin
  with OpenDialog do begin
    if length(edExeFile.Text)>0 then
      InitialDir:=SetDirName(edAppPath.Text)+ExtractFilePath(edExeFile.Text)
    else InitialDir:=edAppPath.Text;
    DefaultExt:='exe';
    Filename:='';
    Filter:=_('Executables')+'|*.exe;*.com|'+_('Batch files')+'|*.bat|'+_('All')+'|*.*';
    Title:=_('Select executable for startup');
    if Execute then begin
      if IsSubPath(edAppPath.Text,Filename) then
        edExeFile.Text:=MakeRelativePath(SetDirName(edAppPath.Text),Filename)
      else ErrorDialog(SafeFormat(_('The executable file must be located beneath the root path:'+
        sLineBreak+'%s'+sLineBreak+'Please try again!'),[edAppPath.Text]));
      end;
    end;
  end;

procedure TAppSettingsDialog.btPathClick(Sender: TObject);
var
  s : string;
begin
  s:=GetExistingParentPath(edAppPath.Text,frmMain.BasicSettings.RootPath);
  if length(s)=0 then s:=frmMain.BasicSettings.RootPath;
  if ShellDirDialog.Execute (SafeFormat(_('Select path to be mounted as drive %s'),[cbHardDrive.Text]),
      false,true,false,frmMain.BasicSettings.RootPath,s) then edAppPath.Text:=s;
  end;

procedure TAppSettingsDialog.btRebuildClick(Sender: TObject);
begin
  GetCdDrives;
  end;

procedure TAppSettingsDialog.cbHardDriveCloseUp(Sender: TObject);
begin
  with edCommands do Text:=AnsiReplaceText(Text,LastDrive+':',cbHardDrive.Text[1]+':');
  LastDrive:=cbHardDrive.Text;
  end;

procedure TAppSettingsDialog.edAppPathChange(Sender: TObject);
var
  ok : boolean;
begin
  ok:=DirectoryExists(edAppPath.Text);
  edExeFile.Enabled:=ok;
  btExeFile.Enabled:=ok;
  edParam.Enabled:=ok;
  edIconFile.Enabled:=ok;
  btIconFile.Enabled:=ok;
  edMapperFile.Enabled:=ok;
  end;

function TAppSettingsDialog.Execute (Categories : TStrings;
                                     var DosBoxApp : TDosBoxApp) : boolean;
var
  i,n : integer;
begin
  with cbCategory do begin
    Clear;
    for i:=0 to Categories.Count-1 do Items.AddObject(Categories[i],pointer(i));
    end;
  FDosBoxApp:=DosBoxApp;
  with DosBoxApp do begin
    edAppname.Text:=AppName;
    with cbCategory do ItemIndex:=Items.IndexOf(Category);
    edAppPath.Text:=AppPath;
    with cbHardDrive do begin
      n:=Items.IndexOf(HardDrv);
      if n>=0 then ItemIndex:=n else ItemIndex:=2;
      end;
    LastDrive:=cbHardDrive.Text;
    with cbCdRomDrive do begin
      n:=Items.IndexOf(CdDrv);
      if n>=0 then ItemIndex:=n else ItemIndex:=3;
      end;
    ChangeCdRom(IsoImage);
    gbCdDrive.Checked:=MountCd;
    if IsoImage then edIsoFile.Text:=CdPath
    else with cbDrive do ItemIndex:=Items.IndexOf(CdPath);
    edExeFile.Text:=AppFile;
    edParam.Text:=Parameters;
    edCommands.Text:=Commands;
    edIconFile.Text:=IconFile;
    edManFile.Text:=ManFile;
    edDescription.Text:=Description;
    lbMixerSettings.Items.DelimitedText:=MixerChannels;
    cxAutoEnd.Checked:=AutoEnd;
    ShowMixerChannel(0);
    ShowConfig;
    with rgConfig do if AppConfig then ItemIndex:=1 else ItemIndex:=0;
    with bbEditConfig do begin
      Visible:=FileExists(frmMain.BasicSettings.TextEditor);
      Enabled:=AppConfig;
      end;
    imgIcon.Picture.Assign(Icons);
    NewIcons:=TAppIcons.CreateFrom(Icons);
    pcSettings.ActivePage:=tsGeneral;
    Result:=ShowModal=mrOK;
    if Result then begin
      AppName:=edAppname.Text;
      Category:=cbCategory.Text;
      if AnsiSameText(Category,MiscName) then Category:='';
      if length(Category)>0 then
        with cbCategory.Items do if IndexOf(Category)<0 then Add(Category);
      AppPath:=edAppPath.Text;
      HardDrv:=cbHardDrive.Text[1];
      CdDrv:=cbCdRomDrive.Text[1];
      MountCd:=gbCdDrive.Checked;
      IsoImage:=rbIsoImage.Checked;
      if IsoImage then CdPath:=edIsoFile.Text else CdPath:=cbDrive.Text;
      AppFile:=edExeFile.Text;
      Parameters:=edParam.Text;
      Commands:=edCommands.Text;
      IconFile:=edIconFile.Text;
      AppMapper:=edMapperFile.Text;
      ManFile:=edManFile.Text;
      Description:=edDescription.Text;
      MixerChannels:=lbMixerSettings.Items.DelimitedText;
      FullScreen:=cxFullScreen.Checked;
      AutoEnd:=cxAutoEnd.Checked;
      MemSize:=MemSizeList[cbMemSize.ItemIndex];
      case cbCycles.ItemIndex of
      0 : Speed:=0;
      1 : Speed:=maxCycles;
      2 : Speed:=5000;
      3 : Speed:=10000;
      4 : Speed:=25000;
      5 : Speed:=50000;
      else Speed:=-1;
        end;
      AppConfig:=rgConfig.ItemIndex=1;
      Icons.Assign(NewIcons);
      end;
    NewIcons.Free;
    end;
  end;

end.
