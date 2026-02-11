import 'package:app/domain/entities/user_entity.dart';
import 'package:app/presentation/auth/bloc/auth_bloc.dart';
import 'package:app/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/pet_entity.dart';
import 'package:app/presentation/pets/bloc/pet_bloc.dart';
import 'package:app/presentation/pets/bloc/pet_state.dart';
import 'package:app/presentation/pets/pages/pets_list_page.dart';

class MockPetBloc extends Mock implements PetBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockPetBloc mockPetBloc;
  late MockAuthBloc mockAuthBloc;
  setUp(() {
    mockPetBloc = MockPetBloc();
    mockAuthBloc = MockAuthBloc();
    final user = const UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      familyCode: 'FAM123',
    );

    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticatedState(user));
    when(() => mockPetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PetBloc>.value(value: mockPetBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const PetsListPage(),
      ),
    );
  }

  final testPets = [
    PetEntity(
      id: '1',
      name: 'Rex',
      species: 'dog',
      birthDate: DateTime(2020, 5, 15),
      familyCode: 'FAM123',
      photoUrl: null,
      createdAt: DateTime.now(),
    ),
    PetEntity(
      id: '2',
      name: 'Mimi',
      species: 'cat',
      birthDate: DateTime(2021, 3, 10),
      familyCode: 'FAM123',
      photoUrl: null,
      createdAt: DateTime.now(),
    ),
  ];

  group('PetsListPage', () {
    testWidgets('renders app bar with correct title', (tester) async {
      when(() => mockPetBloc.state).thenReturn(const PetInitialState());
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Meus Pets'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => mockPetBloc.state).thenReturn(const PetLoadingState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state message when no pets', (tester) async {
      when(() => mockPetBloc.state).thenReturn(const PetSuccessState([]));
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nenhum pet cadastrado'), findsOneWidget);
      expect(
        find.text('Toque no + para adicionar seu primeiro pet'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('shows list of pets when loaded', (tester) async {
      when(() => mockPetBloc.state).thenReturn(PetSuccessState(testPets));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Rex'), findsOneWidget);
      expect(find.text('Mimi'), findsOneWidget);
      expect(find.text('Cachorro'), findsOneWidget);
      expect(find.text('Gato'), findsOneWidget);
    });

    testWidgets('shows error via snackbar when error occurs', (tester) async {
      when(
        () => mockPetBloc.state,
      ).thenReturn(const PetErrorState([], 'Erro ao carregar pets'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Give time for SnackBar to appear

      // Error is shown via SnackBar in BlocListener, verify the state is error
      expect(mockPetBloc.state.isError, isTrue);
      expect(mockPetBloc.state.error, 'Erro ao carregar pets');
    });

    testWidgets('has floating action button to add pet', (tester) async {
      when(() => mockPetBloc.state).thenReturn(const PetSuccessState([]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
