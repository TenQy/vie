import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/exercise/data/repositories/workout_repository_impl.dart';
import 'package:app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:app/features/exercise/domain/entities/routine_entity.dart';

void main() {
  test('saveRoutineWithExercises saves exercises and emits atomically in watchRoutines',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = WorkoutRepositoryImpl(db);

    final now = DateTime.now();
    final routine = RoutineEntity(
      id: 'routine-1',
      name: 'Rutina Pierna',
      createdAt: now,
      updatedAt: now,
    );
    final initialExercises = [
      ExerciseEntity(
        id: 'ex-1',
        routineId: 'routine-1',
        name: 'Sentadilla',
        muscleGroup: 'Piernas',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final emissions = <List<RoutineEntity>>[];
    final sub = repo.watchRoutines().listen((data) {
      emissions.add(data);
    });

    await repo.saveRoutineWithExercises(
      routine: routine,
      exercises: initialExercises,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    expect(emissions.last.first.exercises.length, 1);
    expect(emissions.last.first.exercises.first.name, 'Sentadilla');

    // Update with 2 different exercises
    final updatedRoutine = routine.copyWith(name: 'Rutina Pierna & Glúteos');
    final updatedExercises = [
      ExerciseEntity(
        id: 'ex-2',
        routineId: 'routine-1',
        name: 'Prensa',
        muscleGroup: 'Piernas',
        createdAt: now,
        updatedAt: now,
      ),
      ExerciseEntity(
        id: 'ex-3',
        routineId: 'routine-1',
        name: 'Curl Femoral',
        muscleGroup: 'Piernas',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await repo.saveRoutineWithExercises(
      routine: updatedRoutine,
      exercises: updatedExercises,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    expect(emissions.last.first.exercises.length, 2);
    expect(emissions.last.first.name, 'Rutina Pierna & Glúteos');
    expect(emissions.last.first.exercises.map((e) => e.name).toList(),
        ['Prensa', 'Curl Femoral']);

    await sub.cancel();
    await db.close();
  });
}
