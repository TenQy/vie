import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/exercise_entity.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final Widget? trailing;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildLeadingIndicator(),
            const SizedBox(width: 14),
            Expanded(child: _buildDetailsColumn()),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIndicator() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          '${exercise.targetSets}x',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: AppTypography.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildMuscleBadge(exercise.muscleGroup),
            const SizedBox(width: 8),
            Text(
              '${exercise.targetReps} reps • ${exercise.targetWeight} kg',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMuscleBadge(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        muscle,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
