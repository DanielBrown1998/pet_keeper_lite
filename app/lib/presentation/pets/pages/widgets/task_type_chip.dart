import 'package:flutter/material.dart';

import '../../../../core/theme/text_pet_keeper.dart';

import '../../../../domain/entities/pet_task_entity.dart';

class TaskTypeChip extends StatelessWidget {
  final TaskType type;

  const TaskTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final (color, label, icon) = _getTypeData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(127)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          TextPetKeeper(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  (Color, String, IconData) _getTypeData() {
    return switch (type) {
      TaskType.vaccine => (Colors.blue, 'Vacina', Icons.vaccines),
      TaskType.grooming => (Colors.purple, 'Banho', Icons.bathtub),
      TaskType.other => (Colors.orange, 'Outro', Icons.task),
    };
  }
}
