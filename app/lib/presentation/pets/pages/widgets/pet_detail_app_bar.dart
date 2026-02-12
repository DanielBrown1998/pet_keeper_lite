import 'package:app/presentation/notification/bloc/notification_bloc.dart';
import 'package:app/presentation/notification/bloc/notification_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/text_pet_keeper.dart';

import '../../../../domain/entities/pet_entity.dart';
import 'notify_family_dialog.dart';
import 'pet_delete_dialog.dart';

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
    final theme = Theme.of(context);
    // final screenWidth = MediaQuery.of(context).size.width;
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(229),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextPetKeeper(
                  pet.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () => _showNotifyDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextPetKeeper(
                          (state is NotificationSendingState)
                              ? 'Enviando...'
                              : 'Notificar família',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 2),
                        (state is NotificationSendingState)
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.notifications_active,
                                size: 14,
                                color: Colors.white,
                              ),
                      ],
                    ),
                  );
                },
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
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(229),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: onEdit,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(229),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
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
          colors: [Colors.transparent, Colors.black.withAlpha(178)],
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
      builder: (dialogContext) => NotifyFamilyDialog(
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
