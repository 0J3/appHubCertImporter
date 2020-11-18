@echo off
CLS

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

TITLE WAITING FOR ADMIN PERMISSIONS

ECHO.
ECHO *********************************************
ECHO * Invoking UAC for Privilege Escalation     *
ECHO *                                           *
ECHO * Please accept the prompt for admin        *
ECHO * permissions to continue...                *
ECHO *********************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

CLS

TITLE SETUP - Waiting for confirmation...

echo ---
echo Pending Setup Confirmation
echo ---
echo Please note, that by running this software, you accept the terms of the AGPL 3.0, or at your wish, any later version
echo The AGPL-3.0 can be found here: https://gnu.org/licenses/agpl-3.0.md
echo ---
echo Press any key to begin the setup.
echo ---

PAUSE >nul

cls

TITLE SETUP - Making TMP Directory - Please Wait...

cd "%TEMP%"

mkdir appHub-CERT

cd appHub-CERT

TITLE SETUP - Downloading File - Please Wait...

bitsadmin /transfer "CERTIFICATE-APPHUB" "https://github.com/0J3/appHubCertImporter/blob/master/default.cer?raw=true" "%TEMP%\appHub-CERT\cert.crt"

TITLE SETUP - Installing Certificate - Please Wait...

certutil -addstore "Root" "cert.crt"

TITLE SETUP - Cleaning Up... - Please Wait...

del cert.crt

cd ..

rmdir appHub-CERT

cls

TITLE Done!

echo --- Finished Installation ---
echo Press any key to close this window...

PAUSE >nul
