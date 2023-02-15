; Setup script for DosPanel
; =========================
;  © Dr. J. Rathlev, D-24222 Schwentinental (info(a)rathlev-home.de)

;  The contents of this file may be used under the terms of the
;  Mozilla Public License ("MPL") or
;  GNU Lesser General Public License Version 2 or later (the "LGPL")

;  Software distributed under this License is distributed on an "AS IS" basis,
;  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
;  the specific language governing rights and limitations under the License.

#define ApplicationVersion GetFileVersion('..\Release\Win32\DosPanel.exe')

[Setup]
PrivilegesRequired=admin
AppName=Dos Panel
AppVerName=Dos Panel {#ApplicationVersion}
AppVersion={#ApplicationVersion}
AppPublisher=Dr. J. Rathlev
AppPublisherURL=http://www.rathlev-home.de/?tools/othertools.html
AppSupportURL=http://www.rathlev-home.de/?tools/othertools.html
AppUpdatesURL=http://www.rathlev-home.de/?tools/othertools.html
AppCopyright=Copyright © 2011-2023 Dr. J. Rathlev
VersionInfoVersion={#ApplicationVersion}
DefaultDirName={commonpf}\DosPanel
DefaultGroupName=Dos Panel
OutputDir=.
OutputBaseFilename=dospanel-setup
SetupIconFile=DosPanel.ico
UninstallDisplayIcon={app}\DosPanel-u.ico
WizardImageFile=Dp-Install-Image.bmp
WizardSmallImageFile=Dp-Install-Small.bmp
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes
ShowLanguageDialog=auto
DisableDirPage=auto
DisableWelcomePage=no
DisableProgramGroupPage=auto

[Languages]
Name: "en"; MessagesFile: compiler:Default.isl; LicenseFile:"..\docs\license-en.rtf"; InfoBeforeFile:"..\docs\notes-en.rtf";
Name: "de"; MessagesFile: compiler:Languages\German.isl; LicenseFile:"..\docs\license-de.rtf"; InfoBeforeFile:"..\docs\notes-de.rtf";

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\Release\Win32\DosPanel.exe"; DestDir: "{app}"; Flags: ignoreversion restartreplace
Source: "..\Release\Win32\locale\*.mo"; DestDir: "{app}\locale"; Flags: recursesubdirs ignoreversion restartreplace
Source: "..\Release\Win32\language.cfg"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion restartreplace
Source: "..\docs\license-*.rtf"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\docs\DosPanel-de.chm"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\docs\DosPanel-en.chm"; DestDir: "{app}"; Flags: ignoreversion
Source: "DosPanel-u.ico"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\Dos Panel"; Filename: "{app}\DosPanel.exe"
Name: "{group}\{cm:UninstallProgram,Dos Panel}"; Filename: "{uninstallexe}"; IconFilename: "{app}\DosPanel-u.ico"
Name: "{commondesktop}\Dos Panel"; Filename: "{app}\DosPanel.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\DosPanel.exe"; Description: "{cm:LaunchProgram,Dos Panel}"; Flags: nowait postinstall runasoriginaluser


