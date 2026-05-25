# iOS — só 1 configuração manual

O `codemagic.yaml` já faz certificado, perfil, pods e IPA sozinho.

## Você só precisa colar 3 secrets no Codemagic

1. Apple: https://appstoreconnect.apple.com/access/integrations/api  
   - Gerar API Key (App Manager), baixar `.p8`, copiar **Issuer ID** e **Key ID**

2. Codemagic: app → **Environment variables** → grupo **`app_store_credentials`**:

| Variável | Valor |
|----------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | conteúdo completo do `.p8` |

Marque as três como **Secure**.

3. Apple Developer: bundle `com.mycompany.deficitcalorico` + **Sign In with Apple**

4. App Store Connect: criar app iOS com o mesmo bundle

5. **Start build** → workflow **Deficit Calorico iOS**

## Script assistido no Windows

```powershell
cd c:\Users\drluc\Downloads\deficit_calorico\deficit_calorico
powershell -ExecutionPolicy Bypass -File tools\configurar-ios-codemagic.ps1
```

Abre cada página e explica o que clicar.

## Android (bonus)

Workflow **Deficit Calorico Android** gera o `.aab` sem secrets Apple.
