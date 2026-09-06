import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/routine_list_controller.dart';
import '../providers/workout_repository_provider.dart';
import '../widgets/active_session_banner.dart';
import '../widgets/exercise_card.dart';
import 'active_workout_screen.dart';
import 'workout_settings_screen.dart';

class WorkoutHomeScreen extends ConsumerWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionAsync = ref.watch(activeSessionStreamProvider);
    final routinesAsync = ref.watch(routinesStreamProvider);

    return Scaffold(
      appBar: AppHeader(
        title: 'Entrenamiento',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Gestión de rutinas',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutSettingsScreen()),
            ),
          ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) => _buildContent(context, ref, routines, activeSessionAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar rutinas: $err')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<RoutineEntity> routines,
    AsyncValue activeSessionAsync,
  ) {
    final currentDay = DateHelpers.currentDayOfWeek;
    final scheduledRoutine = routines
        .where((r) => r.targetDay == currentDay)
        .firstOrNull ??
        routines.firstOrNull;

    final activeBanner = activeSessionAsync.maybeWhen(
      data: (session) {
        if (session == null) return const SizedBox.shrink();
        return ActiveSessionBanner(
          session: session,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActiveWorkoutScreen(session: session),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );

    if (scheduledRoutine == null) {
      return Column(
        children: [
          activeBanner,
          Expanded(
            child: EmptyState(
              icon: LucideIcons.dumbbell,
              title: 'No hay rutina programada para hoy',
              description:
                  'Crea tu primera plantilla para comenzar a registrar tus entrenamientos.',
              action: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutSettingsScreen(),
                  ),
                ),
                icon: const Icon(LucideIcons.plus),
                label: const Text('Crear Primera Rutina'),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        activeBanner,
        _buildScheduledRoutineSection(context, ref, scheduledRoutine),
      ],
    );
  }

  Widget _buildScheduledRoutineSection(
    BuildContext context,
    WidgetRef ref,
    RoutineEntity routine,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(routine.name, style: AppTypography.displayMedium),
              ),
            ],
          ),
          if (routine.description != null) ...[
            const SizedBox(height: 4),
            Text(routine.description!, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _startWorkout(context, ref, routine),
            icon: const Icon(LucideIcons.play),
            label: const Text('Iniciar Entrenamiento'),
          ),
          const SizedBox(height: 24),
          Text(
            'Ejercicios programados (${routine.exercises.length})',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 12),
          ...routine.exercises.map((ex) => ExerciseCard(exercise: ex)),
        ],
      ),
    );
  }

  void _startWorkout(
    BuildContext context,
    WidgetRef ref,
    RoutineEntity routine,
  ) async {
    await ref
        .read(activeWorkoutControllerProvider.notifier)
        .startWorkoutFromRoutine(routine);

    final session = await ref.read(workoutRepositoryProvider).getActiveSession();
    if (session != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreen(session: session),
        ),
      );
    }
  }
}
