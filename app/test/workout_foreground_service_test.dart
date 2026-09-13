import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/services/workout_foreground_service.dart';
import 'package:app/features/exercise/presentation/controllers/rest_timer_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutForegroundService', () {
    test('WorkoutTaskHandler instantiates cleanly', () {
      final handler = WorkoutTaskHandler();
      expect(handler, isNotNull);
    });

    test('Service safe methods execute without uncaught exceptions', () async {
      WorkoutForegroundService.init();
      await WorkoutForegroundService.requestPermission();
      await WorkoutForegroundService.startWorkout(routineName: 'Push Day');
      await WorkoutForegroundService.updateRest(
        remainingSeconds: 60,
        nextExercise: 'Press Banca',
        isRunning: true,
      );
      await WorkoutForegroundService.showRestCompleted(
        nextExercise: 'Press Banca',
      );
      await WorkoutForegroundService.stop();
    });
  });

  group('RestTimerNotifier foreground integration', () {
    test('start, togglePause, add, subtract updates state properly', () {
      final notifier = RestTimerNotifier();
      expect(notifier.state.remainingSeconds, equals(0));
      expect(notifier.state.isRunning, isFalse);

      notifier.start(90, nextExerciseName: 'Sentadillas');
      expect(notifier.state.remainingSeconds, equals(90));
      expect(notifier.state.totalSeconds, equals(90));
      expect(notifier.state.isRunning, isTrue);
      expect(notifier.state.nextExerciseName, equals('Sentadillas'));

      notifier.togglePause();
      expect(notifier.state.isRunning, isFalse);

      notifier.togglePause();
      expect(notifier.state.isRunning, isTrue);

      notifier.add30Seconds();
      expect(notifier.state.remainingSeconds, equals(120));
      expect(notifier.state.totalSeconds, equals(120));

      notifier.subtract15Seconds();
      expect(notifier.state.remainingSeconds, equals(105));

      notifier.setTime(45);
      expect(notifier.state.remainingSeconds, equals(45));
      expect(notifier.state.totalSeconds, equals(45));

      notifier.stop();
      expect(notifier.state.remainingSeconds, equals(0));
      expect(notifier.state.isRunning, isFalse);
    });
  });
}
