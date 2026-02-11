import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet_entity.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object?> get props => [];
}

class PetWatchRequested extends PetEvent {
  final String familyCode;

  const PetWatchRequested(this.familyCode);

  @override
  List<Object?> get props => [familyCode];
}

class PetCreateRequested extends PetEvent {
  final PetEntity pet;
  final File? photo;

  const PetCreateRequested({required this.pet, this.photo});

  @override
  List<Object?> get props => [pet, photo];
}

class PetUpdateRequested extends PetEvent {
  final PetEntity pet;
  final File? photo;

  const PetUpdateRequested({required this.pet, this.photo});

  @override
  List<Object?> get props => [pet, photo];
}

class PetDeleteRequested extends PetEvent {
  final String petId;

  const PetDeleteRequested(this.petId);

  @override
  List<Object?> get props => [petId];
}
