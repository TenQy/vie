import 'package:drift/drift.dart';

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text().nullable()();
  TextColumn get routineName => text().withLength(min: 1, max: 100)();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // active, completed, cancelled
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get totalDurationSeconds =>
      integer().withDefault(const Constant(0))();
  RealColumn get totalVolumeKg => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class SetRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(WorkoutSessions, #id)();
  TextColumn get exerciseId => text().nullable()();
  TextColumn get exerciseName => text().withLength(min: 1, max: 100)();
  TextColumn get muscleGroup => text().withLength(min: 1, max: 50)();
  IntColumn get setNumber => integer()();
  TextColumn get metricType =>
      text().withDefault(const Constant('reps_weight'))();
  IntColumn get targetReps => integer().withDefault(const Constant(0))();
  RealColumn get targetWeight => real().withDefault(const Constant(0.0))();
  IntColumn get completedReps => integer().withDefault(const Constant(0))();
  RealColumn get completedWeight => real().withDefault(const Constant(0.0))();
  IntColumn get restTimeSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
