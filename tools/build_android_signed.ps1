# Gera AAB release e assina com upload-keystore (Play Store).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    & flutter pub get
    & flutter build appbundle --release
    & "$PSScriptRoot\sign_release_aab.ps1" `
        -Keystore "android\app\upload-keystore.jks" `
        -StorePass "DeficitCalorico2026!" `
        -KeyPass "DeficitCalorico2026!" `
        -Alias upload
    $signed = Join-Path $root "build\app\outputs\bundle\release\deficit-calorico-release-signed.aab"
    Copy-Item $signed "C:\Users\drluc\Downloads\116-signed.aab" -Force
    Write-Host "OK: C:\Users\drluc\Downloads\116-signed.aab"
}
finally {
    Pop-Location
}
