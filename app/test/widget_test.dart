import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:app/features/exercise/presentation/widgets/exercise_card.dart';

void main() {
  testWidgets('ExerciseCard displays name, sets and muscle group',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final exercise = ExerciseEntity(
      id: '1',
      routineId: 'r1',
      name: 'Press de Banca Plano',
      muscleGroup: 'Pectoral',
      targetSets: 4,
      targetReps: 10,
      targetWeight: 60.0,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseCard(exercise: exercise),
        ),
      ),
    );

    expect(find.text('Press de Banca Plano'), findsOneWidget);
    expect(find.text('4x'), findsOneWidget);
    expect(find.text('Pectoral'), findsOneWidget);
    expect(find.text('10 reps • 60.0 kg'), findsOneWidget);
  });
}
