import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/routine_entity.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../mappers/workout_mappers.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final AppDatabase _db;

  WorkoutRepositoryImpl(this._db);

  @override
  Stream<List<RoutineEntity>> watchRoutines() {
    return _db.select(_db.routines).watch().asyncMap((routines) async {
      final result = <RoutineEntity>[];
      for (final r in routines) {
        final exercises = await (_db.select(_db.routineExercises)
              ..where((tbl) => tbl.routineId.equals(r.id))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
            .get();
        result.add(WorkoutMappers.toRoutineEntity(r, exercises));
      }
      return result;
    });
  }

  @override
  Future<List<RoutineEntity>> getRoutines() async {
    final routines = await _db.select(_db.routines).get();
    final result = <RoutineEntity>[];
    for (final r in routines) {
      final exercises = await (_db.select(_db.routineExercises)
            ..where((tbl) => tbl.routineId.equals(r.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      result.add(WorkoutMappers.toRoutineEntity(r, exercises));
    }
    return result;
  }

  @override
  Future<RoutineEntity?> getRoutineById(String id) async {
    final routine = await (_db.select(_db.routines)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (routine == null) return null;

    final exercises = await (_db.select(_db.routineExercises)
          ..where((tbl) => tbl.routineId.equals(id))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();
    return WorkoutMappers.toRoutineEntity(routine, exercises);
  }

  @override
  Future<void> saveRoutine(RoutineEntity routine) async {
    await _db.into(_db.routines).insertOnConflictUpdate(
          RoutinesCompanion.insert(
            id: routine.id,
            name: routine.name,
            description: Value(routine.description),
            targetDay: Value(routine.targetDay),
            isActive: Value(routine.isActive),
            orderIndex: Value(routine.orderIndex),
            createdAt: Value(routine.createdAt),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
          ),
        );
  }

  @override
  Future<void> deleteRoutine(String id) async {
    await (_db.delete(_db.routineExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .go();
    await (_db.delete(_db.routines)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> saveRoutineExercise(ExerciseEntity exercise) async {
    await _db.into(_db.routineExercises).insertOnConflictUpdate(
          RoutineExercisesCompanion.insert(
            id: exercise.id,
            routineId: exercise.routineId,
            name: exercise.name,
            muscleGroup: exercise.muscleGroup,
            metricType: Value(exercise.metricType),
            targetSets: Value(exercise.targetSets),
            targetReps: Value(exercise.targetReps),
            targetWeight: Value(exercise.targetWeight),
            restSeconds: Value(exercise.restSeconds),
            orderIndex: Value(exercise.orderIndex),
            notes: Value(exercise.notes),
            createdAt: Value(exercise.createdAt),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
          ),
        );
  }

  @override
  Future<void> deleteRoutineExercise(String exerciseId) async {
    await (_db.delete(_db.routineExercises)
          ..where((tbl) => tbl.id.equals(exerciseId)))
        .go();
  }

  @override
  Future<void> deleteRoutineExercises(String routineId) async {
    await (_db.delete(_db.routineExercises)
          ..where((tbl) => tbl.routineId.equals(routineId)))
        .go();
  }

  @override
  Stream<WorkoutSessionEntity?> watchActiveSession() {
    return (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.status.equals('active'))
          ..limit(1))
        .watchSingleOrNull()
        .asyncMap((session) async {
      if (session == null) return null;
      final sets = await (_db.select(_db.setRecords)
            ..where((tbl) => tbl.sessionId.equals(session.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
          .get();
      return WorkoutMappers.toSessionEntity(session, sets);
    });
  }

  @override
  Future<WorkoutSessionEntity?> getActiveSession() async {
    final session = await (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.status.equals('active'))
          ..limit(1))
        .getSingleOrNull();
    if (session == null) return null;

    final sets = await (_db.select(_db.setRecords)
          ..where((tbl) => tbl.sessionId.equals(session.id))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
        .get();
    return WorkoutMappers.toSessionEntity(session, sets);
  }

  @override
  Future<void> startWorkoutSession(WorkoutSessionEntity session) async {
    await _db.into(_db.workoutSessions).insert(
          WorkoutSessionsCompanion.insert(
            id: session.id,
            routineId: Value(session.routineId),
            routineName: session.routineName,
            status: const Value('active'),
            startTime: session.startTime,
            totalDurationSeconds: Value(session.totalDurationSeconds),
            totalVolumeKg: Value(session.totalVolumeKg),
            createdAt: Value(session.createdAt),
            updatedAt: Value(session.updatedAt),
            syncStatus: const Value('pending'),
          ),
        );

    for (final s in session.sets) {
      await _db.into(_db.setRecords).insert(
            SetRecordsCompanion.insert(
              id: s.id,
              sessionId: session.id,
              exerciseId: Value(s.exerciseId),
              exerciseName: s.exerciseName,
              muscleGroup: s.muscleGroup,
              setNumber: s.setNumber,
              metricType: Value(s.metricType),
              targetReps: Value(s.targetReps),
              targetWeight: Value(s.targetWeight),
              completedReps: Value(s.completedReps),
              completedWeight: Value(s.completedWeight),
              restTimeSeconds: Value(s.restTimeSeconds),
              isCompleted: Value(s.isCompleted),
              completedAt: Value(s.completedAt),
              createdAt: Value(s.createdAt),
              updatedAt: Value(s.updatedAt),
              syncStatus: const Value('pending'),
            ),
          );
    }
  }

  @override
  Future<void> updateWorkoutSession(WorkoutSessionEntity session) async {
    await (_db.update(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(session.id)))
        .write(
      WorkoutSessionsCompanion(
        totalDurationSeconds: Value(session.totalDurationSeconds),
        totalVolumeKg: Value(session.totalVolumeKg),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  @override
  Future<void> updateSetRecord(SetRecordEntity setRecord) async {
    await (_db.update(_db.setRecords)
          ..where((tbl) => tbl.id.equals(setRecord.id)))
        .write(
      SetRecordsCompanion(
        completedReps: Value(setRecord.completedReps),
        completedWeight: Value(setRecord.completedWeight),
        restTimeSeconds: Value(setRecord.restTimeSeconds),
        isCompleted: Value(setRecord.isCompleted),
        completedAt: Value(setRecord.completedAt),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  @override
  Future<void> completeWorkoutSession(String sessionId) async {
    final sets = await (_db.select(_db.setRecords)
          ..where((tbl) => tbl.sessionId.equals(sessionId)))
        .get();

    double totalVolume = 0;
    for (final s in sets) {
      if (s.isCompleted) {
        totalVolume += s.completedWeight * s.completedReps;
      }
    }

    final session = await (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(sessionId)))
        .getSingle();

    final now = DateTime.now();
    final duration = now.difference(session.startTime).inSeconds;

    await (_db.update(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(sessionId)))
        .write(
      WorkoutSessionsCompanion(
        status: const Value('completed'),
        endTime: Value(now),
        totalDurationSeconds: Value(duration),
        totalVolumeKg: Value(totalVolume),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  @override
  Future<void> cancelWorkoutSession(String sessionId) async {
    await (_db.update(_db.workoutSessions)
          ..where((tbl) => tbl.id.equals(sessionId)))
        .write(
      WorkoutSessionsCompanion(
        status: const Value('cancelled'),
        endTime: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  @override
  Future<List<WorkoutSessionEntity>> getCompletedSessions({
    int limit = 20,
  }) async {
    final sessions = await (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.status.equals('completed'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)])
          ..limit(limit))
        .get();

    final result = <WorkoutSessionEntity>[];
    for (final s in sessions) {
      final sets = await (_db.select(_db.setRecords)
            ..where((tbl) => tbl.sessionId.equals(s.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
          .get();
      result.add(WorkoutMappers.toSessionEntity(s, sets));
    }
    return result;
  }

  @override
  Future<void> clearAllData() async {
    await _db.delete(_db.setRecords).go();
    await _db.delete(_db.workoutSessions).go();
    await _db.delete(_db.routineExercises).go();
    await _db.delete(_db.routines).go();
  }
}
