import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para enviar notificação para a família
class SendFamilyNotification extends NotificationEvent {
  final String petId;
  final String message;

  const SendFamilyNotification({required this.petId, required this.message});

  @override
  List<Object?> get props => [petId, message];
}

/// Evento para limpar o estado após mostrar feedback
class NotificationReset extends NotificationEvent {
  const NotificationReset();
}
