import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/core/widgets/number_counter.dart';

void main() {
  group('NumberCounter', () {
    testWidgets('disables decrement button when at or below minValue',
        (WidgetTester tester) async {
      var decremented = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(
              label: 'Series',
              value: 1,
              minValue: 1,
              maxValue: 20,
              onDecrement: () => decremented = true,
              onIncrement: () {},
            ),
          ),
        ),
      );

      final minusBtn = find.widgetWithIcon(IconButton, LucideIcons.minus);
      expect(tester.widget<IconButton>(minusBtn).onPressed, isNull);

      await tester.tap(minusBtn);
      await tester.pump();
      expect(decremented, isFalse);
    });

    testWidgets('disables increment button when at or above maxValue',
        (WidgetTester tester) async {
      var incremented = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(
              label: 'Series',
              value: 20,
              minValue: 1,
              maxValue: 20,
              onDecrement: () {},
              onIncrement: () => incremented = true,
            ),
          ),
        ),
      );

      final plusBtn = find.widgetWithIcon(IconButton, LucideIcons.plus);
      expect(tester.widget<IconButton>(plusBtn).onPressed, isNull);

      await tester.tap(plusBtn);
      await tester.pump();
      expect(incremented, isFalse);
    });
  });
}
