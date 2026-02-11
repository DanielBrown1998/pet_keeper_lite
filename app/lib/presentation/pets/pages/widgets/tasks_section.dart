import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/pet_task_entity.dart';
import '../../../tasks/bloc/task_bloc.dart';
import '../../../tasks/bloc/task_event.dart';
import '../../../tasks/bloc/task_state.dart';
import 'task_item_tile.dart';

class TasksSection extends StatefulWidget {
  final String petId;
  final void Function(String taskId) onEditTask;
  final void Function(String taskId) onDeleteTask;

  const TasksSection({
    super.key,
    required this.petId,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  State<TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends State<TasksSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(TaskWatchRequested(widget.petId));
    });
  }

  @override
  void didUpdateWidget(covariant TasksSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.petId != widget.petId) {
      context.read<TaskBloc>().add(TaskWatchRequested(widget.petId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      buildWhen: (previous, current) =>
          previous.tasks != current.tasks ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TasksHeader(isLoading: state.isLoading),
                const Divider(),
                if (state.tasks.isEmpty)
                  const _EmptyTasksMessage()
                else
                  _TasksList(
                    tasks: state.tasks,
                    onEditTask: widget.onEditTask,
                    onDeleteTask: widget.onDeleteTask,
                  ),
                const SizedBox(height: 60), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final bool isLoading;

  const _TasksHeader({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Vacinas & Tarefas',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

class _EmptyTasksMessage extends StatelessWidget {
  const _EmptyTasksMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Nenhuma tarefa cadastrada',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  final List<PetTaskEntity> tasks;
  final void Function(String taskId) onEditTask;
  final void Function(String taskId) onDeleteTask;

  const _TasksList({
    required this.tasks,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItemTile(
          task: task,
          onToggleDone: (done) {
            context.read<TaskBloc>().add(
              TaskToggleDoneRequested(taskId: task.id, done: done),
            );
          },
          onEdit: () => onEditTask(task.id),
          onDelete: () => onDeleteTask(task.id),
        );
      },
    );
  }
}
