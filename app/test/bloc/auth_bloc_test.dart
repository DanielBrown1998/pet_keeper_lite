import 'package:app/core/error/failures.dart';
import 'package:app/core/usecases/usecase.dart';
import 'package:app/domain/entities/user_entity.dart';
import 'package:app/domain/usecases/auth/get_current_user.dart';
import 'package:app/domain/usecases/auth/sign_in_with_email.dart';
import 'package:app/domain/usecases/auth/sign_in_with_google.dart';
import 'package:app/domain/usecases/auth/sign_out.dart';
import 'package:app/domain/usecases/auth/sign_up_with_email.dart';
import 'package:app/domain/usecases/auth/watch_auth_state.dart';
import 'package:app/domain/usecases/notification/setup_fcm_token.dart';
import 'package:app/presentation/auth/bloc/auth_bloc.dart';
import 'package:app/presentation/auth/bloc/auth_event.dart';
import 'package:app/presentation/auth/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class MockWatchAuthState extends Mock implements WatchAuthState {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSetupFcmToken extends Mock implements SetupFcmToken {}

class FakeSignInWithEmailParams extends Fake implements SignInWithEmailParams {}

class FakeSignUpWithEmailParams extends Fake implements SignUpWithEmailParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthBloc authBloc;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignUpWithEmail mockSignUpWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockWatchAuthState mockWatchAuthState;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockSetupFcmToken mockSetupFcmToken;

  setUpAll(() {
    registerFallbackValue(FakeSignInWithEmailParams());
    registerFallbackValue(FakeSignUpWithEmailParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignUpWithEmail = MockSignUpWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockWatchAuthState = MockWatchAuthState();
    mockGetCurrentUser = MockGetCurrentUser();
    mockSetupFcmToken = MockSetupFcmToken();

    // Setup default stream - use empty stream that never emits to preserve initial state
    when(
      () => mockWatchAuthState(any()),
    ).thenAnswer((_) => const Stream.empty());

    authBloc = AuthBloc(
      signInWithEmail: mockSignInWithEmail,
      signUpWithEmail: mockSignUpWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
      watchAuthState: mockWatchAuthState,
      getCurrentUser: mockGetCurrentUser,
      setupFcmToken: mockSetupFcmToken,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testUser = UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      familyCode: 'FAMILY01',
    );

    test('initial state is AuthUnknownState', () {
      expect(authBloc.state, const AuthUnknownState());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when sign in succeeds',
      build: () {
        when(
          () => mockSignInWithEmail(any()),
        ).thenAnswer((_) async => const Right(testUser));
        when(
          () => mockSetupFcmToken(any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(
          email: 'test@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoadingState(),
        const AuthAuthenticatedState(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when sign in fails',
      build: () {
        when(() => mockSignInWithEmail(any())).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid credentials')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ),
      expect: () => [
        const AuthLoadingState(),
        const AuthUnauthenticatedState('Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when sign out is requested',
      build: () {
        when(
          () => mockSignOut(any()),
        ).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthLoadingState(),
        const AuthUnauthenticatedState(),
      ],
    );
  });
}
