@echo off
chcp 65001 >nul
setlocal
echo.
echo ============================================================
echo   SETUP iOS DEFINITIVO - Deficit Calorico (fazer UMA vez)
echo ============================================================
echo.

set KEY=%USERPROFILE%\Downloads\deficit_ios_dist_private.key

where openssl >nul 2>&1
if errorlevel 1 (
  echo Instale OpenSSL ou Git for Windows com openssl no PATH.
  pause
  exit /b 1
)

if exist "%KEY%" (
  echo Arquivo de chave ja existe:
  echo   %KEY%
  echo.
  choice /C SN /M "Gerar chave NOVA? (apaga a antiga - so se nunca funcionou)"
  if errorlevel 2 goto :show
)

echo Gerando chave RSA 2048...
openssl genpkey -algorithm RSA -out "%KEY%" -pkeyopt rsa_keygen_bits:2048
if errorlevel 1 (
  echo Falhou ao gerar chave.
  pause
  exit /b 1
)

:show
echo.
echo ============================================================
echo   PASSO A - Apagar certificados antigos na Apple
echo ============================================================
start https://developer.apple.com/account/resources/certificates/list
echo Na pagina que abriu: apague TODOS "Apple Distribution" / "iOS Distribution"
echo Se tiver "Pending", espere sumir ou apague tambem.
echo.
pause

echo.
echo ============================================================
echo   PASSO B - Colar chave no Codemagic
echo ============================================================
start https://codemagic.io/apps
echo.
echo 1) Abra o app deficit_calorico
echo 2) Environment variables
echo 3) Crie grupo: ios_code_signing
echo 4) Nova variavel:
echo      Nome:  CERTIFICATE_PRIVATE_KEY
echo      Valor: COPIE O ARQUIVO ABAIXO INTEIRO
echo      Marque: Secure
echo.
echo Abrindo o arquivo da chave no Bloco de Notas...
notepad "%KEY%"
echo.
echo ============================================================
echo   PASSO C - Rodar build
echo ============================================================
echo Workflow: ^>^>^> USAR ESTE - iOS App Store ^<^<^<
echo Branch: main
echo.
echo Esta chave NAO muda mais. Nao apague o arquivo .key no PC.
echo ============================================================
pause
