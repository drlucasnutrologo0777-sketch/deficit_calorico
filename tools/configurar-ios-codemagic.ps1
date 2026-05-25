# Configuração iOS Codemagic — abre os links certos e mostra o que colar.
# Execute: powershell -ExecutionPolicy Bypass -File tools\configurar-ios-codemagic.ps1

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=== Déficit Calórico — setup iOS (Codemagic) ===" -ForegroundColor Cyan
Write-Host ""

$steps = @(
    @{
        Title = "1) Criar API Key na Apple"
        Url   = "https://appstoreconnect.apple.com/access/integrations/api"
        Text  = @"
- Clique no botão + (Generate API Key)
- Nome: Codemagic Deficit
- Acesso: App Manager
- Baixe o arquivo .p8 (só baixa UMA vez)
- Copie e guarde: Issuer ID (topo da página) e Key ID (na tabela)
"@
    }
    @{
        Title = "2) Colar as 3 chaves no Codemagic"
        Url   = "https://codemagic.io/apps"
        Text  = @"
- Abra seu app → Settings → Environment variables
- Crie um grupo: app_store_credentials
- Adicione estas 3 variáveis (marque Secure):
    APP_STORE_CONNECT_ISSUER_ID     = (Issuer ID da Apple)
    APP_STORE_CONNECT_KEY_IDENTIFIER = (Key ID da Apple)
    APP_STORE_CONNECT_PRIVATE_KEY   = cole TODO o texto do arquivo .p8
- Salve
"@
    }
    @{
        Title = "3) Bundle ID na Apple Developer"
        Url   = "https://developer.apple.com/account/resources/identifiers/list"
        Text  = @"
- Botão + → App IDs → App
- Description: Deficit Calorico
- Bundle ID: com.mycompany.deficitcalorico
- Capabilities: marque 'Sign In with Apple'
- Register
"@
    }
    @{
        Title = "4) App na App Store Connect"
        Url   = "https://appstoreconnect.apple.com/apps"
        Text  = @"
- Botão + → New App
- Platform: iOS
- Name: Déficit Calórico
- Bundle ID: com.mycompany.deficitcalorico
- SKU: deficitcalorico (qualquer texto único)
"@
    }
    @{
        Title = "5) Rodar build no Codemagic"
        Url   = "https://codemagic.io/apps"
        Text  = @"
- Start new build → workflow: Deficit Calorico iOS
- Branch: main (ou a que tiver o codemagic.yaml atualizado)
- Start build
- Quando terminar: baixe o .ipa em Artifacts
"@
    }
)

foreach ($s in $steps) {
    Write-Host $s.Title -ForegroundColor Yellow
    Write-Host $s.Text
    Write-Host "Abrindo: $($s.Url)" -ForegroundColor DarkGray
    Start-Process $s.Url
    Write-Host ""
    $null = Read-Host "Pressione ENTER para o próximo passo (ou Ctrl+C para sair)"
}

Write-Host "Pronto. Depois do build iOS, envie o IPA pelo Transporter ou publishing do Codemagic." -ForegroundColor Green
Write-Host ""
