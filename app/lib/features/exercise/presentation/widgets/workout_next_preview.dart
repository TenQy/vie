import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/set_record_entity.dart';

class WorkoutNextPreview extends StatelessWidget {
  final SetRecordEntity? nextSet;

  const WorkoutNextPreview({super.key, this.nextSet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: nextSet != null ? _buildNextSetContent() : _buildFinishContent(),
    );
  }

  Widget _buildNextSetContent() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.arrowRight, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A CONTINUACIÓN (SERIE ${nextSet!.setNumber})',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${nextSet!.exerciseName} • ${nextSet!.targetReps} reps • ${nextSet!.targetWeight} kg',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinishContent() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.trophy, size: 18, color: AppColors.success),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡ÚLTIMA SERIE DEL ENTRENAMIENTO!',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Da tu máximo esfuerzo para finalizar la sesión con éxito.',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
