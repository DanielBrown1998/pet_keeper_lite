import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/pet_task_entity.dart';
import '../../repositories/task_repository.dart';

class GetTask implements UseCase<PetTaskEntity, String> {
  final TaskRepository _repository;

  GetTask(this._repository);

  @override
  Future<Either<Failure, PetTaskEntity>> call(String taskId) {
    return _repository.getTask(taskId);
  }
}
