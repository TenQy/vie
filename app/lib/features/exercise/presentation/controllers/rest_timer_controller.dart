import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/workout_alert_service.dart';
import '../../../../core/services/workout_foreground_service.dart';

class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final String? nextExerciseName;

  const RestTimerState({
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isRunning = false,
    this.nextExerciseName,
  });

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    String? nextExerciseName,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      nextExerciseName: nextExerciseName ?? this.nextExerciseName,
    );
  }
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;

  RestTimerNotifier() : super(const RestTimerState());

  void start(int seconds, {String? nextExerciseName}) {
    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
      nextExerciseName: nextExerciseName ?? state.nextExerciseName,
    );
    WorkoutForegroundService.updateRest(
      remainingSeconds: seconds,
      nextExercise: state.nextExerciseName,
      isRunning: true,
    );
    _startTimer();
  }

  void setTime(int seconds) {
    final running = state.isRunning;
    WorkoutForegroundService.updateRest(
      remainingSeconds: seconds,
      nextExercise: state.nextExerciseName,
      isRunning: running,
    );
    state = state.copyWith(remainingSeconds: seconds, totalSeconds: seconds);
    if (running && _timer == null) _startTimer();
  }

  void add30Seconds() => _addSeconds(30);

  void add60Seconds() => _addSeconds(60);

  void _addSeconds(int seconds) {
    if (state.remainingSeconds == 0) {
      start(seconds);
    } else {
      final updated = state.remainingSeconds + seconds;
      WorkoutForegroundService.updateRest(
        remainingSeconds: updated,
        nextExercise: state.nextExerciseName,
        isRunning: state.isRunning,
      );
      state = state.copyWith(
        remainingSeconds: updated,
        totalSeconds: state.totalSeconds + seconds,
      );
    }
  }

  void subtract15Seconds() {
    if (state.remainingSeconds <= 15) {
      stop();
    } else {
      final updated = state.remainingSeconds - 15;
      WorkoutForegroundService.updateRest(
        remainingSeconds: updated,
        nextExercise: state.nextExerciseName,
        isRunning: state.isRunning,
      );
      state = state.copyWith(remainingSeconds: updated);
    }
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
    WorkoutForegroundService.updateRest(
      remainingSeconds: state.remainingSeconds,
      nextExercise: state.nextExerciseName,
      isRunning: false,
    );
  }

  void resume() {
    if (state.remainingSeconds <= 0) return;
    state = state.copyWith(isRunning: true);
    WorkoutForegroundService.updateRest(
      remainingSeconds: state.remainingSeconds,
      nextExercise: state.nextExerciseName,
      isRunning: true,
    );
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
      );
      _timer?.cancel();
      _timer = null;
      state = const RestTimerState();
    } else {
      final next = state.remainingSeconds - 1;
      WorkoutForegroundService.updateRest(
        remainingSeconds: next,
        nextExercise: state.nextExerciseName,
        isRunning: true,
      );
      state = state.copyWith(remainingSeconds: next);
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
