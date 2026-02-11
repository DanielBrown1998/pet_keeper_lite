import '../../../core/usecases/usecase.dart';
import '../../entities/pet_task_entity.dart';
import '../../repositories/task_repository.dart';

class WatchTasks implements StreamUseCase<List<PetTaskEntity>, String> {
  final TaskRepository _repository;

  WatchTasks(this._repository);

  @override
  Stream<List<PetTaskEntity>> call(String petId) {
    return _repository.watchTasks(petId);
  }
}
