import 'dart:async';
import 'package:flutter/material.dart';
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
    FlutterForegroundTask.initCommunicationPort();
    if (_isInitialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vie_workout_channel_v2',
        channelName: 'Entrenamiento Vie',
        channelDescription:
            'Seguimiento en tiempo real de tu sesión de entrenamiento y descansos',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
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

  static List<NotificationButton> _restButtons({bool isRunning = true}) => [
        const NotificationButton(
          id: 'add_30s',
          text: '+30s',
          textColor: Color(0xFF6C5CE7),
        ),
        NotificationButton(
          id: 'toggle_pause',
          text: isRunning ? '⏸️ Pausa' : '▶️ Reanudar',
          textColor:
              isRunning ? const Color(0xFFFFA502) : const Color(0xFF2ED573),
        ),
        const NotificationButton(
          id: 'skip_rest',
          text: '⏭️ Saltar',
          textColor: Color(0xFFFF4757),
        ),
      ];

  static const _icon = NotificationIcon(
    metaDataName: 'com.pravera.flutter_foreground_task.notificationIcon',
    backgroundColor: Color(0xFF6C5CE7),
  );

  static Future<void> startWorkout({required String routineName}) async {
    try {
      init();
      if (await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.startService(
        serviceId: 101,
        notificationTitle: '🏋️ $routineName',
        notificationText: 'Sesión iniciada • ¡A darlo todo!',
        notificationIcon: _icon,
        notificationButtons: _restButtons(isRunning: true),
        callback: startForegroundCallback,
      );
    } catch (_) {}
  }

  static Future<void> updateRest({
    required int remainingSeconds,
    String? nextExercise,
    bool isRunning = true,
  }) async {
    try {
      init();
      final formatted = DateHelpers.formatDuration(remainingSeconds);
      final title = isRunning
          ? '⏱️ $formatted • Descanso activo'
          : '⏸️ $formatted (Pausado) • Descanso';
      final subtitle = nextExercise != null
          ? '🏋️ Siguiente: $nextExercise'
          : '💪 Recuperando energía...';

      if (!await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.startService(
          serviceId: 101,
          notificationTitle: title,
          notificationText: subtitle,
          notificationIcon: _icon,
          notificationButtons: _restButtons(isRunning: isRunning),
          callback: startForegroundCallback,
        );
      } else {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: subtitle,
          notificationButtons: _restButtons(isRunning: isRunning),
        );
      }
    } catch (_) {}
  }

  static Future<void> showRestCompleted({String? nextExercise}) async {
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      final subtitle = nextExercise != null
          ? '💪 ¡Hora de $nextExercise!'
          : '💪 ¡Listo para la siguiente serie!';
      await FlutterForegroundTask.updateService(
        notificationTitle: '🔔 ¡Descanso completado!',
        notificationText: subtitle,
        notificationButtons: const [],
      );
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {}
  }
}
