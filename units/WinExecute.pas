(* Delphi-Unit
   Subroutines to start a process 
   ==============================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Mai 2005
         1.1 - Aug. 2005 : return process exit code
         2.0 - July 2015 : optional view of console output fixed
   last modified: June 2022
   *)

unit WinExecute;

interface

uses Winapi.Windows, Vcl.Forms, System.Classes, System.SysUtils;

type
  EProcessError = class(Exception);
  TProcessFlag = (pfConsole,pfShowConsole,pfShowOutput,pfShowError);
  TProcessFlags = set of TProcessFlag;

// Programm mit CreateProcess starten
function ExecuteProcess (const AppName,Options,WorkDir : string; Flags : TProcessFlags;
                         WaitTime : integer = 0; IgnoreTimeout : boolean = false;
                         Output : TStringList = nil; CodePage : integer = 850) : HResult; overload;

function ExecuteProcess (const CmdLine,WorkDir : string; Flags : TProcessFlags;
                         WaitTime : integer = 0; IgnoreTimeout : boolean = false;
                         Output : TStringList = nil) : HResult; overload;

function ExecuteProcess (const CmdLine,WorkDir : string; Output : TStringList = nil; CodePage : integer = 850) : HResult; overload;

function ExecuteConsoleProcess (const CmdLine,WorkDir : string; Output : TStringList; CodePage : integer = 850) : HResult;

procedure CancelProcess;

function StartProcess (const CmdLine,WorkDir : string) : THandle;

function StartProcessAsUser (const UserName,Domain,Password,CmdLine,WorkDir : WideString) : THandle;

function WaitForProcess (ph : THandle; WaitTime : integer = 0; IgnoreTimeout : boolean = false) : HResult;

procedure StopProcess (ph : THandle);

// Programm mit ShellExecute starten
function ShellExecuteProcess (const ExecuteFile,ParamString,WorkDir : string;
             RunAs : boolean = false; WaitTime : integer = 0; IgnoreTimeout : boolean = false) : HResult;

// Programm mit erhöhten Rechten starten
function RunElevated (const ExecuteFile,ParamString,WorkDir : string) : boolean; overload;
function RunElevated (const ExecuteFile,ParamString : string) : boolean; overload;
function RunElevated (const ExecuteFile : string) : boolean; overload;

implementation

uses Winapi.Shellapi, Show, WinUtils, MsgDialogs, WinApiUtils, StringUtils, UnitConsts;

var
  FCancelProcess : boolean;

function RawByteToUnicode(sa : RawByteString; CodePage : integer = 1252) : string;
var
  ta,tu : TBytes;
begin
  if length(sa)=0 then Result:=''
  else begin
    SetLength(ta,length(sa));
    Move(sa[1],ta[0],Length(ta));
    SetLength(tu,length(sa)*sizeof(Char));
    tu:=TEncoding.Convert(TEncoding.GetEncoding(CodePage),TEncoding.Unicode,ta);
    SetLength(Result,length(sa));
    Move(tu[0],Result[1],Length(tu));
    ta:=nil; tu:=nil;
    end;
  end;

{ ------------------------------------------------------------------- }
// Prozess starten
// AppName: exe-Datei
// Options: Parameter der Befehlszeile
// WorkDir: Arbeistverzeichnis
// Flags: pfConsole     - ist eine Konsolen-Anwendung
//        pfShowConsole - Konsolenfenszer anzeigen
//        pfShowOutput  - StdOut als Fenster anzeigen
//        pfShowError   - Anzeige von Fehlern
// WaitTime  > 0 : Warte auf das Ende des Prozesses für max. "WaitTime" in Millisekunden
//           = 0 : Warten auf den gestarteten Prozess
// IgnoreTimeout = true: Timeout nicht als Fehler zurück geben
// Output : TStringList für die Anzeige von StdOut
// Result: = 0: ok
//         > 0 :  Bit 29 ($20000000) gesetzt : ExitCode = Result and $FF
//                sonst  Systemfehler von GetLastErr (siehe SysErrorMessage)
function ExecuteProcess (const AppName,Options,WorkDir : string; Flags : TProcessFlags;
                         WaitTime : integer = 0; IgnoreTimeout : boolean = false;
                         Output : TStringList = nil; CodePage : integer = 850) : HResult; overload;
const
  BUFSIZE = 1024;
var
  si        : TStartupInfo;
  pi        : TProcessInformation;
  s         : string;
  sa        : RawByteString;
  saPipe    : TSecurityAttributes;
  hChildStdoutRd,hChildStdoutWr,
  hChildStdoutRdDup  : THandle;
  chBuf     : array [0..BUFSIZE] of AnsiChar;
  dwread,ec,cf : DWord;
//  frmShow   : TfrmShow;
  pApp,pDir : PWideChar;
begin
  FCancelProcess:=false;
// Set the bInheritHandle flag so pipe handles are inherited.
  with saPipe do begin
    nLength:=sizeof(TSecurityAttributes);
    bInheritHandle:=TRUE;
    lpSecurityDescriptor:=nil;
    end;

 // The steps for redirecting child process's STDOUT:
 //     1. Save current STDOUT, to be restored later.
 //     2. Create anonymous pipe to be STDOUT for child process.
 //     3. Set STDOUT of the parent process to be write handle to
 //        the pipe, so it is inherited by the child process.
 //        (this is made instead by CreateProcess - StartupInfo, JR)
 //     4. Create a noninheritable duplicate of the read handle and
 //        close the inheritable read handle.

// Save the handle to the current STDOUT.
//    hSaveStdout:=GetStdHandle(STD_OUTPUT_HANDLE);
// Create a pipe for the child process's STDOUT.
  if not CreatePipe(hChildStdoutRd,hChildStdoutWr,@saPipe, 0) then begin
    if pfShowError in Flags then ErrorDialog(rsExecuteError,rsCreatePipeError);
    Result:=ERROR_PIPE_CONNECTED;
    exit;
    end;

// Create noninheritable read handle and close the inheritable read
// handle.
  if not DuplicateHandle(GetCurrentProcess,hChildStdoutRd,GetCurrentProcess,
                         @hChildStdoutRdDup , 0, FALSE,
                         DUPLICATE_SAME_ACCESS) then begin
    if pfShowError in Flags then ErrorDialog(rsExecuteError,rsDupHandleError);
    Result:=E_HANDLE;
    exit;
    end;
  CloseHandle(hChildStdoutRd);

// Create process to start Program
  FillChar(si, SizeOf(TStartupInfo), 0);
  with si do begin
    cb:=Sizeof(TStartupInfo);
    dwFlags:=STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    wShowWindow:=SW_SHOWNORMAL;
    if (pfConsole in Flags) and not (pfShowConsole in Flags) then hStdOutput:=hChildStdoutWr;
    end;

  cf:=NORMAL_PRIORITY_CLASS;
  if pfConsole in Flags then begin
    if pfShowConsole in Flags then cf:=cf or CREATE_NEW_CONSOLE else cf:=cf or CREATE_NO_WINDOW;
    end;
  if length(AppName)=0 then pApp:=nil else pApp:=pchar(AppName);
  if length(WorkDir)=0 then pDir:=nil else pDir:=pchar(WorkDir);

  if CreateProcess(pApp,               // Anwendungsname
                   pchar(Options),
                   nil,                // Security process
                   nil,                // Security thread
                   true,               // use InheritHandles
                   cf,                 // Creation flags
                   nil,                // Environment
                   pDir,               // Work directory
                   si,pi) then begin
//    while WaitForSingleObject(pi.hProcess,10)=WAIT_TIMEOUT do Application.ProcessMessages;
    if WaitTime=0 then begin  // wait for end
      while (WaitForSingleObject(pi.hProcess,100)<>WAIT_OBJECT_0) and not FCancelProcess
        do Application.ProcessMessages;
      if FCancelProcess then Result:=WAIT_TIMEOUT
      else Result:=0;
      end
    else begin   // wait for timeout
      if WaitForSingleObject(pi.hProcess,abs(WaitTime))<>WAIT_TIMEOUT then Result:=0
      else Result:=WAIT_TIMEOUT;
      end;
    if (Result=0) or IgnoreTimeout then begin
      if GetExitCodeProcess(pi.hProcess,ec) then begin
        if ec>0 then begin
          if ec<$10000 then Result:=ec or UserError;  // return exit code
          end;
        end
      else Result:=GetLastError;
      end;

    if (pfConsole in Flags) and (pfShowConsole in Flags) then TerminateProcess(pi.hProcess,0);
    CloseHandle(pi.hThread); CloseHandle(pi.hProcess);

// Close the write end of the pipe before reading from the
// read end of the pipe.
    if not CloseHandle(hChildStdoutWr) then begin
      if pfShowError in Flags then ErrorDialog(rsExecuteError,rsCloseHandleError);
      Result:=E_HANDLE;
      exit;
      end;
    if (Result=0) or (Result and UserError<>0) then begin
      FillChar(chBuf[0],BUFSIZE+1,#0); sa:='';
  // Read output from the child process, and write to parent's STDOUT.
      while ReadFile(hChildStdoutRdDup,chBuf[0],BUFSIZE,dwRead,nil)
            and (dwRead=BUFSIZE) do sa:=sa+chBuf;
      if dwRead>0 then begin
        chBuf[dwread]:=#0;
        sa:=sa+chBuf;
        end;
      end;
    s:=RawByteToUnicode(sa,CodePage);
    CloseHandle(hChildStdoutRdDup);
// copy console output
    if pfConsole in Flags then begin
      if assigned(Output) then Output.Text:=s
      else if (pfShowOutput in Flags) and (length(s)>0) then ShowText(AppName,s);
      end;
    end
  else Result:=GetLastError;
  end;

// Prozess mit Befehlszeile "CmdLine" starten
function ExecuteProcess (const CmdLine,WorkDir : string; Flags : TProcessFlags;
                         WaitTime : integer = 0; IgnoreTimeout : boolean = false;
                         Output : TStringList = nil) : HResult;
begin
  Result:=ExecuteProcess('',CmdLine,WorkDir,Flags,WaitTime,IgnoreTimeout,Output);
  end;

function ExecuteProcess (const CmdLine,WorkDir : string; Output : TStringList; CodePage : integer) : HResult;
begin
  Result:=ExecuteProcess('',CmdLine,WorkDir,[],0,false,Output,CodePage);
  end;

function ExecuteConsoleProcess (const CmdLine,WorkDir : string; Output : TStringList; CodePage : integer) : HResult;
begin
  Result:=ExecuteProcess('',CmdLine,WorkDir,[pfConsole],0,false,Output,CodePage);
  end;

procedure CancelProcess;
begin
  FCancelProcess:=true;
  end;

{ ------------------------------------------------------------------- }
// Prozess starten, nicht auf Ende warten
function StartProcess (const CmdLine,WorkDir : string) : THandle;
var
  si        : TStartupInfo;
  pi        : TProcessInformation;
  pwd       : PChar;
begin
// Create process to start Program
  FillChar(si, SizeOf(TStartupInfo), 0);
  with si do begin
    cb := Sizeof(TStartupInfo);
    dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    wShowWindow:=SW_SHOWNORMAL;
    end;
  if length(WorkDir)>0 then pwd:=pchar(WorkDir) else pwd:=nil;
  if CreateProcess(nil,                // Anwendungsname
                   pchar(CmdLine),
                   nil,                // Security
                   nil,                // Security
                   true,               // use InheritHandles
                   NORMAL_PRIORITY_CLASS, // Priorität
                   nil,                   // Environment
                   pwd,                   // Verzeichnis
                   si,pi) then begin
     Result:=pi.hProcess;
     end
   else begin
     Result:=0;
     raise EProcessError.Create (SysErrorMessage(GetLastError));
     end;
   end;

// Prozess als anderer Benutzer starten, nicht auf Ende warten
function StartProcessAsUser (const UserName,Domain,Password,CmdLine,WorkDir : WideString) : THandle;
var
  si        : TStartupInfoW;
  pi        : TProcessInformation;
  d,w       : PWideChar;
  ec        : dword;
begin
// Create process to start Program
  FillChar(si, SizeOf(TStartupInfo), 0);
  with si do begin
    cb := Sizeof(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow:=SW_SHOW;
    end;
  if length(Domain)=0 then d:=nil else d:=pwidechar(Domain);
  if length(WorkDir)=0 then w:=nil else w:=pwidechar(WorkDir);
  if CreateProcessWithLogonW (pwidechar(UserName),d,pwidechar(Password),
                   LOGON_WITH_PROFILE,
                   nil,                   // Anwendungsname
                   pwidechar(CmdLine),    // command line
                   NORMAL_PRIORITY_CLASS, // Priorität
                   nil,                   // Environment
                   w,                     // Verzeichnis
                   si,pi) then begin
     Result:=pi.hProcess;
     end
   else begin
     Result:=0; ec:=GetLastError;
     raise EProcessError.Create (SysErrorMessage(ec)+' (0x'+IntToHex(ec,8)+')');
     end;
   end;

{ ------------------------------------------------------------------- }
// Prüfen, ob gestarterer Prozess noch läuft
// ph : Handle des laufenden Prozesses
// WaitTime > 0 : Warte auf das Ende des Prozesses für max. "WaitTime" in Millisekunden
//          = 0 : Warten auf den gestarteten Prozess
// IgnoreTimeout = true: Timeout nicht als Fehler zurück geben
// Result: = 0: ok
//         > 0 :  Bit 29 ($20000000) gesetzt : ExitCode = Result and $FF
//                sonst  Systemfehler von GetLastErr (siehe SysErrorMessage)
function WaitForProcess (ph : THandle; WaitTime : integer = 0; IgnoreTimeout : boolean = false) : HResult;
var
  ec : DWORD;
begin
  if WaitTime=0 then begin  // wait for end
    while WaitForSingleObject(ph,100)<>WAIT_OBJECT_0 do Application.ProcessMessages;
    Result:=0;
    end
  else begin   // wait for timeout
    if WaitForSingleObject(ph,WaitTime)<>WAIT_TIMEOUT then Result:=0
    else Result:=WAIT_TIMEOUT;
    end;
  if (Result=0) or IgnoreTimeout then begin
    if GetExitCodeProcess(ph,ec) then begin
      if ec>0 then Result:=ec or UserError;  // return exit code
      end
    else Result:=GetLastError;
    CloseHandle(ph);
    end;
  end;

procedure StopProcess (ph : THandle);
begin
  TerminateProcess(ph,0);
  CloseHandle(ph);
  end;

{ ------------------------------------------------------------------- }
// Programm mit ShellExecute starten
function ShellExecuteProcess (const ExecuteFile,ParamString,WorkDir : string;
      RunAs : boolean = false; WaitTime : integer = 0; IgnoreTimeout : boolean = false) : HResult;
var
   SEInfo : TShellExecuteInfo;
   ec : DWord;
begin
  FillChar(SEInfo,SizeOf(SEInfo), 0);
  SEInfo.cbSize:=SizeOf(TShellExecuteInfo);
  with SEInfo do begin
    fMask:=SEE_MASK_NOCLOSEPROCESS;
    if RunAs then lpVerb:=PChar('runas') else lpVerb:=PChar('open');
    lpFile:=PChar(ExecuteFile);
    lpParameters:=PChar(ParamString);
    if length(WorkDir)=0 then lpDirectory:=nil else lpDirectory:=pchar(WorkDir);
    nShow:=SW_SHOWNORMAL;
    end;
  if ShellExecuteEx(@SEInfo) then begin
    if WaitTime=0 then begin  // wait for end
      while WaitForSingleObject(SEInfo.hProcess,100)<>WAIT_OBJECT_0 do Application.ProcessMessages;
      Result:=0;
      end
    else begin   // wait for timeout
      if WaitForSingleObject(SEInfo.hProcess,abs(WaitTime))<>WAIT_TIMEOUT then Result:=0
      else Result:=WAIT_TIMEOUT;
      end;
    if (Result=0) or IgnoreTimeout then begin
      if GetExitCodeProcess(SEInfo.hProcess,ec) then begin
        if ec>0 then Result:=ec or UserError;  // return exit code
        end
      else Result:=GetLastError;
      end;
    end
  else Result:=GetLastError;
  end;

{ ---------------------------------------------------------------- }
// Programm mit erhöhten Rechten starten
function RunElevated (const ExecuteFile,ParamString,WorkDir : string) : boolean;
begin
  if not IsElevatedUser then begin
    Result:=ShellExecute(0,'runas',pchar(ExecuteFile),pchar(ParamString),pchar(WorkDir),SW_SHOWNORMAL)>32;
    end
  else Result:=false;
  end;

function GetParams : string;
begin
  Result:=CmdLine;
  ReadNxtQuotedStr(Result,' ','"');
  end;

function RunElevated (const ExecuteFile,ParamString : string) : boolean;
var
  sd : string;
begin
  GetDir(0,sd);
  Result:=RunElevated(ExecuteFile,ParamString,sd);
  end;

function RunElevated (const ExecuteFile : string) : boolean;
begin
  Result:=RunElevated(ExecuteFile,GetParams);
  end;

initialization
  FCancelProcess:=false;

end.

