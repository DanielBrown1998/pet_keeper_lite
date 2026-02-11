import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/pet_task_entity.dart';

abstract class TaskRepository {
  Stream<List<PetTaskEntity>> watchTasks(String petId);
  Future<Either<Failure, PetTaskEntity>> getTask(String taskId);
  Future<Either<Failure, PetTaskEntity>> createTask(PetTaskEntity task);
  Future<Either<Failure, PetTaskEntity>> updateTask(PetTaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> toggleTaskDone(String taskId, bool done);
}
