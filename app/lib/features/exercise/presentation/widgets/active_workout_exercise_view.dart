import 'package:flutter/material.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';
import 'active_workout_progress_bar.dart';
import 'current_exercise_card.dart';
import 'workout_next_preview.dart';

class ActiveWorkoutExerciseView extends StatelessWidget {
  final WorkoutSessionEntity session;
  final SetRecordEntity currentSet;
  final SetRecordEntity? nextSet;
  final void Function(int reps, double weight) onCompleteSet;
  final VoidCallback onSkipSet;

  const ActiveWorkoutExerciseView({
    super.key,
    required this.session,
    required this.currentSet,
    required this.nextSet,
    required this.onCompleteSet,
    required this.onSkipSet,
  });

  @override
  Widget build(BuildContext context) {
    final totalSetsForEx = session.sets
        .where((s) => s.exerciseName == currentSet.exerciseName)
        .length;
    final completedCount = session.sets.where((s) => s.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        ActiveWorkoutProgressBar(
          completedSets: completedCount,
          totalSets: session.sets.length,
        ),
        CurrentExerciseCard(
          currentSet: currentSet,
          totalSetsForExercise: totalSetsForEx,
          onCompleteSet: onCompleteSet,
          onSkipSet: onSkipSet,
        ),
        WorkoutNextPreview(nextSet: nextSet),
      ],
    );
  }
}
