import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';

class RestTimePickerSheet extends StatelessWidget {
  final int currentSeconds;
  final ValueChanged<int> onSelect;

  static const List<(String, int)> _presets = [
    ('30s', 30),
    ('45s', 45),
    ('60s', 60),
    ('90s', 90),
    ('2 min', 120),
    ('2:30', 150),
    ('3 min', 180),
    ('5 min', 300),
  ];

  const RestTimePickerSheet({
    super.key,
    required this.currentSeconds,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ajustar tiempo de descanso',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _presets.map((p) => _buildPresetChip(context, p.$1, p.$2)).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, String label, int seconds) {
    final isSelected = currentSeconds == seconds;

    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor:
          isSelected ? AppColors.primary : AppColors.surfaceElevated,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onSelect(seconds);
      },
    );
  }
}
