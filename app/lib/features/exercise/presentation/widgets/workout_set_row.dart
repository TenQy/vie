import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/set_record_entity.dart';

class WorkoutSetRow extends StatelessWidget {
  final SetRecordEntity setRecord;
  final VoidCallback onToggle;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double> onWeightChanged;

  const WorkoutSetRow({
    super.key,
    required this.setRecord,
    required this.onToggle,
    required this.onRepsChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = setRecord.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _buildSetBadge(),
          const SizedBox(width: 12),
          _buildWeightInput(context),
          const SizedBox(width: 8),
          _buildRepsInput(context),
          const Spacer(),
          _buildCheckButton(),
        ],
      ),
    );
  }

  Widget _buildSetBadge() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          '${setRecord.setNumber}',
          style: AppTypography.titleMedium.copyWith(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildWeightInput(BuildContext context) {
    return Row(
      children: [
        Text(
          '${setRecord.completedWeight.toStringAsFixed(1)} kg',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRepsInput(BuildContext context) {
    return Row(
      children: [
        Text(
          '•  ${setRecord.completedReps} reps',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCheckButton() {
    final isDone = setRecord.isCompleted;
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isDone ? LucideIcons.checkCircle2 : LucideIcons.circle,
        color: isDone ? AppColors.primary : AppColors.textMuted,
        size: 26,
      ),
    );
  }
}
