import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/entities/routine_entity.dart';

class RoutineManagementCard extends StatelessWidget {
  final RoutineEntity routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoutineManagementCard({
    super.key,
    required this.routine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalSets = routine.exercises.fold<int>(
      0,
      (sum, ex) => sum + ex.targetSets,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildDayBadge(),
                  const Spacer(),
                  Text(
                    '${routine.exercises.length} ejercicios • $totalSets series',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                routine.name,
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              if (routine.description != null && routine.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  routine.description!,
                  style: AppTypography.bodyMedium,
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(LucideIcons.pencil, size: 16),
                      label: const Text('Editar Rutina'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
                    tooltip: 'Eliminar Rutina',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayBadge() {
    final hasDay = routine.targetDay != null;
    final isToday = hasDay && routine.targetDay == DateHelpers.currentDayOfWeek;

    final label = !hasDay
        ? 'SIN ASIGNAR'
        : (isToday
            ? 'HOY • ${DateHelpers.getDayName(routine.targetDay!).toUpperCase()}'
            : DateHelpers.getDayName(routine.targetDay!).toUpperCase());

    final bgColor = hasDay
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColors.surface;

    final textColor = hasDay ? AppColors.primary : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: hasDay ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
