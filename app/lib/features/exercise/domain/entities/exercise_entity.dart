class ExerciseEntity {
  final String id;
  final String routineId;
  final String name;
  final String muscleGroup;
  final String metricType; // 'reps_weight' or 'time'
  final int targetSets;
  final int targetReps;
  final double targetWeight;
  final int restSeconds;
  final int orderIndex;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const ExerciseEntity({
    required this.id,
    required this.routineId,
    required this.name,
    required this.muscleGroup,
    this.metricType = 'reps_weight',
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetWeight = 0.0,
    this.restSeconds = 90,
    this.orderIndex = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  ExerciseEntity copyWith({
    String? id,
    String? routineId,
    String? name,
    String? muscleGroup,
    String? metricType,
    int? targetSets,
    int? targetReps,
    double? targetWeight,
    int? restSeconds,
    int? orderIndex,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      metricType: metricType ?? this.metricType,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      restSeconds: restSeconds ?? this.restSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
