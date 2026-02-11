import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/notification/notify_family.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotifyFamily _notifyFamily;

  NotificationBloc({required NotifyFamily notifyFamily})
    : _notifyFamily = notifyFamily,
      super(const NotificationInitialState()) {
    on<SendFamilyNotification>(_onSendFamilyNotification);
    on<NotificationReset>(_onReset);
  }

  Future<void> _onSendFamilyNotification(
    SendFamilyNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationSendingState());

    final result = await _notifyFamily(
      NotifyFamilyParams(petId: event.petId, message: event.message),
    );

    result.fold(
      (failure) => emit(NotificationErrorState(failure.message)),
      (_) => emit(const NotificationSuccessState('Família notificada!')),
    );
  }

  void _onReset(NotificationReset event, Emitter<NotificationState> emit) {
    emit(const NotificationInitialState());
  }
}
