import '../../../../core/database/app_database.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/routine_entity.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';

abstract final class WorkoutMappers {
  static RoutineEntity toRoutineEntity(
    Routine row,
    List<RoutineExercise> exerciseRows,
  ) {
    return RoutineEntity(
      id: row.id,
      name: row.name,
      description: row.description,
      targetDay: row.targetDay,
      isActive: row.isActive,
      orderIndex: row.orderIndex,
      exercises: exerciseRows.map(toExerciseEntity).toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      syncStatus: row.syncStatus,
    );
  }

  static ExerciseEntity toExerciseEntity(RoutineExercise row) {
    return ExerciseEntity(
      id: row.id,
      routineId: row.routineId,
      name: row.name,
      muscleGroup: row.muscleGroup,
      metricType: row.metricType,
      targetSets: row.targetSets,
      targetReps: row.targetReps,
      targetWeight: row.targetWeight,
      restSeconds: row.restSeconds,
      orderIndex: row.orderIndex,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      syncStatus: row.syncStatus,
    );
  }

  static WorkoutSessionEntity toSessionEntity(
    WorkoutSession row,
    List<SetRecord> setRows,
  ) {
    return WorkoutSessionEntity(
      id: row.id,
      routineId: row.routineId,
      routineName: row.routineName,
      status: row.status,
      startTime: row.startTime,
      endTime: row.endTime,
      totalDurationSeconds: row.totalDurationSeconds,
      totalVolumeKg: row.totalVolumeKg,
      sets: setRows.map(toSetRecordEntity).toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      syncStatus: row.syncStatus,
    );
  }

  static SetRecordEntity toSetRecordEntity(SetRecord row) {
    return SetRecordEntity(
      id: row.id,
      sessionId: row.sessionId,
      exerciseId: row.exerciseId,
      exerciseName: row.exerciseName,
      muscleGroup: row.muscleGroup,
      setNumber: row.setNumber,
      metricType: row.metricType,
      targetReps: row.targetReps,
      targetWeight: row.targetWeight,
      completedReps: row.completedReps,
      completedWeight: row.completedWeight,
      restTimeSeconds: row.restTimeSeconds,
      isCompleted: row.isCompleted,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      syncStatus: row.syncStatus,
    );
  }
}
