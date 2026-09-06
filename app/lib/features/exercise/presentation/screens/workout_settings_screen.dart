import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/routine_list_controller.dart';
import '../widgets/routine_management_card.dart';
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
      return EmptyState(
        icon: LucideIcons.calendar,
        title: 'No hay rutinas creadas',
        description:
            'Crea plantillas personalizadas para estructurar tus entrenamientos semanales.',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutineEditorScreen()),
          ),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Crear Primera Rutina'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return RoutineManagementCard(
          routine: routine,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoutineEditorScreen(initialRoutine: routine),
            ),
          ),
          onDelete: () => _confirmDelete(context, ref, routine),
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
