import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/routine_list_controller.dart';

import 'routine_editor_screen.dart';

class WorkoutSettingsScreen extends ConsumerWidget {
  const WorkoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesStreamProvider);

    return Scaffold(
      appBar: AppHeader(
        title: 'Gestión de Rutinas',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Nueva Rutina',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoutineEditorScreen()),
            ),
          ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) => _buildRoutineList(context, ref, routines),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRoutineList(
    BuildContext context,
    WidgetRef ref,
    List<RoutineEntity> routines,
  ) {
    if (routines.isEmpty) {
      return Center(
        child: Text('No hay rutinas guardadas', style: AppTypography.bodyLarge),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(routine.name, style: AppTypography.titleMedium),
            subtitle: Text(
              routine.targetDay != null
                  ? 'Asignado: ${DateHelpers.getDayName(routine.targetDay!)} • ${routine.exercises.length} ejercicios'
                  : 'Plantilla huérfana • ${routine.exercises.length} ejercicios',
              style: AppTypography.bodyMedium,
            ),
            trailing: IconButton(
              icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
              onPressed: () => _confirmDelete(context, ref, routine),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, RoutineEntity routine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Rutina?'),
        content: Text('Se eliminará "${routine.name}" y todos sus ejercicios asignados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(routineListControllerProvider.notifier).deleteRoutine(routine.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
