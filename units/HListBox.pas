unit HListBox;
{ enth�lt
   - THistoryList, verwendbar zur Verwaltung
     von geladenen Dateien und zum Anh�ngen an ein Men�
   - THistoryCombo, die Combobox, die diese
     die Eingaben automatisch in einer Liste sammelt

   Autor: Elmar Warken, 1995

   erweitert: J. Rathlev, Jun. 1996
   - THistoryCombo.AddItem hinzugef�gt
   - Separator in THistoryList.AddMenuItems
   - FList (�hnlich FMenu) hinzugef�gt zur Verwaltung der
     HistoryList in den Dialog-Komponenten
   - THistoryCombo.AddItemObject hinzugef�gt, DoExit ge�ndert
   - DoEnter und Modified hinzugef�gt
   Feb. 2008:
   - 2. Men� f�r THistoryList
   Jun. 2009
   - SeparatorCount eingef�gt, da sonst bei angeh�ngten Men�s mit Ternnlinie
     in RemoveMenuItems der Index auf die Stringlist falsch berechnet wird
   Okt. 2012
   - Delete durch Free ersetzt, um den f�r TMenuItem belegten Speicher freizugeben
    }

interface

uses
  System.SysUtils, WinApi.Messages, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IniFiles, Vcl.Menus;

// Definiere CompPalPage (siehe Register)
{$Include UserComps.pas }

type
  { Event, das bei Anwahl eines der automatisch zum Men�
    hinzugef�gten Eintr�ge ausgel�st wird: }
  TListMenuEvent = procedure(Sender : TObject; MenuText : string)
                     of object;
  TListMenuEventIndex = procedure(Sender : TObject; Index : integer)
                     of object;

(* ----------------------------------------------------------------------- *)
{ Stringliste, die
  - sich selbst an ein Men� anh�ngen kann, wobei sie
    die Men�punkte mit Zahlen durchnumeriert,
  - sich in eine INI-Datei speichern
    und von dort wieder lesen kann }
  THistoryList = class(TStringList)
  private
    FMenu,FMenu2 : TMenuItem;
    FList : TStrings;
    SeparatorCount,
    ListSizeBefore,
    MenuSizeBefore : integer;
    { Speichert die vorherige Men�gr��e zur sp�teren
      Rekonstruktion }
    FOnAutoItemClick       : TListMenuEvent;
    FOnAutoItemClickIndex  : TListMenuEventIndex;
    FRadioMenu : boolean;
    FCheckedItem : string;

    procedure SetMenu(Menu : TMenuItem);
    procedure SetList(List : TStrings);
    procedure AddMenuItems;
    procedure RemoveMenuItems;
    procedure AddListItems;
    procedure RemoveListItems;
    procedure SetRadioMenu (RmOn : boolean);

  protected
    FMaxLen : integer;
    procedure SetMaxLen(AnInt : integer);
    procedure DoAutoItemClick(Sender : TObject); virtual;
       { empf�ngt die OnClick-Ereignisse }

  public
    constructor Create;
    destructor Destroy; override;

    { Maximale L�nge der Liste, Voreinstellung 10
      (wird nicht gespeichert, daher kein default-Teil): }
    property MaxLen : integer read FMaxLen write SetMaxLen;

    { Aufnahme eines Strings in die Liste, doppelte
      werden gel�scht: }
    procedure AddString(s : string);
    procedure AddStringObject(s : string; AObject: TObject);

    { String aus der Liste entfernen }
    procedure RemString(s : string);
    procedure ClearAll;

    (* Men�eintrag ausw�hlen
       Ergebnis = true - Eintrag vorhanden, = false - Eintrag nicht vorhanden *) 
    function SelectMenuItem (s : string) : boolean;

    { Funktionsbereich INI-Datei: die beiden folgenden
      Funktionen m�ssen manuell aufgerufen werden
      (f�r die Automatisierung gibt es die THistoryCombo): }
    procedure SaveToIni(IniName, IniSection : string;
                        Erase : boolean);
    procedure LoadFromIni(IniName,IniSection : string);

    procedure AssignList (AList : TStrings);

    { Funktionsbereich Men�: sobald Menu einmal gesetzt ist,
      pa�t die Liste das Men� immer an. }
    property Menu : TMenuItem read FMenu write SetMenu;
    property Menu2 : TMenuItem read FMenu2 write FMenu2;

    { Funktionsbereich Liste: sobald StrList einmal gesetzt ist,
      passen sich die Listen immer an. }
    property StrList : TStrings read FList write SetList;

    property OnAutoItemClick : TListMenuEvent read FOnAutoItemClick
                                            write FOnAutoItemClick;

    property OnAutoItemClickIndex : TListMenuEventIndex read FOnAutoItemClickIndex
                                            write FOnAutoItemClickIndex;

    property RadioMenu : boolean read FRadioMenu write SetRadioMenu;

    end;

(* ----------------------------------------------------------------------- *)
{ Combobox, die beim Laden aus einem Stream automatisch
  einen in einer INI-Datei gespeicherten Zustand wiederherstellt,
  und bei Programmende die INI-Datei aktualisiert.
  Setzt voraus, da� die Instanzen dieser Klasse aus einer
  Formulardatei geladen werden (anstatt dynamisch erzeugt zu
  werden). }
  THistoryCombo = class(TComboBox)
  private
    FSaveText    : string;
    FModified,
    FAutoUpdate  : boolean; // JR - siehe DoExit
    property Items;
  protected
    FIniFileName,
    FIniSection  : string;
    FHistoryList : THistoryList;
    FEraseSection : boolean;  // JR - siehe SaveToIni

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override; { hier wird die INI-Datei geschrieben }
    procedure DoEnter; override;
    procedure DoExit; override; { hier wird die Liste aktualisiert }
    function GetMaxItems : integer;
    procedure SetMaxItems (n : integer);

  public
    procedure LoadFromIni(IniName,IniSection : string);
    procedure AssignList (AList : TStrings);
    procedure Loaded; override; { Laden der INI-Datei findet nur hier statt }
    procedure UpdateList; { Laden der HistoryList in die eigenen Items. }
    procedure AddItem (s : string); { *neu* siehe THistoryList.AddString}
    procedure AddItemObject (s : string; AObject: TObject); { *neu* siehe THistoryList.AddStringObject}
    procedure DeleteItem (s : string); { *neu* siehe THistoryList.RemString}
    function FindItem (const AText : string) : integer;
    property HistoryList : THistoryList read FHistoryList write FHistoryList; { verwaltet
      die Liste der Strings (automatische L�ngenbeschr�nkung etc) }
    { Eintrag wurde ge�ndert }
    property Modified : boolean read FModified write FModified;

  published
    { automatisches Update der Liste }
    property AutoUpdate : boolean read FAutoUpdate write FAutoUpdate default true;
    { max. Anzahl der Eintr�ge in der Liste }
    property MaxItems : integer read GetMaxItems write SetMaxItems;
    { Name der zu verwendenden INI-Datei: }
    property IniFileName : string read FIniFileName write FIniFileName;
    { Name des zu verwendenden INI-Datei-Abschnitts: }
    property IniSection : string read FIniSection write FIniSection;
    property EraseSection : boolean read FEraseSection write FEraseSection default false;
  end;


(* ----------------------------------------------------------------------- *)
(* Combobox mit zus�tzlicher Stringliste "Values" *)
  TExtComboBox = class(TComboBox)
  published
    Values : TStringList;
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

uses  System.StrUtils;

(********** THistoryList ***********)

constructor THistoryList.Create;
begin
  inherited Create;
  FMaxLen:=15;
  FRadioMenu:=false;
  FCheckedItem:='';
  FMenu:=nil; FMenu2:=nil;
  end;

destructor THistoryList.Destroy;
begin
  RemoveMenuItems;
  inherited Destroy;
  end;

procedure THistoryList.SetRadioMenu (RmOn : boolean);
begin
  FRadioMenu:=RmOn;
  end;

procedure THistoryList.SaveToIni (IniName, IniSection : string;
                                  Erase : boolean);
var
  i : integer;
  IniFile : TIniFile;
begin
  { Da IniFile.FileName nicht nachtr�glich ge�ndert werden kann,
    mu� IniFile jedesmal neu initialisiert werden: }
  IniFile:=TIniFile.Create(IniName);
  try
    if Erase then IniFile.EraseSection(IniSection);
    { Falls die INI.Datei mehr Eintr�ge enth�lt, als die aktuelle
      Liste, werden die �berz�hligen Eintr�ge nicht �berschrieben. }
    for i:=0 to Count-1 do begin
      if Strings[i]=' ' then Strings[i]:='?';   // sonst ist String leer
      IniFile.WriteString(IniSection, 'History'+IntToStr(i), Strings[i]);
      end;
  finally
    IniFile.Free;
  end;
end;

procedure THistoryList.LoadFromIni (IniName,IniSection : string);
var
  i : integer;
  IniFile : TIniFile;
  s : string;
begin
  IniFile:=TIniFile.Create(IniName);
  Clear;
  try
    { TIniFile.ReadSection sieht zwar aus, als k�nne sie
      die Strings auf einen Schlag lesen, liest aber nur die
      Variablennamen vor dem = }
    for i:=0 to FMaxLen-1 do begin
      s:=IniFile.ReadString(IniSection, 'History'+IntToStr(i), '');
      if s='?' then s:=' ';   // sonst ist String leer
      if (s<>'') then Add(s);
    end;
  finally
    IniFile.Free;
  end;
end;

procedure THistoryList.AssignList (AList : TStrings);
var
  i : integer;
begin
 Clear;
 for i:=0 to FMaxLen-1 do if i<AList.Count then Add(AList[i]);
 end;

procedure THistoryList.SetMenu(Menu : TMenuItem);
begin
  if Assigned(FMenu) then RemoveMenuItems;
  FMenu:=Menu; { Property-zugeh�rige Variable setzen }
  SeparatorCount:=0;
  MenuSizeBefore:=Menu.Count; { bisherige Men�gr��e speichern }
  AddMenuItems; { ab sofort bleibt das Men� aktuell }
  end;

procedure THistoryList.RemoveMenuItems;
var
  n : integer;
begin
  { alle Men�eintr�ge ab der gespeicherten Position
    MenuSizeBefore wieder entfernen: }
  FCheckedItem:='';
  if Assigned(FMenu) then with FMenu do while Count>MenuSizeBefore do begin
    n:=Count-1-MenuSizeBefore-SeparatorCount;
    if Items[Count-1].Checked then FCheckedItem:=Strings[n];
    Items[Count-1].Free;
//    Delete(Count-1);
    end;
  if Assigned(FMenu2) then with FMenu2 do while Count>0 do begin
    Items[Count-1].Free;
//    Delete(Count-1);
    end;
  end;

procedure THistoryList.AddMenuItems;
{ Gegenst�ck zu RemoveMenuItems }
var
  i  : integer;
  mi : TMenuItem;
  ch : boolean;
  s  : string;

  procedure CloneMenuItem(source, dest : TMenuItem);
  begin
     with dest do begin
       Action  := source.Action;
       Caption := source.Caption;
       ShortCut := source.ShortCut;
       Checked  := source.Checked;
       Enabled  := source.Enabled;
       Visible  := source.Visible;
       OnClick  := source.OnClick;
       HelpContext := source.HelpContext;
       Hint        := source.Hint;
       RadioItem   := source.RadioItem;
       end;
    end;

begin
  if Assigned(FMenu) then begin
    (* �nderung - keine Linie, wenn Men� leer *)
    if MenuSizeBefore>0 then begin
      FMenu.Add(NewLine); { mit einem Separator abtrennen }
      SeparatorCount:=1;
      end;
    for i:=0 to Count-1 do begin
      ch:=FRadioMenu and (Strings[i]=FCheckedItem);
      if i<15 then s:=Format('%1x %s', [i+1, Strings[i]])
      else s:=Format('%2x %s', [i+1, Strings[i]]);
      mi:=NewItem(s,0,ch, True, DoAutoItemClick, 0, '');
      with mi do begin
        RadioItem:=FRadioMenu;
        GroupIndex:=99;
        end;
      FMenu.Add(mi);
      end;
    { so sieht das Men� aus (erste Ziffer unterstrichen):
      ...
      ----------
      1 Eintrag1
      2 Eintrag2
    }
    if Assigned(FMenu2) then begin
      FMenu2.Clear;
      for i:=MenuSizeBefore to FMenu.Count-1 do begin
        mi:=TMenuItem.Create(FMenu2);
        CloneMenuItem(FMenu.Items[i],mi);
        FMenu2.Add(mi);
        end;
      end;
    end;
  end;

procedure THistoryList.SetList(List : TStrings);
begin
  if Assigned(FList) then RemoveListItems;
  FList:=List; { Property-zugeh�rige Variable setzen }
  ListSizeBefore:=List.Count; { bisherige Men�gr��e speichern }
  AddListItems; { ab sofort bleibt das Men� aktuell }
end;

procedure THistoryList.RemoveListItems;
begin
  { alle Listeneintr�ge ab der gespeicherten Position
    ListSizeBefore wieder entfernen: }
  if Assigned(FList) then with FList do
    while Count>ListSizeBefore do Delete(Count-1);
end;

procedure THistoryList.AddListItems;
{ Gegenst�ck zu RemoveListItems }
var
  i : integer;
begin
  if Assigned(FList) then begin
    for i:=0 to Count-1 do FList.Add(Strings[i]);
  end;
end;

procedure THistoryList.SetMaxLen(AnInt : integer);
begin
  if (AnInt>=1) and (AnInt<=100) then begin
    FMaxLen:=AnInt;
    while Count>FMaxLen do
      Delete(Count-1); { alle �berz�hligen Eintr�ge l�schen }
  end;
end;

procedure THistoryList.AddString(s : string);
var
  OldIndex : integer;
begin
  if length(s)>0 then begin
    { String schon vorhanden? }
    OldIndex:=IndexOf(s);
    RemoveMenuItems; { Men� in Ursprungszustand versetzen... }
//    FCheckedItem:=s;
    if OldIndex<>-1 then Delete(OldIndex); { dann das Duplikat l�schen }
    Insert(0, s); { auf alle F�lle an erster Stelle einf�gen }
    { Maximall�nge �berschritten? }
    if Count>FMaxLen then Delete(Count-1); { letzten Eintrag l�schen }
    AddMenuItems; { ...und alle Eintr�ge neu anh�ngen. }
    RemoveListItems; { Liste in Ursprungszustand versetzen... }
    AddListItems; { ...und alle Eintr�ge neu anh�ngen. }
    end;
  end;

procedure THistoryList.AddStringObject(s : string; AObject: TObject);
var
  OldIndex : integer;
begin
  if length(s)>0 then begin
    { String schon vorhanden? }
    OldIndex:=IndexOf(s);
    RemoveMenuItems; { Men� in Ursprungszustand versetzen... }
//    FCheckedItem:=s;
    if OldIndex<>-1 then Delete(OldIndex); { dann das Duplikat l�schen }
    InsertObject(0,s,AObject); { auf alle F�lle an erster Stelle einf�gen }
    { Maximall�nge �berschritten? }
    if Count>FMaxLen then Delete(Count-1); { letzten Eintrag l�schen }
    AddMenuItems; { ...und alle Eintr�ge neu anh�ngen. }
    RemoveListItems; { Liste in Ursprungszustand versetzen... }
    AddListItems; { ...und alle Eintr�ge neu anh�ngen. }
    end;
  end;

procedure THistoryList.RemString(s : string);
var
  OldIndex : integer;
begin
  { String vorhanden? }
  OldIndex:=IndexOf(s);
  RemoveMenuItems; { Men� in Ursprungszustand versetzen... }
  if OldIndex<>-1 then Delete(OldIndex); { l�schen }
  AddMenuItems; { ...und alle Eintr�ge neu anh�ngen. }
  RemoveListItems; { Liste in Ursprungszustand versetzen... }
  AddListItems; { ...und alle Eintr�ge neu anh�ngen. }
  end;

procedure THistoryList.ClearAll;
begin
  RemoveMenuItems; { Men� in Ursprungszustand versetzen... }
  RemoveListItems; { Liste in Ursprungszustand versetzen... }
  Clear;
  end;

function THistoryList.SelectMenuItem (s : string) : boolean;
var
  n : integer;
begin
  n:=IndexOf(s);
  if n>=0 then FMenu.Items[n+MenuSizeBefore+SeparatorCount].Checked:=true;
  Result:=n>=0;
  end;

procedure THistoryList.DoAutoItemClick(Sender : TObject);
var
  Text,s : String;
  Index : Integer;
begin
  Text:=(Sender as TMenuItem).Caption;
  (Sender as TMenuItem).Checked:=true;
  { Text sieht so aus:
    &12 MenuText
    das "&" mu� �bersprungen werden, dann folgt bis
    zum Leerzeichen der Index, der angeklickt wurde }
  s:=Copy(Text,1,Pos(' ',Text)-1);
  system.Delete(s,Pos('&',s),1);
  Index:=StrToInt('$'+s);
  if Assigned (FOnAutoItemClick) then begin
    { Index - 1 ergibt den Index in der internen
      Stringliste: }
    if Index>0 then FOnAutoItemClick(FMenu, Strings[index-1]);
    end
  else if assigned(FOnAutoItemClickIndex) then begin
    if Index>0 then FOnAutoItemClickIndex(FMenu,Index-1);
    end;
  end;

(********** THistoryCombo ***********)

constructor THistoryCombo.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FAutoUpdate:=true;
  FEraseSection:=false;
  FSaveText:=''; FModified:=false;
  FHistoryList:=THistoryList.Create;
end;

destructor THistoryCombo.Destroy;
begin
  { Automatische Speicherung, wenn die notwendigen
    Angaben gemacht sind: }
  if (FIniFileName<>'') and (FIniSection<>'') then begin
    FHistoryList.SaveToIni(FIniFileName, FIniSection,FEraseSection);
  end;
  { da FHistoryList nicht in der Komponentenliste ist,
    mu� sie manuell freigegeben werden: }
  FHistoryList.Free;
  inherited Destroy;
  end;

function THistoryCombo.GetMaxItems : integer;
begin
  Result:=FHistoryList.FMaxLen;
  end;

procedure THistoryCombo.SetMaxItems (n : integer);
begin
  FHistoryList.SetMaxLen(n);
  end;

procedure THistoryCombo.AddItem (s : string);
begin
  FHistoryList.AddString(s);
  UpdateList;
  end;

procedure THistoryCombo.AddItemObject (s : string; AObject: TObject);
begin
  FHistoryList.AddStringObject(s,AObject);
  UpdateList;
  end;

procedure THistoryCombo.DeleteItem (s : string);
begin
  FHistoryList.RemString(s);
  UpdateList;
  end;

function THistoryCombo.FindItem (const AText : string) : integer;
begin
  with HistoryList do for Result:=0 to Count-1 do if AnsiStartsText(AText,Strings[Result]) then Exit;
  Result:=-1;
  end;


procedure THistoryCombo.UpdateList;
begin
  Items:=FHistoryList;
  end;

procedure THistoryCombo.DoEnter;
begin
  if not FModified then FSaveText:=Text;
  end;

procedure THistoryCombo.DoExit;
{ Fokus-Wechsel -> Eintrag speichern. }
begin
  inherited DoExit;
  FModified:=not AnsiSameText(FSavetext,Text);
  if FAutoUpdate then begin    // JR - nur bei AutoUpdate speichern
    FHistoryList.AddString(Text);
    UpdateList;
    end;
  end;

procedure THistoryCombo.Loaded;
begin
  inherited Loaded;
  { Automatisches INI-Datei-Lesen, wenn die notwendigen
    Angaben gemacht sind: }
  if (FIniFileName<>'') and (FIniSection<>'') then begin
    FHistoryList.LoadFromIni(FIniFileName, FIniSection);
    UpdateList;
    end;
  end;

procedure THistoryCombo.LoadFromIni(IniName, IniSection : string);
begin
  FIniFileName:=IniName;
  FIniSection:=IniSection;
  if FileExists(FIniFileName) and (FIniSection<>'') then begin
    FHistoryList.LoadFromIni(FIniFileName, FIniSection);
    UpdateList;
    end;
  end;

procedure THistoryCombo.AssignList (AList : TStrings);
begin
  FHistoryList.AssignList(AList);
  UpdateList;
  end;

(* ----------------------------------------------------------------------- *)
(* Combobox mit zus�tzlicher Stringliste "Values" *)
constructor TExtComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Values := TStringList.Create;
  end;


(************** Register ***************)

procedure Register;
begin
  RegisterComponents(CompPalPage, [THistoryCombo,TExtComboBox]);
end;

end.
