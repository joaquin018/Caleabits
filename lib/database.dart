import 'package:drift/drift.dart';
import 'package:crdt/crdt.dart';
import 'package:uuid/uuid.dart';
import 'database_connection.dart'
    if (dart.library.js_interop) 'database_web.dart'
    if (dart.library.io) 'database_native.dart'
    as impl;

part 'database.g.dart';

// Mixin to add CRDT columns to tables
mixin CrdtColumns on Table {
  TextColumn get id => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get hlc => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Habits extends Table with CrdtColumns {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get detail => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitEntries extends Table with CrdtColumns {
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  IntColumn get status => integer()(); // 0: none, 1: success, 2: failure
}

@DriftDatabase(tables: [Habits, HabitEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  late Hlc _clock;
  final _uuid = const Uuid();

  void initClock(String nodeId) {
    _clock = Hlc.now(nodeId);
  }

  Hlc get hlc => _clock = _clock.increment();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
          await m.createTable(table);
        }
      }
    },
  );

  Future<List<Habit>> getAllHabits() =>
      (select(habits)..where((t) => t.isDeleted.equals(false))).get();

  Stream<List<Habit>> watchHabits() =>
      (select(habits)..where((t) => t.isDeleted.equals(false))).watch();

  Future<void> upsertHabit(HabitsCompanion habit) async {
    final id = habit.id.present ? habit.id.value : _uuid.v4();
    final companion = habit.copyWith(
      id: Value(id),
      hlc: Value(hlc.toString()),
      isDeleted: const Value(false),
    );
    await into(habits).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteHabit(String id) async {
    await (update(habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(isDeleted: const Value(true), hlc: Value(hlc.toString())),
    );
  }

  Future<List<HabitEntry>> getEntriesForHabit(String habitId) => (select(
    habitEntries,
  )..where((t) => t.habitId.equals(habitId) & t.isDeleted.equals(false))).get();



  Future<void> upsertEntry(HabitEntriesCompanion entry) async {
    final habitIdValue = entry.habitId.value;
    final dateValue = entry.date.value;
    final deterministicId =
        "${habitIdValue}_${dateValue.millisecondsSinceEpoch}";

    final companion = entry.copyWith(
      id: Value(deterministicId),
      hlc: Value(hlc.toString()),
      isDeleted: const Value(false),
    );
    await into(habitEntries).insertOnConflictUpdate(companion);
  }

  Future<Map<String, dynamic>> exportSyncData() async {
    final allHabits = await select(habits).get();
    final allEntries = await select(habitEntries).get();

    return {
      'hlc': _clock.toString(),
      'habits': allHabits.map((h) => h.toJson()).toList(),
      'entries': allEntries.map((e) => e.toJson()).toList(),
    };
  }

  Future<void> importSyncData(Map<String, dynamic> data) async {
    final remoteHlc = Hlc.parse(data['hlc'] as String);
    _clock = _clock.merge(remoteHlc);

    final remoteHabits = (data['habits'] as List).cast<Map<String, dynamic>>();
    final remoteEntries = (data['entries'] as List)
        .cast<Map<String, dynamic>>();

    await transaction(() async {
      for (final habitMap in remoteHabits) {
        final habit = Habit.fromJson(habitMap);
        final local = await (select(
          habits,
        )..where((t) => t.id.equals(habit.id))).getSingleOrNull();
        if (local == null ||
            Hlc.parse(habit.hlc).compareTo(Hlc.parse(local.hlc)) > 0) {
          await into(habits).insertOnConflictUpdate(habit);
        }
      }

      for (final entryMap in remoteEntries) {
        final entry = HabitEntry.fromJson(entryMap);
        final local = await (select(
          habitEntries,
        )..where((t) => t.id.equals(entry.id))).getSingleOrNull();
        if (local == null ||
            Hlc.parse(entry.hlc).compareTo(Hlc.parse(local.hlc)) > 0) {
          await into(habitEntries).insertOnConflictUpdate(entry);
        }
      }
    });
  }

  static QueryExecutor _openConnection() {
    return impl.openConnection();
  }
}
