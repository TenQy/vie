import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/routine_list_controller.dart';

class WorkoutSettingsScreen extends ConsumerWidget {
  const WorkoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Rutinas'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Nueva Rutina',
            onPressed: () => _showCreateRoutineDialog(context, ref),
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

  void _showCreateRoutineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int? selectedDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nueva Rutina', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre de rutina'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: selectedDay,
                decoration: const InputDecoration(labelText: 'Día programado'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Plantilla Huérfana')),
                  for (int i = 1; i <= 7; i++)
                    DropdownMenuItem(value: i, child: Text(DateHelpers.getDayName(i))),
                ],
                onChanged: (val) => setState(() => selectedDay = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  ref.read(routineListControllerProvider.notifier).createRoutine(
                        name: nameController.text.trim(),
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                        targetDay: selectedDay,
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('Crear Rutina'),
              ),
            ],
          ),
        ),
      ),
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
