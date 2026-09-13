import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/number_counter.dart';
import '../../domain/entities/set_record_entity.dart';

class CurrentExerciseCard extends StatefulWidget {
  final SetRecordEntity currentSet;
  final int totalSetsForExercise;
  final Function(int reps, double weight) onCompleteSet;
  final VoidCallback onSkipSet;

  const CurrentExerciseCard({
    super.key,
    required this.currentSet,
    required this.totalSetsForExercise,
    required this.onCompleteSet,
    required this.onSkipSet,
  });

  @override
  State<CurrentExerciseCard> createState() => _CurrentExerciseCardState();
}

class _CurrentExerciseCardState extends State<CurrentExerciseCard> {
  late int _reps;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  @override
  void didUpdateWidget(covariant CurrentExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSet.id != widget.currentSet.id) {
      _initValues();
    }
  }

  void _initValues() {
    _reps = widget.currentSet.completedReps > 0
        ? widget.currentSet.completedReps
        : widget.currentSet.targetReps;
    _weight = widget.currentSet.completedWeight > 0
        ? widget.currentSet.completedWeight
        : widget.currentSet.targetWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBadgesRow(),
            const SizedBox(height: 12),
            Text(
              widget.currentSet.exerciseName,
              style: AppTypography.displayMedium.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Objetivo: ${widget.currentSet.targetReps} reps • ${widget.currentSet.targetWeight} kg • ${widget.currentSet.restTimeSeconds}s descanso',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildInputsRow(),
            const SizedBox(height: 18),
            _buildCompleteButton(),
            const SizedBox(height: 6),
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    final isCompleted = widget.currentSet.isCompleted;

    return Row(
      children: [
        _buildBadge(widget.currentSet.muscleGroup, AppColors.primary),
        const SizedBox(width: 8),
        _buildBadge(
          'SERIE ${widget.currentSet.setNumber} DE ${widget.totalSetsForExercise}',
          AppColors.secondary,
        ),
        const Spacer(),
        if (isCompleted)
          _buildBadge('COMPLETADA', AppColors.success)
        else
          _buildBadge('EN CURSO', AppColors.primary),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInputsRow() {
    return Row(
      children: [
        Expanded(
          child: NumberCounter(
            label: 'Reps',
            value: _reps,
            onDecrement: () =>
                setState(() => _reps = (_reps > 1) ? _reps - 1 : 1),
            onIncrement: () => setState(() => _reps++),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildWeightCounter()),
      ],
    );
  }

  Widget _buildWeightCounter() {
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
          Text('Peso', style: AppTypography.bodyMedium),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.minus, size: 16),
                onPressed: () => setState(() {
                  _weight = (_weight >= 2.5) ? _weight - 2.5 : 0.0;
                }),
              ),
              Text(
                _weight % 1 == 0 ? '${_weight.toInt()}k' : '${_weight}k',
                style: AppTypography.titleMedium,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: () => setState(() => _weight += 2.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    final isCompleted = widget.currentSet.isCompleted;

    return ElevatedButton.icon(
      onPressed: () => widget.onCompleteSet(_reps, _weight),
      icon: Icon(
        isCompleted ? LucideIcons.checkCheck : LucideIcons.check,
        size: 20,
      ),
      label: Text(isCompleted ? 'Actualizar Serie' : 'Completar Serie'),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton.icon(
        onPressed: widget.onSkipSet,
        icon: const Icon(LucideIcons.skipForward, size: 16),
        label: const Text('Saltar Serie'),
      ),
    );
  }
}
