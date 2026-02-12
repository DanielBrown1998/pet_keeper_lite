import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/text_pet_keeper.dart';

import '../../../core/helpers/pet_species.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/pet_bloc.dart';
import '../bloc/pet_event.dart';
import '../bloc/pet_state.dart';

class PetsListPage extends StatefulWidget {
  const PetsListPage({super.key});

  @override
  State<PetsListPage> createState() => _PetsListPageState();
}

class _PetsListPageState extends State<PetsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user?.familyCode != null) {
        context.read<PetBloc>().add(
          PetWatchRequested(authState.user!.familyCode!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.isAuthenticated) {
          context.go('/login');
        }
        if (state.user?.familyCode != null) {
          context.read<PetBloc>().add(
            PetWatchRequested(state.user?.familyCode ?? ''),
          );
        }
      },

      builder: (context, state) {
        return const _PetsListView();
      },
    );
  }
}

class _PetsListView extends StatelessWidget {
  const _PetsListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TextPetKeeper('Meus Pets'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final familyCode = state.user?.familyCode ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Tooltip(
                  message: 'Toque para copiar',
                  child: ActionChip(
                    avatar: const Icon(Icons.family_restroom, size: 16),
                    label: TextPetKeeper(
                      familyCode,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: familyCode.isNotEmpty
                        ? () async {
                            await FlutterClipboard.copy(familyCode);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: TextPetKeeper(
                                  'Código da família "$familyCode" copiado!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<PetBloc, PetState>(
        listenWhen: (previous, current) =>
            previous.error != current.error ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextPetKeeper(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextPetKeeper(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.pets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  TextPetKeeper(
                    'Nenhum pet cadastrado',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const TextPetKeeper(
                    'Toque no + para adicionar seu primeiro pet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState.user?.familyCode != null) {
                context.read<PetBloc>().add(
                  PetWatchRequested(authState.user!.familyCode!),
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.pets.length,
              itemBuilder: (context, index) {
                final pet = state.pets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.go('/pets/${pet.id}'),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: pet.photoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: pet.photoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.pets, size: 40),
                                      ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    PetSpecies.fromValue(pet.species).icon,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextPetKeeper(
                                  pet.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      PetSpecies.fromValue(pet.species).icon,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    TextPetKeeper(
                                      PetSpecies.fromValue(
                                        pet.species,
                                      ).displayName,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                if (pet.weightKg != null) ...[
                                  const SizedBox(height: 4),
                                  TextPetKeeper(
                                    '${pet.weightKg!.toStringAsFixed(1)} kg',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/pets/add'),
        icon: const Icon(Icons.add),
        label: const TextPetKeeper('Adicionar Pet'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
