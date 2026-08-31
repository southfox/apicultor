class Apiary {
  const Apiary({required this.id, required this.name, required this.createdAt});

  final int id;
  final String name;
  final DateTime createdAt;

  factory Apiary.fromMap(Map<String, Object?> map) => Apiary(
    id: map['id']! as int,
    name: map['name']! as String,
    createdAt: DateTime.parse(map['created_at']! as String),
  );
}

enum HiveCondition { i, ii, iii }

class Hive {
  const Hive({
    required this.id,
    required this.apiaryId,
    required this.code,
    required this.condition,
    required this.queenSeen,
    required this.pendingTasks,
  });

  final int id;
  final int apiaryId;
  final String code;
  final HiveCondition condition;
  final bool queenSeen;
  final int pendingTasks;

  factory Hive.fromMap(Map<String, Object?> map) => Hive(
    id: map['id']! as int,
    apiaryId: map['apiary_id']! as int,
    code: map['code']! as String,
    condition: HiveCondition.values.byName(map['condition']! as String),
    queenSeen: (map['queen_seen']! as int) == 1,
    pendingTasks: map['pending_tasks']! as int,
  );
}
