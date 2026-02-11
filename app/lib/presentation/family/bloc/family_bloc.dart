import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/family/check_family_exists.dart';
import '../../../domain/usecases/family/create_family.dart';
import '../../../domain/usecases/family/get_family.dart';
import '../../../domain/usecases/family/join_family.dart';
import 'family_event.dart';
import 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final CreateFamily _createFamily;
  final JoinFamily _joinFamily;
  final CheckFamilyExists _checkFamilyExists;
  final GetFamily _getFamily;

  FamilyBloc({
    required CreateFamily createFamily,
    required JoinFamily joinFamily,
    required CheckFamilyExists checkFamilyExists,
    required GetFamily getFamily,
  }) : _createFamily = createFamily,
       _joinFamily = joinFamily,
       _checkFamilyExists = checkFamilyExists,
       _getFamily = getFamily,
       super(const FamilyInitialState()) {
    on<FamilyCreateRequested>(_onCreateFamily);
    on<FamilyJoinRequested>(_onJoinFamily);
    on<FamilyCheckRequested>(_onCheckFamily);
    on<FamilyGetRequested>(_onGetFamily);
  }

  Future<void> _onCreateFamily(
    FamilyCreateRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoadingState());

    final result = await _createFamily(event.familyCode);

    result.fold(
      (failure) => emit(FamilyErrorState(failure.message)),
      (family) => emit(FamilySuccessState(family: family)),
    );
  }

  Future<void> _onJoinFamily(
    FamilyJoinRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoadingState());

    final result = await _joinFamily(event.familyCode);

    result.fold(
      (failure) => emit(FamilyErrorState(failure.message)),
      (family) => emit(FamilySuccessState(family: family)),
    );
  }

  Future<void> _onCheckFamily(
    FamilyCheckRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoadingState());

    final result = await _checkFamilyExists(event.familyCode);

    result.fold(
      (failure) => emit(FamilyErrorState(failure.message)),
      (exists) => emit(FamilySuccessState(familyExists: exists)),
    );
  }

  Future<void> _onGetFamily(
    FamilyGetRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoadingState());

    final result = await _getFamily(event.familyCode);

    result.fold(
      (failure) => emit(FamilyErrorState(failure.message)),
      (family) => emit(FamilySuccessState(family: family)),
    );
  }
}
