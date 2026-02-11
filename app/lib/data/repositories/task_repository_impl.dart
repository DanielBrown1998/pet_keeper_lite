import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/pet_task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/pet_task_model.dart';
import '../sources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _taskRemoteDataSource;

  TaskRepositoryImpl({required TaskRemoteDataSource taskRemoteDataSource})
    : _taskRemoteDataSource = taskRemoteDataSource;

  @override
  Stream<List<PetTaskEntity>> watchTasks(String petId) {
    return _taskRemoteDataSource
        .watchTasks(petId)
        .map(
          (models) => models.map((model) => model as PetTaskEntity).toList(),
        );
  }

  @override
  Future<Either<Failure, PetTaskEntity>> getTask(String taskId) async {
    try {
      final task = await _taskRemoteDataSource.getTask(taskId);
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
      await _taskRemoteDataSource.createTask(taskModel);
      return Right(taskModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetTaskEntity>> updateTask(PetTaskEntity task) async {
    try {
      final taskModel = PetTaskModel.fromEntity(task);
      await _taskRemoteDataSource.updateTask(taskModel);
      return Right(taskModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _taskRemoteDataSource.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleTaskDone(String taskId, bool done) async {
    try {
      await _taskRemoteDataSource.toggleTaskDone(taskId, done);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
