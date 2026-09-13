import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/rest_timer_controller.dart';
import '../widgets/active_workout_progress_bar.dart';
import '../widgets/current_exercise_card.dart';
import '../widgets/rest_timer_ring_view.dart';
import '../widgets/workout_dialogs.dart';
import '../widgets/workout_next_preview.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutSessionEntity session;

  const ActiveWorkoutScreen({super.key, required this.session});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _currentSetIndex = 0;
  String? _lastCompletedSetId;

  @override
  void initState() {
    super.initState();
    final firstPending = widget.session.sets.indexWhere((s) => !s.isCompleted);
    if (firstPending != -1) {
      _currentSetIndex = firstPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveSessionAsync = ref.watch(activeSessionStreamProvider);
    final session = liveSessionAsync.valueOrNull ?? widget.session;
    final restTimer = ref.watch(restTimerProvider);

    if (session.sets.isEmpty) {
      return Scaffold(
        appBar: AppHeader(title: session.routineName),
        body: const Center(child: Text('No hay series configuradas.')),
      );
    }

    final safeIndex = _currentSetIndex.clamp(0, session.sets.length - 1);
    final currentSet = session.sets[safeIndex];

    if (restTimer.remainingSeconds > 0) {
      return Scaffold(
        appBar: _buildRestAppBar(context, session.routineName, session),
        body: RestTimerRingView(
          remainingSeconds: restTimer.remainingSeconds,
          totalSeconds: restTimer.totalSeconds,
          isRunning: restTimer.isRunning,
          nextSet: currentSet.isCompleted ? null : currentSet,
          onAdd30Seconds: () =>
              ref.read(restTimerProvider.notifier).add30Seconds(),
          onSubtract15Seconds: () =>
              ref.read(restTimerProvider.notifier).subtract15Seconds(),
          onTogglePause: () {
            final n = ref.read(restTimerProvider.notifier);
            restTimer.isRunning ? n.pause() : n.resume();
          },
          onSkipRest: () => ref.read(restTimerProvider.notifier).stop(),
        ),
      );
    }

    final nextSet = (safeIndex + 1 < session.sets.length)
        ? session.sets[safeIndex + 1]
        : null;
    final totalSetsForEx = session.sets
        .where((s) => s.exerciseName == currentSet.exerciseName)
        .length;
    final completedCount = session.sets.where((s) => s.isCompleted).length;

    return Scaffold(
      appBar: _buildWorkoutAppBar(context, session.routineName, session.id),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ActiveWorkoutProgressBar(
            completedSets: completedCount,
            totalSets: session.sets.length,
          ),
          CurrentExerciseCard(
            currentSet: currentSet,
            totalSetsForExercise: totalSetsForEx,
            onCompleteSet: (reps, weight) => _handleCompleteSet(
              currentSet,
              reps,
              weight,
              session.sets.length,
            ),
            onSkipSet: () => _handleSkipSet(session.sets.length),
          ),
          WorkoutNextPreview(nextSet: nextSet),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, session.id),
    );
  }

  PreferredSizeWidget _buildRestAppBar(
    BuildContext context,
    String title,
    WorkoutSessionEntity session,
  ) {
    return AppHeader(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.error),
          tooltip: 'Cancelar descanso y deshacer serie',
          onPressed: () => _handleCancelRest(session),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildWorkoutAppBar(
    BuildContext context,
    String title,
    String sessionId,
  ) {
    return AppHeader(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.error),
          tooltip: 'Cancelar sesión',
          onPressed: () => WorkoutDialogs.confirmCancel(
            context: context,
            onConfirm: () {
              ref
                  .read(activeWorkoutControllerProvider.notifier)
                  .cancelWorkout(sessionId);
              ref.read(restTimerProvider.notifier).stop();
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, String sessionId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: () => WorkoutDialogs.confirmFinish(
            context: context,
            onConfirm: () {
              ref
                  .read(activeWorkoutControllerProvider.notifier)
                  .finishWorkout(sessionId);
              ref.read(restTimerProvider.notifier).stop();
              Navigator.pop(context);
            },
          ),
          icon: const Icon(LucideIcons.check),
          label: const Text('Finalizar Entrenamiento'),
        ),
      ),
    );
  }

  void _handleCompleteSet(
    SetRecordEntity currentSet,
    int reps,
    double weight,
    int totalSets,
  ) {
    _lastCompletedSetId = currentSet.id;
    ref
        .read(activeWorkoutControllerProvider.notifier)
        .completeSet(currentSet, reps: reps, weight: weight);

    if (_currentSetIndex < totalSets - 1) {
      setState(() => _currentSetIndex++);
    }

    final rest =
        currentSet.restTimeSeconds > 0 ? currentSet.restTimeSeconds : 90;
    ref.read(restTimerProvider.notifier).start(rest);
  }

  void _handleCancelRest(WorkoutSessionEntity session) {
    WorkoutDialogs.confirmCancelRest(
      context: context,
      onConfirm: () {
        ref.read(restTimerProvider.notifier).stop();
        if (_lastCompletedSetId != null) {
          final targetIndex =
              session.sets.indexWhere((s) => s.id == _lastCompletedSetId);
          if (targetIndex != -1) {
            final setToRevert = session.sets[targetIndex];
            ref
                .read(activeWorkoutControllerProvider.notifier)
                .revertSetCompletion(setToRevert);
            setState(() {
              _currentSetIndex = targetIndex;
              _lastCompletedSetId = null;
            });
          }
        }
      },
    );
  }

  void _handleSkipSet(int totalSets) {
    if (_currentSetIndex < totalSets - 1) {
      setState(() => _currentSetIndex++);
    }
  }
}
