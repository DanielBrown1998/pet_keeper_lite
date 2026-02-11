import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/pet_task_entity.dart';
import '../../repositories/task_repository.dart';

class CreateTask implements UseCase<PetTaskEntity, PetTaskEntity> {
  final TaskRepository _repository;

  CreateTask(this._repository);

  @override
  Future<Either<Failure, PetTaskEntity>> call(PetTaskEntity task) {
    return _repository.createTask(task);
  }
}
