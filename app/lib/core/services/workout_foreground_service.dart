import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../utils/date_helpers.dart';

@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(WorkoutTaskHandler());
}

class WorkoutTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {
    FlutterForegroundTask.sendDataToMain(id);
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

abstract final class WorkoutForegroundService {
  static bool _isInitialized = false;

  static void init() {
    if (_isInitialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vie_workout_channel',
        channelName: 'Entrenamiento Vie',
        channelDescription:
            'Seguimiento en tiempo real de tu sesión de entrenamiento y descansos',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
      ),
    );
    _isInitialized = true;
  }

  static Future<void> requestPermission() async {
    try {
      final status =
          await FlutterForegroundTask.checkNotificationPermission();
      if (status != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (_) {}
  }

  static Future<void> startWorkout({required String routineName}) async {
    try {
      init();
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (isRunning) return;

      await FlutterForegroundTask.startService(
        serviceId: 101,
        notificationTitle: routineName,
        notificationText: 'Entrenamiento en curso',
        notificationButtons: const [
          NotificationButton(id: 'add_30s', text: '+30s'),
          NotificationButton(id: 'toggle_pause', text: 'Pausa'),
          NotificationButton(id: 'skip_rest', text: 'Saltar'),
        ],
        callback: startForegroundCallback,
      );
    } catch (_) {}
  }

  static Future<void> updateRest({
    required int remainingSeconds,
    String? nextExercise,
  }) async {
    try {
      final formatted = DateHelpers.formatDuration(remainingSeconds);
      final subtitle = nextExercise != null
          ? 'Siguiente: $nextExercise'
          : 'Recuperando energía...';

      await FlutterForegroundTask.updateService(
        notificationTitle: 'En descanso: $formatted',
        notificationText: subtitle,
      );
    } catch (_) {}
  }

  static Future<void> updateExercise({
    required String exerciseName,
    required int setNumber,
    required int totalSets,
  }) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: exerciseName,
        notificationText: 'Serie $setNumber de $totalSets en curso',
      );
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (isRunning) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}
  }
}
