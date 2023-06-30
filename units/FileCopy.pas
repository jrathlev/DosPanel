(* Delphi Unit (Unicode)
   Copy file
   ==========================================================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1.0 - June 2023
   *)

unit FileCopy;

interface

uses WinApi.Windows, System.Classes, System.SysUtils;

const
  defBlockSize = 256*1024;

type
{ ---------------------------------------------------------------- }
  ECopyError = class(EInOutError)
  public
    constructor Create (const ErrString : string);
    end;

// Copy file with timestamp and attributes
// AAttr = -1: copy original attributes
procedure CopyFileTS (const srcfilename,destfilename : String;
                      AAttr : integer = -1; BlockSize : integer = defBlockSize);

implementation

uses FileConsts;

{ ---------------------------------------------------------------- }
constructor ECopyError.Create(const ErrString : string);
begin
  inherited Create (ErrString);
  end;

{ ---------------------------------------------------------------- }
// get time (UTC) of last file write
function GetFileLastWriteTime(const FileName: string): TFileTime;
var
  Handle   : THandle;
  FindData : TWin32FindData;
begin
  Handle:=FindFirstFile(PChar(FileName),FindData);
  if Handle <> INVALID_HANDLE_VALUE then begin
    WinApi.Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
      Result:=FindData.ftLastWriteTime; Exit;
      end;
    end;
  with Result do begin
    dwLowDateTime:=0; dwHighDateTime:=0;
    end;
  end;

// set time (UTC) of last file write
// CheckTime = true: Change FileTime to actual time if out of range
function SetFileLastWriteTime(const FileName: string; FileTime : TFileTime) : integer;
var
  Handle   : THandle;
begin
  Handle:=FileOpen(FileName,fmOpenWrite);
  if Handle=THandle(-1) then Result:=GetLastError
  else begin
    if SetFileTime(Handle,nil,nil,@FileTime) then Result:=0
    else Result:=GetLastError;
    FileClose(Handle);
    end;
  end;

{ ------------------------------------------------------------------- }
// Copy file with timestamp and attributes
// AAttr = -1: copy original attributes
procedure CopyFileTS (const srcfilename,destfilename : String;
                      AAttr : integer = -1; BlockSize : integer = defBlockSize);
var
  srcfile, destfile : TFileStream;
  FTime             : TFileTime;
  Buffer            : pointer;
  NRead,NWrite      : Integer;
  Attr              : word;
begin
  if AnsiSameText(srcfilename,destfilename) then Exit;
  if FileExists(srcfilename) and (length(destfilename)>0) then begin
    GetMem(Buffer,BlockSize);
    try
      FTime:=GetFileLastWriteTime(srcfilename);
      if AAttr<0 then Attr:=FileGetAttr(srcfilename) else Attr:=AAttr;
      try
        srcfile:=TFileStream.Create(srcfilename,fmOpenRead+fmShareDenyNone);
      except
        on EFOpenError do
          raise ECopyError.Create (Format(rsErrOpening,[srcfilename]));
        end;
      // Ziel immer überschreiben
      if FileExists(destfilename) then begin
        if FileSetAttr(destfilename,faArchive)<>0 then begin
          try srcfile.Free; except end;
          raise ECopyError.Create (Format(rsErrCreating,[destfilename]));
          end;
        end;
      try
        destfile:=TFileStream.Create(destfilename,fmCreate);
      except
        on EFCreateError do begin
          try srcfile.Free; except end;
          raise ECopyError.Create (Format(rsErrCreating,[destfilename]));
          end;
        end;
      repeat
        try
          NRead:=srcfile.Read(Buffer^,BlockSize);
        except
          on EReadError do
            raise ECopyError.Create (Format(rsErrReading,[srcfilename]));
          end;
        try
          NWrite:=destfile.Write(Buffer^,NRead);
          if NWrite<NRead then  // Ziel-Medium voll
            raise ECopyError.Create (Format(rsErrWriting,[destfilename]));
        except
          on EWriteError do
            raise ECopyError.Create (Format(rsErrWriting,[destfilename]));
          end;
        until NRead<BlockSize;
      if  destfile.Size<>srcfile.Size then begin
      // z.B. wenn "srcfile" gelockt ist (siehe LockFile)
        srcfile.Free; destfile.Free;
        raise ECopyError.Create (Format(rsErrReading,[srcfilename]));
        end;
      try
        srcfile.Free;
      except
        on EFileStreamError do
          raise ECopyError.Create (Format(rsErrClosing,[srcfilename]));
        end;
      try
        destfile.Free;
      except
        on EFileStreamError do
          raise ECopyError.Create (Format(rsErrClosing,[destfilename]));
        end;
      if SetFileLastWriteTime(destfilename,FTime)=0 then begin
        if FileSetAttr(destfilename,Attr)>0 then
          raise ECopyError.Create (Format(rsErrSetAttr,[destfilename]));
        end
      else
        raise ECopyError.Create (Format(rsErrTimeStamp,[destfilename]));
    finally
      FreeMem(Buffer,BlockSize);
      end;
    end
  else raise ECopyError.Create (Format(rsErrNotFound,[srcfilename]));
  end;

end.
