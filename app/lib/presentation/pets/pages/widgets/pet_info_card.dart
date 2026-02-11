import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/pet_entity.dart';
import '../../../../core/helpers/pet_species.dart';

class PetInfoCard extends StatelessWidget {
  final PetEntity pet;

  const PetInfoCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.category,
              label: 'Espécie',
              value: PetSpecies.fromValue(pet.species).displayNameWithEmoji,
            ),
            if (pet.birthDate != null)
              _InfoRow(
                icon: Icons.cake,
                label: 'Data de Nascimento',
                value: DateFormat('dd/MM/yyyy').format(pet.birthDate!),
              ),
            if (pet.birthDate != null)
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Idade',
                value: _calculateAge(pet.birthDate!),
              ),
            if (pet.weightKg != null)
              _InfoRow(
                icon: Icons.monitor_weight,
                label: 'Peso',
                value: '${pet.weightKg!.toStringAsFixed(1)} kg',
              ),
          ],
        ),
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years ano${years > 1 ? 's' : ''} e $months mês${months > 1 ? 'es' : ''}';
    } else {
      return '$months mês${months > 1 ? 'es' : ''}';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
