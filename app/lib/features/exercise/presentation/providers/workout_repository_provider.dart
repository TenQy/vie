import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkoutRepositoryImpl(db);
});
