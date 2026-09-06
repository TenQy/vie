import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class ExerciseListEmptyCard extends StatelessWidget {
  const ExerciseListEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.dumbbell, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Aún no has agregado ejercicios',
              style: AppTypography.titleMedium.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text('Presiona "+ Agregar Ejercicio" para armar tu rutina.',
              style: AppTypography.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
