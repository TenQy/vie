import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/workout_session_entity.dart';

class ActiveSessionBanner extends StatelessWidget {
  final WorkoutSessionEntity session;
  final VoidCallback onTap;

  const ActiveSessionBanner({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _buildBoxDecoration(),
        child: Row(
          children: [
            _buildPulsingIcon(),
            const SizedBox(width: 14),
            Expanded(child: _buildInfoColumn()),
            _buildResumeButton(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.2),
          AppColors.surfaceCard,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
    );
  }

  Widget _buildPulsingIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(LucideIcons.activity, color: AppColors.primary, size: 20),
    );
  }

  Widget _buildInfoColumn() {
    final completedSets = session.sets.where((s) => s.isCompleted).length;
    final totalSets = session.sets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrenamiento en curso',
          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 2),
        Text(
          session.routineName,
          style: AppTypography.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$completedSets de $totalSets series completadas',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildResumeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Reanudar',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
