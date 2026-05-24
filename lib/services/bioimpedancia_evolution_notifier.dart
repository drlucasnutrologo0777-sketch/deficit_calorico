import '/backend/schema/registros_bioimpedancia_record.dart';
import '/services/local_notification_service.dart';

class BioimpedanciaEvolutionMessage {
  const BioimpedanciaEvolutionMessage({
    required this.title,
    required this.body,
    required this.summary,
    this.metricas = const [],
  });

  final String title;
  final String body;
  final String summary;
  final List<BioimpedanciaMetricParecer> metricas;
}

class BioimpedanciaMetricParecer {
  const BioimpedanciaMetricParecer({
    required this.nome,
    required this.anterior,
    required this.atual,
    required this.delta,
    required this.tendencia,
    required this.menorEhMelhor,
  });

  final String nome;
  final double anterior;
  final double atual;
  final double delta;
  /// `melhor`, `atenção` ou `estável`
  final String tendencia;
  final bool menorEhMelhor;

  bool get isMelhor => tendencia == 'melhor';
  bool get isEstavel => tendencia == 'estável';
}

String _fmtDelta(double delta) {
  final sign = delta > 0 ? '+' : '';
  return '$sign${delta.toStringAsFixed(1)} p.p.';
}

BioimpedanciaMetricParecer _metricaParecer({
  required String nome,
  required double anterior,
  required double atual,
  required bool menorEhMelhor,
}) {
  final delta = atual - anterior;
  if (delta.abs() < 0.05) {
    return BioimpedanciaMetricParecer(
      nome: nome,
      anterior: anterior,
      atual: atual,
      delta: 0,
      tendencia: 'estável',
      menorEhMelhor: menorEhMelhor,
    );
  }
  final melhor = menorEhMelhor ? delta < 0 : delta > 0;
  return BioimpedanciaMetricParecer(
    nome: nome,
    anterior: anterior,
    atual: atual,
    delta: delta,
    tendencia: melhor ? 'melhor' : 'atenção',
    menorEhMelhor: menorEhMelhor,
  );
}

BioimpedanciaEvolutionMessage buildBioimpedanciaEvolutionMessage({
  required RegistrosBioimpedanciaRecord? anterior,
  required RegistrosBioimpedanciaRecord atual,
}) {
  if (anterior == null) {
    final resumo =
        'Gordura ${atual.percGordura.toStringAsFixed(1)}%, '
        'músculo ${atual.percMusculo.toStringAsFixed(1)}%, '
        'água ${atual.percAgua.toStringAsFixed(1)}%.';
    return BioimpedanciaEvolutionMessage(
      title: 'Bioimpedância registada',
      body: 'Primeiro registo guardado. $resumo',
      summary: 'Primeiro registo de bioimpedância guardado.',
      metricas: [
        BioimpedanciaMetricParecer(
          nome: 'Gordura',
          anterior: 0,
          atual: atual.percGordura,
          delta: 0,
          tendencia: 'estável',
          menorEhMelhor: true,
        ),
        BioimpedanciaMetricParecer(
          nome: 'Músculo',
          anterior: 0,
          atual: atual.percMusculo,
          delta: 0,
          tendencia: 'estável',
          menorEhMelhor: false,
        ),
        BioimpedanciaMetricParecer(
          nome: 'Água',
          anterior: 0,
          atual: atual.percAgua,
          delta: 0,
          tendencia: 'estável',
          menorEhMelhor: false,
        ),
      ],
    );
  }

  final metricas = [
    _metricaParecer(
      nome: 'Gordura',
      anterior: anterior.percGordura,
      atual: atual.percGordura,
      menorEhMelhor: true,
    ),
    _metricaParecer(
      nome: 'Músculo',
      anterior: anterior.percMusculo,
      atual: atual.percMusculo,
      menorEhMelhor: false,
    ),
    _metricaParecer(
      nome: 'Água',
      anterior: anterior.percAgua,
      atual: atual.percAgua,
      menorEhMelhor: false,
    ),
  ];

  final linhas = metricas.map((m) {
    if (m.isEstavel) {
      return '${m.nome}: estável (${m.atual.toStringAsFixed(1)}%)';
    }
    return '${m.nome}: ${_fmtDelta(m.delta)} (${m.atual.toStringAsFixed(1)}%, ${m.tendencia})';
  }).toList();

  final gorduraDesceu = atual.percGordura < anterior.percGordura - 0.05;
  final musculoSubiu = atual.percMusculo > anterior.percMusculo + 0.05;
  final aguaEstavel = (atual.percAgua - anterior.percAgua).abs() < 0.5;

  String resumoGeral;
  if (gorduraDesceu && musculoSubiu) {
    resumoGeral = 'Boa evolução: menos gordura e mais músculo.';
  } else if (gorduraDesceu) {
    resumoGeral = 'Gordura em queda — continue assim.';
  } else if (musculoSubiu) {
    resumoGeral = 'Ganho de músculo registado.';
  } else if (!aguaEstavel && atual.percAgua < anterior.percAgua) {
    resumoGeral = 'Hidratação ligeiramente mais baixa — atenção à água.';
  } else {
    resumoGeral = 'Comparado ao registo anterior.';
  }

  return BioimpedanciaEvolutionMessage(
    title: 'Evolução da bioimpedância',
    body: '$resumoGeral\n${linhas.join('\n')}',
    summary: linhas.join(' · '),
    metricas: metricas,
  );
}

Future<BioimpedanciaEvolutionMessage> notifyBioimpedanciaEvolution({
  required RegistrosBioimpedanciaRecord? anterior,
  required RegistrosBioimpedanciaRecord atual,
}) async {
  final message = buildBioimpedanciaEvolutionMessage(
    anterior: anterior,
    atual: atual,
  );

  await LocalNotificationService.show(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: message.title,
    body: message.body,
  );

  return message;
}
