# Gera UNICO AAB correto para Play Store (SHA1: 86:2A...).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$desktop = [Environment]::GetFolderPath("Desktop")
$quarantine = Join-Path $env:USERPROFILE "Downloads\NAO-ENVIAR-75B4"
$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
$jarsigner = "C:\Program Files\Android\Android Studio\jbr\bin\jarsigner.exe"
$keystore = Join-Path $root "android\app\upload-keystore.jks"
$storePass = "DeficitCalorico2026!"
$playSha1 = "86:2A:33:C2:13:CD:C8:78:E9:A1:74:D9:2C:0A:32:B4:8E:B9:8D:24"
$wrongSha1 = "75:B4:88:E9:F0:FA:13:47:00:49:D5:2C:6D:D1:27:AF:48:83:D0:6F"
$buildNum = (Select-String -Path (Join-Path $root "pubspec.yaml") -Pattern "^version:").Line -replace ".*\+", ""

New-Item -ItemType Directory -Force -Path $quarantine | Out-Null

# Remove TUDO da area de trabalho que pareca AAB/APK (inclusive .NAO-USAR)
Get-ChildItem $desktop -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '\.aab|\.apk|build11|build12|deficit-calorico|ENVIAR|SUBIR|PLAY'
} | ForEach-Object {
    Move-Item $_.FullName (Join-Path $quarantine $_.Name) -Force
    Write-Host "Removido da Area de Trabalho: $($_.Name)"
}

Push-Location $root
try {
    & flutter pub get
    & flutter build appbundle --release --build-number=$buildNum

    $unsigned = Join-Path $root "build\app\outputs\bundle\release\app-release.aab"
    if (-not (Test-Path $unsigned)) { throw "AAB nao gerado" }

    $signed = Join-Path $root "build\app\outputs\bundle\release\PLAY-SIGNED.aab"
    Copy-Item $unsigned $signed -Force
    & $jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -keystore $keystore -storepass $storePass -keypass $storePass $signed upload
    & $jarsigner -verify $signed | Out-Null

    $shaVal = ((& $keytool -printcert -jarfile $signed 2>&1 | Select-String "SHA1:" | Select-Object -First 1).Line -replace '.*SHA1:\s*','').Trim()
    if ($shaVal -eq $wrongSha1) { throw "CERTIFICADO ERRADO 75:B4" }
    if ($shaVal -ne $playSha1) { throw "SHA1 errado: $shaVal" }

    $dest = Join-Path $desktop "ENVIAR-NA-PLAY-build${buildNum}-$(Get-Date -Format 'yyyyMMdd-HHmm').aab"
    Copy-Item $signed $dest -Force

    $aabName = Split-Path $dest -Leaf
    @"
UNICO ARQUIVO PARA A PLAY STORE
================================
$aabName
build: $buildNum
SHA1: $playSha1

PASSOS:
1. Play Console > apague o rascunho inteiro
2. Nova versao
3. Envie SOMENTE: $aabName

Se der erro 75:B4 voce escolheu arquivo errado.
Arquivos antigos estao em: Downloads\NAO-ENVIAR-75B4
"@ | Set-Content (Join-Path $desktop "LEIA-ANTES-DE-ENVIAR.txt") -Encoding UTF8

    Write-Host ""
    Write-Host "PRONTO: $dest"
    Write-Host "SHA1 OK: $shaVal"
}
finally {
    Pop-Location
}
