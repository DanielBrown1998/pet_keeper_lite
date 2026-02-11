import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/pet_entity.dart';
import '../../../domain/usecases/pet/create_pet.dart';
import '../../../domain/usecases/pet/delete_pet.dart';
import '../../../domain/usecases/pet/update_pet.dart';
import '../../../domain/usecases/pet/watch_pets.dart';
import 'pet_event.dart';
import 'pet_state.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  final WatchPets _watchPets;
  final CreatePet _createPet;
  final UpdatePet _updatePet;
  final DeletePet _deletePet;

  PetBloc({
    required WatchPets watchPets,
    required CreatePet createPet,
    required UpdatePet updatePet,
    required DeletePet deletePet,
  }) : _watchPets = watchPets,
       _createPet = createPet,
       _updatePet = updatePet,
       _deletePet = deletePet,
       super(const PetInitialState()) {
    on<PetWatchRequested>(
      _onWatchPets,
      transformer: restartable(), // Garante que apenas um stream ativo por vez
    );
    on<PetCreateRequested>(_onCreatePet);
    on<PetUpdateRequested>(_onUpdatePet);
    on<PetDeleteRequested>(_onDeletePet);
  }

  

  Future<void> _onWatchPets(
    PetWatchRequested event,
    Emitter<PetState> emit,
  ) async {
    emit(PetLoadingState(pets: state.pets));

    await emit.forEach<List<PetEntity>>(
      _watchPets(event.familyCode),
      onData: (pets) => PetSuccessState(pets),
      onError: (error, stackTrace) =>
          PetErrorState(state.pets, error.toString()),
    );
  }

  Future<void> _onCreatePet(
    PetCreateRequested event,
    Emitter<PetState> emit,
  ) async {
    emit(PetLoadingState(pets: state.pets, submitting: true));

    final result = await _createPet(
      CreatePetParams(pet: event.pet, photo: event.photo),
    );

    result.fold(
      (failure) {
        emit(PetErrorState(state.pets, failure.message));
      },
      (pet) {
        emit(PetSuccessState(state.pets, 'Pet criado com sucesso!'));
      },
    );
  }

  Future<void> _onUpdatePet(
    PetUpdateRequested event,
    Emitter<PetState> emit,
  ) async {
    emit(PetLoadingState(pets: state.pets, submitting: true));

    final result = await _updatePet(
      UpdatePetParams(pet: event.pet, photo: event.photo),
    );

    result.fold(
      (failure) {
        emit(PetErrorState(state.pets, failure.message));
      },
      (_) {
        emit(PetSuccessState(state.pets, 'Pet atualizado com sucesso!'));
      },
    );
  }

  Future<void> _onDeletePet(
    PetDeleteRequested event,
    Emitter<PetState> emit,
  ) async {
    emit(PetLoadingState(pets: state.pets, submitting: true));

    final result = await _deletePet(event.petId);

    result.fold(
      (failure) {
        emit(PetErrorState(state.pets, failure.message));
      },
      (_) {
        emit(PetSuccessState(state.pets, 'Pet removido com sucesso!'));
      },
    );
  }
}
