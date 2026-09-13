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

    if (restTimer.isRunning && restTimer.remainingSeconds > 0) {
      return Scaffold(
        appBar: _buildAppBar(context, session.routineName, session.id),
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
      appBar: _buildAppBar(context, session.routineName, session.id),
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

  PreferredSizeWidget _buildAppBar(
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
          onPressed: () => _confirmCancel(context, sessionId),
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
          onPressed: () => _confirmFinish(context, sessionId),
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

  void _handleSkipSet(int totalSets) {
    if (_currentSetIndex < totalSets - 1) {
      setState(() => _currentSetIndex++);
    }
  }

  void _confirmFinish(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar Entrenamiento?'),
        content: const Text('Se guardará el volumen y tiempos de tu sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(activeWorkoutControllerProvider.notifier)
                  .finishWorkout(sessionId);
              ref.read(restTimerProvider.notifier).stop();
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar Entrenamiento?'),
        content: const Text('La sesión quedará registrada como cancelada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(activeWorkoutControllerProvider.notifier)
                  .cancelWorkout(sessionId);
              ref.read(restTimerProvider.notifier).stop();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar sesión'),
          ),
        ],
      ),
    );
  }
}
