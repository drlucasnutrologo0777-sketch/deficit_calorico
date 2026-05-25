@echo off
chcp 65001 >nul
title Deficit Calorico - FAZER AGORA
color 0B
echo.
echo   Vou abrir as paginas e rodar o script da Apple.
echo   So precisa COLAR o Issuer ID quando pedir (1 vez).
echo.
start https://appstoreconnect.apple.com/access/integrations/api
start https://developer.apple.com/account/resources/identifiers/list
start https://codemagic.io/apps
timeout /t 2 >nul
cd /d "%~dp0"
python tools\configurar_apple.py
pause
