import 'package:equatable/equatable.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  bool get isSending => this is NotificationSendingState;
  bool get isSuccess => this is NotificationSuccessState;
  bool get isError => this is NotificationErrorState;

  String? get successMessage => this is NotificationSuccessState
      ? (this as NotificationSuccessState).message
      : null;

  String? get error => this is NotificationErrorState
      ? (this as NotificationErrorState).error
      : null;
}

/// Estado inicial
final class NotificationInitialState extends NotificationState {
  const NotificationInitialState();

  @override
  List<Object?> get props => [];
}

/// Estado de envio em andamento
final class NotificationSendingState extends NotificationState {
  const NotificationSendingState();

  @override
  List<Object?> get props => [];
}

/// Estado de sucesso
final class NotificationSuccessState extends NotificationState {
  final String message;

  const NotificationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de erro
final class NotificationErrorState extends NotificationState {
  @override
  final String error;

  const NotificationErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
