import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/routine_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../providers/workout_repository_provider.dart';

final routinesStreamProvider = StreamProvider<List<RoutineEntity>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchRoutines();
});

class RoutineListController extends StateNotifier<AsyncValue<void>> {
  final WorkoutRepository _repository;
  final _uuid = const Uuid();

  RoutineListController(this._repository) : super(const AsyncValue.data(null));

  Future<void> seedDefaultRoutinesIfEmpty() async {
    final existing = await _repository.getRoutines();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final routineId = _uuid.v4();

    // Default template: Push / Empuje
    final routine = RoutineEntity(
      id: routineId,
      name: 'Empuje & Torso (Fuerza)',
      description: 'Pectoral, deltoides anterior y tríceps con sobrecarga progresiva',
      targetDay: DateTime.now().weekday, // Assign to current day for immediate testing!
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveRoutine(routine);

    final defaultExercises = [
      ExerciseEntity(
        id: _uuid.v4(),
        routineId: routineId,
        name: 'Press de Banca Plano',
        muscleGroup: 'Pectoral',
        targetSets: 4,
        targetReps: 8,
        targetWeight: 60.0,
        restSeconds: 120,
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      ),
      ExerciseEntity(
        id: _uuid.v4(),
        routineId: routineId,
        name: 'Press Militar con Barra',
        muscleGroup: 'Hombros',
        targetSets: 3,
        targetReps: 10,
        targetWeight: 35.0,
        restSeconds: 90,
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      ExerciseEntity(
        id: _uuid.v4(),
        routineId: routineId,
        name: 'Fondos en Paralelas',
        muscleGroup: 'Tríceps',
        targetSets: 3,
        targetReps: 12,
        targetWeight: 0.0,
        restSeconds: 60,
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final ex in defaultExercises) {
      await _repository.saveRoutineExercise(ex);
    }
  }

  Future<void> deleteRoutine(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteRoutine(id));
  }

  Future<void> createRoutine({
    required String name,
    String? description,
    int? targetDay,
  }) async {
    final now = DateTime.now();
    final routine = RoutineEntity(
      id: _uuid.v4(),
      name: name,
      description: description,
      targetDay: targetDay,
      createdAt: now,
      updatedAt: now,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.saveRoutine(routine));
  }
}

final routineListControllerProvider =
    StateNotifierProvider<RoutineListController, AsyncValue<void>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return RoutineListController(repo);
});
