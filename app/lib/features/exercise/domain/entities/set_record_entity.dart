class SetRecordEntity {
  final String id;
  final String sessionId;
  final String? exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final int setNumber;
  final String metricType;
  final int targetReps;
  final double targetWeight;
  final int completedReps;
  final double completedWeight;
  final int restTimeSeconds;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const SetRecordEntity({
    required this.id,
    required this.sessionId,
    this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.setNumber,
    this.metricType = 'reps_weight',
    this.targetReps = 0,
    this.targetWeight = 0.0,
    this.completedReps = 0,
    this.completedWeight = 0.0,
    this.restTimeSeconds = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  SetRecordEntity copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    int? setNumber,
    String? metricType,
    int? targetReps,
    double? targetWeight,
    int? completedReps,
    double? completedWeight,
    int? restTimeSeconds,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return SetRecordEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      setNumber: setNumber ?? this.setNumber,
      metricType: metricType ?? this.metricType,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      completedReps: completedReps ?? this.completedReps,
      completedWeight: completedWeight ?? this.completedWeight,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
