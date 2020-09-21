(* Delphi Dialog
   Verzeichniswahldialog mit ShellTreeView
   =======================================
   Design �hnlich wie Windows-Datei-Dialog
   
   � Dr. J. Rathlev 24222 Schwentinental
     Web:  www.rathlev-home.de
     Mail: kontakt(a)rathlev-home.de

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   Vers. 1 - August 2003
   Vers. 1.1 - Sep. 2005 : changes for use with XpManifest (TPanel is transp.)
   Vers. 2.0 - Jun. 2006 : optional file window
   Vers. 2.1 - Jan. 2007 : starts on MyFiles if no directory specified
   Vers. 2.2 - Apr. 2008 : changes in ShellCtrls - see
                           http://www.kutinsoft.com/Hints/DelphiHints.php
   Vers. 2.3 - Sep. 2009 : history list for selected directories
   Vers. 2.4 - Mar. 2010 : adjustable window sizes
   Vers. 3.0 - Apr. 2012 : Delphi XE2
   Vers. 3.1 - Nov. 2015 : Delph 10, adaption to new shell control components
   last modified: January 2020
   *)

unit ShellDirDlg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Shell.ShellCtrls, Vcl.Menus;

const
  NetLink = 'target.lnk';

type
  TShellDirDialog = class(TForm)
    btbOK: TBitBtn;
    btbCancel: TBitBtn;
    ShellTreeView: TShellTreeView;
    spbNew: TSpeedButton;
    cbxSelectedDir: TComboBox;
    Label1: TLabel;
    spbUp: TSpeedButton;
    spbHome: TSpeedButton;
    panRoot: TPanel;
    spbNetwork: TSpeedButton;
    spbComputer: TSpeedButton;
    spbDesktop: TSpeedButton;
    spbMyFiles: TSpeedButton;
    cbxFiles: TCheckBox;
    ShellListView: TShellListView;
    PanelLeft: TPanel;
    PanelRight: TPanel;
    Panel1: TPanel;
    PopupMenu: TPopupMenu;
    itmDelete: TMenuItem;
    N1: TMenuItem;
    cancel1: TMenuItem;
    itmCreate: TMenuItem;
    itmUpdate: TMenuItem;
    Splitter: TSplitter;
    procedure ShellTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure spbDesktopClick(Sender: TObject);
    procedure spbMyFilesClick(Sender: TObject);
    procedure spbComputerClick(Sender: TObject);
    procedure spbNetworkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spbUpClick(Sender: TObject);
    procedure spbHomeClick(Sender: TObject);
    procedure spbNewClick(Sender: TObject);
    procedure btbOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ShellTreeViewClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbxFilesClick(Sender: TObject);
    procedure itmDeleteClick(Sender: TObject);
    procedure itmUpdateClick(Sender: TObject);
    procedure ShellTreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PopupMenuPopup(Sender: TObject);
    procedure cbxSelectedDirCloseUp(Sender: TObject);
    procedure cbxSelectedDirChange(Sender: TObject);
  private
    { Private declarations }
    FDefaultDir,FIniName,FIniSection : string;
    procedure NewColWidths (n1,n2,n3,n4 : integer);
    procedure ShowFiles (AShow : boolean);
    procedure AddHistory (ADir : string);
    procedure DeleteHistory (ADir : string);
    procedure SelectDir (const ADir : string);
  public
    { Public declarations }
    procedure LoadFromIni(IniName, Section : string);
    procedure ResetPosition;
    function Execute (const ATitle  : string;
                      Hidden,FileView,ZipAsFiles : boolean;
                      const HomeDir : string;
                      var Dir : string) : boolean;
  end;

procedure InitDirectoryDialog (const AIniName,ASection : string);
function DirectoryDialog (const ATitle  : string; Hidden,FileView  : boolean;
                          const HomeDir : string; var Dir : string) : boolean; overload;
function DirectoryDialog (const ATitle  : string; Hidden,FileView,ZipAsFiles  : boolean;
                          const HomeDir : string; var Dir : string) : boolean; overload;

var
  ShellDirDialog: TShellDirDialog;

implementation

{$R *.dfm}

uses System.IniFiles, Vcl.Dialogs, System.StrUtils, Winapi.ShlObj, Winapi.Shellapi,
  Winapi.ActiveX, ExtSysUtils, WmiUtils, WinShell, WinUtils, FileUtils, IniFileUtils,
  GnuGetText, SelectDlg;

const
  FMaxLen = 15;

var
  IniFileName,SectionName   : string;

{ ------------------------------------------------------------------- }
procedure TShellDirDialog.FormCreate(Sender: TObject);
begin
{$IFDEF Trace}
  WriteDebugLog('Create ShellDirDlg');
{$EndIf}
  TranslateComponent (self,'dialogs');
  NewColWidths(20,10,15,15);
  FIniName:='';
  FIniSection:='';
  FDefaultDir:='';
  panRoot.ParentBackground:=false;
  Top:=(Screen.Height-Height) div 2;
  Left:=(Screen.Width-Width) div 2;
  if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=10) then // Windows 10
    spbNetwork.Visible:=Smb1Installed;
  end;

{ ------------------------------------------------------------------- }
const
  iniHistory = 'History';
  iniFileView = 'Fileview';
  iniTop = 'Top';
  iniLeft = 'Left';
  iniHeight = 'Height';
  iniLWidth = 'DirWidth';
  iniRWidth= 'FileWidth';

(* load history list *)
procedure TShellDirDialog.LoadFromIni(IniName, Section : string);
var
  i       : integer;
  IniFile : TIniFile;
  s       : string;
begin
  FIniName:=IniName; FIniSection:=Section;
  cbxSelectedDir.Items.Clear;
  if FileExists(FIniName) and (length(FIniSection)>0) then begin
    IniFile:=TIniFile.Create(IniName);
    for i:=0 to FMaxLen-1 do begin
      s:=IniFile.ReadString(FIniSection,iniHistory+IntToStr(i),'');
      if s<>'' then cbxSelectedDir.AddItem(s,nil);
      end;
    with IniFile do begin
      Top:=ReadInteger(FIniSection,iniTop,0);
      Left:=ReadInteger(FIniSection,iniLeft,Left);
      Height:=ReadInteger(FIniSection,iniHeight,Height);
      with PanelLeft do Width:=ReadInteger(FIniSection,iniLWidth,Width);
      with PanelRight do Width:=ReadInteger(FIniSection,iniRWidth,Width);
      Splitter.Left:=PanelRight.Left;
      cbxFiles.Checked:=ReadBool(FIniSection,iniFileView,false);
      if Top=0 then begin
        Top:=(Screen.Height-Height) div 2;
        Left:=(Screen.Width-Width) div 2;
        end;
      Free;
      end;
    end;
  end;

procedure TShellDirDialog.ResetPosition;
begin
  Top:=50; Left:=50;
  end;

(* save history list *)
procedure TShellDirDialog.FormDestroy(Sender: TObject);
var
  i       : integer;
begin
  if (length(FIniName)>0) and (length(FIniSection)>0) then begin
    EraseSectionFromIniFile(FIniName,FIniSection);
    with cbxSelectedDir.Items do for i:=0 to Count-1 do
      WriteStringToIniFile(FIniName,FIniSection,iniHistory+IntToStr(i),Strings[i]);
    WriteIntegerToIniFile(FIniName,FIniSection,iniTop,Top);
    WriteIntegerToIniFile(FIniName,FIniSection,iniLeft,Left);
    WriteIntegerToIniFile(FIniName,FIniSection,iniHeight,Height);
    WriteIntegerToIniFile(FIniName,FIniSection,iniLWidth,PanelLeft.Width);
    WriteIntegerToIniFile(FIniName,FIniSection,iniRWidth,PanelRight.Width);
    WriteBoolToIniFile(FIniName,FIniSection,iniFileView,cbxFiles.Checked);
    UpdateIniFile(FIniName);
    end;
  end;

{ ------------------------------------------------------------------- }
(* add directory to history list *)
procedure TShellDirDialog.AddHistory (ADir : string);
begin
  with cbxSelectedDir.Items do begin
    if IndexOf(ADir)<0 then Add (ADir);
    end;
  end;

(* delete directory from history list *)
procedure TShellDirDialog.DeleteHistory (ADir : string);
var
  i : integer;
begin
  with cbxSelectedDir,Items do begin
    i:=IndexOf(ADir);
    if i>=0 then Delete (i);
    ItemIndex:=0;
    end;
  end;

// set column widths in number of characters
procedure TShellDirDialog.NewColWidths (n1,n2,n3,n4 : integer);
begin
  ShellListView.SetColWidths([MulDiv(n1,Screen.PixelsPerInch,PixelsPerInchOnDesign),
                        MulDiv(n2,Screen.PixelsPerInch,PixelsPerInchOnDesign),
                        MulDiv(n3,Screen.PixelsPerInch,PixelsPerInchOnDesign),
                        MulDiv(n4,Screen.PixelsPerInch,PixelsPerInchOnDesign)]);
  end;

{ ------------------------------------------------------------------- }
(* Initialize *)
procedure TShellDirDialog.FormShow(Sender: TObject);
begin
  FitToScreen(Screen,self);
  with spbHome do begin
    Visible:=FDefaultDir<>'';
    Hint:=dgettext('dialogs','Default: ')+FDefaultDir;
    end;
  with cbxSelectedDir do begin
    if Items.Count>0 then Style:=csDropDown else Style:=csSimple;
    end;
  end;


procedure TShellDirDialog.FormActivate(Sender: TObject);
begin
  with ShellTreeView do begin
//      Path:=cbxSelectedDir.Text;
    try
      Selected.MakeVisible;
    except
      end;
    SetFocus;
    end;
  end;

{------------------------------------------------------------------- }
(* go to parent directory *)
procedure TShellDirDialog.spbUpClick(Sender: TObject);
begin
  with ShellTreeView do begin
//    s:=SelectedFolder.Parent.PathName;
    if (Selected.Parent=nil) then begin
      Root:='rfMyComputer'; // Path:='';
      end
    else if (Selected.Parent.Level>0) then Path:=SelectedFolder.Parent.PathName;
    Selected.MakeVisible;
    SetFocus;
    end;
{  s:=cbxSelectedDir.Text;
  if (copy(s,1,2)<>'\\') or (PosEx('\',s,3)>0) then begin
    while s[length(s)]<>'\' do delete (s,length(s),1);
    delete (s,length(s),1);
    if length(s)>0 then begin
      if (length(s)=2) and (copy(s,2,1)=':') then begin
        ShellTreeView.Root:='rfMyComputer'; s:=s+'\';
        end;
      with ShellTreeView do begin
        Path:=s; Selected.MakeVisible;
        end;
      end;
    end;
  ShellTreeView.SetFocus;   }
  end;

(* go to home directory *)
procedure TShellDirDialog.spbHomeClick(Sender: TObject);
begin
  if not SetCurrentDir(FDefaultDir) then begin
    ErrorDialog(TryFormat(dgettext('dialogs','Directory not found:'+sLineBreak+'%s!'),[FDefaultDir]));
    DeleteHistory(FDefaultDir);
    end
  else with ShellTreeView do begin
    if (Root='rfNetwork') or ((length(FDefaultDir)=3) and (copy(FDefaultDir,2,2)=':\')) then Root:=FDefaultDir
    else begin
      Root:='rfMyComputer';
      try Path:=FDefaultDir; except end;
      Selected.MakeVisible;
      end;
    end;
  ShellTreeView.SetFocus;
  end;

(* create new directory *)
procedure TShellDirDialog.spbNewClick(Sender: TObject);
var
  s : string;
begin
  s:='';
  if InputQuery (ShellTreeView.Path,dgettext('dialogs','New subdirectory:'),s) then begin
    s:=IncludeTrailingPathDelimiter(ShellTreeView.Path)+s;
    if not ForceDirectories(s) then
      ErrorDialog(TryFormat(dgettext('dialogs','Could not create directory:'+sLineBreak+'%s!'),[s]))
    else with ShellTreeView do begin
      Root:='rfMyComputer';
      try Path:=s; except end;
      Selected.MakeVisible;
      end;
    end;
  ShellTreeView.SetFocus;
  end;

procedure TShellDirDialog.itmDeleteClick(Sender: TObject);
var
  s : string;
  fc,dc,ec : cardinal;
  n   : integer;
  err : boolean;
begin
  s:=ShellTreeView.Path;
  n:=SelectOption(dgettext('dialogs','Delete directory'),
    TryFormat(dgettext('dialogs','Delete "%s"'),[s]),mtConfirmation,[fsBold],
    [dgettext('dialogs','Definitely'),dgettext('dialogs','To recycle bin')]);
  if n>=0 then begin
    spbUpClick(Sender);
    if n=0 then begin
      fc:=0; dc:=0; ec:=0;
      DeleteDirectory(s,'',true,dc,fc,ec);
      err:=ec>0;
      if not err then InfoDialog(TryFormat(dgettext('dialogs','%u directories with %u files deleted!'),[dc,fc]));
      end
    else begin
      if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=6) then // IsVista or newer
        err:=IShellDeleteDir (Application.Handle,SetDirName(s),true)<>NO_ERROR
      else err:=ShellDeleteAll (Application.Handle,SetDirName(s),'',true)<>NO_ERROR;
      if not err then InfoDialog(TryFormat(dgettext('dialogs','%s moved to Recycle Bin!'),[s]));
      end;
    if err then ErrorDialog(TryFormat(dgettext('dialogs','Error deleting directory:'+sLineBreak+'%s!'),[s]));
    itmUpdateClick(Sender);
    end;
  end;

procedure TShellDirDialog.itmUpdateClick(Sender: TObject);
begin
  with ShellTreeView do Refresh(Selected);
  end;

{------------------------------------------------------------------- }
procedure TShellDirDialog.btbOKClick(Sender: TObject);
begin
  AddHistory(cbxSelectedDir.Text);
  end;

procedure TShellDirDialog.PopupMenuPopup(Sender: TObject);
begin
  itmUpdateClick(Sender);
  end;

procedure TShellDirDialog.ShellTreeViewClick(Sender: TObject);
begin
{  with ShellTreeView do if assigned(Selected) then begin
    Refresh(Selected);
    Selected.MakeVisible;
    end;      }
  end;

procedure TShellDirDialog.ShellTreeViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  if Button=mbRight then with ShellTreeView do begin
//    n:=GetItemAt(x,y).Index;
  end;

procedure TShellDirDialog.ShellTreeViewChange(Sender: TObject;
  Node: TTreeNode);
var
  s,s1,s2,s3,s4 : string;
begin
  if Active then with ShellTreeView,SelectedFolder do begin
    btbOk.Enabled:=fpFileSystem in Properties;
    cbxSelectedDir.Text:=PathName;
    if fpIsLink in Properties then begin
      s:=IncludeTrailingPathDelimiter(PathName)+NetLink;
      if FileExists(s) then begin
        GetLink(s,s1,s2,s3,s4);
        cbxSelectedDir.Text:=s1;
        end
      end;
    end;
  end;

procedure TShellDirDialog.spbDesktopClick(Sender: TObject);
begin
  ShellTreeView.Root:='rfDesktop';
  end;

procedure TShellDirDialog.spbMyFilesClick(Sender: TObject);
begin
  ShellTreeView.Root:='rfPersonal';
  end;

procedure TShellDirDialog.spbComputerClick(Sender: TObject);
begin
  ShellTreeView.Root:='rfMyComputer';
  end;

procedure TShellDirDialog.spbNetworkClick(Sender: TObject);
begin
  ShellTreeView.Root:='rfNetwork';
  end;

procedure TShellDirDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[]) and (Key=VK_F5) then
    with ShellTreeView do if assigned(Selected) then Refresh(Selected);
  if Key=VK_Return then ModalResult:=mrOK;
  end;

procedure TShellDirDialog.ShowFiles (AShow : boolean);
var
  d : integer;
begin
  if AShow then with PanelRight do begin
//    Width:=301;
    d:=Left+Width;
    Visible:=true;
    ShellTreeView.ShellListView:=ShellListView;
    with cbxSelectedDir do if length(Text)>0 then ShellTreeView.Path:=Text;
    end
  else with PanelLeft do begin
    d:=Width;
    PanelRight.Visible:=false;
    ShellTreeView.ShellListView:=nil;
    end;
  ClientWidth:=d;
  cbxSelectedDir.Text:=ShellTreeView.Path;
  btbOk.Enabled:=DirectoryExists(cbxSelectedDir.Text);
  end;

procedure TShellDirDialog.cbxFilesClick(Sender: TObject);
begin
  if Visible then ShowFiles(cbxFiles.Checked);
  end;

procedure TShellDirDialog.cbxSelectedDirChange(Sender: TObject);
begin
  btbOk.Enabled:=DirectoryExists(cbxSelectedDir.Text);
  end;

procedure TShellDirDialog.cbxSelectedDirCloseUp(Sender: TObject);
begin
  with cbxSelectedDir do SelectDir(Items[ItemIndex]);
  end;

procedure TShellDirDialog.SelectDir (const ADir : string);
var
  s,r : string;
begin
  s:=ADir;
  if length(s)=0 then s:=FDefaultDir;
  if (length(s)=0) or not DirectoryExists(s)then begin
    s:=GetDesktopFolder(CSIDL_PERSONAL);
    r:='rfMyComputer';
//    r:='rfPersonal';
    if length(s)=0 then begin
      s:=GetCurrentDir;
      end;
    end
  else begin
    if copy(s,1,2)='\\' then begin
      r:='rfNetwork';
      end
    else r:='rfMyComputer';
    end;
  with ShellTreeView do begin
    Root:=r;
    Path:=s;
    if assigned(Selected) then try Selected.Expand(false); except end;
    end;
  end;

{------------------------------------------------------------------- }
(* Dialog an Position anzeigen *)
function TShellDirDialog.Execute (const ATitle  : string;
                                  Hidden,FileView,ZipAsFiles  : boolean;
                                  const HomeDir : string;
                                  var Dir : string) : boolean;
var
  ok : boolean;
begin
  Caption:=ATitle; FDefaultDir:=HomeDir;
  with ShellTreeView do begin
    if Hidden then ObjectTypes:=ObjectTypes+[otHidden,otHiddenSystem]
    else ObjectTypes:=ObjectTypes-[otHidden,otHiddenSystem];
    ShowZip:=not ZipAsFiles;
    end;
  if (copy(Dir,1,2)='\\') and not spbNetwork.Visible then begin
    ErrorDialog(_('Browsing the network is not supported on this system!'));
    SelectDir(HomeDir);
//    Exit;
    end
  else SelectDir(Dir);
  with ShellListView do begin
    if Hidden then ObjectTypes:=ObjectTypes+[otHidden,otHiddenSystem]
    else ObjectTypes:=ObjectTypes-[otHidden,otHiddenSystem];
    ShowZip:=ZipAsFiles;
    end;
  cbxSelectedDir.Text:=ShellTreeView.Path;
  cbxFiles.Visible:=FileView;
  if FileView then ShowFiles(cbxFiles.Checked)
  else ShowFiles(false);
  ok:=ShowModal=mrOK;
  if ok then Dir:=SetDirName(cbxSelectedDir.Text);
  Result:=ok;
  end;

procedure InitDirectoryDialog (const AIniName,ASection : string);
begin
  IniFileName:=AIniName; SectionName:=ASection;
  end;

function DirectoryDialog (const ATitle  : string; Hidden,FileView,ZipAsFiles  : boolean;
                          const HomeDir : string; var Dir : string) : boolean; overload;
begin
  if not assigned(ShellDirDialog)then begin
    ShellDirDialog:=TShellDirDialog.Create(Application);
    ShellDirDialog.LoadFromIni(IniFileName,SectionName);
    end;
  Result:=ShellDirDialog.Execute(ATitle,Hidden,FileView,ZipAsFiles,HomeDir,Dir);
  end;

function DirectoryDialog (const ATitle  : string; Hidden,FileView  : boolean;
                          const HomeDir : string; var Dir : string) : boolean;
begin
  Result:=DirectoryDialog(ATitle,Hidden,FileView,true,HomeDir,Dir);
  end;

initialization
  IniFileName:=''; SectionName:='';
finalization
end.
