import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/exercise_entity.dart';

class AddExerciseSheet extends StatefulWidget {
  final ValueChanged<ExerciseEntity> onExerciseAdded;

  const AddExerciseSheet({super.key, required this.onExerciseAdded});

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
    'Pectoral',
    'Espalda',
    'Piernas',
    'Hombros',
    'Brazos',
    'Core',
    'Cuerpo Completo',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 12),
            _buildMuscleDropdown(),
            const SizedBox(height: 16),
            _buildSetsAndRepsRow(),
            const SizedBox(height: 16),
            _buildWeightAndRestRow(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Agregar Ejercicio', style: AppTypography.titleLarge),
        IconButton(
          icon: const Icon(LucideIcons.x, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      autofocus: true,
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
      items: _muscleGroups
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedMuscle = val);
      },
    );
  }

  Widget _buildSetsAndRepsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildNumberCounter(
            label: 'Series',
            value: _targetSets,
            onDecrement: () => setState(() => _targetSets = (_targetSets > 1) ? _targetSets - 1 : 1),
            onIncrement: () => setState(() => _targetSets++),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberCounter(
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
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              suffixText: 'kg',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _restSeconds,
            decoration: const InputDecoration(labelText: 'Descanso'),
            items: const [
              DropdownMenuItem(value: 45, child: Text('45s')),
              DropdownMenuItem(value: 60, child: Text('60s')),
              DropdownMenuItem(value: 90, child: Text('90s')),
              DropdownMenuItem(value: 120, child: Text('120s')),
              DropdownMenuItem(value: 180, child: Text('180s')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _restSeconds = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberCounter({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.minus, size: 16),
                onPressed: onDecrement,
              ),
              Text('$value', style: AppTypography.titleMedium),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _handleSubmit,
      child: const Text('Agregar a la Rutina'),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final now = DateTime.now();

    final exercise = ExerciseEntity(
      id: const Uuid().v4(),
      routineId: '', // Assigned upon routine creation
      name: name,
      muscleGroup: _selectedMuscle,
      targetSets: _targetSets,
      targetReps: _targetReps,
      targetWeight: weight,
      restSeconds: _restSeconds,
      createdAt: now,
      updatedAt: now,
    );

    widget.onExerciseAdded(exercise);
    Navigator.pop(context);
  }
}
