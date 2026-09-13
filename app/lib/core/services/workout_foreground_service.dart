import 'dart:async';
import 'package:flutter/services.dart';
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
  static const _nativeChannel = MethodChannel('com.vie.app/workout_notification');
  static bool _isInitialized = false;

  static void init() {
    FlutterForegroundTask.initCommunicationPort();
    if (_isInitialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vie_workout_channel_v3',
        channelName: 'Descansos y Entrenamiento',
        channelDescription: 'Seguimiento de tiempos de recuperación y series',
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
      final status = await FlutterForegroundTask.checkNotificationPermission();
      if (status != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (_) {}
  }

  static List<NotificationButton> _restButtons({bool isRunning = true}) => [
        const NotificationButton(id: 'add_30s', text: '+30s', textColor: Color(0xFF6C5CE7)),
        NotificationButton(id: 'toggle_pause', text: isRunning ? 'Pausar' : 'Reanudar'),
        const NotificationButton(id: 'skip_rest', text: 'Saltar', textColor: Color(0xFFFF4757)),
      ];

  static const _icon = NotificationIcon(
    metaDataName: 'com.pravera.flutter_foreground_task.notificationIcon',
    backgroundColor: Color(0xFF6C5CE7),
  );

  static String _restText({
    String? next, int? setNum, int? total, int? reps, double? kg,
  }) {
    final b = StringBuffer();
    if (next != null) {
      final s = (total != null && total > 0) ? ' (Serie $setNum de $total)' : '';
      b.writeln('Siguiente: $next$s');
    }
    if (reps != null && reps > 0) {
      final w = (kg != null && kg > 0) ? '$kg kg × ' : '';
      b.write('Objetivo: $w$reps reps');
    }
    return b.toString();
  }

  static Future<void> startWorkout({required String routineName}) async {
    try {
      init();
      if (await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.startService(
        serviceId: 101,
        notificationTitle: routineName,
        notificationText: 'Sesión activa en curso',
        notificationIcon: _icon,
        notificationButtons: _restButtons(isRunning: true),
        callback: startForegroundCallback,
      );
    } catch (_) {}
  }

  static Future<void> updateRest({
    required int remainingSeconds,
    required int totalSeconds,
    String? nextExercise,
    int? setNumber,
    int? totalSets,
    int? targetReps,
    double? targetWeight,
    bool isRunning = true,
  }) async {
    try {
      init();
      final formatted = DateHelpers.formatDuration(remainingSeconds);
      final title = isRunning ? '$formatted  |  Descanso' : '$formatted  |  En pausa';
      final text = _restText(
        next: nextExercise,
        setNum: setNumber,
        total: totalSets,
        reps: targetReps,
        kg: targetWeight,
      );

      if (!await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.startService(
          serviceId: 101,
          notificationTitle: title,
          notificationText: text,
          notificationIcon: _icon,
          notificationButtons: _restButtons(isRunning: isRunning),
          callback: startForegroundCallback,
        );
      }

      final elapsed = (totalSeconds - remainingSeconds).clamp(0, totalSeconds);
      try {
        await _nativeChannel.invokeMethod('updateProgress', {
          'max': totalSeconds,
          'progress': elapsed,
          'title': title,
          'text': text,
          'isRunning': isRunning,
        });
      } catch (_) {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: text,
          notificationButtons: _restButtons(isRunning: isRunning),
        );
      }
    } catch (_) {}
  }

  static Future<void> showRestCompleted({
    String? nextExercise,
    int? setNumber,
    int? totalSets,
    int? targetReps,
    double? targetWeight,
  }) async {
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      final b = StringBuffer();
      if (nextExercise != null) {
        b.writeln('Momento de iniciar: $nextExercise${totalSets != null && totalSets > 0 ? ' • Serie $setNumber de $totalSets' : ''}');
      }
      if (targetReps != null && targetReps > 0) {
        b.writeln('Objetivo: ${targetWeight != null && targetWeight > 0 ? '$targetWeight kg × ' : ''}$targetReps reps');
      }
      b.write('Toca para volver al entrenamiento');
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Descanso completado',
        notificationText: b.toString(),
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
