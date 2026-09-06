import '../entities/exercise_entity.dart';
import '../entities/routine_entity.dart';
import '../entities/set_record_entity.dart';
import '../entities/workout_session_entity.dart';

abstract interface class WorkoutRepository {
  // Routine management
  Stream<List<RoutineEntity>> watchRoutines();
  Future<List<RoutineEntity>> getRoutines();
  Future<RoutineEntity?> getRoutineById(String id);
  Future<void> saveRoutine(RoutineEntity routine);
  Future<void> deleteRoutine(String id);
  Future<void> saveRoutineExercise(ExerciseEntity exercise);
  Future<void> deleteRoutineExercise(String exerciseId);
  Future<void> deleteRoutineExercises(String routineId);
  Future<void> saveRoutineWithExercises({
    required RoutineEntity routine,
    required List<ExerciseEntity> exercises,
  });

  // Active workout session
  Stream<WorkoutSessionEntity?> watchActiveSession();
  Future<WorkoutSessionEntity?> getActiveSession();
  Future<void> startWorkoutSession(WorkoutSessionEntity session);
  Future<void> updateWorkoutSession(WorkoutSessionEntity session);
  Future<void> updateSetRecord(SetRecordEntity setRecord);
  Future<void> completeWorkoutSession(String sessionId);
  Future<void> cancelWorkoutSession(String sessionId);

  // Historical sessions
  Future<List<WorkoutSessionEntity>> getCompletedSessions({int limit = 20});

  // Database maintenance
  Future<void> clearAllData();
}
