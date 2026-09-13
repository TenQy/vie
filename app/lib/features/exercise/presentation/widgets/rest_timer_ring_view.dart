import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/set_record_entity.dart';
import 'glowing_timer_ring.dart';
import 'rest_time_picker_sheet.dart';

class RestTimerRingView extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final SetRecordEntity? nextSet;
  final VoidCallback onAdd30Seconds;
  final VoidCallback onAdd60Seconds;
  final VoidCallback onSubtract15Seconds;
  final VoidCallback onTogglePause;
  final VoidCallback onSkipRest;
  final ValueChanged<int> onSetTime;

  const RestTimerRingView({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.nextSet,
    required this.onAdd30Seconds,
    required this.onAdd60Seconds,
    required this.onSubtract15Seconds,
    required this.onTogglePause,
    required this.onSkipRest,
    required this.onSetTime,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Spacer(),
            GlowingTimerRing(
              remainingSeconds: remainingSeconds,
              totalSeconds: totalSeconds,
              isRunning: isRunning,
              onTapTime: () => _showTimePicker(context),
            ),
            const SizedBox(height: 32),
            _buildQuickControls(),
            const SizedBox(height: 24),
            _buildActionButton(),
            const Spacer(),
            if (nextSet != null) _buildPreparationCard(nextSet!),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RestTimePickerSheet(
        currentSeconds: remainingSeconds,
        onSelect: onSetTime,
      ),
    );
  }

  Widget _buildQuickControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPillButton('-15s', () {
          HapticFeedback.lightImpact();
          onSubtract15Seconds();
        }),
        const SizedBox(width: 12),
        _buildPlayPauseButton(),
        const SizedBox(width: 12),
        _buildPillButton('+30s', () {
          HapticFeedback.lightImpact();
          onAdd30Seconds();
        }),
        const SizedBox(width: 8),
        _buildPillButton('+1m', () {
          HapticFeedback.lightImpact();
          onAdd60Seconds();
        }),
      ],
    );
  }

  Widget _buildPillButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton.filled(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onTogglePause();
      },
      icon: Icon(isRunning ? LucideIcons.pause : LucideIcons.play, size: 24),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceElevated,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.all(16),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          onSkipRest();
        },
        icon: const Icon(LucideIcons.zap, size: 20),
        label: const Text('¡Listo para la serie!'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPreparationCard(SetRecordEntity next) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PREPÁRATE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Serie ${next.setNumber}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            next.exerciseName,
            style: AppTypography.titleMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            'Cargar ${next.targetWeight} kg • ${next.targetReps} reps • ${next.muscleGroup}',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
