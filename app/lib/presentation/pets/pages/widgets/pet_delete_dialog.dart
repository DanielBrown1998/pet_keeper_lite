import 'package:flutter/material.dart';

import '../../../../core/theme/text_pet_keeper.dart';

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
    // final theme = Theme.of(context);
    return AlertDialog(
      title: const TextPetKeeper('Excluir Pet'),
      content: const TextPetKeeper(
        'Tem certeza que deseja excluir este pet? '
        'Todas as vacinas e tarefas também serão removidas.',
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const TextPetKeeper('Cancelar')),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const TextPetKeeper('Excluir'),
        ),
      ],
    );
  }
}
