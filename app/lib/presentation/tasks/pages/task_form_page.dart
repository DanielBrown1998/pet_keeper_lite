import 'package:flutter/material.dart';

import 'task_form_create_page.dart';
import 'task_form_edit_page.dart';

class TaskFormPage extends StatelessWidget {
  final String petId;
  final String? taskId;

  const TaskFormPage({super.key, required this.petId, this.taskId});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    if (taskId == null) {
      return TaskFormCreatePage(petId: petId);
    }
    return TaskFormEditPage(petId: petId, taskId: taskId!);
  }
}
