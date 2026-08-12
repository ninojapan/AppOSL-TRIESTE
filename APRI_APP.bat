@echo off
REM ============================================================
REM  Gestione O.S.L. Nave TRIESTE - Launcher completo
REM  (questo e' il file da usare tutti i giorni: doppio clic)
REM ============================================================
pushd "%~dp0"

echo ==================================================
echo    Avvio Gestione O.S.L. Nave TRIESTE
echo ==================================================
echo.

echo [1/3] Chiusura eventuali server PowerShell residui...
taskkill /F /IM powershell.exe >nul 2>&1
REM attesa ~2s per il cleanup dei processi
ping -n 3 127.0.0.1 >nul

echo [2/3] Apertura app nel browser (Microsoft Edge)...
start msedge.exe http://localhost:5030

echo [3/3] Avvio server locale (finestra PowerShell minimizzata)...
start /MIN powershell -ExecutionPolicy Bypass -NoExit -Command "cd '%~dp0'; .\server.ps1"

echo.
echo App avviata!
echo Se il browser non si apre da solo, vai su:  http://localhost:5030
echo Per chiudere tutto: chiudi la finestra PowerShell minimizzata.
echo.

popd
exit
