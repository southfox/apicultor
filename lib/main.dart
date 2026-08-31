import 'package:flutter/material.dart';

void main() => runApp(const ApicultorApp());

class ApicultorApp extends StatelessWidget {
  const ApicultorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xffb7791f),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Apicultor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfffffbf5),
      ),
      home: const ApiaryHomePage(),
    );
  }
}

enum HiveCondition { i, ii, iii }

class HiveSummary {
  const HiveSummary({
    required this.number,
    required this.condition,
    required this.queenSeen,
    required this.pendingTasks,
  });

  final int number;
  final HiveCondition condition;
  final bool queenSeen;
  final int pendingTasks;
}

class ApiaryHomePage extends StatefulWidget {
  const ApiaryHomePage({super.key});

  @override
  State<ApiaryHomePage> createState() => _ApiaryHomePageState();
}

class _ApiaryHomePageState extends State<ApiaryHomePage> {
  final List<HiveSummary> _hives = const [
    HiveSummary(
      number: 1,
      condition: HiveCondition.ii,
      queenSeen: true,
      pendingTasks: 1,
    ),
    HiveSummary(
      number: 2,
      condition: HiveCondition.i,
      queenSeen: true,
      pendingTasks: 0,
    ),
    HiveSummary(
      number: 3,
      condition: HiveCondition.iii,
      queenSeen: false,
      pendingTasks: 2,
    ),
  ];
  int? _activeHive;

  void _startInspection(int hiveNumber) {
    setState(() => _activeHive = hiveNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Revisión de colmena $hiveNumber iniciada.'),
        action: SnackBarAction(
          label: 'Finalizar',
          onPressed: _finishInspection,
        ),
      ),
    );
  }

  void _finishInspection() {
    final hive = _activeHive;
    if (hive == null) return;
    setState(() => _activeHive = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Revisión de colmena $hive finalizada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeHive = _activeHive;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apicultor'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: activeHive == null
            ? () => _startInspection(1)
            : _finishInspection,
        icon: Icon(
          activeHive == null
              ? Icons.mic_none_outlined
              : Icons.stop_circle_outlined,
        ),
        label: Text(
          activeHive == null ? 'Iniciar revisión' : 'Finalizar revisión',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Apiario Campo Norte',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            activeHive == null
                ? 'Vista inicial · persistencia local en el próximo módulo'
                : 'Revisión en curso · Colmena $activeHive',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _StatusCard(activeHive: activeHive),
          const SizedBox(height: 24),
          const Text(
            'Mis colmenas',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ..._hives.map(
            (hive) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HiveCard(
                hive: hive,
                active: activeHive == hive.number,
                onStart: () => _startInspection(hive.number),
              ),
            ),
          ),
          const SizedBox(height: 86),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.activeHive});
  final int? activeHive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              activeHive == null
                  ? Icons.cloud_off_outlined
                  : Icons.timer_outlined,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                activeHive == null
                    ? 'Modo campo\nPreparado para almacenamiento local.'
                    : 'Cronómetro activo\nColmena $activeHive',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HiveCard extends StatelessWidget {
  const _HiveCard({
    required this.hive,
    required this.active,
    required this.onStart,
  });
  final HiveSummary hive;
  final bool active;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final condition = switch (hive.condition) {
      HiveCondition.i => 'I · fuerte',
      HiveCondition.ii => 'II · atención',
      HiveCondition.iii => 'III · crítica',
    };
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${hive.number}')),
        title: Text(
          'Colmena ${hive.number}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$condition\nReina ${hive.queenSeen ? 'vista' : 'no vista'} · ${hive.pendingTasks} tarea${hive.pendingTasks == 1 ? '' : 's'}',
        ),
        trailing: active
            ? const Icon(Icons.timer_outlined)
            : FilledButton.tonal(
                onPressed: onStart,
                child: const Text('Revisar'),
              ),
        isThreeLine: true,
        titleAlignment: ListTileTitleAlignment.top,
      ),
    );
  }
}
