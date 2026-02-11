import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/auth/get_current_user.dart';
import '../../../domain/usecases/auth/sign_in_with_email.dart';
import '../../../domain/usecases/auth/sign_in_with_google.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import '../../../domain/usecases/auth/sign_up_with_email.dart';
import '../../../domain/usecases/auth/watch_auth_state.dart';
import '../../../domain/usecases/notification/setup_fcm_token.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final WatchAuthState _watchAuthState;
  final GetCurrentUser _getCurrentUser;
  final SetupFcmToken _setupFcmToken;

  StreamSubscription? _authSubscription;

  AuthBloc({
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required WatchAuthState watchAuthState,
    required GetCurrentUser getCurrentUser,
    required SetupFcmToken setupFcmToken,
  }) : _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signOut = signOut,
       _watchAuthState = watchAuthState,
       _getCurrentUser = getCurrentUser,
       _setupFcmToken = setupFcmToken,
       super(const AuthUnknownState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignUpWithEmailRequested>(_onSignUpWithEmail);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);

    _authSubscription = _watchAuthState(const NoParams()).listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _getCurrentUser(const NoParams());
    result.fold((failure) => emit(const AuthUnauthenticatedState()), (user) {
      if (user != null) {
        emit(AuthAuthenticatedState(user));
        _setupFcmToken(const NoParams());
      } else {
        emit(const AuthUnauthenticatedState());
      }
    });
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold((failure) => emit(AuthUnauthenticatedState(failure.message)), (
      user,
    ) {
      emit(AuthAuthenticatedState(user));
      _setupFcmToken(const NoParams());
    });
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    result.fold((failure) => emit(AuthUnauthenticatedState(failure.message)), (
      user,
    ) {
      emit(AuthAuthenticatedState(user));
      _setupFcmToken(const NoParams());
    });
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    final result = await _signInWithGoogle(const NoParams());
    result.fold((failure) => emit(AuthUnauthenticatedState(failure.message)), (
      user,
    ) {
      emit(AuthAuthenticatedState(user));
      _setupFcmToken(const NoParams());
    });
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    await _signOut(const NoParams());
    emit(const AuthUnauthenticatedState());
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticatedState(event.user!));
    } else {
      emit(const AuthUnauthenticatedState());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
