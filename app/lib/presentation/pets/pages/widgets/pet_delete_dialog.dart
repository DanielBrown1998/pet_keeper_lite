import 'package:flutter/material.dart';

class PetDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PetDeleteDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir Pet'),
      content: const Text(
        'Tem certeza que deseja excluir este pet? '
        'Todas as vacinas e tarefas também serão removidas.',
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
