import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet_task_entity.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  /// Lista de tarefas (disponível em todos os estados exceto initial)
  List<PetTaskEntity> get tasks => const [];

  /// Mensagem de erro, se houver
  String? get error => null;

  /// Mensagem de sucesso, se houver
  String? get successMessage => null;

  /// Helpers de estado
  bool get isLoading => this is TaskLoadingState;
  bool get isSubmitting =>
      this is TaskLoadingState && (this as TaskLoadingState).submitting;
  bool get isError => this is TaskErrorState;
  bool get isSuccess => this is TaskSuccessState;
  bool get isEmpty => this is TaskEmptyState;

  /// Tarefas pendentes
  List<PetTaskEntity> get pendingTasks => tasks.where((t) => !t.done).toList();

  /// Tarefas concluídas
  List<PetTaskEntity> get completedTasks => tasks.where((t) => t.done).toList();

  /// Tarefas de vacina
  List<PetTaskEntity> get vaccineTasks =>
      tasks.where((t) => t.type == TaskType.vaccine).toList();
}

/// Estado inicial
final class TaskInitialState extends TaskState {
  const TaskInitialState();

  @override
  List<Object?> get props => [];
}

/// Estado de carregamento (dados ou submissão)
final class TaskLoadingState extends TaskState {
  @override
  final List<PetTaskEntity> tasks;
  final bool submitting;

  const TaskLoadingState({this.tasks = const [], this.submitting = false});

  @override
  List<Object?> get props => [tasks, submitting];
}

/// Estado de sucesso com lista de tarefas
final class TaskSuccessState extends TaskState {
  @override
  final List<PetTaskEntity> tasks;
  @override
  final String? successMessage;

  const TaskSuccessState(this.tasks, [this.successMessage]);

  @override
  List<Object?> get props => [tasks, successMessage];
}

/// Estado vazio - sem tarefas
final class TaskEmptyState extends TaskState {
  const TaskEmptyState();

  @override
  List<Object?> get props => [];
}

/// Estado de erro
final class TaskErrorState extends TaskState {
  @override
  final List<PetTaskEntity> tasks;
  @override
  final String error;

  const TaskErrorState(this.tasks, this.error);

  @override
  List<Object?> get props => [tasks, error];
}
