import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/services/workout_foreground_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/rest_timer_controller.dart';
import '../widgets/active_workout_bottom_bar.dart';
import '../widgets/active_workout_exercise_view.dart';
import '../widgets/rest_timer_ring_view.dart';
import '../widgets/workout_dialogs.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutSessionEntity session;

  const ActiveWorkoutScreen({super.key, required this.session});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen>
    with WidgetsBindingObserver {
  int _currentSetIndex = 0;
  String? _lastCompletedSetId;

  @override
  void initState() {
    super.initState();
    final firstPending = widget.session.sets.indexWhere((s) => !s.isCompleted);
    if (firstPending != -1) _currentSetIndex = firstPending;
    WidgetsBinding.instance.addObserver(this);
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WorkoutForegroundService.requestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    WorkoutForegroundService.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (ref.read(restTimerProvider).remainingSeconds <= 0) {
        WorkoutForegroundService.stop();
      }
    }
  }

  void _onReceiveTaskData(dynamic data) {
    if (data is! String) return;
    final t = ref.read(restTimerProvider.notifier);
    if (data == 'add_30s') t.add30Seconds();
    if (data == 'toggle_pause') t.togglePause();
    if (data == 'skip_rest') t.stop();
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
      final notifier = ref.read(restTimerProvider.notifier);
      return Scaffold(
        appBar: _appBar(
          session.routineName,
          'Cancelar descanso',
          () => _handleCancelRest(session),
        ),
        body: RestTimerRingView(
          remainingSeconds: restTimer.remainingSeconds,
          totalSeconds: restTimer.totalSeconds,
          isRunning: restTimer.isRunning,
          nextSet: currentSet.isCompleted ? null : currentSet,
          onAdd30Seconds: notifier.add30Seconds,
          onAdd60Seconds: notifier.add60Seconds,
          onSubtract15Seconds: notifier.subtract15Seconds,
          onTogglePause: notifier.togglePause,
          onSkipRest: notifier.stop,
          onSetTime: notifier.setTime,
        ),
      );
    }

    final nextSet = (safeIndex + 1 < session.sets.length)
        ? session.sets[safeIndex + 1]
        : null;

    return Scaffold(
      appBar: _appBar(
        session.routineName,
        'Cancelar sesión',
        () => _confirmCancel(session.id),
      ),
      body: ActiveWorkoutExerciseView(
        session: session,
        currentSet: currentSet,
        nextSet: nextSet,
        onCompleteSet: (reps, weight) => _handleCompleteSet(
          currentSet,
          reps,
          weight,
          session.sets.length,
          nextSet?.exerciseName,
        ),
        onSkipSet: () => _handleSkipSet(session.sets.length),
      ),
      bottomNavigationBar: ActiveWorkoutBottomBar(
        onFinish: () => _confirmFinish(session.id),
      ),
    );
  }

  PreferredSizeWidget _appBar(String t, String tip, VoidCallback fn) =>
      AppHeader(title: t, actions: [
        IconButton(icon: const Icon(LucideIcons.x, color: AppColors.error), tooltip: tip, onPressed: fn),
      ]);

  void _endWorkout(void Function(String) action, String sessionId) {
    action(sessionId);
    ref.read(restTimerProvider.notifier).stop();
    WorkoutForegroundService.stop();
    Navigator.pop(context);
  }

  void _confirmCancel(String id) => WorkoutDialogs.confirmCancel(
        context: context,
        onConfirm: () => _endWorkout(ref.read(activeWorkoutControllerProvider.notifier).cancelWorkout, id),
      );

  void _confirmFinish(String id) => WorkoutDialogs.confirmFinish(
        context: context,
        onConfirm: () => _endWorkout(ref.read(activeWorkoutControllerProvider.notifier).finishWorkout, id),
      );

  void _handleCompleteSet(
    SetRecordEntity set,
    int reps,
    double weight,
    int total,
    String? nextEx,
  ) {
    _lastCompletedSetId = set.id;
    ref
        .read(activeWorkoutControllerProvider.notifier)
        .completeSet(set, reps: reps, weight: weight);
    if (_currentSetIndex < total - 1) setState(() => _currentSetIndex++);
    final rest = set.restTimeSeconds > 0 ? set.restTimeSeconds : 90;
    ref.read(restTimerProvider.notifier).start(rest, nextExerciseName: nextEx);
  }

  void _handleCancelRest(WorkoutSessionEntity session) =>
      WorkoutDialogs.confirmCancelRest(
        context: context,
        onConfirm: () {
          ref.read(restTimerProvider.notifier).stop();
          final id = _lastCompletedSetId;
          if (id == null) return;
          final idx = session.sets.indexWhere((s) => s.id == id);
          if (idx == -1) return;
          ref
              .read(activeWorkoutControllerProvider.notifier)
              .revertSetCompletion(session.sets[idx]);
          setState(() {
            _currentSetIndex = idx;
            _lastCompletedSetId = null;
          });
        },
      );

  void _handleSkipSet(int totalSets) {
    if (_currentSetIndex < totalSets - 1) setState(() => _currentSetIndex++);
  }
}
