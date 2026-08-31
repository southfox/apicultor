import 'package:apicultor/data/beekeeping_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('guarda apiarios, colmenas e inspecciones en SQLite', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    final repository = await BeekeepingRepository.openForTest(database);

    final apiary = await repository.createApiary('La Quebrada');
    final hive = await repository.createHive(apiaryId: apiary.id, code: '1');
    final startedAt = DateTime(2026, 8, 31, 10);
    await repository.finishInspection(
      hive: hive,
      startedAt: startedAt,
      finishedAt: startedAt.add(const Duration(minutes: 4)),
    );

    expect((await repository.listApiaries()).single.name, 'La Quebrada');
    expect((await repository.listHives(apiary.id)).single.code, '1');
    final rows = await database.query('inspections');
    expect(rows, hasLength(1));
    expect(rows.single['hive_id'], hive.id);

    await repository.close();
  });
}
