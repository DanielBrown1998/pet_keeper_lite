import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/pet_entity.dart';
import 'pet_delete_dialog.dart';
import 'pet_notify_dialog.dart';

class PetDetailAppBar extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;
  final void Function(String petId, String message) onNotifyFamily;

  const PetDetailAppBar({
    super.key,
    required this.pet,
    required this.onEdit,
    required this.onDeleted,
    required this.onNotifyFamily,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pet.name,
          style: const TextStyle(
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [_buildBackground(), _buildGradientOverlay()],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteDialog(context),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'notify') {
              _showNotifyDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'notify',
              child: Row(
                children: [
                  Icon(Icons.notifications_active),
                  SizedBox(width: 8),
                  Text('Avisar Família'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground() {
    if (pet.photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: pet.photoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.pets, size: 80),
        ),
      );
    }
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.pets, size: 80, color: Colors.grey),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PetDeleteDialog(
        onConfirm: () {
          Navigator.pop(dialogContext);
          onDeleted();
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  void _showNotifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PetNotifyDialog(
        petName: pet.name,
        onSend: (message) {
          Navigator.pop(dialogContext);
          onNotifyFamily(pet.id, '${pet.name}: $message');
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }
}
