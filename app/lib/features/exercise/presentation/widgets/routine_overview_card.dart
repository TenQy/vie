import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/routine_entity.dart';

class RoutineOverviewCard extends StatelessWidget {
  final RoutineEntity routine;
  final VoidCallback onStartWorkout;

  const RoutineOverviewCard({
    super.key,
    required this.routine,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final totalSets = routine.exercises.fold<int>(
      0,
      (sum, ex) => sum + ex.targetSets,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildBadge(),
                const Spacer(),
                Text(
                  '${routine.exercises.length} ejercicios • $totalSets series',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              routine.name,
              style: AppTypography.displayMedium.copyWith(fontSize: 24),
            ),
            if (routine.description != null && routine.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                routine.description!,
                style: AppTypography.bodyMedium,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onStartWorkout,
              icon: const Icon(LucideIcons.play, size: 18),
              label: const Text('Iniciar Entrenamiento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'RUTINA DE HOY',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
