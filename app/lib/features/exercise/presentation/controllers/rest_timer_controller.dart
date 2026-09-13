import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/workout_alert_service.dart';
import '../../../../core/services/workout_foreground_service.dart';

class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final String? nextExerciseName;
  final int? nextSetNumber;
  final int? totalSetsForExercise;
  final int? nextTargetReps;
  final double? nextTargetWeight;

  const RestTimerState({
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isRunning = false,
    this.nextExerciseName,
    this.nextSetNumber,
    this.totalSetsForExercise,
    this.nextTargetReps,
    this.nextTargetWeight,
  });

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    String? nextExerciseName,
    int? nextSetNumber,
    int? totalSetsForExercise,
    int? nextTargetReps,
    double? nextTargetWeight,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      nextExerciseName: nextExerciseName ?? this.nextExerciseName,
      nextSetNumber: nextSetNumber ?? this.nextSetNumber,
      totalSetsForExercise:
          totalSetsForExercise ?? this.totalSetsForExercise,
      nextTargetReps: nextTargetReps ?? this.nextTargetReps,
      nextTargetWeight: nextTargetWeight ?? this.nextTargetWeight,
    );
  }
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;

  RestTimerNotifier() : super(const RestTimerState());

  void start(
    int seconds, {
    String? nextExerciseName,
    int? nextSetNumber,
    int? totalSetsForExercise,
    int? nextTargetReps,
    double? nextTargetWeight,
  }) {
    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
      nextExerciseName: nextExerciseName ?? state.nextExerciseName,
      nextSetNumber: nextSetNumber ?? state.nextSetNumber,
      totalSetsForExercise:
          totalSetsForExercise ?? state.totalSetsForExercise,
      nextTargetReps: nextTargetReps ?? state.nextTargetReps,
      nextTargetWeight: nextTargetWeight ?? state.nextTargetWeight,
    );
    _syncService();
    _startTimer();
  }

  void _syncService({bool? running}) {
    WorkoutForegroundService.updateRest(
      remainingSeconds: state.remainingSeconds,
      totalSeconds: state.totalSeconds,
      nextExercise: state.nextExerciseName,
      setNumber: state.nextSetNumber,
      totalSets: state.totalSetsForExercise,
      targetReps: state.nextTargetReps,
      targetWeight: state.nextTargetWeight,
      isRunning: running ?? state.isRunning,
    );
  }

  void setTime(int seconds) {
    state = state.copyWith(remainingSeconds: seconds, totalSeconds: seconds);
    _syncService();
    if (state.isRunning && _timer == null) _startTimer();
  }

  void add30Seconds() => _addSeconds(30);

  void add60Seconds() => _addSeconds(60);

  void _addSeconds(int seconds) {
    if (state.remainingSeconds == 0) {
      start(seconds);
    } else {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds + seconds,
        totalSeconds: state.totalSeconds + seconds,
      );
      _syncService();
    }
  }

  void subtract15Seconds() {
    if (state.remainingSeconds <= 15) {
      stop();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 15);
      _syncService();
    }
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
    _syncService(running: false);
  }

  void resume() {
    if (state.remainingSeconds <= 0) return;
    state = state.copyWith(isRunning: true);
    _syncService(running: true);
    _startTimer();
  }

  void togglePause() => state.isRunning ? pause() : resume();

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const RestTimerState();
    WorkoutForegroundService.stop();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      WorkoutAlertService.notifyRestCompleted();
      WorkoutForegroundService.showRestCompleted(
        nextExercise: state.nextExerciseName,
        setNumber: state.nextSetNumber,
        totalSets: state.totalSetsForExercise,
        targetReps: state.nextTargetReps,
        targetWeight: state.nextTargetWeight,
      );
      _timer?.cancel();
      _timer = null;
      state = const RestTimerState();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      _syncService(running: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier();
});
