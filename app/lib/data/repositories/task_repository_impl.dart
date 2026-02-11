import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/pet_task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/pet_task_model.dart';
import '../sources/task_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskSource _taskSource;

  TaskRepositoryImpl({required TaskSource taskSource})
    : _taskSource = taskSource;

  @override
  Stream<List<PetTaskEntity>> watchTasks(String petId) {
    return _taskSource
        .watchTasks(petId)
        .map(
          (models) => models.map((model) => model as PetTaskEntity).toList(),
        );
  }

  @override
  Future<Either<Failure, PetTaskEntity>> getTask(String taskId) async {
    try {
      final task = await _taskSource.getTask(taskId);
      if (task == null) {
        return const Left(ServerFailure('Tarefa não encontrada'));
      }
      return Right(task);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetTaskEntity>> createTask(PetTaskEntity task) async {
    try {
      final taskModel = PetTaskModel.fromEntity(task);
      await _taskSource.createTask(taskModel);
      return Right(taskModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetTaskEntity>> updateTask(PetTaskEntity task) async {
    try {
      final taskModel = PetTaskModel.fromEntity(task);
      await _taskSource.updateTask(taskModel);
      return Right(taskModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _taskSource.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleTaskDone(String taskId, bool done) async {
    try {
      await _taskSource.toggleTaskDone(taskId, done);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
