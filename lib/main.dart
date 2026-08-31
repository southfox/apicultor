import 'package:apicultor/data/beekeeping_repository.dart';
import 'package:apicultor/domain/beekeeping_models.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ApicultorApp());
}

class ApicultorApp extends StatefulWidget {
  const ApicultorApp({super.key});

  @override
  State<ApicultorApp> createState() => _ApicultorAppState();
}

class _ApicultorAppState extends State<ApicultorApp> {
  late final Future<BeekeepingRepository> _repository =
      BeekeepingRepository.open();

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xffb7791f));
    return MaterialApp(
      title: 'Apicultor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfffffbf5),
      ),
      home: FutureBuilder<BeekeepingRepository>(
        future: _repository,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _StartupError(error: snapshot.error);
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return ApiaryHomePage(repository: snapshot.data!);
        },
      ),
    );
  }
}

class ApiaryHomePage extends StatefulWidget {
  const ApiaryHomePage({super.key, required this.repository});
  final BeekeepingRepository repository;

  @override
  State<ApiaryHomePage> createState() => _ApiaryHomePageState();
}

class _ApiaryHomePageState extends State<ApiaryHomePage> {
  late Future<List<Apiary>> _apiaries;
  int? _selectedApiaryId;
  DateTime? _inspectionStartedAt;
  Hive? _activeHive;

  @override
  void initState() {
    super.initState();
    _apiaries = widget.repository.listApiaries();
  }

  void _reload() =>
      setState(() => _apiaries = widget.repository.listApiaries());

  Future<void> _addApiary() async {
    final name = await _askForText(
      title: 'Nuevo apiario',
      label: 'Nombre del apiario',
      action: 'Crear',
    );
    if (name == null) return;
    final apiary = await widget.repository.createApiary(name);
    setState(() {
      _selectedApiaryId = apiary.id;
      _apiaries = widget.repository.listApiaries();
    });
  }

  Future<void> _addHive(int apiaryId) async {
    final code = await _askForText(
      title: 'Nueva colmena',
      label: 'Código o número',
      action: 'Crear',
    );
    if (code == null) return;
    try {
      await widget.repository.createHive(apiaryId: apiaryId, code: code);
      _reload();
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ese código ya existe en este apiario.'),
          ),
        );
      }
    }
  }

  Future<String?> _askForText({
    required String title,
    required String label,
    required String action,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(action),
          ),
        ],
      ),
    );
    controller.dispose();
    return result == null || result.isEmpty ? null : result;
  }

  void _startInspection(Hive hive) {
    setState(() {
      _activeHive = hive;
      _inspectionStartedAt = DateTime.now();
    });
  }

  Future<void> _finishInspection() async {
    final hive = _activeHive;
    final startedAt = _inspectionStartedAt;
    if (hive == null || startedAt == null) return;
    await widget.repository.finishInspection(
      hive: hive,
      startedAt: startedAt,
      finishedAt: DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      _activeHive = null;
      _inspectionStartedAt = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inspección de ${hive.code} guardada sin conexión.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Apiary>>(
      future: _apiaries,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _StartupError(error: snapshot.error);
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final apiaries = snapshot.data!;
        if (apiaries.isEmpty) return _EmptyApiaries(onAdd: _addApiary);
        final selected =
            apiaries
                .where((apiary) => apiary.id == _selectedApiaryId)
                .firstOrNull ??
            apiaries.first;
        if (_selectedApiaryId != selected.id) _selectedApiaryId = selected.id;
        return _ApiaryContent(
          apiary: selected,
          repository: widget.repository,
          activeHive: _activeHive,
          onSelectApiary: (apiary) =>
              setState(() => _selectedApiaryId = apiary.id),
          apiaries: apiaries,
          onAddApiary: _addApiary,
          onAddHive: () => _addHive(selected.id),
          onStartInspection: _startInspection,
          onFinishInspection: _finishInspection,
        );
      },
    );
  }
}

class _ApiaryContent extends StatelessWidget {
  const _ApiaryContent({
    required this.apiary,
    required this.apiaries,
    required this.repository,
    required this.activeHive,
    required this.onSelectApiary,
    required this.onAddApiary,
    required this.onAddHive,
    required this.onStartInspection,
    required this.onFinishInspection,
  });

  final Apiary apiary;
  final List<Apiary> apiaries;
  final BeekeepingRepository repository;
  final Hive? activeHive;
  final ValueChanged<Apiary> onSelectApiary;
  final VoidCallback onAddApiary;
  final VoidCallback onAddHive;
  final ValueChanged<Hive> onStartInspection;
  final Future<void> Function() onFinishInspection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<Apiary>(
            value: apiary,
            items: apiaries
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (item) => item == null ? null : onSelectApiary(item),
          ),
        ),
        actions: [
          IconButton(
            onPressed: onAddApiary,
            tooltip: 'Agregar apiario',
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: activeHive == null ? onAddHive : onFinishInspection,
        icon: Icon(activeHive == null ? Icons.add : Icons.stop_circle_outlined),
        label: Text(
          activeHive == null ? 'Nueva colmena' : 'Finalizar revisión',
        ),
      ),
      body: FutureBuilder<List<Hive>>(
        future: repository.listHives(apiary.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hives = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(activeHive: activeHive),
              const SizedBox(height: 24),
              const Text(
                'Colmenas',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (hives.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Todavía no hay colmenas. Crea la primera para comenzar.',
                  ),
                ),
              ...hives.map(
                (hive) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HiveCard(
                    hive: hive,
                    active: activeHive?.id == hive.id,
                    onStart: () => onStartInspection(hive),
                  ),
                ),
              ),
              const SizedBox(height: 86),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyApiaries extends StatelessWidget {
  const _EmptyApiaries({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Apicultor')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hive_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Crea tu primer apiario',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'La información se guarda en SQLite en este dispositivo, incluso sin internet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo apiario'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.activeHive});
  final Hive? activeHive;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
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
                  ? 'Modo campo\nSQLite local activo.'
                  : 'Revisión en curso\nColmena ${activeHive!.code}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HiveCard extends StatelessWidget {
  const _HiveCard({
    required this.hive,
    required this.active,
    required this.onStart,
  });
  final Hive hive;
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
        leading: CircleAvatar(child: Text(hive.code)),
        title: Text(
          'Colmena ${hive.code}',
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

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No fue posible abrir la base local.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
