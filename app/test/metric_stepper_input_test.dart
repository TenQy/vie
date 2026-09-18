import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/core/widgets/metric_stepper_input.dart';

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

      final textField = find.byType(TextField);
      await tester.enterText(textField, '23.75');
      await tester.pump();

      expect(latestValue, 23.75);
    });

    testWidgets('blocks typing beyond maxIntegerDigits in decimal inputs',
        (WidgetTester tester) async {
      num latestValue = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricStepperInput(
              label: 'PESO (KG)',
              value: latestValue,
              isDecimal: true,
              maxIntegerDigits: 3,
              maxDecimalDigits: 2,
              step: 2.5,
              onChanged: (val) => latestValue = val,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      // Try to type 1200 (4 integer digits). Formatter blocks 4th digit.
      await tester.enterText(textField, '1200');
      await tester.pump();

      // Text field does not allow 1200
      expect(find.text('1200'), findsNothing);

      // Allows 999.5
      await tester.enterText(textField, '999.5');
      await tester.pump();
      expect(find.text('999.5'), findsOneWidget);
    });

    testWidgets('blocks typing beyond maxIntegerDigits in integer inputs',
        (WidgetTester tester) async {
      num latestValue = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricStepperInput(
              label: 'REPS',
              value: latestValue,
              maxIntegerDigits: 3,
              step: 1,
              onChanged: (val) => latestValue = val,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      // Try to type 1000 (4 digits). Formatter blocks 4th digit.
      await tester.enterText(textField, '1000');
      await tester.pump();

      expect(find.text('1000'), findsNothing);

      // Allows up to 999
      await tester.enterText(textField, '999');
      await tester.pump();
      expect(find.text('999'), findsOneWidget);
    });

    testWidgets('increments and decrements using buttons within bounds',
        (WidgetTester tester) async {
      num latestValue = 998;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricStepperInput(
              label: 'REPS',
              value: latestValue,
              minValue: 1,
              maxValue: 999,
              step: 1,
              onChanged: (val) => latestValue = val,
            ),
          ),
        ),
      );

      // Increment to 999
      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();
      expect(latestValue, 999);

      // Try to increment past 999 -> stays at 999
      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();
      expect(latestValue, 999);

      // Decrement
      await tester.tap(find.byIcon(LucideIcons.minus));
      await tester.pump();
      expect(latestValue, 998);
    });

    testWidgets('selects all text on focus', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricStepperInput(
              label: 'PESO (KG)',
              value: 100.5,
              isDecimal: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      final editable = tester.widget<TextField>(textField);
      expect(editable.controller!.selection.baseOffset, 0);
      expect(editable.controller!.selection.extentOffset, '100.5'.length);
    });
  });
}
