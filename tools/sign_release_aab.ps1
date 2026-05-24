# Assina o AAB de release com o keystore ORIGINAL da Play Store.
# Uso (exemplo):
#   .\tools\sign_release_aab.ps1 -Keystore "C:\caminho\chave-original.jks" -StorePass "senha" -KeyPass "senha" -Alias "upload"

param(
    [Parameter(Mandatory = $true)]
    [string]$Keystore,
    [Parameter(Mandatory = $true)]
    [string]$StorePass,
    [Parameter(Mandatory = $true)]
    [string]$KeyPass,
    [string]$Alias = "upload",
    [string]$ExpectedSha1 = "75:B4:8D:F4:FB:FA:11:47:08:49:05:3D:60:BE:27:AF:48:E3:08:6F"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$unsigned = Join-Path $root "build\app\outputs\bundle\release\app-release.aab"
$signed = Join-Path $root "build\app\outputs\bundle\release\deficit-calorico-release-signed.aab"
$desktop = [Environment]::GetFolderPath("Desktop")
$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
$jarsigner = "C:\Program Files\Android\Android Studio\jbr\bin\jarsigner.exe"

if (-not (Test-Path $Keystore)) { throw "Keystore nao encontrado: $Keystore" }
if (-not (Test-Path $unsigned)) {
    Write-Host "AAB unsigned nao encontrado. A compilar..."
    Push-Location $root
    flutter build appbundle --release
    Pop-Location
}

$shaLine = & $keytool -list -v -keystore $Keystore -storepass $StorePass 2>&1 | Select-String "SHA1:"
$sha1 = ($shaLine | Select-Object -First 1).Line -replace ".*SHA1:\s*", "" -replace "\s", ""
$expected = $ExpectedSha1 -replace ":", "" -replace "\s", ""
$actual = $sha1 -replace ":", "" -replace "\s", ""

Write-Host "SHA1 do keystore: $sha1"
Write-Host "SHA1 esperado Play: $ExpectedSha1"

if ($actual -ne $expected) {
    throw "Keystore errado. A Play Store exige SHA1 $ExpectedSha1"
}

Copy-Item $unsigned $signed -Force
& $jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -keystore $Keystore -storepass $StorePass -keypass $KeyPass $signed $Alias
& $jarsigner -verify $signed | Out-Null

$dest = Join-Path $desktop "deficit-calorico-v1.0.2-build116-release.aab"
Copy-Item $signed $dest -Force
(Get-Item $dest).LastWriteTime = Get-Date

Write-Host "OK: $dest"
