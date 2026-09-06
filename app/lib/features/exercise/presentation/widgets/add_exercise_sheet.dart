import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/number_counter.dart';
import '../../domain/entities/exercise_entity.dart';

class AddExerciseSheet extends StatefulWidget {
  final ExerciseEntity? initialExercise;
  final ValueChanged<ExerciseEntity> onExerciseAdded;

  const AddExerciseSheet({
    super.key,
    this.initialExercise,
    required this.onExerciseAdded,
  });

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController(text: '0');
  String _selectedMuscle = 'Pectoral';
  int _targetSets = 3;
  int _targetReps = 10;
  int _restSeconds = 90;

  static const _muscleGroups = [
    'Pectoral', 'Espalda', 'Piernas', 'Hombros', 'Brazos', 'Core', 'Cuerpo Completo',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialExercise != null) {
      final ex = widget.initialExercise!;
      _nameController.text = ex.name;
      _weightController.text =
          ex.targetWeight % 1 == 0 ? ex.targetWeight.toInt().toString() : ex.targetWeight.toString();
      _selectedMuscle = _muscleGroups.contains(ex.muscleGroup) ? ex.muscleGroup : _muscleGroups.first;
      _targetSets = ex.targetSets;
      _targetReps = ex.targetReps;
      _restSeconds = ex.restSeconds;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExercise != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isEditing),
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 12),
            _buildMuscleDropdown(),
            const SizedBox(height: 16),
            _buildSetsAndRepsRow(),
            const SizedBox(height: 16),
            _buildWeightAndRestRow(),
            const SizedBox(height: 24),
            _buildSubmitButton(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(isEditing ? 'Editar Ejercicio' : 'Agregar Ejercicio', style: AppTypography.titleLarge),
        IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      autofocus: widget.initialExercise == null,
      decoration: const InputDecoration(
        labelText: 'Nombre del ejercicio',
        hintText: 'Ej. Press de Banca Plano',
      ),
    );
  }

  Widget _buildMuscleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMuscle,
      decoration: const InputDecoration(labelText: 'Grupo muscular'),
      items: _muscleGroups.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedMuscle = val);
      },
    );
  }

  Widget _buildSetsAndRepsRow() {
    return Row(
      children: [
        Expanded(
          child: NumberCounter(
            label: 'Series',
            value: _targetSets,
            onDecrement: () => setState(() => _targetSets = (_targetSets > 1) ? _targetSets - 1 : 1),
            onIncrement: () => setState(() => _targetSets++),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NumberCounter(
            label: 'Reps',
            value: _targetReps,
            onDecrement: () => setState(() => _targetReps = (_targetReps > 1) ? _targetReps - 1 : 1),
            onIncrement: () => setState(() => _targetReps++),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightAndRestRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Peso (kg)', suffixText: 'kg'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _restSeconds,
            decoration: const InputDecoration(labelText: 'Descanso'),
            items: const [45, 60, 90, 120, 180]
                .map((s) => DropdownMenuItem(value: s, child: Text('${s}s')))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _restSeconds = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return ElevatedButton(
      onPressed: _handleSubmit,
      child: Text(isEditing ? 'Guardar Cambios' : 'Agregar a la Rutina'),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final now = DateTime.now();

    widget.onExerciseAdded(ExerciseEntity(
      id: widget.initialExercise?.id ?? const Uuid().v4(),
      routineId: widget.initialExercise?.routineId ?? '',
      name: name,
      muscleGroup: _selectedMuscle,
      targetSets: _targetSets,
      targetReps: _targetReps,
      targetWeight: weight,
      restSeconds: _restSeconds,
      orderIndex: widget.initialExercise?.orderIndex ?? 0,
      createdAt: widget.initialExercise?.createdAt ?? now,
      updatedAt: now,
    ));
    Navigator.pop(context);
  }
}
