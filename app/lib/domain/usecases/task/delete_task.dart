import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/task_repository.dart';

class DeleteTask implements UseCase<void, String> {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  @override
  Future<Either<Failure, void>> call(String taskId) {
    return _repository.deleteTask(taskId);
  }
}
