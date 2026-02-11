import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/presentation/auth/bloc/auth_bloc.dart';
import 'package:app/presentation/auth/bloc/auth_state.dart';
import 'package:app/presentation/auth/pages/login_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticatedState());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders login form correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('PetKeeper Lite'), findsOneWidget);
      expect(find.text('Cuide dos seus pets em família'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Continuar com Google'), findsOneWidget);
      expect(find.text('Cadastre-se'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu email'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um email válido'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('shows validation error for short password', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when authenticating', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoadingState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
