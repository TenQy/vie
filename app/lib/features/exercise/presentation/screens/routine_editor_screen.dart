import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/routine_list_controller.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/exercise_card.dart';

class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key});

  @override
  ConsumerState<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedDay;
  final List<ExerciseEntity> _exercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Nueva Rutina'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRoutineDetailsCard(),
          const SizedBox(height: 24),
          _buildExercisesSectionHeader(),
          const SizedBox(height: 12),
          _buildExercisesContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildRoutineDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la rutina',
                hintText: 'Ej. Pierna & Glúteos',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej. Enfoque en cuádriceps y gemelos',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _selectedDay,
              decoration: const InputDecoration(labelText: 'Día programado'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Plantilla Huérfana')),
                for (int i = 1; i <= 7; i++)
                  DropdownMenuItem(value: i, child: Text(DateHelpers.getDayName(i))),
              ],
              onChanged: (val) => setState(() => _selectedDay = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ejercicios (${_exercises.length})',
          style: AppTypography.titleMedium,
        ),
        TextButton.icon(
          onPressed: _openAddExerciseSheet,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Agregar Ejercicio'),
        ),
      ],
    );
  }

  Widget _buildExercisesContent() {
    if (_exercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.dumbbell, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Aún no has agregado ejercicios',
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Presiona "+ Agregar Ejercicio" para armar tu rutina.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < _exercises.length; i++)
          ExerciseCard(
            exercise: _exercises[i],
            trailing: IconButton(
              icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
              onPressed: () => setState(() => _exercises.removeAt(i)),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final canSave = _nameController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: canSave ? _saveRoutine : null,
          child: const Text('Guardar Rutina'),
        ),
      ),
    );
  }

  void _openAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddExerciseSheet(
        onExerciseAdded: (ex) => setState(() => _exercises.add(ex)),
      ),
    );
  }

  void _saveRoutine() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final routine = RoutineEntity(
      id: const Uuid().v4(),
      name: name,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      targetDay: _selectedDay,
      createdAt: now,
      updatedAt: now,
    );

    await ref
        .read(routineListControllerProvider.notifier)
        .saveRoutineWithExercises(
          routine: routine,
          exercises: _exercises,
        );

    if (mounted) Navigator.pop(context);
  }
}
