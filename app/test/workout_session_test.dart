import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/exercise/data/repositories/workout_repository_impl.dart';
import 'package:app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:app/features/exercise/domain/entities/routine_entity.dart';
import 'package:app/features/exercise/domain/entities/set_record_entity.dart';
import 'package:app/features/exercise/domain/entities/workout_session_entity.dart';

void main() {
  test('startWorkoutSession creates all sets atomically and watchActiveSession emits all sets',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = WorkoutRepositoryImpl(db);

    final now = DateTime.now();
    final routine = RoutineEntity(
      id: 'routine-1',
      name: 'Pecho y Tríceps',
      createdAt: now,
      updatedAt: now,
      exercises: [
        ExerciseEntity(
          id: 'ex-1',
          routineId: 'routine-1',
          name: 'Press de Banca',
          muscleGroup: 'Pectoral',
          targetSets: 3,
          targetReps: 10,
          targetWeight: 60.0,
          createdAt: now,
          updatedAt: now,
        ),
        ExerciseEntity(
          id: 'ex-2',
          routineId: 'routine-1',
          name: 'Fondos',
          muscleGroup: 'Brazos',
          targetSets: 3,
          targetReps: 12,
          targetWeight: 0.0,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final sessionId = 'session-1';
    final sets = <SetRecordEntity>[];
    int order = 0;
    for (final ex in routine.exercises) {
      for (int i = 1; i <= ex.targetSets; i++) {
        order++;
        sets.add(
          SetRecordEntity(
            id: 'set-$order',
            sessionId: sessionId,
            exerciseId: ex.id,
            exerciseName: ex.name,
            muscleGroup: ex.muscleGroup,
            setNumber: i,
            targetReps: ex.targetReps,
            targetWeight: ex.targetWeight,
            createdAt: now.add(Duration(milliseconds: order * 10)),
            updatedAt: now,
          ),
        );
      }
    }

    final session = WorkoutSessionEntity(
      id: sessionId,
      routineId: routine.id,
      routineName: routine.name,
      status: 'active',
      startTime: now,
      sets: sets,
      createdAt: now,
      updatedAt: now,
    );

    final emissions = <WorkoutSessionEntity?>[];
    final sub = repo.watchActiveSession().listen((data) {
      emissions.add(data);
    });

    await repo.startWorkoutSession(session);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(emissions.last, isNotNull);
    expect(emissions.last!.sets.length, 6);
    final setNamesAndNumbers = emissions.last!.sets
        .map((s) => '${s.exerciseName} S${s.setNumber}')
        .toList();
    expect(setNamesAndNumbers, [
      'Press de Banca S1',
      'Press de Banca S2',
      'Press de Banca S3',
      'Fondos S1',
      'Fondos S2',
      'Fondos S3',
    ]);

    // Test updating a set record
    final firstSet = emissions.last!.sets.first;
    final updatedFirstSet = firstSet.copyWith(
      isCompleted: true,
      completedReps: 12,
      completedWeight: 65.0,
      completedAt: DateTime.now(),
    );

    await repo.updateSetRecord(updatedFirstSet);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(emissions.last!.sets.first.isCompleted, isTrue);
    expect(emissions.last!.sets.first.completedReps, 12);
    expect(emissions.last!.sets.first.completedWeight, 65.0);

    await sub.cancel();
    await db.close();
  });

  test(
      'startWorkoutSession automatically cancels previous active sessions and isolates sets',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = WorkoutRepositoryImpl(db);
    final now = DateTime.now();

    final session1 = WorkoutSessionEntity(
      id: 'session-old',
      routineId: 'routine-1',
      routineName: 'Rutina 1',
      status: 'active',
      startTime: now.subtract(const Duration(minutes: 30)),
      sets: [
        SetRecordEntity(
          id: 'set-s1-1',
          sessionId: 'session-old',
          exerciseName: 'Sentadilla',
          muscleGroup: 'Piernas',
          setNumber: 1,
          createdAt: now,
          updatedAt: now,
        ),
        SetRecordEntity(
          id: 'set-s1-2',
          sessionId: 'session-old',
          exerciseName: 'Sentadilla',
          muscleGroup: 'Piernas',
          setNumber: 2,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await repo.startWorkoutSession(session1);

    final active1 = await repo.getActiveSession();
    expect(active1, isNotNull);
    expect(active1!.id, 'session-old');
    expect(active1.sets.length, 2);

    // Now start a second session without finishing session 1
    final session2 = WorkoutSessionEntity(
      id: 'session-new',
      routineId: 'routine-2',
      routineName: 'Rutina 2',
      status: 'active',
      startTime: now,
      sets: [
        SetRecordEntity(
          id: 'set-s2-1',
          sessionId: 'session-new',
          exerciseName: 'Press Militar',
          muscleGroup: 'Hombros',
          setNumber: 1,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await repo.startWorkoutSession(session2);

    // Active session should now be session2
    final active2 = await repo.getActiveSession();
    expect(active2, isNotNull);
    expect(active2!.id, 'session-new');
    expect(active2.sets.length, 1);
    expect(active2.sets.first.exerciseName, 'Press Militar');

    // And watchActiveSession must only emit session2 sets (not 3 sets!)
    final emitted = await repo.watchActiveSession().first;
    expect(emitted, isNotNull);
    expect(emitted!.id, 'session-new');
    expect(emitted.sets.length, 1);

    // Check that session1 is marked as cancelled
    final allSessions = await db.select(db.workoutSessions).get();
    final oldDbSession = allSessions.firstWhere((s) => s.id == 'session-old');
    expect(oldDbSession.status, 'cancelled');

    await db.close();
  });
}
