import 'exercise_entity.dart';

class RoutineEntity {
  final String id;
  final String name;
  final String? description;
  final int? targetDay; // 1 = Monday, 7 = Sunday, null = orphan template
  final bool isActive;
  final int orderIndex;
  final List<ExerciseEntity> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const RoutineEntity({
    required this.id,
    required this.name,
    this.description,
    this.targetDay,
    this.isActive = true,
    this.orderIndex = 0,
    this.exercises = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  RoutineEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? targetDay,
    bool? isActive,
    int? orderIndex,
    List<ExerciseEntity>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return RoutineEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetDay: targetDay ?? this.targetDay,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
