@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"

rem ---- Configuracao: cole sua chave Groq entre as aspas abaixo ----
set "GROQ_KEY="
set "SITE_URL=https://ditado-new.vercel.app/"
set "BROWSER_PREF=chrome"
if exist "config.txt" for /f "usebackq tokens=1,* delims==" %%A in ("config.txt") do (
  if /i "%%A"=="SITE_URL" set "SITE_URL=%%B"
  if /i "%%A"=="BROWSER" set "BROWSER_PREF=%%B"
)

if "%GROQ_KEY%"=="" (
  echo Edite Abrir-Ditado.bat e cole sua chave Groq em set "GROQ_KEY=" ^(linha 7^).
  pause
  exit /b 1
)

rem ---- Backup: usa o ditado-backup*.json mais recente desta pasta (se existir) ----
set "BACKUP_FILE="
for /f "delims=" %%F in ('dir /b /a-d /o-d "ditado-backup*.json" 2^>nul') do if not defined BACKUP_FILE set "BACKUP_FILE=%%F"
set "BK_PARAM="
if defined BACKUP_FILE (
  start "" /b powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0Servir-Backup.ps1" -Path "%~dp0%BACKUP_FILE%" -Port 47831
  set "BK_PARAM=&backup=http%%3A%%2F%%2F127.0.0.1%%3A47831%%2Fbackup.json"
)

set "URL=%SITE_URL%?key=%GROQ_KEY%&engine=whisper%BK_PARAM%"

rem ---- Localiza Chrome e Edge ----
set "CHROME="
for %%P in ("%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" "%LocalAppData%\Google\Chrome\Application\chrome.exe") do if exist %%P if not defined CHROME set "CHROME=%%~P"
set "EDGE="
for %%P in ("%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe") do if exist %%P if not defined EDGE set "EDGE=%%~P"

if /i "%BROWSER_PREF%"=="edge" (
  if defined EDGE ( start "" "%EDGE%" --app="%URL%" & exit /b 0 )
  if defined CHROME ( start "" "%CHROME%" --app="%URL%" & exit /b 0 )
) else (
  if defined CHROME ( start "" "%CHROME%" --app="%URL%" & exit /b 0 )
  if defined EDGE ( start "" "%EDGE%" --app="%URL%" & exit /b 0 )
)
echo Nao encontrei Chrome nem Edge instalados.
pause
exit /b 1
