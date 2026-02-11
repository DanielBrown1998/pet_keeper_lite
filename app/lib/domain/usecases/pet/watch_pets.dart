import '../../../core/usecases/usecase.dart';
import '../../entities/pet_entity.dart';
import '../../repositories/pet_repository.dart';

class WatchPets implements StreamUseCase<List<PetEntity>, String> {
  final PetRepository _repository;

  WatchPets(this._repository);

  @override
  Stream<List<PetEntity>> call(String familyCode) {
    return _repository.watchPets(familyCode);
  }
}
