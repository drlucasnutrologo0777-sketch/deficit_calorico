/// Opções de aeróbico com gasto fixo por 30 min (referência build 114).
class AerobicoOption {
  const AerobicoOption(this.nome, this.kcal30Min);

  final String nome;
  final double kcal30Min;
}

const kAerobicoOptions = <AerobicoOption>[
  AerobicoOption('Bike', 210),
  AerobicoOption('Corrida', 300),
  AerobicoOption('Elíptico', 270),
  AerobicoOption('Caminhada', 150),
  AerobicoOption('Esteira', 240),
  AerobicoOption('Pedal', 195),
];
