@echo off
chcp 65001 >nul
color 0A
echo.
echo ============================================================
echo   FACA SÓ ISTO (3 passos)
echo ============================================================
echo.
echo  PASSO 1 - Ja abri o Bloco de Notas com a chave.
echo           Pressione:  Ctrl+A   depois   Ctrl+C
echo.
echo  PASSO 2 - Ja abri o Codemagic no navegador.
echo           Clique no app deficit_calorico
echo           Menu esquerda: Environment variables
echo           Botao: Add variable
echo.
echo           Nome:  CERTIFICATE_PRIVATE_KEY
echo           Valor: Ctrl+V (colar)
echo           Marque: Secure
echo           Save
echo.
echo  PASSO 3 - Start new build (workflow iOS App Store)
echo.
echo ============================================================
pause
start notepad "%USERPROFILE%\Downloads\deficit_ios_dist_private.key"
timeout /t 2 >nul
start https://codemagic.io/apps
pause
