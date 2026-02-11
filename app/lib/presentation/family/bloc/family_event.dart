import 'package:equatable/equatable.dart';

abstract class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

class FamilyCreateRequested extends FamilyEvent {
  final String familyCode;

  const FamilyCreateRequested(this.familyCode);

  @override
  List<Object?> get props => [familyCode];
}

class FamilyJoinRequested extends FamilyEvent {
  final String familyCode;

  const FamilyJoinRequested(this.familyCode);

  @override
  List<Object?> get props => [familyCode];
}

class FamilyCheckRequested extends FamilyEvent {
  final String familyCode;

  const FamilyCheckRequested(this.familyCode);

  @override
  List<Object?> get props => [familyCode];
}

class FamilyGetRequested extends FamilyEvent {
  final String familyCode;

  const FamilyGetRequested(this.familyCode);

  @override
  List<Object?> get props => [familyCode];
}
