@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"

rem ---- Configuracao (edite em config.txt / groq-key.txt) ----
set "SITE_URL=https://douglasribeiro1.github.io/ditado-new/"
set "BROWSER_PREF=chrome"
set "GROQ_KEY="
if exist "config.txt" for /f "usebackq tokens=1,* delims==" %%A in ("config.txt") do (
  if /i "%%A"=="SITE_URL" set "SITE_URL=%%B"
  if /i "%%A"=="BROWSER" set "BROWSER_PREF=%%B"
)
if exist "groq-key.txt" set /p GROQ_KEY=<"groq-key.txt"

if "%GROQ_KEY%"=="" (
  echo Cole sua chave Groq em groq-key.txt ^(veja groq-key.exemplo.txt^) e abra de novo.
  pause
  exit /b 1
)

set "URL=%SITE_URL%?key=%GROQ_KEY%&engine=whisper"

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
