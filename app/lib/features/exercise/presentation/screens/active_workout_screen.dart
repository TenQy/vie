import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/set_record_entity.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/rest_timer_controller.dart';
import '../widgets/rest_timer_overlay.dart';
import '../widgets/workout_set_row.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  final WorkoutSessionEntity session;

  const ActiveWorkoutScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedSets = _groupSetsByExercise(session.sets);

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: groupedSets.keys.length,
            itemBuilder: (context, index) {
              final exName = groupedSets.keys.elementAt(index);
              final sets = groupedSets[exName]!;
              return _buildExerciseSection(ref, exName, sets);
            },
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RestTimerOverlay(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(session.routineName),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.error),
          tooltip: 'Cancelar sesión',
          onPressed: () => _confirmCancel(context, ref),
        ),
      ],
    );
  }

  Widget _buildExerciseSection(
    WidgetRef ref,
    String exerciseName,
    List<SetRecordEntity> sets,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exerciseName, style: AppTypography.titleMedium),
          const SizedBox(height: 10),
          ...sets.map((s) => WorkoutSetRow(
                setRecord: s,
                onToggle: () => _handleToggleSet(ref, s),
                onRepsChanged: (r) {},
                onWeightChanged: (w) {},
              )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _confirmFinish(context, ref),
        icon: const Icon(LucideIcons.check),
        label: const Text('Finalizar Entrenamiento'),
      ),
    );
  }

  Map<String, List<SetRecordEntity>> _groupSetsByExercise(
    List<SetRecordEntity> sets,
  ) {
    final map = <String, List<SetRecordEntity>>{};
    for (final s in sets) {
      map.putIfAbsent(s.exerciseName, () => []).add(s);
    }
    return map;
  }

  void _handleToggleSet(WidgetRef ref, SetRecordEntity s) {
    ref
        .read(activeWorkoutControllerProvider.notifier)
        .toggleSetCompletion(s);

    if (!s.isCompleted && s.restTimeSeconds > 0) {
      ref.read(restTimerProvider.notifier).start(s.restTimeSeconds);
    }
  }

  void _confirmFinish(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar Entrenamiento?'),
        content: const Text(
          'Se guardará la telemetría, volumen total y tiempos de tu sesión en la base de datos local.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar entrenando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(activeWorkoutControllerProvider.notifier)
                  .finishWorkout(session.id);
              ref.read(restTimerProvider.notifier).stop();
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar Entrenamiento?'),
        content: const Text(
          'La sesión quedará registrada como cancelada y no se computará como terminada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(activeWorkoutControllerProvider.notifier)
                  .cancelWorkout(session.id);
              ref.read(restTimerProvider.notifier).stop();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar sesión'),
          ),
        ],
      ),
    );
  }
}
