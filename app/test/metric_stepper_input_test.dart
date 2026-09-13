import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/features/exercise/presentation/widgets/metric_stepper_input.dart';

void main() {
  group('MetricStepperInput', () {
    testWidgets('allows free typing of decimal numbers for weight',
        (WidgetTester tester) async {
      num latestValue = 20.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricStepperInput(
              label: 'PESO (KG)',
              value: latestValue,
              isDecimal: true,
              step: 2.5,
              onChanged: (val) => latestValue = val,
            ),
          ),
        ),
      );

      expect(find.text('20'), findsOneWidget);

      final textField = find.byType(TextField);
      await tester.enterText(textField, '23.75');
      await tester.pump();

      expect(latestValue, 23.75);
    });

    testWidgets('increments and decrements using buttons',
        (WidgetTester tester) async {
      num latestValue = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricStepperInput(
              label: 'REPS',
              value: latestValue,
              minValue: 1,
              step: 1,
              onChanged: (val) => latestValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();
      expect(latestValue, 11);

      await tester.tap(find.byIcon(LucideIcons.minus));
      await tester.pump();
      expect(latestValue, 10);
    });
  });
}
