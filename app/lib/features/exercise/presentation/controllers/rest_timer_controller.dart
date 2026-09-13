import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/workout_alert_service.dart';

class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;

  const RestTimerState({
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isRunning = false,
  });

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;

  RestTimerNotifier() : super(const RestTimerState());

  void start(int seconds) {
    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
    );
    _startTimer();
  }

  void setTime(int seconds) {
    final running = state.isRunning;
    state = state.copyWith(
      remainingSeconds: seconds,
      totalSeconds: seconds,
    );
    if (running && _timer == null) {
      _startTimer();
    }
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
    }
  }

  void subtract15Seconds() {
    if (state.remainingSeconds <= 15) {
      stop();
    } else {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 15,
      );
    }
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void resume() {
    if (state.remainingSeconds <= 0) return;
    state = state.copyWith(isRunning: true);
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const RestTimerState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      WorkoutAlertService.notifyRestCompleted();
      stop();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
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
