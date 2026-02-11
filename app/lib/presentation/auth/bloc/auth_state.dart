import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  /// Retorna o usuário se estiver autenticado, null caso contrário
  UserEntity? get user => null;

  /// Retorna o erro se houver, null caso contrário
  String? get error => null;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => this is AuthAuthenticatedState;

  /// Verifica se está carregando
  bool get isLoading => this is AuthLoadingState;

  /// Verifica se o usuário pertence a uma família
  bool get hasFamily =>
      user?.familyCode != null && user!.familyCode!.isNotEmpty;
}

/// Estado inicial - ainda não verificou autenticação
final class AuthUnknownState extends AuthState {
  const AuthUnknownState();

  @override
  List<Object?> get props => [];
}

/// Estado de carregamento durante operações de autenticação
final class AuthLoadingState extends AuthState {
  const AuthLoadingState();

  @override
  List<Object?> get props => [];
}

/// Estado autenticado com usuário logado
final class AuthAuthenticatedState extends AuthState {
  @override
  final UserEntity user;

  const AuthAuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado não autenticado, opcionalmente com mensagem de erro
final class AuthUnauthenticatedState extends AuthState {
  @override
  final String? error;

  const AuthUnauthenticatedState([this.error]);

  @override
  List<Object?> get props => [error];
}
