Name "geai ${MAJORVERSION}.${MINORVERSION}.${BUILDVERSION}" # VERSION variables set through command line arguments
InstallDir "$InstDir"
OutFile "${OUTPUTFILE}" # set through command line arguments

# Links for "Add/Remove Programs"
!define HELPURL "https://github.com/ethereumai/go-ethereumai/issues"
!define UPDATEURL "https://github.com/ethereumai/go-ethereumai/releases"
!define ABOUTURL "https://github.com/ethereumai/go-ethereumai#ethereumai-go"
!define /date NOW "%Y%m%d"

PageEx license
  LicenseData {{.License}}
PageExEnd

# Install geai binary
Section "Geai" GEAI_IDX
  SetOutPath $INSTDIR
  file {{.Geai}}

  # Create start menu launcher
  createDirectory "$SMPROGRAMS\${APPNAME}"
  createShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\geai.exe" "--fast" "--cache=512"
  createShortCut "$SMPROGRAMS\${APPNAME}\Attach.lnk" "$INSTDIR\geai.exe" "attach" "" ""
  createShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "" ""

  # Firewall - remove rules (if exists)
  SimpleFC::AdvRemoveRule "Geai incoming peers (TCP:30303)"
  SimpleFC::AdvRemoveRule "Geai outgoing peers (TCP:30303)"
  SimpleFC::AdvRemoveRule "Geai UDP discovery (UDP:30303)"

  # Firewall - add rules
  SimpleFC::AdvAddRule "Geai incoming peers (TCP:30303)" ""  6 1 1 2147483647 1 "$INSTDIR\geai.exe" "" "" "EthereumAI" 30303 "" "" ""
  SimpleFC::AdvAddRule "Geai outgoing peers (TCP:30303)" ""  6 2 1 2147483647 1 "$INSTDIR\geai.exe" "" "" "EthereumAI" "" 30303 "" ""
  SimpleFC::AdvAddRule "Geai UDP discovery (UDP:30303)" "" 17 2 1 2147483647 1 "$INSTDIR\geai.exe" "" "" "EthereumAI" "" 30303 "" ""

  # Set default IPC endpoint (https://github.com/ethereumai/EIPs/issues/147)
  ${EnvVarUpdate} $0 "ETHEREUMAI_SOCKET" "R" "HKLM" "\\.\pipe\geai.ipc"
  ${EnvVarUpdate} $0 "ETHEREUMAI_SOCKET" "A" "HKLM" "\\.\pipe\geai.ipc"

  # Add instdir to PATH
  Push "$INSTDIR"
  Call AddToPath
SectionEnd

# Install optional develop tools.
Section /o "Development tools" DEV_TOOLS_IDX
  SetOutPath $INSTDIR
  {{range .DevTools}}file {{.}}
  {{end}}
SectionEnd

# Return on top of stack the total size (as DWORD) of the selected/installed sections.
Var GetInstalledSize.total
Function GetInstalledSize
  StrCpy $GetInstalledSize.total 0

  ${if} ${SectionIsSelected} ${GEAI_IDX}
    SectionGetSize ${GEAI_IDX} $0
    IntOp $GetInstalledSize.total $GetInstalledSize.total + $0
  ${endif}

  ${if} ${SectionIsSelected} ${DEV_TOOLS_IDX}
    SectionGetSize ${DEV_TOOLS_IDX} $0
    IntOp $GetInstalledSize.total $GetInstalledSize.total + $0
  ${endif}

  IntFmt $GetInstalledSize.total "0x%08X" $GetInstalledSize.total
  Push $GetInstalledSize.total
FunctionEnd

# Write registry, Windows uses these values in various tools such as add/remove program.
# PowerShell: Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, InstallLocation, InstallDate | Format-Table –AutoSize
function .onInstSuccess
  # Save information in registry in HKEY_LOCAL_MACHINE branch, Windows add/remove functionality depends on this
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "DisplayName" "${GROUPNAME} - ${APPNAME} - ${DESCRIPTION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "InstallDate" "${NOW}"
  # Wait for Alex
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "Publisher" "${GROUPNAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "HelpLink" "${HELPURL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "DisplayVersion" "${MAJORVERSION}.${MINORVERSION}.${BUILDVERSION}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "VersionMajor" ${MAJORVERSION}
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "VersionMinor" ${MINORVERSION}
  # There is no option for modifying or repairing the install
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "NoRepair" 1

  Call GetInstalledSize
  Pop $0
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GROUPNAME} ${APPNAME}" "EstimatedSize" "$0"

  # Create uninstaller
  writeUninstaller "$INSTDIR\uninstall.exe"
functionEnd

Page components
Page directory
Page instfiles
