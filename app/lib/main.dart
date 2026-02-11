import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'domain/usecases/auth/get_current_user.dart';
import 'domain/usecases/auth/sign_in_with_email.dart';
import 'domain/usecases/auth/sign_in_with_google.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/auth/sign_up_with_email.dart';
import 'domain/usecases/auth/watch_auth_state.dart';
import 'domain/usecases/family/check_family_exists.dart';
import 'domain/usecases/family/create_family.dart';
import 'domain/usecases/family/get_family.dart';
import 'domain/usecases/family/join_family.dart';
import 'domain/usecases/notification/setup_fcm_token.dart';
import 'domain/usecases/pet/create_pet.dart';
import 'domain/usecases/pet/delete_pet.dart';
import 'domain/usecases/pet/update_pet.dart';
import 'domain/usecases/pet/watch_pets.dart';
import 'domain/usecases/task/create_task.dart';
import 'domain/usecases/task/delete_task.dart';
import 'domain/usecases/task/toggle_task_done.dart';
import 'domain/usecases/task/update_task.dart';
import 'domain/usecases/task/watch_tasks.dart';
import 'firebase_options.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/family/bloc/family_bloc.dart';
import 'presentation/notification/bloc/notification_bloc.dart';
import 'presentation/pets/bloc/pet_bloc.dart';
import 'presentation/tasks/bloc/task_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Set to true to use Firebase emulators
const bool useEmulators = false;

/// Your local machine IP address (for physical devices)
/// Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) to find it
const String localMachineIp = '192.168.1.5';

/// Configure Firebase to use local emulators
Future<void> _configureEmulators() async {
  // For physical Android devices, use your machine's local IP
  // For Android emulator, use 10.0.2.2
  // For iOS simulator or desktop, use localhost
  String emulatorHost;

  if (defaultTargetPlatform == TargetPlatform.android) {
    // Use local IP for physical devices (works for both emulator and physical)
    emulatorHost = localMachineIp;
  } else {
    emulatorHost = 'localhost';
  }

  await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
  await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);

  debugPrint('🔧 Using Firebase emulators at $emulatorHost');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!useEmulators) {
    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }
  if (useEmulators && kDebugMode) {
    await _configureEmulators();
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      signInWithEmail: getIt<SignInWithEmail>(),
      signUpWithEmail: getIt<SignUpWithEmail>(),
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signOut: getIt<SignOut>(),
      watchAuthState: getIt<WatchAuthState>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      setupFcmToken: getIt<SetupFcmToken>(),
    )..add(const AuthCheckRequested());

    _appRouter = AppRouter(authBloc: _authBloc);
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap when app is in background
      final petId = message.data['petId'];
      if (petId != null) {
        // go to pet page
        _appRouter.router.go('/pets/$petId');
      }
    });
  }

  void _showLocalNotification(RemoteNotification notification) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title ?? 'Notificação',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (notification.body != null) Text(notification.body!),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<PetBloc>(
          create: (context) => PetBloc(
            watchPets: getIt<WatchPets>(),
            createPet: getIt<CreatePet>(),
            updatePet: getIt<UpdatePet>(),
            deletePet: getIt<DeletePet>(),
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => getIt<NotificationBloc>(),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(
            watchTasks: getIt<WatchTasks>(),
            createTask: getIt<CreateTask>(),
            updateTask: getIt<UpdateTask>(),
            deleteTask: getIt<DeleteTask>(),
            toggleTaskDone: getIt<ToggleTaskDone>(),
          ),
        ),
        BlocProvider<FamilyBloc>(
          create: (context) => FamilyBloc(
            createFamily: getIt<CreateFamily>(),
            joinFamily: getIt<JoinFamily>(),
            checkFamilyExists: getIt<CheckFamilyExists>(),
            getFamily: getIt<GetFamily>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'PetKeeper Lite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
