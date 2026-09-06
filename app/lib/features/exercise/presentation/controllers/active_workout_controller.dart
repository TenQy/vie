import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/routine_entity.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../providers/workout_repository_provider.dart';

final activeSessionStreamProvider = StreamProvider<WorkoutSessionEntity?>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchActiveSession();
});

class ActiveWorkoutController extends StateNotifier<AsyncValue<void>> {
  final WorkoutRepository _repository;
  final _uuid = const Uuid();

  ActiveWorkoutController(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> startWorkoutFromRoutine(RoutineEntity routine) async {
    final now = DateTime.now();
    final sessionId = _uuid.v4();

    final sets = <SetRecordEntity>[];
    int order = 0;
    for (final ex in routine.exercises) {
      for (int i = 1; i <= ex.targetSets; i++) {
        order++;
        sets.add(
          SetRecordEntity(
            id: _uuid.v4(),
            sessionId: sessionId,
            exerciseId: ex.id,
            exerciseName: ex.name,
            muscleGroup: ex.muscleGroup,
            setNumber: i,
            metricType: ex.metricType,
            targetReps: ex.targetReps,
            targetWeight: ex.targetWeight,
            completedReps: ex.targetReps,
            completedWeight: ex.targetWeight,
            restTimeSeconds: ex.restSeconds,
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

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.startWorkoutSession(session));
  }

  Future<void> startFreeWorkout() async {
    final now = DateTime.now();
    final sessionId = _uuid.v4();

    final session = WorkoutSessionEntity(
      id: sessionId,
      routineName: 'Entrenamiento Libre',
      status: 'active',
      startTime: now,
      sets: const [],
      createdAt: now,
      updatedAt: now,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.startWorkoutSession(session));
  }

  Future<void> toggleSetCompletion(
    SetRecordEntity setRecord, {
    int? completedReps,
    double? completedWeight,
  }) async {
    final now = DateTime.now();
    final updated = setRecord.copyWith(
      isCompleted: !setRecord.isCompleted,
      completedReps: completedReps ?? setRecord.completedReps,
      completedWeight: completedWeight ?? setRecord.completedWeight,
      completedAt: !setRecord.isCompleted ? now : null,
      updatedAt: now,
    );

    state = await AsyncValue.guard(() => _repository.updateSetRecord(updated));
  }

  Future<void> completeSet(
    SetRecordEntity setRecord, {
    required int reps,
    required double weight,
  }) async {
    final now = DateTime.now();
    final updated = setRecord.copyWith(
      isCompleted: true,
      completedReps: reps,
      completedWeight: weight,
      completedAt: now,
      updatedAt: now,
    );

    state = await AsyncValue.guard(() => _repository.updateSetRecord(updated));
  }

  Future<void> finishWorkout(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.completeWorkoutSession(sessionId),
    );
  }

  Future<void> cancelWorkout(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.cancelWorkoutSession(sessionId),
    );
  }
}

final activeWorkoutControllerProvider =
    StateNotifierProvider<ActiveWorkoutController, AsyncValue<void>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return ActiveWorkoutController(repo);
});
