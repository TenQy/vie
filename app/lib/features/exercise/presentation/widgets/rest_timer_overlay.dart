import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../controllers/rest_timer_controller.dart';

class RestTimerOverlay extends ConsumerWidget {
  const RestTimerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    if (timerState.remainingSeconds <= 0 && !timerState.isRunning) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _buildDecoration(),
      child: Row(
        children: [
          _buildTimerDisplay(timerState),
          const SizedBox(width: 16),
          Expanded(child: _buildControls(ref, timerState)),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay(RestTimerState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descanso',
          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
        ),
        Text(
          DateHelpers.formatDuration(state.remainingSeconds),
          style: AppTypography.metricValue.copyWith(fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildControls(WidgetRef ref, RestTimerState state) {
    final notifier = ref.read(restTimerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: notifier.add30Seconds,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('+30s'),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: state.isRunning ? notifier.pause : notifier.resume,
          icon: Icon(
            state.isRunning ? LucideIcons.pause : LucideIcons.play,
            size: 18,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceCard,
            foregroundColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: notifier.stop,
          icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
