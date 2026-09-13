import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ActiveWorkoutProgressBar extends StatelessWidget {
  final int completedSets;
  final int totalSets;

  const ActiveWorkoutProgressBar({
    super.key,
    required this.completedSets,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        totalSets > 0 ? (completedSets / totalSets).clamp(0.0, 1.0) : 0.0;
    final int percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progreso', style: AppTypography.bodyMedium),
              Text(
                '$percentage%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
