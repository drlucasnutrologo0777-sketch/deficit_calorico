import '/backend/schema/alimentos_record.dart';
import 'food_seed_data.dart';

/// Categorias do registo alimentar — rótulo na UI vs chave(s) em Firestore `categorias`.
class FoodCategoryEntry {
  const FoodCategoryEntry({
    required this.label,
    required this.firestoreKeys,
    this.seedKey,
    this.isManualCalories = false,
  });

  final String label;
  final List<String> firestoreKeys;

  /// Chave do catálogo local em [kFoodSeedsByCategory] (fallback se Firestore vazio).
  final String? seedKey;
  final bool isManualCalories;
}

const kFoodCategories = <FoodCategoryEntry>[
  FoodCategoryEntry(
    label: 'Açúcares e mel',
    firestoreKeys: ['Açúcares e mel', 'Acucares e mel'],
    seedKey: kCatAcucares,
  ),
  FoodCategoryEntry(
    label: 'Arroz, grãos e tubérculos',
    firestoreKeys: [
      'Arroz, grãos e tubérculos',
      'Arroz  Farinhas e Grãos',
      'Arroz Farinhas e Grãos',
    ],
    seedKey: kCatArrozGraos,
  ),
  FoodCategoryEntry(
    label: 'Bebidas industrializadas',
    firestoreKeys: ['Bebidas industrializadas'],
    seedKey: kCatBebInd,
  ),
  FoodCategoryEntry(
    label: 'Bebidas naturais',
    firestoreKeys: ['Bebidas naturais'],
    seedKey: kCatBebNat,
  ),
  FoodCategoryEntry(
    label: 'Carnes brancas',
    firestoreKeys: ['Carnes brancas', 'Carnes Brancas'],
    seedKey: kCatCarnesBrancas,
  ),
  FoodCategoryEntry(
    label: 'Carnes vermelhas',
    firestoreKeys: ['Carnes Vermelhas', 'Carnes vermelhas'],
    seedKey: kCatCarnesVermelhas,
  ),
  FoodCategoryEntry(
    label: 'Frutas',
    firestoreKeys: ['Frutas'],
    seedKey: kCatFrutas,
  ),
  FoodCategoryEntry(
    label: 'Leite, queijo e derivados',
    firestoreKeys: [
      'Leite , Queijo e Derivados',
      'Leite, Queijo e Derivados',
      'Lácteos e derivados',
    ],
    seedKey: kCatLacteos,
  ),
  FoodCategoryEntry(
    label: 'Castanhas',
    firestoreKeys: ['Castanhas'],
    seedKey: kCatCastanhas,
  ),
  FoodCategoryEntry(
    label: 'Ovos',
    firestoreKeys: ['Ovos'],
    seedKey: kCatOvos,
  ),
  FoodCategoryEntry(
    label: 'Verduras, legumes e hortaliças',
    firestoreKeys: [
      'Verduras, Legumes e Hortaliças',
      'Verduras , Legumes e Hortaliças',
      'Legumes e hortaliças',
    ],
    seedKey: kCatHortalicas,
  ),
  FoodCategoryEntry(
    label: 'Óleos, sementes e manteigas',
    firestoreKeys: [
      'Óleo, Sementes e Manteigas',
      'Óleo ,  Sementes e Manteigas',
      'Óleo, Sementes e Manteigas',
    ],
    seedKey: kCatOleos,
  ),
  FoodCategoryEntry(
    label: 'Outras calorias ingeridas',
    firestoreKeys: [],
    isManualCalories: true,
  ),
];

FoodCategoryEntry? foodCategoryByFirestoreKey(String? key) {
  if (key == null || key.isEmpty) {
    return null;
  }
  for (final entry in kFoodCategories) {
    if (entry.firestoreKeys.any((k) => k == key)) {
      return entry;
    }
  }
  return null;
}

FoodCategoryEntry foodCategoryOrDefault(String? key) {
  return foodCategoryByFirestoreKey(key) ??
      const FoodCategoryEntry(
        label: 'Carnes vermelhas',
        firestoreKeys: ['Carnes Vermelhas'],
        seedKey: kCatCarnesVermelhas,
      );
}

String _seedDocId(String categorias, String nome) {
  final raw =
      'seed_${categorias}_$nome'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return raw.length > 120 ? raw.substring(0, 120) : raw;
}

AlimentosRecord alimentoFromSeedMap(Map<String, dynamic> data) {
  final nome = data['tipo_de_alimento'] as String? ?? '';
  final cat = data['categorias'] as String? ?? '';
  return AlimentosRecord.getDocumentFromData(
    createAlimentosRecordData(
      tipoDeAlimento: nome,
      categorias: cat,
      porcaoBase: (data['porcao_base'] as num?)?.toDouble(),
      calorias: (data['calorias'] as num?)?.toDouble(),
      proteinas: (data['proteinas'] as num?)?.toDouble(),
      gorduras: (data['gorduras'] as num?)?.toDouble(),
      carboidratos: (data['carboidratos'] as num?)?.toDouble(),
    ),
    AlimentosRecord.collection.doc(_seedDocId(cat, nome)),
  );
}

/// Junta itens do Firestore com o catálogo local da categoria.
List<AlimentosRecord> mergeWithCategorySeed(
  List<AlimentosRecord> fromDb,
  String? seedKey,
) {
  final seeds = seedsForCategoryKey(seedKey);
  if (seeds.isEmpty) {
    return fromDb;
  }

  final keys = fromDb.map((e) => e.tipoDeAlimento.toLowerCase().trim()).toSet();
  final merged = List<AlimentosRecord>.from(fromDb);
  for (final seed in seeds) {
    final nome = (seed['tipo_de_alimento'] as String).toLowerCase().trim();
    if (!keys.contains(nome)) {
      merged.add(alimentoFromSeedMap(seed));
      keys.add(nome);
    }
  }
  merged.sort(
    (a, b) => a.tipoDeAlimento.toLowerCase().compareTo(
          b.tipoDeAlimento.toLowerCase(),
        ),
  );
  return merged;
}

@Deprecated('Use mergeWithCategorySeed')
List<AlimentosRecord> mergeWithCarnesVermelhasSeed(List<AlimentosRecord> fromDb) {
  return mergeWithCategorySeed(fromDb, kCatCarnesVermelhas);
}

double foodScaleFactor(AlimentosRecord food, double grams) {
  final base = food.porcaoBase > 0 ? food.porcaoBase : 100.0;
  return grams / base;
}

double scaledMacro(double perPortion, AlimentosRecord food, double grams) {
  return perPortion * foodScaleFactor(food, grams);
}
