import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/family_entity.dart';

abstract class FamilyRepository {
  Future<Either<Failure, FamilyEntity>> createFamily(String familyCode);
  Future<Either<Failure, FamilyEntity?>> getFamily(String familyCode);
  Future<Either<Failure, bool>> familyExists(String familyCode);
  Future<Either<Failure, void>> joinFamily(String familyCode);
}
