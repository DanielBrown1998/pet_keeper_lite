import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet_task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskWatchRequested extends TaskEvent {
  final String petId;

  const TaskWatchRequested(this.petId);

  @override
  List<Object?> get props => [petId];
}

class TaskCreateRequested extends TaskEvent {
  final PetTaskEntity task;

  const TaskCreateRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdateRequested extends TaskEvent {
  final PetTaskEntity task;

  const TaskUpdateRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleteRequested extends TaskEvent {
  final String taskId;

  const TaskDeleteRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskToggleDoneRequested extends TaskEvent {
  final String taskId;
  final bool done;

  const TaskToggleDoneRequested({required this.taskId, required this.done});

  @override
  List<Object?> get props => [taskId, done];
}
