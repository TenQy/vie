import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/exercise/presentation/controllers/rest_timer_controller.dart';
import 'package:app/features/exercise/presentation/widgets/rest_time_picker_sheet.dart';

void main() {
  group('RestTimePickerSheet', () {
    testWidgets('displays CupertinoTimerPicker, presets and triggers onSelect',
        (WidgetTester tester) async {
      int? selectedSeconds;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestTimePickerSheet(
              currentSeconds: 90,
              onSelect: (s) => selectedSeconds = s,
            ),
          ),
        ),
      );

      expect(find.text('Ajustar tiempo de descanso'), findsOneWidget);
      expect(find.byType(CupertinoTimerPicker), findsOneWidget);
      expect(find.text('1:30'), findsOneWidget);
      expect(find.text('Aplicar (01:30)'), findsOneWidget);

      await tester.tap(find.text('Aplicar (01:30)'));
      await tester.pumpAndSettle();

      expect(selectedSeconds, 90);
    });

    testWidgets('tapping quick preset triggers onSelect directly',
        (WidgetTester tester) async {
      int? selectedSeconds;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestTimePickerSheet(
              currentSeconds: 60,
              onSelect: (s) => selectedSeconds = s,
            ),
          ),
        ),
      );

      await tester.tap(find.text('2m'));
      await tester.pumpAndSettle();

      expect(selectedSeconds, 120);
    });
  });

  group('RestTimerNotifier setTime', () {
    test('setTime updates remainingSeconds and totalSeconds', () {
      final notifier = RestTimerNotifier();
      notifier.start(60);
      expect(notifier.state.remainingSeconds, 60);

      notifier.setTime(120);
      expect(notifier.state.remainingSeconds, 120);
      expect(notifier.state.totalSeconds, 120);

      notifier.stop();
    });
  });
}
