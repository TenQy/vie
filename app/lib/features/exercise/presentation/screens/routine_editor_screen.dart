import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/routine_entity.dart';
import '../controllers/routine_list_controller.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_list_empty_card.dart';
import '../widgets/routine_details_form.dart';

class RoutineEditorScreen extends ConsumerStatefulWidget {
  final RoutineEntity? initialRoutine;

  const RoutineEditorScreen({super.key, this.initialRoutine});

  @override
  ConsumerState<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedDay;
  final List<ExerciseEntity> _exercises = [];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
    if (widget.initialRoutine != null) {
      final routine = widget.initialRoutine!;
      _nameController.text = routine.name;
      _descController.text = routine.description ?? '';
      _selectedDay = routine.targetDay;
      _exercises.addAll(routine.exercises);
    }
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRoutine != null;

    return Scaffold(
      appBar: AppHeader(title: isEditing ? 'Editar Rutina' : 'Nueva Rutina'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoutineDetailsForm(
            nameController: _nameController,
            descController: _descController,
            selectedDay: _selectedDay,
            onDayChanged: (val) => setState(() => _selectedDay = val),
          ),
          const SizedBox(height: 24),
          _buildExercisesSectionHeader(),
          const SizedBox(height: 12),
          _buildExercisesContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isEditing),
    );
  }

  Widget _buildExercisesSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Ejercicios (${_exercises.length})', style: AppTypography.titleMedium),
        TextButton.icon(
          onPressed: () => _openExerciseSheet(),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Agregar Ejercicio'),
        ),
      ],
    );
  }

  Widget _buildExercisesContent() {
    if (_exercises.isEmpty) {
      return const ExerciseListEmptyCard();
    }

    return Column(
      children: [
        for (int i = 0; i < _exercises.length; i++)
          ExerciseCard(
            exercise: _exercises[i],
            onTap: () => _openExerciseSheet(index: i),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  tooltip: 'Editar ejercicio',
                  onPressed: () => _openExerciseSheet(index: i),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
                  tooltip: 'Eliminar ejercicio',
                  onPressed: () => setState(() => _exercises.removeAt(i)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(bool isEditing) {
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
          child: Text(isEditing ? 'Guardar Cambios' : 'Guardar Rutina'),
        ),
      ),
    );
  }

  void _openExerciseSheet({int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddExerciseSheet(
        initialExercise: index != null ? _exercises[index] : null,
        onExerciseAdded: (ex) {
          setState(() {
            if (index != null) {
              _exercises[index] = ex;
            } else {
              _exercises.add(ex);
            }
          });
        },
      ),
    );
  }

  void _saveRoutine() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final routine = RoutineEntity(
      id: widget.initialRoutine?.id ?? const Uuid().v4(),
      name: name,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      targetDay: _selectedDay,
      isActive: widget.initialRoutine?.isActive ?? true,
      orderIndex: widget.initialRoutine?.orderIndex ?? 0,
      createdAt: widget.initialRoutine?.createdAt ?? now,
      updatedAt: now,
    );

    await ref
        .read(routineListControllerProvider.notifier)
        .saveRoutineWithExercises(routine: routine, exercises: _exercises);

    if (!mounted) return;
    final state = ref.read(routineListControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la rutina: ${state.error}')),
      );
      return;
    }

    Navigator.pop(context);
  }
}
