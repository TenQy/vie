import 'set_record_entity.dart';

class WorkoutSessionEntity {
  final String id;
  final String? routineId;
  final String routineName;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime startTime;
  final DateTime? endTime;
  final int totalDurationSeconds;
  final double totalVolumeKg;
  final List<SetRecordEntity> sets;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const WorkoutSessionEntity({
    required this.id,
    this.routineId,
    required this.routineName,
    this.status = 'active',
    required this.startTime,
    this.endTime,
    this.totalDurationSeconds = 0,
    this.totalVolumeKg = 0.0,
    this.sets = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  WorkoutSessionEntity copyWith({
    String? id,
    String? routineId,
    String? routineName,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    int? totalDurationSeconds,
    double? totalVolumeKg,
    List<SetRecordEntity>? sets,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return WorkoutSessionEntity(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      routineName: routineName ?? this.routineName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
