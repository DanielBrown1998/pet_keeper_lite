import 'package:equatable/equatable.dart';
import '../../../domain/entities/family_entity.dart';

sealed class FamilyState extends Equatable {
  const FamilyState();

  /// Família atual, se existir
  FamilyEntity? get family => null;

  /// Mensagem de erro, se houver
  String? get error => null;

  /// Se a família existe (usado em verificações)
  bool get familyExists => false;

  /// Helpers de estado
  bool get isLoading => this is FamilyLoadingState;
  bool get isSuccess => this is FamilySuccessState;
  bool get isError => this is FamilyErrorState;
}

/// Estado inicial
final class FamilyInitialState extends FamilyState {
  const FamilyInitialState();

  @override
  List<Object?> get props => [];
}

/// Estado de carregamento
final class FamilyLoadingState extends FamilyState {
  const FamilyLoadingState();

  @override
  List<Object?> get props => [];
}

/// Estado de sucesso com família
final class FamilySuccessState extends FamilyState {
  @override
  final FamilyEntity? family;
  @override
  final bool familyExists;

  const FamilySuccessState({this.family, this.familyExists = false});

  @override
  List<Object?> get props => [family, familyExists];
}

/// Estado de erro
final class FamilyErrorState extends FamilyState {
  @override
  final String error;

  const FamilyErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
