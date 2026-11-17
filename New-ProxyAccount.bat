@echo off
setlocal
if not exist "%~dp0.git" (
  echo This folder is not a Git clone of the accounts repo.
  echo First run: git clone https://github.com/aregulargamedeveloper/accounts.git
  echo Then open the cloned accounts folder and double-click this file.
  echo.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-ProxyAccount.ps1"
if errorlevel 1 (
  echo Account creation failed.
) else (
  echo.
  echo To activate it, run these commands in this folder:
  echo   git add accounts.json
  echo   git commit -m "Add proxy account"
  echo   git push
)
echo.
pause

