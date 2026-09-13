import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/features/exercise/domain/entities/set_record_entity.dart';
import 'package:app/features/exercise/presentation/widgets/active_workout_progress_bar.dart';
import 'package:app/features/exercise/presentation/widgets/current_exercise_card.dart';
import 'package:app/features/exercise/presentation/widgets/rest_timer_ring_view.dart';
import 'package:app/features/exercise/presentation/widgets/workout_dialogs.dart';

void main() {
  group('ActiveWorkoutProgressBar', () {
    testWidgets('displays Progreso and correct percentage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutProgressBar(
              completedSets: 2,
              totalSets: 4,
            ),
          ),
        ),
      );

      expect(find.text('Progreso'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('handles zero total sets without division by zero',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActiveWorkoutProgressBar(
              completedSets: 0,
              totalSets: 0,
            ),
          ),
        ),
      );

      expect(find.text('Progreso'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });
  });

  group('CurrentExerciseCard', () {
    final testSet = SetRecordEntity(
      id: 'set-1',
      sessionId: 'sess-1',
      exerciseName: 'Press Militar',
      muscleGroup: 'Hombros',
      setNumber: 1,
      targetReps: 10,
      targetWeight: 40.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('shows single Saltar Serie button without chevron navigation',
        (WidgetTester tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentExerciseCard(
              currentSet: testSet,
              totalSetsForExercise: 3,
              onCompleteSet: (reps, weight) {},
              onSkipSet: () => skipped = true,
            ),
          ),
        ),
      );

      expect(find.text('Saltar Serie'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);

      await tester.tap(find.text('Saltar Serie'));
      await tester.pump();

      expect(skipped, isTrue);
    });
  });

  group('RestTimerRingView', () {
    testWidgets('displays remaining time and triggers onSkipRest',
        (WidgetTester tester) async {
      bool skipRestCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestTimerRingView(
              remainingSeconds: 75,
              totalSeconds: 90,
              isRunning: true,
              nextSet: null,
              onAdd30Seconds: () {},
              onAdd60Seconds: () {},
              onSubtract15Seconds: () {},
              onTogglePause: () {},
              onSkipRest: () => skipRestCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('01:15'), findsOneWidget);
      expect(find.text('DESCANSO'), findsOneWidget);
      expect(find.text('¡Listo para la serie!'), findsOneWidget);

      await tester.tap(find.text('¡Listo para la serie!'));
      await tester.pump();

      expect(skipRestCalled, isTrue);
    });

    testWidgets('displays PAUSADO and play icon when paused, triggers toggle',
        (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestTimerRingView(
              remainingSeconds: 45,
              totalSeconds: 60,
              isRunning: false,
              nextSet: null,
              onAdd30Seconds: () {},
              onAdd60Seconds: () {},
              onSubtract15Seconds: () {},
              onTogglePause: () => toggleCalled = true,
              onSkipRest: () {},
            ),
          ),
        ),
      );

      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('PAUSADO'), findsOneWidget);
      expect(find.byIcon(LucideIcons.play), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.play));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });
  });

  group('WorkoutDialogs', () {
    testWidgets('confirmCancelRest shows dialog and triggers onConfirm',
        (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => WorkoutDialogs.confirmCancelRest(
                  context: context,
                  onConfirm: () => confirmed = true,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cancelar Descanso?'), findsOneWidget);
      expect(find.text('Deshacer serie'), findsOneWidget);

      await tester.tap(find.text('Deshacer serie'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.text('¿Cancelar Descanso?'), findsNothing);
    });
  });
}
