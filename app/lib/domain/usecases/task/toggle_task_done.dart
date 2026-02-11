import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/task_repository.dart';

class ToggleTaskDoneParams {
  final String taskId;
  final bool done;

  const ToggleTaskDoneParams({required this.taskId, required this.done});
}

class ToggleTaskDone implements UseCase<void, ToggleTaskDoneParams> {
  final TaskRepository _repository;

  ToggleTaskDone(this._repository);

  @override
  Future<Either<Failure, void>> call(ToggleTaskDoneParams params) {
    return _repository.toggleTaskDone(params.taskId, params.done);
  }
}
