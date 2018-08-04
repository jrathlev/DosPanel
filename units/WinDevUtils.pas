(* Delphi Unit
   collection of subroutines for Windows drives and devices
   ===========================================================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Dec. 2016
   last updated: May 2017
   *)

unit WinDevUtils;

interface

{$Z4}        // use DWORD (4 bytes for enumerations)
{$Align on}  // align records

uses WinApi.Windows, System.Classes, System.SysUtils;

type
  TDriveType = (dtUnknown,dtNoRoot,dtRemovable,dtFixed,dtRemote,dtCdRom,dtRamDisk);
  TDriveTypes = set of TDriveType;
  TPathType =  (ptNotAvailable,ptFixed,ptRelative,ptRemovable,ptRemote);

  TDriveProperties = class(TObject)
    Number    : integer;
    DriveType : TDriveType;
    DriveName,
    VolName   : string
    end;

  STORAGE_PROPERTY_ID = (
    StorageDeviceProperty,
    StorageAdapterProperty,
    StorageDeviceIdProperty,
    StorageDeviceUniqueIdProperty,              // See storduid.h for details
    StorageDeviceWriteCacheProperty,
    StorageMiniportProperty,
    StorageAccessAlignmentProperty,
    StorageDeviceSeekPenaltyProperty,
    StorageDeviceTrimProperty,
    StorageDeviceWriteAggregationProperty);

  STORAGE_QUERY_TYPE = (
    PropertyStandardQuery,              // Retrieves the descriptor
    PropertyExistsQuery,                // Used to test whether the descriptor is supported
    PropertyMaskQuery,                  // Used to retrieve a mask of writeable fields in the descriptor
    PropertyQueryMaxDefined);           // use to validate the value

  PStoragePropertyQuery = ^TStoragePropertyQuery;
  _STORAGE_PROPERTY_QUERY = record
    PropertyId : STORAGE_PROPERTY_ID;
    QueryType : STORAGE_QUERY_TYPE;
    AdditionalParameters : byte;
    end;
  TStoragePropertyQuery = _STORAGE_PROPERTY_QUERY;

  STORAGE_BUS_TYPE = (
    BusTypeUnknown = 0,
    BusTypeScsi,
    BusTypeAtapi,
    BusTypeAta,
    BusType1394,
    BusTypeSsa,
    BusTypeFibre,
    BusTypeUsb,
    BusTypeRAID,
    BusTypeiScsi,
    BusTypeSas,
    BusTypeSata,
    BusTypeSd,
    BusTypeMmc,
    BusTypeVirtual,
    BusTypeFileBackedVirtual,
    BusTypeMax);
  TBusType = STORAGE_BUS_TYPE;

  PStorageDeviceDescriptor = ^TStorageDeviceDescriptor;
  STORAGE_DEVICE_DESCRIPTOR = record
    Version, Size : DWORD;
    DeviceType, DeviceTypeModifier : byte;
    RemovableMedia, CommandQueueing : boolean;
    VendorIdOffset, ProductIdOffset,
    ProductRevisionOffset, SerialNumberOffset : DWORD;
    BusType : STORAGE_BUS_TYPE;
    RawPropertiesLength : DWORD;
    RawDeviceProperties : byte;
    end;
  TStorageDeviceDescriptor = STORAGE_DEVICE_DESCRIPTOR;

const
  DriveTypeNames : array [TDriveType] of string =
    ('Unknown','Not mounted','Removable','Fixed','Remote','CD/DVD','Ramdisk');
  BusNames : array [TBusType] of string =
    ('Unknown','SCSI','Atapi', 'ATA','IEEE1394','SSA','Fiber channel','USB','RAID',
     'iSCSI','SCSI (SAS)','SATA','SD','MMC','Virtual','File-backed virtual','Unknown');

// Typ eines Laufwerkes ermitteln
function DriveType (const Path : string) : TDriveType;

// Typ eines Pfades ermitteln (siehe TPathtype)
function CheckPath (const Path : string) : TPathType;

// Removable oder Fixed
function IsLocalDrive (const Path : string) : boolean;

// check if system drive
function IsSystemDrive (const Path : string) : boolean;

// Prüfe Laufwerk auf Verfügbarkeit
function CheckForDriveAvailable (const Path : string; var VolumeID : string) : boolean; overload;
function CheckForDriveAvailable (const Path : string) : boolean; overload;

// Liste aller Laufwerke der Typen "UseTypes" aufbauen
procedure BuildDriveList(DriveList : TStrings; UseTypes : TDriveTypes);

// Zu einem Datenträgernamen gehörendes Laufwerk ermitteln
function GetDriveLetterForVolume (const Vol : string; FirstDrive : integer) : string;

function GetDriveForVolume (const VolName : string; var DriveName : string;
  OnlyMounted : boolean = false) : integer;
function DriveForVolume (const VolName : string; OnlyMounted : boolean = false) : string;

function PathIsAvailable (const Path : string) : boolean;
function CheckForWritablePath (const Path : string) : boolean;

function GetStorageProperty (const Drive : string; var StorageProperty : TStorageDeviceDescriptor) : boolean;
function GetBusType (const Drive : string) : TBusType;
function IsRemovableDrive (const Drive : string) : boolean;

implementation

uses UnitConsts, WinApiUtils;

// Typ eines Laufwerkes ermitteln
function DriveType (const Path : string) : TDriveType;
var
  Drive : string;
begin
  Drive:=ExtractFileDrive(Path)+'\';
  case GetDriveType(pchar(Drive)) of
  DRIVE_NO_ROOT_DIR : Result:=dtNoRoot;
  DRIVE_REMOVABLE   : Result:=dtRemovable;
  DRIVE_FIXED       : Result:=dtFixed;
  DRIVE_REMOTE      : Result:=dtRemote;
  DRIVE_CDROM       : Result:=dtCdRom;
  DRIVE_RAMDISK     : Result:=dtRamDisk;
  else Result:=dtUnknown;
    end;
// some Windows 10 systems returns DRIVE_FIXED also for USB connected storage media
  if (Result=dtFixed) and IsRemovableDrive(Drive) then Result:=dtRemovable;
  end;

// Typ eines Pfades ermitteln (siehe TPathType)
function CheckPath (const Path : string) : TPathType;
var
  dr : string;
  dt : TDriveType;
begin
  dr:=ExtractFileDrive(IncludeTrailingPathDelimiter(Path));
  if length(dr)>0 then begin
    if AnsiSameText(copy(dr,1,2),'\\?\Volume{') then Result:=ptFixed
    else if (copy(dr,1,2)='\\') then Result:=ptRemote    // Netzwerkumgebung
    else begin                                      // Pfad mit Laufwerksangabe
      dt:=DriveType(dr);
      case dt of
      dtRemote : Result:=ptRemote;          // Netzlaufwerk
      dtUnknown,
      dtNoRoot : Result:=ptNotAvailable;    // nicht verfügbar
      dtCdRom,
      dtRemovable : Result:=ptRemovable;    // Laufwerk mit Wechselmedium
      else Result:=ptFixed;
        end;
      end;
    end
  else Result:=ptRelative;
  end;

function IsLocalDrive (const Path : string) : boolean;
var
  pt : TPathType;
begin
  pt:=CheckPath(Path);
  Result:=(pt=ptFixed) or (pt=ptRemovable);
  end;

function IsSystemDrive (const Path : string) : boolean;
var
  sd : string;
var
  p : pchar;
begin
  p:=StrAlloc(MAX_PATH+1);
  GetSystemDirectory (p,MAX_PATH+1);
  Result:=AnsiSameText(ExtractFileDrive(Path),ExtractFileDrive(p));
  Strdispose(p);
  end;

// Prüfe Laufwerk auf Verfügbarkeit
function CheckForDriveAvailable (const Path : string; var VolumeID : string) : boolean;
var
  v : pchar;
  d : string;
  n,cl,sf : dword;
begin
  d:=IncludeTrailingPathDelimiter(ExtractFileDrive(Path));
  n:=50; v:=StrAlloc(n);
  Result:=GetVolumeInformation(pchar(d),v,n,nil,cl,sf,nil,0);
  if Result then VolumeID:=Trim(v)  // remove leading and trailing spaces
  else VolumeID:=rsNotAvail;
  StrDispose(v);
  end;

function CheckForDriveAvailable (const Path : string) : boolean;
var
  s : string;
begin
  Result:=CheckForDriveAvailable(Path,s);
  end;

// Liste aller Laufwerke der Typen "UseTypes" aufbauen
procedure BuildDriveList (DriveList : TStrings; UseTypes : TDriveTypes);
var
  i         : integer;
  DriveBits : set of 0..25;
  dp        : TDriveProperties;
begin
  DriveList.Clear;
  Integer(DriveBits):=GetLogicalDrives;
  for i:=0 to 25 do begin
    if not (i in DriveBits) then Continue;
    dp:=TDriveProperties.Create;
    with dp do begin
      Number:=i;
      DriveName:=Char(i+Ord('A'))+':\';
      DriveType:=TDriveType(GetDriveType(PChar(DriveName)));
      CheckForDriveAvailable(DriveName,VolName);
      end;
    if dp.DriveType in UseTypes then DriveList.AddObject(dp.VolName,dp)
    else dp.Free;;
    end;
  end;

// Zu einem Datenträgernamen gehörendes Laufwerk ermitteln
function GetDriveLetterForVolume (const Vol : string; FirstDrive : integer) : string;
var
  i         : integer;
  DriveBits : set of 0..25;
  sd,sv     : string;
begin
  Result:='';
  Integer(DriveBits):=GetLogicalDrives;
  for i:=FirstDrive to 25 do begin
    if not (i in DriveBits) then Continue;
    sd:=Char(i+Ord('A'))+':\';
    if CheckForDriveAvailable(sd,sv) and AnsiSameText(sv,Vol) then begin
      Result:=sd; Exit;
      end;
    end;
  end;

// Get the drive name associated with a volume name
// if not mounted, return volume GUID
function GetDriveForVolume (const VolName : string; var DriveName : string;
  OnlyMounted : boolean = false) : integer;
var
  VolHandle,
  MountHandle : THandle;
  Buf         : array [0..MAX_PATH+1] of Char;
  VolumeId,
  VName       : string;
  n,cl,sf     : cardinal;
begin
  Result:=NO_ERROR;
  VolHandle:=FindFirstVolume(Buf,length(Buf));
  if VolHandle=INVALID_HANDLE_VALUE then Result:=GetLastError
  else begin
    repeat
      VolumeId:=Buf;
      if GetVolumePathNamesForVolumeName(PChar(VolumeId),Buf,length(Buf),n) then begin
        DriveName:=Buf;
        if GetVolumeInformation(pchar(VolumeId),Buf,length(Buf),nil,cl,sf,nil,0) then begin
          VName:=Buf;
          if AnsiSameText(VolName,VName) then begin
            if (length(DriveName)=0) then begin
              if OnlyMounted then DriveName:=''
              else DriveName:=VolumeId;
              end;
            Break;
            end
          else DriveName:='';
          end
        else begin
          Result:=GetLastError;
          if Result=ERROR_NOT_READY then DriveName:=''
          else Break;
          end;
        end
      else begin
        Result:=GetLastError; Break;
        end;
      until not FindNextVolume(VolHandle,Buf,length(Buf));
    end;
  FindVolumeClose(VolHandle);
  if length(DriveName)=0 then Result:=ERROR_NO_VOLUME_LABEL;
  end;

function DriveForVolume (const VolName : string; OnlyMounted : boolean = false) : string;
begin
  GetDriveForVolume(VolName,Result,OnlyMounted);
  end;

function PathIsAvailable (const Path : string) : boolean;
var
  n,m : int64;
begin
  Result:=GetDiskFreeSpaceEx(pchar(IncludeTrailingPathDelimiter(Path)),n,m,nil);
  end;

const
  TestName = 'test.tmp';

// Prüfen, ob in einen Pfad geschrieben werden kann
function CheckForWritablePath (const Path : string) : boolean;
var
  fsT      : TextFile;
  s        : string;
  nd       : boolean;
begin
  Result:=DirectoryExists(Path);
  nd:=not Result;
  if nd then Result:=ForceDirectories(Path);  // versuche Pfad zu erstellen
  if Result then begin
    s:=IncludeTrailingPathDelimiter(Path)+TestName;
    AssignFile (fsT,s);
    {$I-} Rewrite(fsT); {$I+}
    Result:=IoResult=0;
    if Result then begin
      CloseFile(fsT);
      DeleteFile(s);
      end;
    if nd then RemoveDir(Path);
    end;
  end;

function GetStorageProperty (const Drive : string; var StorageProperty : TStorageDeviceDescriptor) : boolean;
var
  Handle : THandle;
  query  : TStoragePropertyQuery;
  bytes  : DWORD;
begin
  Result:=false;
  ZeroMemory(@StorageProperty, SizeOf(TStorageDeviceDescriptor));
  Handle:=CreateFile(PChar('\\.\'+copy(Drive,1,2)),0,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil,OPEN_EXISTING,0,0);
  if Handle <> INVALID_HANDLE_VALUE then begin
    with query do begin
      PropertyId:=StorageDeviceProperty; QueryType:=PropertyStandardQuery;
      AdditionalParameters:=0;
      end;
    Result:=DeviceIoControl(Handle,IOCTL_STORAGE_QUERY_PROPERTY,
        @query,sizeof(query),@StorageProperty,sizeof(TStorageDeviceDescriptor),bytes,nil);
    CloseHandle(Handle);
    end;
  end;

function GetBusType (const Drive : string) : TBusType;
var
  StgProp : TStorageDeviceDescriptor;
begin
  if GetStorageProperty (Drive,StgProp) then Result:=StgProp.BusType
  else Result:=BusTypeUnknown;
  end;

function IsRemovableDrive (const Drive : string) : boolean;
var
  StgProp : TStorageDeviceDescriptor;
begin
  if GetStorageProperty (Drive,StgProp) then Result:=StgProp.RemovableMedia
  else Result:=false;
  end;

end.
