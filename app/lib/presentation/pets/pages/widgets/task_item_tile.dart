import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/pet_task_entity.dart';
import 'task_type_chip.dart';

class TaskItemTile extends StatelessWidget {
  final PetTaskEntity task;
  final void Function(bool done) onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: task.done,
        onChanged: (value) => onToggleDone(value ?? false),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.done ? TextDecoration.lineThrough : null,
          color: task.done ? Colors.grey : null,
        ),
      ),
      subtitle: task.dueDate != null
          ? Text(
              DateFormat('dd/MM/yyyy').format(task.dueDate!),
              style: TextStyle(
                color: _isOverdue(task.dueDate!) && !task.done
                    ? Colors.red
                    : Colors.grey,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskTypeChip(type: task.type),
          _TaskPopupMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }
}

class _TaskPopupMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskPopupMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
