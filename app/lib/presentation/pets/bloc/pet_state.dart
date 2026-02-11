import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet_entity.dart';

sealed class PetState extends Equatable {
  const PetState();

  /// Lista de pets (disponível em todos os estados exceto initial)
  List<PetEntity> get pets => const [];

  /// Mensagem de erro, se houver
  String? get error => null;

  /// Mensagem de sucesso, se houver
  String? get successMessage => null;

  /// Helpers de estado
  bool get isLoading => this is PetLoadingState;
  bool get isSubmitting =>
      this is PetLoadingState && (this as PetLoadingState).submitting;
  bool get isError => this is PetErrorState;
  bool get isSuccess => this is PetSuccessState;
}

/// Estado inicial - app acabou de abrir
final class PetInitialState extends PetState {
  const PetInitialState();

  @override
  List<Object?> get props => [];
}

/// Estado de carregamento (dados ou submissão)
final class PetLoadingState extends PetState {
  @override
  final List<PetEntity> pets;
  final bool submitting;

  const PetLoadingState({this.pets = const [], this.submitting = false});

  @override
  List<Object?> get props => [pets, submitting];
}

/// Estado de sucesso com lista de pets
final class PetSuccessState extends PetState {
  @override
  final List<PetEntity> pets;
  @override
  final String? successMessage;

  const PetSuccessState(this.pets, [this.successMessage]);

  @override
  List<Object?> get props => [pets, successMessage];
}

/// Estado de erro
final class PetErrorState extends PetState {
  @override
  final List<PetEntity> pets;
  @override
  final String error;

  const PetErrorState(this.pets, this.error);

  @override
  List<Object?> get props => [pets, error];
}
