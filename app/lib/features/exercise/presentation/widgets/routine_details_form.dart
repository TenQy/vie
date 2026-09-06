import 'package:flutter/material.dart';
import '../../../../core/utils/date_helpers.dart';

class RoutineDetailsForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final int? selectedDay;
  final ValueChanged<int?> onDayChanged;

  const RoutineDetailsForm({
    super.key,
    required this.nameController,
    required this.descController,
    required this.selectedDay,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la rutina',
                hintText: 'Ej. Pierna & Glúteos',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej. Enfoque en cuádriceps y gemelos',
              ),
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
              onChanged: onDayChanged,
            ),
          ],
        ),
      ),
    );
  }
}
