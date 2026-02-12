import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/text_pet_keeper.dart';

import '../../notification/bloc/notification_bloc.dart';
import '../../notification/bloc/notification_event.dart';
import '../../notification/bloc/notification_state.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../bloc/pet_bloc.dart';
import '../bloc/pet_event.dart';
import '../bloc/pet_state.dart';
import 'widgets/widgets.dart';

class PetDetailPage extends StatelessWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return _PetDetailView(petId: petId);
  }
}

class _PetDetailView extends StatelessWidget {
  final String petId;

  const _PetDetailView({required this.petId});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return BlocBuilder<PetBloc, PetState>(
      builder: (context, petState) {
        final pet = petState.pets.where((p) => p.id == petId).firstOrNull;

        if (pet == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: TextPetKeeper('Pet não encontrado')),
          );
        }

        return BlocListener<NotificationBloc, NotificationState>(
          listenWhen: (previous, current) =>
              current is NotificationSuccessState ||
              current is NotificationErrorState,
          listener: (context, state) {
            if (state is NotificationSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: TextPetKeeper(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<NotificationBloc>().add(const NotificationReset());
            } else if (state is NotificationErrorState) {
              debugPrint('Notification error: ${state.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: TextPetKeeper("Envio da Notificacao falhou!"),
                  backgroundColor: Colors.red,
                ),
              );
              context.read<NotificationBloc>().add(const NotificationReset());
            }
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                PetDetailAppBar(
                  pet: pet,
                  onEdit: () => context.go('/pets/$petId/edit'),
                  onDeleted: () {
                    context.read<PetBloc>().add(PetDeleteRequested(petId));
                    context.go('/pets');
                  },
                  onNotifyFamily: (id, message) {
                    context.read<NotificationBloc>().add(
                      SendFamilyNotification(petId: id, message: message),
                    );
                  },
                ),
                SliverToBoxAdapter(child: PetInfoCard(pet: pet)),
                SliverToBoxAdapter(
                  child: TasksSection(
                    petId: petId,
                    onEditTask: (taskId) =>
                        context.go('/pets/$petId/tasks/$taskId/edit'),
                    onDeleteTask: (taskId) => context.read<TaskBloc>().add(
                      TaskDeleteRequested(taskId),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.go('/pets/$petId/tasks/add'),
              icon: const Icon(Icons.add),
              label: const TextPetKeeper('Adicionar Tarefa'),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
