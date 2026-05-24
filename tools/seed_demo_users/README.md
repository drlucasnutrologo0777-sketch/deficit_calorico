# Utilizadores demo (8 contas fictícias)

Script que cria contas reais no Firebase Auth + dados no Firestore (perfil, treinos, consumos, chat e presença na Sala 1).

## Pré-requisitos

1. **Email/Password** activo no Firebase Authentication.
2. **Chave Admin** (conta de serviço):
   - [Firebase Console](https://console.firebase.google.com/project/deficit-calorico-52663/settings/serviceaccounts/adminsdk)
   - *Generate new private key* → guardar como `serviceAccountKey.json` nesta pasta.
3. **Regras publicadas** (`firebase deploy --only firestore:rules` na raiz do projecto).

## Executar

```powershell
cd tools\seed_demo_users
npm install
npm run seed
```

## Contas criadas

| # | Email | Senha | Nome |
|---|-------|-------|------|
| 1 | ana.silva@demo-deficit.app | Demo2026!1 | Ana Silva |
| 2 | bruno.costa@demo-deficit.app | Demo2026!2 | Bruno Costa |
| 3 | carla.mendes@demo-deficit.app | Demo2026!3 | Carla Mendes |
| 4 | diego.ferreira@demo-deficit.app | Demo2026!4 | Diego Ferreira |
| 5 | elisa.rocha@demo-deficit.app | Demo2026!5 | Elisa Rocha |
| 6 | felipe.alves@demo-deficit.app | Demo2026!6 | Felipe Alves |
| 7 | gabi.santos@demo-deficit.app | Demo2026!7 | Gabi Santos |
| 8 | henrique.lima@demo-deficit.app | Demo2026!8 | Henrique Lima |

## O que é simulado por utilizador

- Perfil completo (`users`): TMB, peso, altura, macros do dia, gasto/ingestão.
- 2 registos de **consumo** (`registros_consumo`).
- 2 registos de **treino** — aeróbico, musculação ou “outros gastos”.
- **15 mensagens** na Sala 1 (`mensagens_chat`) — conversa de comunidade.
- **3 presenças** activas (`presenca_sala`) — Ana, Diego e Henrique “online”.

## Testar na app

1. Login com `bruno.costa@demo-deficit.app` / `Demo2026!2`.
2. Painel → ver ingestão/gasto do dia.
3. Resenha Bodybuilder → Sala 1 → ver conversa e presença.
4. Entrar na sala → o seu nome aparece na barra de presença.

## Erros corrigidos (resumo)

| Problema | Solução |
|----------|---------|
| Chat não carregava | Regras: leitura de `mensagens_chat` para autenticados |
| Sala vazia sem ninguém | `presenca_sala` + entrada automática ao abrir chat |
| `FormatException: Invalid double` (treino) | Preview usa `parseTreinoNumero` em vez de `double.parse` |
| Overflow no Aeróbico | `SingleChildScrollView` + secção “Outros gastos calóricos” |
| Índice Firestore | `firestore.indexes.json` para `mensagens_chat` |

**Nota:** `serviceAccountKey.json` nunca deve ir para o Git (já está no `.gitignore`).
