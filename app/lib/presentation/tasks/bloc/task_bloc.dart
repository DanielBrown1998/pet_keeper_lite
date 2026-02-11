import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/pet_task_entity.dart';
import '../../../domain/usecases/task/create_task.dart';
import '../../../domain/usecases/task/delete_task.dart';
import '../../../domain/usecases/task/toggle_task_done.dart';
import '../../../domain/usecases/task/update_task.dart';
import '../../../domain/usecases/task/watch_tasks.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final WatchTasks _watchTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final ToggleTaskDone _toggleTaskDone;

  TaskBloc({
    required WatchTasks watchTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required ToggleTaskDone toggleTaskDone,
  }) : _watchTasks = watchTasks,
       _createTask = createTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _toggleTaskDone = toggleTaskDone,
       super(const TaskInitialState()) {
    on<TaskWatchRequested>(_onWatchTasks, transformer: restartable());
    on<TaskCreateRequested>(_onCreateTask);
    on<TaskUpdateRequested>(_onUpdateTask);
    on<TaskDeleteRequested>(_onDeleteTask);
    on<TaskToggleDoneRequested>(_onToggleDone);
  }

  Future<void> _onWatchTasks(
    TaskWatchRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoadingState(tasks: state.tasks));

    await emit.forEach<List<PetTaskEntity>>(
      _watchTasks(event.petId),
      onData: (tasks) =>
          tasks.isEmpty ? const TaskEmptyState() : TaskSuccessState(tasks),
      onError: (error, stackTrace) =>
          TaskErrorState(state.tasks, error.toString()),
    );
  }

  

  Future<void> _onCreateTask(
    TaskCreateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoadingState(tasks: state.tasks, submitting: true));

    final result = await _createTask(event.task);

    result.fold(
      (failure) {
        emit(TaskErrorState(state.tasks, failure.message));
      },
      (_) {
        emit(TaskSuccessState(state.tasks, 'Tarefa criada com sucesso!'));
      },
    );
  }

  Future<void> _onUpdateTask(
    TaskUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoadingState(tasks: state.tasks, submitting: true));

    final result = await _updateTask(event.task);

    result.fold(
      (failure) {
        emit(TaskErrorState(state.tasks, failure.message));
      },
      (_) {
        emit(TaskSuccessState(state.tasks, 'Tarefa atualizada com sucesso!'));
      },
    );
  }

  Future<void> _onDeleteTask(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoadingState(tasks: state.tasks, submitting: true));

    final result = await _deleteTask(event.taskId);

    result.fold(
      (failure) {
        emit(TaskErrorState(state.tasks, failure.message));
      },
      (_) {
        emit(TaskSuccessState(state.tasks, 'Tarefa removida com sucesso!'));
      },
    );
  }

  Future<void> _onToggleDone(
    TaskToggleDoneRequested event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _toggleTaskDone(
      ToggleTaskDoneParams(taskId: event.taskId, done: event.done),
    );

    result.fold(
      (failure) {
        emit(TaskErrorState(state.tasks, failure.message));
      },
      (_) {
        // Status updated via stream
      },
    );
  }
}
