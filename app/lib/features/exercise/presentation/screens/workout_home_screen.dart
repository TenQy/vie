import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/routine_list_controller.dart';
import '../providers/workout_repository_provider.dart';
import '../widgets/active_session_banner.dart';
import '../widgets/exercise_card.dart';
import 'active_workout_screen.dart';
import 'workout_settings_screen.dart';

class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(routineListControllerProvider.notifier)
          .seedDefaultRoutinesIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSessionAsync = ref.watch(activeSessionStreamProvider);
    final routinesAsync = ref.watch(routinesStreamProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: routinesAsync.when(
        data: (routines) => _buildContent(context, routines, activeSessionAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar rutinas: $err')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateHelpers.getDayName(DateHelpers.currentDayOfWeek).toUpperCase(),
            style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
          ),
          Text('Entrenamiento', style: AppTypography.titleLarge),
        ],
      ),
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
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<RoutineEntity> routines,
    AsyncValue activeSessionAsync,
  ) {
    final currentDay = DateHelpers.currentDayOfWeek;
    final scheduledRoutine = routines
        .where((r) => r.targetDay == currentDay)
        .firstOrNull ??
        routines.firstOrNull;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        activeSessionAsync.maybeWhen(
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
        ),
        if (scheduledRoutine != null)
          _buildScheduledRoutineSection(context, scheduledRoutine)
        else
          _buildEmptyRoutineState(context),
      ],
    );
  }

  Widget _buildScheduledRoutineSection(
    BuildContext context,
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
            onPressed: () => _startWorkout(context, routine),
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

  Widget _buildEmptyRoutineState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(LucideIcons.dumbbell, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No hay rutina programada para hoy', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Inicia un entrenamiento libre o crea una nueva plantilla en ajustes.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref
                .read(activeWorkoutControllerProvider.notifier)
                .startFreeWorkout(),
            child: const Text('Entrenamiento Libre'),
          ),
        ],
      ),
    );
  }

  void _startWorkout(BuildContext context, RoutineEntity routine) async {
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
