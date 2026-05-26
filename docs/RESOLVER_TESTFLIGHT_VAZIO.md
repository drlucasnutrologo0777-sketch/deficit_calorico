# TestFlight vazio — resolver em 3 passos

**Problema:** TestFlight diz *"Envie uma compilação para começar a testar"*.

**Causa:** o `.ipa` ficou só no Codemagic. **Não chegou na Apple.**

**Você NÃO precisa de Mac/Transporter** se usar o Codemagic com o passo de envio (já está no `codemagic.yaml`).

---

## Passo 1 — Subir o código (1 vez)

No PowerShell:

```powershell
cd C:\Users\drluc\Downloads\deficit_calorico\deficit_calorico_restore
git add pubspec.yaml codemagic.yaml
git commit -m "Envio automatico do IPA para TestFlight"
git push
```

(O `pubspec.yaml` está em `1.0.2+117` — número novo para a Apple aceitar.)

---

## Passo 2 — Rodar build no Codemagic

1. https://codemagic.io/apps  
2. **Start new build**  
3. Workflow: **>>> USAR ESTE - iOS App Store <<<**  
4. Branch: **main**  
5. Espere terminar (~15 min)  
6. No log, procure o passo **"ENVIAR para Apple"** — tem que dar **verde**

---

## Passo 3 — No App Store Connect (build 117 ja enviada)

Se o Codemagic mostrou **Processing state: VALID** e **Version: 117**, o upload **deu certo** (mesmo se o passo ficou vermelho por e-mail do TestFlight).

1. **TestFlight** → build **117** → se pedir **Export Compliance** / criptografia:
   - Pergunta: o app usa criptografia além do HTTPS padrão? → em geral **Não**
2. **App Store** → versão **1.0.2** → **Selecionar compilação** → **117** → **Enviar para revisão**

(TestFlight externo e e-mail de feedback sao opcionais — nao bloqueiam publicar na loja.)

---

## Só use Transporter (Mac) se o passo "ENVIAR" falhar no Codemagic

1. Baixe `Deficit_Calorico.ipa` nos Artifacts do build  
2. Mac → App Store → **Transporter** → arrastar o `.ipa` → **Enviar**

---

## Checklist rápido

- [ ] `git push` feito  
- [ ] Build Codemagic **finished** + passo **ENVIAR** verde  
- [ ] TestFlight mostra build (não vazio)  
- [ ] App Store → compilação selecionada → enviar revisão
