import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';

class RestTimePickerSheet extends StatefulWidget {
  final int currentSeconds;
  final ValueChanged<int> onSelect;

  const RestTimePickerSheet({
    super.key,
    required this.currentSeconds,
    required this.onSelect,
  });

  @override
  State<RestTimePickerSheet> createState() => _RestTimePickerSheetState();
}

class _RestTimePickerSheetState extends State<RestTimePickerSheet> {
  late int _selectedSeconds;

  static const List<(String, int)> _quickPresets = [
    ('45s', 45),
    ('1m', 60),
    ('1:30', 90),
    ('2m', 120),
    ('3m', 180),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSeconds = widget.currentSeconds > 0 ? widget.currentSeconds : 90;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 12),
            _buildHeader(),
            const SizedBox(height: 12),
            _buildQuickPresets(),
            const SizedBox(height: 10),
            _buildWheelPicker(),
            const SizedBox(height: 16),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Ajustar tiempo de descanso',
      style: AppTypography.titleMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildQuickPresets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _quickPresets.map((p) {
        final isCurrent = _selectedSeconds == p.$2;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(
            label: Text(p.$1),
            labelStyle: AppTypography.labelSmall.copyWith(
              color: isCurrent ? Colors.white : AppColors.textPrimary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
            backgroundColor:
                isCurrent ? AppColors.primary : AppColors.surfaceElevated,
            side: BorderSide(
              color: isCurrent ? AppColors.primary : AppColors.border,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              widget.onSelect(p.$2);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWheelPicker() {
    return SizedBox(
      height: 130,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.ms,
          initialTimerDuration: Duration(seconds: _selectedSeconds),
          onTimerDurationChanged: (duration) {
            setState(() {
              _selectedSeconds =
                  duration.inSeconds > 0 ? duration.inSeconds : 5;
            });
          },
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    final formatted = DateHelpers.formatDuration(_selectedSeconds);
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        widget.onSelect(_selectedSeconds);
      },
      icon: const Icon(LucideIcons.check, size: 18),
      label: Text('Aplicar ($formatted)'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
