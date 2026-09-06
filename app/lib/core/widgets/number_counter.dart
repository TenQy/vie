import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';

class NumberCounter extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const NumberCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.minus, size: 16),
                onPressed: onDecrement,
              ),
              Text('$value', style: AppTypography.titleMedium),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
