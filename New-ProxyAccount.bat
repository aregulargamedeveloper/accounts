@echo off
setlocal
if exist "%~dp0.git" goto createAccount
where git >nul 2>&1
if errorlevel 1 (
  echo Git is required to create and publish accounts. Install Git for Windows, then double-click this file again.
  echo.
  pause
  exit /b 1
)
set "ACCOUNT_REPO=%USERPROFILE%\accounts"
if not exist "%ACCOUNT_REPO%\.git" set "ACCOUNT_REPO=%LOCALAPPDATA%\ProxyAccounts"
if not exist "%ACCOUNT_REPO%\.git" (
  echo Downloading the private account manager to "%ACCOUNT_REPO%"...
  git clone https://github.com/aregulargamedeveloper/accounts.git "%ACCOUNT_REPO%"
  if errorlevel 1 (
    echo Could not clone the accounts repository. Check your internet connection and Git access.
    echo.
    pause
    exit /b 1
  )
)
call "%ACCOUNT_REPO%\New-ProxyAccount.bat"
exit /b %errorlevel%
:createAccount
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-ProxyAccount.ps1"
if errorlevel 1 (
  echo Account creation failed.
  echo.
  pause
  exit /b 1
)
echo.
set /p publishNow=Publish this account to GitHub now? Press Enter for Yes, or type N:
if /I "%publishNow%"=="N" goto manual
git diff --cached --quiet
if errorlevel 1 goto publishFailed
git add accounts.json
if errorlevel 1 goto publishFailed
git commit -m "Add proxy account"
if errorlevel 1 goto publishFailed
git push
if errorlevel 1 goto publishFailed
echo.
echo Account published. Share the username and 5-character password privately.
goto done
:manual
echo.
echo Account saved locally. To activate it later, run:
echo   git add accounts.json
echo   git commit -m "Add proxy account"
echo   git push
goto done
:publishFailed
echo.
echo Automatic publish failed. The account is saved locally. Run these commands after fixing Git:
echo   git add accounts.json
echo   git commit -m "Add proxy account"
echo   git push
:done
echo.
pause
