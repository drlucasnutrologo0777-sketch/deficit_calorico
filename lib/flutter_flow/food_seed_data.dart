/// Valores nutricionais por 100 g (referência TACO / tabelas BR — arredondados).
Map<String, dynamic> foodSeed(
  String nome,
  String categorias, {
  required double calorias,
  double proteinas = 0,
  double gorduras = 0,
  double carboidratos = 0,
  double porcaoBase = 100,
}) =>
    {
      'tipo_de_alimento': nome,
      'categorias': categorias,
      'porcao_base': porcaoBase,
      'calorias': calorias,
      'proteinas': proteinas,
      'gorduras': gorduras,
      'carboidratos': carboidratos,
    };

const kCatFrutas = 'Frutas';
const kCatHortalicas = 'Verduras, Legumes e Hortaliças';
const kCatArrozGraos = 'Arroz, grãos e tubérculos';
const kCatCarnesVermelhas = 'Carnes Vermelhas';
const kCatCarnesBrancas = 'Carnes brancas';
const kCatOvos = 'Ovos';
const kCatLacteos = 'Leite, Queijo e Derivados';
const kCatCastanhas = 'Castanhas';
const kCatOleos = 'Óleo, Sementes e Manteigas';
const kCatAcucares = 'Açúcares e mel';
const kCatBebInd = 'Bebidas industrializadas';
const kCatBebNat = 'Bebidas naturais';

/// Chave usada em [FoodCategoryEntry.seedKey] → lista de alimentos locais.
final Map<String, List<Map<String, dynamic>>> kFoodSeedsByCategory = {
  // Sacolão e supermercado — manter tudo o que costuma ser vendido fresco.
  kCatFrutas: [
    foodSeed('Abacate', kCatFrutas, calorias: 160, gorduras: 15, carboidratos: 6),
    foodSeed('Abacaxi', kCatFrutas, calorias: 48, carboidratos: 12),
    foodSeed('Acerola', kCatFrutas, calorias: 33, carboidratos: 8),
    foodSeed('Açaí (polpa)', kCatFrutas, calorias: 58, gorduras: 4, carboidratos: 6),
    foodSeed('Ameixa', kCatFrutas, calorias: 53, carboidratos: 13),
    foodSeed('Atemoia', kCatFrutas, calorias: 96, carboidratos: 23),
    foodSeed('Banana da terra', kCatFrutas, calorias: 122, carboidratos: 32),
    foodSeed('Banana nanica', kCatFrutas, calorias: 92, carboidratos: 24),
    foodSeed('Banana prata', kCatFrutas, calorias: 98, carboidratos: 26),
    foodSeed('Bergamota', kCatFrutas, calorias: 38, carboidratos: 10),
    foodSeed('Caju', kCatFrutas, calorias: 43, carboidratos: 10),
    foodSeed('Caqui', kCatFrutas, calorias: 71, carboidratos: 19),
    foodSeed('Carambola', kCatFrutas, calorias: 31, carboidratos: 7),
    foodSeed('Figo', kCatFrutas, calorias: 74, carboidratos: 19),
    foodSeed('Framboesa', kCatFrutas, calorias: 52, carboidratos: 12),
    foodSeed('Goiaba', kCatFrutas, calorias: 54, carboidratos: 13),
    foodSeed('Graviola', kCatFrutas, calorias: 62, carboidratos: 15),
    foodSeed('Jabuticaba', kCatFrutas, calorias: 58, carboidratos: 15),
    foodSeed('Kiwi', kCatFrutas, calorias: 51, carboidratos: 12),
    foodSeed('Laranja', kCatFrutas, calorias: 37, carboidratos: 9),
    foodSeed('Limão', kCatFrutas, calorias: 32, carboidratos: 10),
    foodSeed('Maçã', kCatFrutas, calorias: 56, carboidratos: 15),
    foodSeed('Mamão', kCatFrutas, calorias: 40, carboidratos: 10),
    foodSeed('Manga', kCatFrutas, calorias: 64, carboidratos: 16),
    foodSeed('Maracujá', kCatFrutas, calorias: 68, carboidratos: 16),
    foodSeed('Melancia', kCatFrutas, calorias: 24, carboidratos: 6),
    foodSeed('Melão', kCatFrutas, calorias: 29, carboidratos: 7),
    foodSeed('Mexerica', kCatFrutas, calorias: 53, carboidratos: 13),
    foodSeed('Morango', kCatFrutas, calorias: 30, carboidratos: 7),
    foodSeed('Nêspera', kCatFrutas, calorias: 43, carboidratos: 11),
    foodSeed('Pera', kCatFrutas, calorias: 53, carboidratos: 14),
    foodSeed('Pêssego', kCatFrutas, calorias: 36, carboidratos: 9),
    foodSeed('Pitanga', kCatFrutas, calorias: 33, carboidratos: 8),
    foodSeed('Pitaya', kCatFrutas, calorias: 50, carboidratos: 11),
    foodSeed('Sapoti', kCatFrutas, calorias: 98, carboidratos: 24),
    foodSeed('Tamarindo', kCatFrutas, calorias: 239, carboidratos: 63),
    foodSeed('Tangerina', kCatFrutas, calorias: 38, carboidratos: 10),
    foodSeed('Uva', kCatFrutas, calorias: 53, carboidratos: 14),
    foodSeed('Uva passa', kCatFrutas, calorias: 283, carboidratos: 75),
  ],
  // Hortaliças comuns de sacolão e hortifruti (sem folhas/legumes raros).
  kCatHortalicas: [
    foodSeed('Abóbora moranga', kCatHortalicas, calorias: 24, carboidratos: 6),
    foodSeed('Abóbora cabotiá', kCatHortalicas, calorias: 48, carboidratos: 12),
    foodSeed('Abobrinha', kCatHortalicas, calorias: 19, carboidratos: 3),
    foodSeed('Acelga', kCatHortalicas, calorias: 20, carboidratos: 4),
    foodSeed('Agrião', kCatHortalicas, calorias: 17, proteinas: 2, carboidratos: 2),
    foodSeed('Alface americana', kCatHortalicas, calorias: 11, carboidratos: 2),
    foodSeed('Alface crespa', kCatHortalicas, calorias: 10, carboidratos: 2),
    foodSeed('Alho', kCatHortalicas, calorias: 113, carboidratos: 24),
    foodSeed('Alho-poró', kCatHortalicas, calorias: 31, carboidratos: 7),
    foodSeed('Berinjela', kCatHortalicas, calorias: 20, carboidratos: 5),
    foodSeed('Beterraba', kCatHortalicas, calorias: 49, carboidratos: 11),
    foodSeed('Brócolis', kCatHortalicas, calorias: 25, proteinas: 3, carboidratos: 4),
    foodSeed('Cebola', kCatHortalicas, calorias: 43, carboidratos: 10),
    foodSeed('Cebolinha verde', kCatHortalicas, calorias: 24, carboidratos: 5),
    foodSeed('Cenoura', kCatHortalicas, calorias: 34, carboidratos: 8),
    foodSeed('Chuchu', kCatHortalicas, calorias: 17, carboidratos: 4),
    foodSeed('Coentro (folhas)', kCatHortalicas, calorias: 23, carboidratos: 4),
    foodSeed('Couve', kCatHortalicas, calorias: 27, proteinas: 3, carboidratos: 4),
    foodSeed('Couve-flor', kCatHortalicas, calorias: 23, proteinas: 2, carboidratos: 4),
    foodSeed('Couve-manteiga', kCatHortalicas, calorias: 28, proteinas: 3, carboidratos: 5),
    foodSeed('Espinafre', kCatHortalicas, calorias: 16, proteinas: 2, carboidratos: 2),
    foodSeed('Ervilha em vagem', kCatHortalicas, calorias: 44, proteinas: 3, carboidratos: 8),
    foodSeed('Escarola', kCatHortalicas, calorias: 15, carboidratos: 3),
    foodSeed('Feijão verde (vagem)', kCatHortalicas, calorias: 25, proteinas: 2, carboidratos: 5),
    foodSeed('Jiló', kCatHortalicas, calorias: 20, carboidratos: 4),
    foodSeed('Palmito', kCatHortalicas, calorias: 23, proteinas: 2, carboidratos: 4),
    foodSeed('Pepino', kCatHortalicas, calorias: 10, carboidratos: 2),
    foodSeed('Pimentão amarelo', kCatHortalicas, calorias: 28, carboidratos: 6),
    foodSeed('Pimentão verde', kCatHortalicas, calorias: 21, carboidratos: 5),
    foodSeed('Pimentão vermelho', kCatHortalicas, calorias: 23, carboidratos: 5),
    foodSeed('Quiabo', kCatHortalicas, calorias: 30, carboidratos: 7),
    foodSeed('Rabanete', kCatHortalicas, calorias: 13, carboidratos: 3),
    foodSeed('Repolho', kCatHortalicas, calorias: 17, carboidratos: 4),
    foodSeed('Rúcula', kCatHortalicas, calorias: 13, proteinas: 2, carboidratos: 2),
    foodSeed('Salsa', kCatHortalicas, calorias: 30, carboidratos: 5),
    foodSeed('Tomate', kCatHortalicas, calorias: 15, carboidratos: 3),
    foodSeed('Tomate cereja', kCatHortalicas, calorias: 18, carboidratos: 4),
    foodSeed('Vagem', kCatHortalicas, calorias: 25, proteinas: 2, carboidratos: 5),
  ],
  kCatArrozGraos: [
    foodSeed('Arroz branco cozido', kCatArrozGraos, calorias: 128, carboidratos: 28),
    foodSeed('Arroz integral cozido', kCatArrozGraos, calorias: 124, carboidratos: 26),
    foodSeed('Arroz parboilizado cozido', kCatArrozGraos, calorias: 123, carboidratos: 27),
    foodSeed('Aveia em flocos', kCatArrozGraos, calorias: 394, proteinas: 14, gorduras: 8, carboidratos: 66),
    foodSeed('Batata doce cozida', kCatArrozGraos, calorias: 77, carboidratos: 18),
    foodSeed('Batata inglesa cozida', kCatArrozGraos, calorias: 52, carboidratos: 12),
    foodSeed('Batata baroa cozida', kCatArrozGraos, calorias: 72, carboidratos: 17),
    foodSeed('Cuscuz de milho', kCatArrozGraos, calorias: 113, carboidratos: 25),
    foodSeed('Farinha de mandioca (crua)', kCatArrozGraos, calorias: 361, carboidratos: 89),
    foodSeed('Farinha de trigo', kCatArrozGraos, calorias: 360, proteinas: 10, carboidratos: 76),
    foodSeed('Feijão carioca cozido', kCatArrozGraos, calorias: 76, proteinas: 5, carboidratos: 14),
    foodSeed('Feijão preto cozido', kCatArrozGraos, calorias: 77, proteinas: 5, carboidratos: 14),
    foodSeed('Feijão fradinho cozido', kCatArrozGraos, calorias: 78, proteinas: 5, carboidratos: 14),
    foodSeed('Grão-de-bico cozido', kCatArrozGraos, calorias: 121, proteinas: 7, carboidratos: 20),
    foodSeed('Lentilha cozida', kCatArrozGraos, calorias: 93, proteinas: 7, carboidratos: 16),
    foodSeed('Macarrão cozido', kCatArrozGraos, calorias: 124, proteinas: 4, carboidratos: 25),
    foodSeed('Mandioca cozida', kCatArrozGraos, calorias: 125, carboidratos: 30),
    foodSeed('Milho verde cozido', kCatArrozGraos, calorias: 98, proteinas: 3, carboidratos: 21),
    foodSeed('Pão francês', kCatArrozGraos, calorias: 300, proteinas: 9, gorduras: 4, carboidratos: 58),
    foodSeed('Pão integral', kCatArrozGraos, calorias: 253, proteinas: 10, gorduras: 4, carboidratos: 47),
    foodSeed('Polenta cozida', kCatArrozGraos, calorias: 70, carboidratos: 15),
    foodSeed('Quinoa cozida', kCatArrozGraos, calorias: 120, proteinas: 4, carboidratos: 21),
    foodSeed('Tapioca (goma hidratada)', kCatArrozGraos, calorias: 182, carboidratos: 45),
    foodSeed('Torrada integral', kCatArrozGraos, calorias: 374, proteinas: 12, gorduras: 5, carboidratos: 72),
  ],
  kCatCarnesBrancas: [
    foodSeed('Peito de frango grelhado', kCatCarnesBrancas, calorias: 159, proteinas: 32, gorduras: 3),
    foodSeed('Coxa de frango sem pele', kCatCarnesBrancas, calorias: 183, proteinas: 26, gorduras: 8),
    foodSeed('Sobrecoxa de frango', kCatCarnesBrancas, calorias: 195, proteinas: 24, gorduras: 10),
    foodSeed('Peito de peru', kCatCarnesBrancas, calorias: 114, proteinas: 24, gorduras: 1),
    foodSeed('Filé de tilápia', kCatCarnesBrancas, calorias: 96, proteinas: 20, gorduras: 2),
    foodSeed('Salmão', kCatCarnesBrancas, calorias: 208, proteinas: 20, gorduras: 13),
    foodSeed('Atum em lata (água)', kCatCarnesBrancas, calorias: 116, proteinas: 26, gorduras: 1),
    foodSeed('Sardinha', kCatCarnesBrancas, calorias: 152, proteinas: 21, gorduras: 7),
    foodSeed('Merluza', kCatCarnesBrancas, calorias: 89, proteinas: 19, gorduras: 1),
    foodSeed('Camarão', kCatCarnesBrancas, calorias: 90, proteinas: 19, gorduras: 1),
  ],
  kCatOvos: [
    foodSeed('Ovo de galinha inteiro', kCatOvos, calorias: 143, proteinas: 13, gorduras: 10),
    foodSeed('Clara de ovo', kCatOvos, calorias: 44, proteinas: 11),
    foodSeed('Gema de ovo', kCatOvos, calorias: 322, proteinas: 16, gorduras: 27),
    foodSeed('Omelete simples', kCatOvos, calorias: 154, proteinas: 11, gorduras: 12),
  ],
  kCatLacteos: [
    foodSeed('Leite integral', kCatLacteos, calorias: 61, proteinas: 3, gorduras: 3, carboidratos: 5),
    foodSeed('Leite desnatado', kCatLacteos, calorias: 35, proteinas: 3, carboidratos: 5),
    foodSeed('Iogurte natural', kCatLacteos, calorias: 51, proteinas: 4, carboidratos: 6),
    foodSeed('Iogurte grego', kCatLacteos, calorias: 97, proteinas: 9, gorduras: 5, carboidratos: 4),
    foodSeed('Queijo minas frescal', kCatLacteos, calorias: 264, proteinas: 18, gorduras: 20),
    foodSeed('Queijo mussarela', kCatLacteos, calorias: 330, proteinas: 22, gorduras: 26),
    foodSeed('Queijo cottage', kCatLacteos, calorias: 98, proteinas: 11, gorduras: 4, carboidratos: 3),
    foodSeed('Requeijão', kCatLacteos, calorias: 257, proteinas: 10, gorduras: 23),
    foodSeed('Ricota', kCatLacteos, calorias: 140, proteinas: 12, gorduras: 8),
    foodSeed('Whey protein (pó)', kCatLacteos, calorias: 400, proteinas: 80, carboidratos: 8),
  ],
  kCatCastanhas: [
    foodSeed('Amendoim', kCatCastanhas, calorias: 544, proteinas: 27, gorduras: 44, carboidratos: 12),
    foodSeed('Amêndoa', kCatCastanhas, calorias: 581, proteinas: 21, gorduras: 50, carboidratos: 10),
    foodSeed('Castanha-do-pará', kCatCastanhas, calorias: 643, proteinas: 15, gorduras: 63, carboidratos: 5),
    foodSeed('Castanha-de-caju', kCatCastanhas, calorias: 570, proteinas: 18, gorduras: 47, carboidratos: 11),
    foodSeed('Noz', kCatCastanhas, calorias: 620, proteinas: 14, gorduras: 61, carboidratos: 4),
    foodSeed('Pasta de amendoim', kCatCastanhas, calorias: 588, proteinas: 25, gorduras: 50, carboidratos: 12),
  ],
  kCatOleos: [
    foodSeed('Azeite de oliva', kCatOleos, calorias: 884, gorduras: 100),
    foodSeed('Óleo de coco', kCatOleos, calorias: 884, gorduras: 100),
    foodSeed('Óleo de soja', kCatOleos, calorias: 884, gorduras: 100),
    foodSeed('Manteiga', kCatOleos, calorias: 720, gorduras: 81),
    foodSeed('Margarina', kCatOleos, calorias: 720, gorduras: 80),
    foodSeed('Chia', kCatOleos, calorias: 486, proteinas: 17, gorduras: 31, carboidratos: 34),
    foodSeed('Linhaça', kCatOleos, calorias: 495, proteinas: 14, gorduras: 42, carboidratos: 22),
  ],
  kCatAcucares: [
    foodSeed('Açúcar refinado', kCatAcucares, calorias: 387, carboidratos: 100),
    foodSeed('Açúcar mascavo', kCatAcucares, calorias: 369, carboidratos: 95),
    foodSeed('Mel', kCatAcucares, calorias: 309, carboidratos: 84),
    foodSeed('Doce de leite', kCatAcucares, calorias: 308, proteinas: 6, gorduras: 7, carboidratos: 58),
    foodSeed('Goiabada', kCatAcucares, calorias: 269, carboidratos: 68),
  ],
  kCatBebInd: [
    foodSeed('Refrigerante cola', kCatBebInd, calorias: 41, carboidratos: 11, porcaoBase: 200),
    foodSeed('Suco de caixa uva', kCatBebInd, calorias: 48, carboidratos: 12, porcaoBase: 200),
    foodSeed('Energético', kCatBebInd, calorias: 45, carboidratos: 11, porcaoBase: 250),
    foodSeed('Cerveja', kCatBebInd, calorias: 43, carboidratos: 3, porcaoBase: 350),
  ],
  kCatBebNat: [
    foodSeed('Água de coco', kCatBebNat, calorias: 22, carboidratos: 4, porcaoBase: 200),
    foodSeed('Suco de laranja natural', kCatBebNat, calorias: 45, carboidratos: 10, porcaoBase: 200),
    foodSeed('Suco de limão', kCatBebNat, calorias: 22, carboidratos: 7, porcaoBase: 200),
    foodSeed('Café preto', kCatBebNat, calorias: 2, porcaoBase: 200),
    foodSeed('Chá verde', kCatBebNat, calorias: 1, porcaoBase: 200),
  ],
};

/// Carnes vermelhas (mantido aqui para um único ponto de catálogo).
const List<Map<String, dynamic>> kSeedCarnesVermelhasMaps = [
  // Copiado do legado — valores por 100 g
  {'tipo_de_alimento': 'Alcatra', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 217.0, 'proteinas': 26.0, 'gorduras': 12.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Picanha', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 289.0, 'proteinas': 25.0, 'gorduras': 21.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Contrafilé', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 219.0, 'proteinas': 26.0, 'gorduras': 12.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Fraldinha', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 219.0, 'proteinas': 26.0, 'gorduras': 13.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Maminha', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 153.0, 'proteinas': 28.0, 'gorduras': 4.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Patinho', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 133.0, 'proteinas': 28.0, 'gorduras': 2.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Acém', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 214.0, 'proteinas': 26.0, 'gorduras': 12.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Coxão mole', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 176.0, 'proteinas': 28.0, 'gorduras': 6.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Coxão duro', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 182.0, 'proteinas': 27.0, 'gorduras': 7.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Lagarto', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 180.0, 'proteinas': 28.0, 'gorduras': 6.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Costela bovina', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 351.0, 'proteinas': 19.0, 'gorduras': 31.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Cupim', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 330.0, 'proteinas': 17.0, 'gorduras': 29.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Músculo', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 162.0, 'proteinas': 28.0, 'gorduras': 5.0, 'carboidratos': 0.0},
  {'tipo_de_alimento': 'Paleta', 'categorias': kCatCarnesVermelhas, 'porcao_base': 100.0, 'calorias': 194.0, 'proteinas': 27.0, 'gorduras': 9.0, 'carboidratos': 0.0},
];

List<Map<String, dynamic>> seedsForCategoryKey(String? seedKey) {
  if (seedKey == null || seedKey.isEmpty) {
    return const [];
  }
  if (seedKey == kCatCarnesVermelhas) {
    return kSeedCarnesVermelhasMaps;
  }
  return kFoodSeedsByCategory[seedKey] ?? const [];
}
