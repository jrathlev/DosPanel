(* Delphi-Unit
   Placeholder utilities
   =====================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Changes   :       - Aug. 2010  (inserted: year + week)
                     - Sep. 2012  (ReplaceAllPlaceHolder)
                     - Jul. 2013  (environment parameters)
   last updated: July 2017
   *)

unit PlaceHolders;

interface

const
  VolPh = '%volume%';
  ProgPh = '%progpath%';

  dphCount = 14;
  DaPlaceHolder : array [0..dphCount-1] of string =
    ('%date%','%yaw%','%dow%','%ldow%','%dnw%','%day%','%week%','%dom%','%wom%',
     '%month%','%lmonth%','%year%','%user%','%computer%');

  tphCount = 9;
  TmPlaceHolder : array [0..tphCount-1] of string =
    ('%time%','%hour%','%minute%','%d#?%','%w#?%','%m#?%','%username%','%computername%',VolPh);

  pphCount = 11;
  PaPlaceHolder : array [0..pphCount-1] of string =
    ('%perspath%','%apppath%','%profile%','%desktop%','%favorites%','%progfiles%',
     '%progpath%','%username%','%computername%','%user%','%computer%');

  sphCount = 9;
  SyPlaceHolder : array [0..sphCount-1] of string =
    ('%appdata%','%localappdata%','%allusersprofile%','%public%','%programfiles%',
     '%commonprogramfiles%','%programfiles(x86)%','%commonprogramfiles(x86)%',
     '%programdata%');

  mphCount = 8;
  MaPlaceHolder : array [0..mphCount-1] of string =
    ('%taskname%','%username%','%computername%','%start%','%end%','%duration%',
     '%status%','%computer%');

function ReplaceTimePlaceHolder (const ps : string) : string;
function ReplacePathPlaceHolder (const ps : string) : string;
function RemovePlaceHolderSubdirs(ADir : string) : string;

function CheckForTimePlaceholder (const ps : string) : boolean;

implementation

uses System.SysUtils, System.DateUtils, System.StrUtils, Winapi.ShlObj, Vcl.Forms,
  System.Masks, StringUtils, WinApiUtils, WinShell;

(* Integer-Zahl in String mit führenden Nullen umsetzen *)
function ZStrInt (x : int64;
                  n : integer) : string;
begin
  Result:=Format('%.'+IntToStr(n)+'d',[x]);
  end;

{ ------------------------------------------------------------------- }
(* Platzhalter im String ersetzen *)
function ReplaceTimePlaceHolder (const ps : string) : string;
var
  i,w,y  : integer;
  s,sv   : string;
begin
  Result:=ps;
  for i:=0 to dphCount-1 do begin
    if AnsiContainsText(Result,DaPlaceHolder[i]) then begin
      case i of
      0 : s:=FormatDateTime('yyyy-mm-dd',Date);
      1 : begin
          w:=WeekOfTheYear(Date); y:=YearOf(Date);
          if (MonthOf(Date)=1) and (w>25) then dec(y); // Woche des Vorjahres
          s:=ZStrint(y,4)+'-'+ZStrInt(w,2);
          end;
      2 : s:=FormatDateTime('ddd',Date);    // day of the week - ShortDayNames
      3 : s:=FormatDateTime('dddd',Date);   // day of the week - LongDayNames
      4 : s:=ZStrInt(DayOfTheWeek(Date),1); // day of the week - Mo = 1
      5 : s:=ZStrInt(DayOfTheYear(Date),3);
      6 : s:=ZStrInt(WeekOfTheYear(Date),2);
      7 : s:=FormatDateTime('dd',Date);
      8 : s:=ZStrInt(WeekOfTheMonth(Date),1);
      9 : s:=FormatDateTime('mm',Date);
      10 : s:=FormatDateTime('mmmm',Date);   // long name of month
      11 : s:=FormatDateTime('yyyy',Date);
      12 : s:=UserName;
      13 : s:=ComputerName;
      else s:='';
        end;
      Result:=AnsiReplaceText(Result,DaPlaceHolder[i],s);
      end;
    end;
  for i:=3 to 5 do begin  // spez. Platzhalter für wechselnde Tage, Wochen und Monate
    sv:=copy(TmPlaceHolder[i],1,3);
    if AnsiContainsText(Result,sv) then begin
      w:=Pos(sv,Result);
      if (w>0) and TryStrToInt(copy(Result,w+3,1),y) then begin
        if i=3 then s:=IntToStr((DayOfTheYear(Date)-1) mod y +1)
        else if i=4 then s:=IntToStr((WeekOfTheYear(Date)-1) mod y +1)
        else s:=IntToStr((MonthOfTheYear(Date)-1) mod y +1);
        end
      else s:='';
      Result:=AnsiReplaceText(Result,copy(Result,w,5),s);
      end;
    end;
  for i:=0 to tphCount-1 do begin
    if AnsiContainsText(Result,TmPlaceHolder[i]) then begin
      case i of
      0 : s:=FormatDateTime('hhnnss',Time);
      1 : s:=FormatDateTime('hh',Time);
      2 : s:=FormatDateTime('nn',Time);
      6 : s:=UserName;
      7 : s:=ComputerName;
      8 : s:='';  // %volume% must have been replaced in calling program if supported
      else s:='';
        end;
      Result:=AnsiReplaceText(Result,TmPlaceHolder[i],s);
      end;
    end;
  end;

function ReplacePathPlaceHolder (const ps : string) : string;
var
  i  : integer;
  s  : string;
begin
  Result:=ps;
  if length(Result)>0 then begin
    for i:=0 to pphCount-1 do begin
      if AnsiContainsText(Result,PaPlaceHolder[i]) then begin
        case i of
        0 : s:=ExcludeTrailingPathDelimiter(GetDesktopFolder(CSIDL_Personal));
        1 : s:=ExcludeTrailingPathDelimiter(GetDesktopFolder(CSIDL_APPDATA));
        2 : s:=ExcludeTrailingPathDelimiter(UserProfile);
        3 : s:=ExcludeTrailingPathDelimiter(GetDesktopFolder(CSIDL_DESKTOP));
        4 : s:=ExcludeTrailingPathDelimiter(GetDesktopFolder(CSIDL_FAVORITES));
        5 : s:=ExcludeTrailingPathDelimiter(GetProgramFolder(pfProgramFiles));
        6 : s:=ExcludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
        7 : s:=UserName;
        8 : s:=ComputerName;
        else s:='';
          end;
        Result:=AnsiReplaceText(Result,PaPlaceHolder[i],s);
        end;
      end;
    for i:=0 to sphCount-1 do begin
      if AnsiContainsText(Result,SyPlaceHolder[i]) then begin
        case i of
        0 : s:=ExcludeTrailingPathDelimiter(GetDesktopFolder(CSIDL_APPDATA));
        1 : s:=ExcludeTrailingPathDelimiter(GetDesktopFolder(CSIDL_LOCAL_APPDATA));
        2 : s:=ExcludeTrailingPathDelimiter(AllUsersProfile);
        3 : s:=ExcludeTrailingPathDelimiter(PublicFolder);
        4 : s:=ExcludeTrailingPathDelimiter(GetProgramFolder(pfProgramFiles64));
        5 : s:=ExcludeTrailingPathDelimiter(GetProgramFolder(pfCommonProgramFiles64));
        6 : s:=ExcludeTrailingPathDelimiter(GetProgramFolder(pfProgramFiles86));
        7 : s:=ExcludeTrailingPathDelimiter(GetProgramFolder(pfCommonProgramFiles86));
        8 : s:=ExcludeTrailingPathDelimiter(AllUsersProfile);
        else s:='';
          end;
        Result:=AnsiReplaceText(Result,SyPlaceHolder[i],s);
        end;
      end;
    end;
  end;

(* Unterverzeichnisse mit Platzhalter aus Verzeichnisnamen entfernen *)
function RemovePlaceHolderSubdirs(ADir : string) : string;
var
  s,t : string;
begin
  if AnsiContainsText(ADir,'%') then begin
    s:='';
    repeat
      t:=ReadNxtStr(ADir,PathDelim);
      if not AnsiContainsText(t,'%') then s:=s+t+PathDelim
      else ADir:='';
      until length(ADir)=0;
    Result:=s;
    end
  else Result:=ADir;
  end;

{ ------------------------------------------------------------------- }
(* Prüfen ob im String ein Platzhalter enthalten ist *)
function CheckForTimePlaceholder (const ps : string) : boolean;
var
  i  : integer;
begin
  Result:=false;
  for i:=0 to dphCount-1 do Result:=Result or AnsiContainsText(ps,DaPlaceHolder[i]);
  if not Result then
    for i:=0 to tphCount-1 do Result:=Result or AnsiContainsText(ps,TmPlaceHolder[i]);
  end;

end.
