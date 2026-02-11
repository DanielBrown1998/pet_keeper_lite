import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
