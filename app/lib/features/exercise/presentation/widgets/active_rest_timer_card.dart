import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../controllers/rest_timer_controller.dart';

class ActiveRestTimerCard extends ConsumerWidget {
  final int defaultRestSeconds;

  const ActiveRestTimerCard({
    super.key,
    this.defaultRestSeconds = 90,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    final notifier = ref.read(restTimerProvider.notifier);
    final isIdle = timerState.remainingSeconds <= 0 && !timerState.isRunning;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: timerState.isRunning
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
            width: timerState.isRunning ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderRow(timerState, isIdle),
            const SizedBox(height: 12),
            _buildTimerValue(timerState, isIdle),
            if (!isIdle && timerState.totalSeconds > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: timerState.remainingSeconds / timerState.totalSeconds,
                  backgroundColor: AppColors.surface,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildControlsRow(notifier, timerState, isIdle),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(RestTimerState state, bool isIdle) {
    String status = 'LISTO';
    Color color = AppColors.textMuted;

    if (state.isRunning) {
      status = 'DESCANSO EN CURSO';
      color = AppColors.primary;
    } else if (!isIdle) {
      status = 'DESCANSO EN PAUSA';
      color = AppColors.accent;
    }

    return Row(
      children: [
        Icon(LucideIcons.timer, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          status,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerValue(RestTimerState state, bool isIdle) {
    final displayTime = isIdle
        ? DateHelpers.formatDuration(defaultRestSeconds)
        : DateHelpers.formatDuration(state.remainingSeconds);

    return Center(
      child: Text(
        displayTime,
        style: AppTypography.metricValue.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: state.isRunning ? AppColors.primary : AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildControlsRow(
    RestTimerNotifier notifier,
    RestTimerState state,
    bool isIdle,
  ) {
    if (isIdle) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => notifier.start(defaultRestSeconds),
          icon: const Icon(LucideIcons.play, size: 16),
          label: Text('Iniciar descanso (${defaultRestSeconds}s)'),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: notifier.subtract15Seconds,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('-15s'),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: state.isRunning ? notifier.pause : notifier.resume,
          icon: Icon(state.isRunning ? LucideIcons.pause : LucideIcons.play, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: notifier.add30Seconds,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('+30s'),
        ),
        const SizedBox(width: 10),
        TextButton.icon(
          onPressed: notifier.stop,
          icon: const Icon(LucideIcons.x, size: 16),
          label: const Text('Omitir'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
        ),
      ],
    );
  }
}
