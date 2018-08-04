(* Delphi Unit
   Collection of subroutines for Windows network connections
   =========================================================
   
   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Sep. 2002
   last updated: Feb. 2017
   *)

unit WinNet;

interface

uses
  WinApi.Windows, System.Classes, System.SysUtils, Vcl.Controls;

type
  TUserAccount = record
    Username,Password : string;
    end;

// Name des angemeldeten Benutzers ermitteln
function GetUserName : string;

// Prüfen, ob ein in einem Pfad enthaltenes Laufwerk (lokal oder Netz) verfügbar ist.
// StdUser: Name des angemeldeten Benutzers oder leer
function NetPathAvailable (const Path,StdUser : string; const AltUser : TUserAccount; ReadOnly,Prompt : boolean) : integer; overload;
function NetPathAvailable (const Path,StdUser : string; ReadOnly,Prompt : boolean) : integer; overload;

function ReconnectPathEx (const Path : string) : cardinal;
function ReconnectPath (const Path : string) : boolean;

function CheckForDirectory (const Path : string) : boolean;
function CheckForFile (const Filename : string) : boolean;

function GetRemoteName : string;

// Account eines alternativen Benutzers abfragen
function ReadAltUserAccount (NetResource : string) : boolean;

// Alternativen Benutzernamen setzen
function MakeAltUserAccount (User,Pwd : string) : TUserAccount;
procedure SetAltUserAccount (User,Pwd : string);

// Alternativen Benutzernamen löschen
function ReconnectDefaultUser (const Path : string) : integer;
function GetAltUserAccount (var Username : string) : boolean;
function ResetAltUserAccount (var NetName,Username : string) : boolean; overload;
function ResetAltUserAccount : boolean; overload;

implementation

uses WinDevUtils, LogonDlg, UnitConsts;

var
  AltUserAccount : TUserAccount;
  AltUserName,
  RemoteName     : string;
//  AltConnect     : boolean;

// Name des angemeldeten Benutzers ermitteln
function GetUserName : string;
var
  ul    : dword;
  un    : pchar;
begin
  ul:=1024; GetMem (un,ul);
  if WNetGetUser(nil,un,ul)=NO_ERROR then Result:=un else Result:='';
  FreeMem (un);
  end;

function MakeNetRes (const Path : string; var NetRes : TNetResource) : integer;
var
  nl : dword;
begin
  with NetRes do begin
    dwScope:=0; dwDisplayType:=0;
    lpProvider:=nil; lpLocalName:=nil; lpComment:=nil;
    dwUsage:=RESOURCEUSAGE_CONNECTABLE;
    dwType:=RESOURCETYPE_DISK;
    if (copy(Path,1,2)='\\') then begin  // Netzwerkumgebung
      lpRemoteName:=StrNew(pchar(ExcludeTrailingPathDelimiter(Path)));
      Result:=ERROR_NOT_CONNECTED;
      end
    else begin
      nl:=1024;
      lpLocalName:=StrNew(pchar(ExtractFileDrive(Path)));
      lpRemoteName:=StrAlloc(nl);
      Result:=WNetGetConnection(lpLocalName,lpRemoteName,nl);   // Netzwerkname des Pfads
      end;
    end;
  end;

procedure ReleaseNetRes (NetRes : TNetResource);
begin
  with NetRes do begin
    StrDispose(lpLocalName); StrDispose(lpRemoteName);
    end;
  end;

// Prüfen, ob ein in einem Pfad enthaltenes Laufwerk (lokal oder Netz) verfügbar ist.
// Bei Netzlaufwerken wird geprüft, ob die Verbindung zum Schreiben verfügbar ist,
// wenn nicht, wird versucht, sie herzustellen. Dazu wird zuerst versucht,
// dies mit dem angemeldeten Benutzer zu machen, dann mit einem eingetragenen
// alternativen Benutzer ("AltUser")
// Prompt = true:  Wenn das nicht geht, wird ein Benutzername und ein Passwort abgefragt.
function NetPathAvailable (const Path,StdUser : string; const AltUser : TUserAccount; ReadOnly,Prompt : boolean) : integer;
var
  ec,nl    : dword;
  NetRes   : TNetResource;
  FindData : TWin32FindData;
begin
//  AltConnect:=false;
  AltUserName:=''; RemoteName:='';
  // prüfe, ob Verbindung vorhanden
  if FindFirstFile(PChar(IncludeTrailingPathDelimiter(ExtractFileDrive(Path))+'*.*'),FindData)=INVALID_HANDLE_VALUE then begin
    ec:=MakeNetRes(Path,NetRes);
    if ec<>NO_ERROR then begin
    // nein - als angemeldeter Benutzer versuchen
      if (length(StdUser)>0) then begin
        nl:=0;
        repeat
          if nl>0 then Sleep(1000); // wait 1 s
          ec:=WNetAddConnection2(NetRes,nil,pchar(StdUser),0);
          if (ec=ERROR_ALREADY_ASSIGNED) or (ec=ERROR_DEVICE_ALREADY_REMEMBERED)
            or (ec=ERROR_SESSION_CREDENTIAL_CONFLICT) then ec:=NO_ERROR;
          inc(nl);
          until (ec<>ERROR_NETNAME_DELETED) or (nl=3);  // try 3 times
        end
      else ec:=ERROR_LOGON_FAILURE;
      end;
    // prüfe, ob geschrieben werden kann, falls nicht "ReadOnly"
    if not ReadOnly and (ec=NO_ERROR) and not CheckForWritablePath(NetRes.lpRemoteName) then
        ec:=ERROR_SESSION_CREDENTIAL_CONFLICT;
    if ec=NO_ERROR then RemoteName:=NetRes.lpRemoteName
    else begin
      // Mit alternativem Benutzer versuchen
      with AltUser do if (length(Username)>0) then begin
        ec:=WNetCancelConnection2(NetRes.lpRemoteName,0,true);
        if (ec=NO_ERROR) or (ec=ERROR_NOT_CONNECTED) then begin
              ec:=WNetAddConnection2(NetRes,pchar(Password),pchar(Username),0);
          if ec=NO_ERROR then begin
//            AltConnect:=true;
            AltUserName:=Username;
            RemoteName:=NetRes.lpRemoteName;
            end;
          end;
        end;
      // falls nicht möglich und Dialog erlaubt, interaktiv versuchen
      if (ec<>NO_ERROR) and Prompt then begin
        repeat
          ec:=WNetCancelConnection2(NetRes.lpRemoteName,0,false);
          if (ec=NO_ERROR) or (ec=ERROR_NOT_CONNECTED) then begin
            ec:=WNetAddConnection2(NetRes,nil,nil,CONNECT_INTERACTIVE or CONNECT_PROMPT);
            end
          else ec:=ERROR_CANCELLED;
          until (ec=NO_ERROR) or (ec=ERROR_CANCELLED);
        if ec=NO_ERROR then begin
          RemoteName:=NetRes.lpRemoteName;
          end;
        end;
      // prüfe, ob geschrieben werden kann, falls nicht "ReadOnly"
      if not ReadOnly and (ec=NO_ERROR) and not CheckForWritablePath(NetRes.lpRemoteName) then
          ec:=ERROR_SESSION_CREDENTIAL_CONFLICT;
      end;
    ReleaseNetRes(NetRes);
    end
  else begin
    if ReadOnly or CheckForWritablePath(Path) then ec:=NO_ERROR else ec:=ERROR_ACCESS_DENIED;
    end;
  Result:=ec;
  end;

function NetPathAvailable (const Path,StdUser : string; ReadOnly,Prompt : boolean) : integer;
begin
  Result:=NetPathAvailable(Path,StdUser,AltUserAccount,ReadOnly,Prompt);
  end;

function ReconnectPathEx (const Path : string) : cardinal;
var
  nl       : dword;
  NetRes   : TNetResource;
  nn       : pchar;
begin
  nl:=1024; nn:=StrAlloc(nl);
  with NetRes do begin
    dwScope:=0; dwDisplayType:=0;
    lpProvider:=''; lpLocalName:='';
    dwUsage:=RESOURCEUSAGE_CONNECTABLE;
    dwType:=RESOURCETYPE_DISK;
    if (copy(Path,1,2)='\\') then begin  // Netzwerkumgebung
      lpRemoteName:=pchar(ExcludeTrailingPathDelimiter(Path));
      end
    else begin
      lpLocalName:=pchar(ExtractFileDrive(Path));
      WNetGetConnection(lpLocalName,nn,nl);   // Netzwerkname des Pfads
      lpRemoteName:=nn;
      end;
    end;
  // als angemeldeter Benutzer versuchen
  Result:=WNetAddConnection2(NetRes,nil,nil,0);
  end;

function ReconnectPath (const Path : string) : boolean;
begin
  Result:=ReconnectPathEx(Path)=NO_ERROR;
  end;

function CheckForDirectory (const Path : string) : boolean;
var
  pt   : TPathType;
begin
  // prüfen, ob lokales Ziel oder im Netz
  pt:=CheckPath(Path);
  if pt=ptNotAvailable then begin // nicht verbundener Netzwerkpfad?
    if ReconnectPath(Path) then begin
      pt:=CheckPath(Path);
      Result:=pt<>ptNotAvailable;
      end
    else Result:=false;
    end
  else Result:=true;
  end;

function CheckForFile (const Filename : string) : boolean;
begin
  Result:=CheckForDirectory(ExtractFilePath(Filename));
  if Result then Result:=FileExists(Filename);
  end;

function GetRemoteName : string;
begin
  Result:=RemoteName;
  end;

// Account eines alternativen Benutzers abfragen
function ReadAltUserAccount (NetResource : string) : boolean;
var
  User,Pwd : string;
begin
  User:=''; Pwd:='';
  if InputUserAccount(rsConnectTo,NetResource,false,User,Pwd)=mrOK then
       with AltUserAccount do begin
    Username:=User; Password:=Pwd;
    Result:=true;
    end
  else Result:=false;
  end;

// Alternativen Benutzernamen setzen
function MakeAltUserAccount (User,Pwd : string) : TUserAccount;
begin
  with Result do begin
    Username:=User; Password:=Pwd;
    end
  end;

procedure SetAltUserAccount (User,Pwd : string);
begin
  AltUserAccount:=MakeAltUserAccount(User,Pwd);
  end;

// wieder mit Standardbenutzer verbinden
function ReconnectDefaultUser (const Path : string) : integer;
var
  NetRes   : TNetResource;
begin
  if (length(RemoteName)>0) then begin
    WNetCancelConnection2(pchar(RemoteName),0,false);
    Result:=MakeNetRes(Path,NetRes);
    if Result<>NO_ERROR then begin
      Result:=WNetAddConnection2(NetRes,nil,nil,0);
      if (Result=ERROR_ALREADY_ASSIGNED) or (Result=ERROR_DEVICE_ALREADY_REMEMBERED)
        or (Result=ERROR_SESSION_CREDENTIAL_CONFLICT) then Result:=NO_ERROR;
      end;
    ReleaseNetRes(NetRes);
    end
  else Result:=NO_ERROR;
  end;

// Abfragen ob eine Verbindung mit alternativem Benutzernamen hergestellt wurde
function GetAltUserAccount (var Username : string) : boolean;
begin
  Username:=AltUsername;
  Result:=length(AltUserName)>0;
  end;

// Alternativen Benutzernamen löschen
function ResetAltUserAccount (var NetName,Username : string) : boolean;
begin
  Username:=AltUsername; NetName:=RemoteName;
  Result:=length(AltUserName)>0;
  if Result and (length(RemoteName)>0) then
    WNetCancelConnection2(pchar(RemoteName),CONNECT_UPDATE_PROFILE,false);
  with AltUserAccount do begin
    Username:=''; Password:='';
    end;
//  AltConnect:=false;
  AltUserName:=''; RemoteName:='';
  end;

function ResetAltUserAccount : boolean;
var
  s,t : string;
begin
  Result:=ResetAltUserAccount(s,t);
  end;

initialization
  with AltUserAccount do begin
    Username:=''; Password:='';
    end;
//  AltConnect:=false;
  AltUserName:=''; RemoteName:='';
finalization
  ResetAltUserAccount;
  end.

