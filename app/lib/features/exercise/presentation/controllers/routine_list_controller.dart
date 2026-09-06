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

  Future<void> clearAllData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.clearAllData());
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

  Future<void> saveRoutineWithExercises({
    required RoutineEntity routine,
    required List<ExerciseEntity> exercises,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.saveRoutineWithExercises(
        routine: routine,
        exercises: exercises,
      ),
    );
  }
}

final routineListControllerProvider =
    StateNotifierProvider<RoutineListController, AsyncValue<void>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return RoutineListController(repo);
});
