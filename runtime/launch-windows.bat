@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%HERMES_LOCAL_STT_VENV%"
if "%VENV_DIR%"=="" set "VENV_DIR=%SCRIPT_DIR%.venv"
set "HOST=%HERMES_LOCAL_STT_HOST%"
if "%HOST%"=="" set "HOST=0.0.0.0"
set "PORT=%HERMES_LOCAL_STT_PORT%"
if "%PORT%"=="" set "PORT=8177"

if not exist "%VENV_DIR%\Scripts\python.exe" (
  echo Missing uv-managed runtime env: %VENV_DIR%
  echo Run %SCRIPT_DIR%setup-windows.bat first.
  exit /b 1
)

"%VENV_DIR%\Scripts\python.exe" "%SCRIPT_DIR%server.py" --host %HOST% --port %PORT%
