import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class ActiveWorkoutBottomBar extends StatelessWidget {
  final VoidCallback onFinish;

  const ActiveWorkoutBottomBar({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: onFinish,
          icon: const Icon(LucideIcons.check),
          label: const Text('Finalizar Entrenamiento'),
        ),
      ),
    );
  }
}
