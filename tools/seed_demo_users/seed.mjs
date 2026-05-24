/**
 * Cria 8 utilizadores demo + perfis + treinos + consumos + chat na Sala 1.
 *
 * Requer chave de serviço Admin (Firebase Console → Definições → Contas de serviço).
 * Coloque em tools/seed_demo_users/serviceAccountKey.json
 *
 *   cd tools/seed_demo_users
 *   npm install
 *   npm run seed
 */

import { readFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import admin from 'firebase-admin';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'deficit-calorico-52663';
const SALA_ID = 'sala_1';
const SALA_NOME = 'Sala 1';

const demoUsers = JSON.parse(
  readFileSync(join(__dirname, 'demo_users.json'), 'utf8'),
);

const CHAT_SCRIPT = [
  { author: 0, text: 'Bom dia, pessoal! Quem treinou hoje cedo?' },
  { author: 1, text: 'Fiz 30 min de bike antes do trabalho. ~210 kcal.' },
  { author: 2, text: 'Eu só caminhada rápida, 150 kcal. Amanhã volto pro leg press.' },
  { author: 3, text: 'Costas e bíceps ontem. Hoje é cardio leve.' },
  { author: 4, text: 'Alguém bate meta de proteína fácil? Eu sempre fico no 80%.' },
  { author: 5, text: 'Frango + ovo + iogurte. Boring mas funciona 😅' },
  { author: 6, text: 'Registrei HIIT customizado: 25 min, 280 kcal. Campo "outros gastos" salvou.' },
  { author: 7, text: 'Boa! Eu usei o déficit programado só como desafio, não como meta fixa.' },
  { author: 1, text: 'Isso! Gordura a queimar vem do saldo real do dia.' },
  { author: 0, text: 'Entrei sozinha na sala e já apareci na lista. Chat ficou vivo 👍' },
  { author: 3, text: 'Supino reto 4x10, 60 kg. App calculou ~85 kcal.' },
  { author: 2, text: 'Vou registrar elíptico depois do almoço.' },
  { author: 4, text: 'Almoço: arroz, feijão, salada — 520 kcal no painel.' },
  { author: 6, text: 'Quem mais está na Sala 1 agora?' },
  { author: 7, text: 'Eu! Presença aparece mesmo com uma pessoa só.' },
];

const CONSUMOS = [
  { alimento: 'Frango grelhado', kcal: 165, p: 31, g: 3.6, c: 0, gGramas: 120 },
  { alimento: 'Arroz branco', kcal: 180, p: 3.5, g: 0.4, c: 40, gGramas: 150 },
  { alimento: 'Ovos mexidos', kcal: 140, p: 12, g: 10, c: 1, gGramas: 100 },
  { alimento: 'Banana', kcal: 89, p: 1.1, g: 0.3, c: 23, gGramas: 100 },
  { alimento: 'Whey protein', kcal: 120, p: 24, g: 1.5, c: 3, gGramas: 30 },
];

const TREINOS = [
  { tipo: 'Bike', kcal: 210, cat: 'Aeróbico', series: 1, reps: 1, carga: 30 },
  { tipo: 'Corrida', kcal: 300, cat: 'Aeróbico', series: 1, reps: 1, carga: 30 },
  { tipo: 'Supino reto', kcal: 85, cat: 'Peito', series: 4, reps: 10, carga: 60 },
  { tipo: 'Agachamento livre', kcal: 120, cat: 'Pernas', series: 4, reps: 8, carga: 80 },
  { tipo: 'Natação', kcal: 280, cat: 'Aeróbico - outros', series: 1, reps: 25, carga: 1 },
];

function initAdmin() {
  const keyPath = join(__dirname, 'serviceAccountKey.json');
  if (existsSync(keyPath)) {
    const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: PROJECT_ID,
    });
    console.log('✓ Admin SDK (serviceAccountKey.json)');
    return;
  }
  admin.initializeApp({ projectId: PROJECT_ID });
  console.log('✓ Admin SDK (Application Default Credentials)');
}

function tsMinutesAgo(min) {
  return admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - min * 60 * 1000),
  );
}

function todayKey() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

async function upsertAuthUser(auth, profile) {
  try {
    const created = await auth.createUser({
      email: profile.email,
      password: profile.password,
      displayName: profile.displayName,
      emailVerified: true,
    });
    return created.uid;
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      const existing = await auth.getUserByEmail(profile.email);
      await auth.updateUser(existing.uid, {
        password: profile.password,
        displayName: profile.displayName,
      });
      console.log(`  ↻ Auth já existia: ${profile.email}`);
      return existing.uid;
    }
    throw e;
  }
}

async function seedUser(db, uid, profile, index) {
  const userRef = db.collection('users').doc(uid);
  const consumo1 = CONSUMOS[index % CONSUMOS.length];
  const consumo2 = CONSUMOS[(index + 2) % CONSUMOS.length];
  const treino1 = TREINOS[index % TREINOS.length];
  const treino2 = TREINOS[(index + 1) % TREINOS.length];

  const ingestao =
    consumo1.kcal + consumo2.kcal;
  const gasto = treino1.kcal + treino2.kcal;
  const proteina = consumo1.p + consumo2.p;
  const gordura = consumo1.g + consumo2.g;
  const carbo = consumo1.c + consumo2.c;

  await userRef.set(
    {
      email: profile.email,
      display_name: profile.displayName,
      uid,
      created_time: admin.firestore.FieldValue.serverTimestamp(),
      peso: profile.peso,
      altura: profile.altura,
      sexo: profile.sexo,
      tmb: profile.tmb,
      nivel_atividade: profile.nivelAtividade,
      get: Math.round(profile.tmb * profile.nivelAtividade),
      tmb_calculado: true,
      cadastro_completo: true,
      ingestao_calorias_total: ingestao,
      calorias_total_dia: gasto,
      proteina_dia: proteina,
      gordura_dia: gordura,
      carboidrato_dia: carbo,
      dia_resumo_dashboard: todayKey(),
      deficit_programado: index % 3 === 0 ? 400 : 0,
      gordura_a_queimar: index % 3 === 0 ? 51.4 : 0,
      dia_meta_programada: index % 3 === 0 ? todayKey() : '',
    },
    { merge: true },
  );

  const now = Date.now();
  for (const [i, c] of [consumo1, consumo2].entries()) {
    await db.collection('registros_consumo').add({
      tipo_de_aliemento: c.alimento,
      calorias_total: c.kcal,
      proteinas_total: c.p,
      gorduras_total: c.g,
      carboidratos_total: c.c,
      quantidade_gramas: c.gGramas,
      user_ref: userRef,
      data_registro: admin.firestore.Timestamp.fromDate(
        new Date(now - (i + 1) * 3600000),
      ),
    });
  }

  for (const [i, t] of [treino1, treino2].entries()) {
    await db.collection('registros_treinos').add({
      tipo_de_exercicio: t.tipo,
      gasto_calorico: t.kcal,
      series: t.series,
      repeticoes: t.reps,
      carga: t.carga,
      categoria: t.cat,
      user_ref: userRef,
      data: admin.firestore.Timestamp.fromDate(
        new Date(now - (i + 3) * 3600000),
      ),
    });
  }

  console.log(
    `  ✓ ${profile.displayName}: ingestão ${ingestao} kcal, gasto ${gasto} kcal`,
  );
  return { uid, userRef, profile };
}

async function seedSalas(db) {
  await db.collection('salas_chat').doc(SALA_ID).set(
    {
      nome: SALA_NOME,
      titulo: SALA_NOME,
      ordem: 1,
      activa: true,
    },
    { merge: true },
  );
  console.log(`✓ Sala "${SALA_NOME}" (${SALA_ID})`);
}

async function seedChat(db, seededUsers) {
  const salaRef = db.collection('salas_chat').doc(SALA_ID);
  let minAgo = CHAT_SCRIPT.length * 3 + 10;

  for (const line of CHAT_SCRIPT) {
    const u = seededUsers[line.author];
    await db.collection('mensagens_chat').add({
      texto: line.text,
      sala_id: SALA_ID,
      sala_ref: salaRef,
      user_ref: u.userRef,
      autor_nome: u.profile.displayName,
      created_at: tsMinutesAgo(minAgo),
    });
    minAgo -= 3;
  }
  console.log(`✓ ${CHAT_SCRIPT.length} mensagens no chat`);
}

async function seedPresenca(db, seededUsers) {
  // Simula 3 pessoas "online" na sala (inclui caso de sala com pouca gente).
  const online = [0, 3, 7];
  for (const idx of online) {
    const u = seededUsers[idx];
    await db
      .collection('presenca_sala')
      .doc(`${SALA_ID}_${u.uid}`)
      .set({
        sala_id: SALA_ID,
        user_ref: u.userRef,
        autor_nome: u.profile.displayName,
        last_seen: admin.firestore.FieldValue.serverTimestamp(),
      });
  }
  console.log(`✓ ${online.length} presenças activas em ${SALA_ID}`);
}

async function main() {
  initAdmin();
  const auth = admin.auth();
  const db = admin.firestore();

  console.log('\n--- Déficit Calórico: seed demo (8 utilizadores) ---\n');

  await seedSalas(db);

  const seededUsers = [];
  for (let i = 0; i < demoUsers.length; i++) {
    const profile = demoUsers[i];
    console.log(`\n[${i + 1}/8] ${profile.email}`);
    const uid = await upsertAuthUser(auth, profile);
    const row = await seedUser(db, uid, profile, i);
    seededUsers.push(row);
  }

  await seedChat(db, seededUsers);
  await seedPresenca(db, seededUsers);

  console.log('\n--- Concluído ---\n');
  console.log('Contas demo (email / senha):');
  for (const u of demoUsers) {
    console.log(`  ${u.email}  /  ${u.password}`);
  }
  console.log('\nEntre com qualquer conta → Resenha Bodybuilder → Sala 1.\n');
}

main().catch((err) => {
  console.error('\n✗ Erro:', err.message || err);
  if (
    err.message?.includes('Could not load the default credentials') ||
    err.code === 'app/invalid-credential'
  ) {
    console.error(`
Coloque serviceAccountKey.json em tools/seed_demo_users/
Firebase Console → Project Settings → Service accounts → Generate new private key
`);
  }
  process.exit(1);
});
