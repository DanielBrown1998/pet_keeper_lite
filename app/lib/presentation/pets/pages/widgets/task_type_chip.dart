import 'package:flutter/material.dart';

import '../../../../domain/entities/pet_task_entity.dart';

class TaskTypeChip extends StatelessWidget {
  final TaskType type;

  const TaskTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = _getTypeData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
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
