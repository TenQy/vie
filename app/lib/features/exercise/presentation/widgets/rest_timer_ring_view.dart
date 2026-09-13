import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/entities/set_record_entity.dart';

class RestTimerRingView extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final SetRecordEntity? nextSet;
  final VoidCallback onAdd30Seconds;
  final VoidCallback onSubtract15Seconds;
  final VoidCallback onTogglePause;
  final VoidCallback onSkipRest;

  const RestTimerRingView({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.nextSet,
    required this.onAdd30Seconds,
    required this.onSubtract15Seconds,
    required this.onTogglePause,
    required this.onSkipRest,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Spacer(),
            _buildTimerRing(),
            const SizedBox(height: 32),
            _buildQuickControls(),
            const SizedBox(height: 24),
            _buildSkipRestButton(),
            const Spacer(),
            if (nextSet != null) _buildNextSetPreview(nextSet!),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerRing() {
    final double progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRunning ? 'DESCANSO' : 'PAUSADO',
                style: AppTypography.labelSmall.copyWith(
                  color: isRunning ? AppColors.primary : AppColors.textMuted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateHelpers.formatDuration(remainingSeconds),
                style: AppTypography.metricValue.copyWith(fontSize: 44),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onSubtract15Seconds,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('-15s'),
        ),
        const SizedBox(width: 16),
        IconButton.filled(
          onPressed: onTogglePause,
          icon: Icon(isRunning ? LucideIcons.pause : LucideIcons.play, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: onAdd30Seconds,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('+30s'),
        ),
      ],
    );
  }

  Widget _buildSkipRestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSkipRest,
        icon: const Icon(LucideIcons.skipForward, size: 20),
        label: const Text('Saltar Descanso'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildNextSetPreview(SetRecordEntity next) {
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
          Text(
            'A CONTINUACIÓN',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next.exerciseName,
            style: AppTypography.titleMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            'Serie ${next.setNumber} • ${next.targetReps} reps • ${next.targetWeight} kg',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
