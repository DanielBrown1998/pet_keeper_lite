import 'package:flutter/material.dart';

import '../../../../core/theme/text_pet_keeper.dart';

class NotifyFamilyDialog extends StatefulWidget {
  final String petName;
  final void Function(String message) onSend;
  final VoidCallback onCancel;

  const NotifyFamilyDialog({
    super.key,
    required this.petName,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<NotifyFamilyDialog> createState() => _NotifyFamilyDialogState();
}

class _NotifyFamilyDialogState extends State<NotifyFamilyDialog> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return AlertDialog(
      title: const TextPetKeeper('Avisar Família'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextPetKeeper(
            'Envie uma notificação para todos os membros da família.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Mensagem',
              hintText: 'Ex: Nova vacina agendada!',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const TextPetKeeper('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_messageController.text.isNotEmpty) {
              widget.onSend(_messageController.text);
            }
          },
          child: const TextPetKeeper('Enviar'),
        ),
      ],
    );
  }
}
