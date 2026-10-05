@echo off
rem Runs the server in the background for the scheduled task created by scripts\install-service-windows.ps1.
rem Settings come from scripts\service.env.cmd (written by the installer; NODE_EXE, PORT, HOST, SP_COMBAT, SP_VERIFY).
rem HOST defaults to '::' (dual-stack): the server then answers on IPv6 and IPv4 alike. service.env.cmd can override it.
rem Output goes to logs\server.log (rotated at 10 MB to logs\server.old.log); the server is restarted 5 s after it exits.
setlocal EnableExtensions
cd /d "%~dp0.."
set "NODE_EXE=node"
rem Bind dual-stack by default: a Node server listening on '::' also accepts IPv4 (ipv6Only stays off).
rem Set before the env file so service.env.cmd (written by the installer) can still override it.
set "HOST=::"
if exist "%~dp0service.env.cmd" call "%~dp0service.env.cmd"
if not exist "logs" mkdir "logs"

:loop
if exist "logs\server.log" for %%A in ("logs\server.log") do if %%~zA GTR 10485760 move /y "logs\server.log" "logs\server.old.log" >nul
echo [%date% %time%] starting: "%NODE_EXE%" server\index.js (PORT=%PORT% HOST=%HOST%) >> "logs\server.log"
"%NODE_EXE%" server\index.js >> "logs\server.log" 2>&1
echo [%date% %time%] server exited with code %errorlevel%, restarting in 5 s >> "logs\server.log"
ping -n 6 127.0.0.1 >nul
goto loop
