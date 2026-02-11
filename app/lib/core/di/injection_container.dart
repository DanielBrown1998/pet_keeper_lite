import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Sources
import '../../data/sources/auth_source.dart';
import '../../data/sources/auth_source_impl.dart';
import '../../data/sources/family_source.dart';
import '../../data/sources/family_source_impl.dart';
import '../../data/sources/google_auth_source.dart';
import '../../data/sources/google_auth_source_impl.dart';
import '../../data/sources/notification_source.dart';
import '../../data/sources/notification_source_impl.dart';
import '../../data/sources/pet_source.dart';
import '../../data/sources/pet_source_impl.dart';
import '../../data/sources/task_source.dart';
import '../../data/sources/task_source_impl.dart';

// Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/family_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/family_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/pet_repository.dart';
import '../../domain/repositories/task_repository.dart';

// Auth UseCases
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in_with_email.dart';
import '../../domain/usecases/auth/sign_in_with_google.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up_with_email.dart';
import '../../domain/usecases/auth/update_fcm_token.dart';
import '../../domain/usecases/auth/update_user_profile.dart';
import '../../domain/usecases/auth/watch_auth_state.dart';

// Pet UseCases
import '../../domain/usecases/pet/create_pet.dart';
import '../../domain/usecases/pet/delete_pet.dart';
import '../../domain/usecases/pet/get_pet.dart';
import '../../domain/usecases/pet/update_pet.dart';
import '../../domain/usecases/pet/watch_pets.dart';

// Task UseCases
import '../../domain/usecases/task/create_task.dart';
import '../../domain/usecases/task/delete_task.dart';
import '../../domain/usecases/task/get_task.dart';
import '../../domain/usecases/task/toggle_task_done.dart';
import '../../domain/usecases/task/update_task.dart';
import '../../domain/usecases/task/watch_tasks.dart';

// Family UseCases
import '../../domain/usecases/family/check_family_exists.dart';
import '../../domain/usecases/family/create_family.dart';
import '../../domain/usecases/family/get_family.dart';
import '../../domain/usecases/family/join_family.dart';

// Notification UseCases
import '../../domain/usecases/notification/get_fcm_token.dart';
import '../../domain/usecases/notification/notify_family.dart';
import '../../domain/usecases/notification/request_notification_permission.dart';
import '../../domain/usecases/notification/setup_fcm_token.dart';

// Blocs
import '../../presentation/notification/bloc/notification_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ===== External Dependencies =====
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  getIt.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );
  getIt.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instanceFor(region: 'us-central1'),
  );
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // ===== Sources =====
  getIt.registerLazySingleton<AuthSource>(
    () => AuthSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<GoogleAuthSource>(
    () => GoogleAuthSourceImpl(googleSignIn: getIt<GoogleSignIn>()),
  );

  getIt.registerLazySingleton<PetSource>(
    () => PetSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );

  getIt.registerLazySingleton<TaskSource>(
    () => TaskSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<FamilySource>(
    () => FamilySourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<NotificationSource>(
    () => NotificationSourceImpl(
      messaging: getIt<FirebaseMessaging>(),
      functions: getIt<FirebaseFunctions>(),
    ),
  );

  // ===== Repositories =====
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authSource: getIt<AuthSource>(),
      googleAuthSource: getIt<GoogleAuthSource>(),
    ),
  );

  getIt.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(petSource: getIt<PetSource>()),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(taskSource: getIt<TaskSource>()),
  );

  getIt.registerLazySingleton<FamilyRepository>(
    () => FamilyRepositoryImpl(
      familySource: getIt<FamilySource>(),
      authSource: getIt<AuthSource>(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationSource: getIt<NotificationSource>(),
    ),
  );

  // ===== Auth UseCases =====
  getIt.registerLazySingleton<SignInWithEmail>(
    () => SignInWithEmail(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignUpWithEmail>(
    () => SignUpWithEmail(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOut>(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton<WatchAuthState>(
    () => WatchAuthState(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpdateUserProfile>(
    () => UpdateUserProfile(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpdateFcmToken>(
    () => UpdateFcmToken(getIt<AuthRepository>()),
  );

  // ===== Pet UseCases =====
  getIt.registerLazySingleton<WatchPets>(
    () => WatchPets(getIt<PetRepository>()),
  );
  getIt.registerLazySingleton<GetPet>(() => GetPet(getIt<PetRepository>()));
  getIt.registerLazySingleton<CreatePet>(
    () => CreatePet(getIt<PetRepository>()),
  );
  getIt.registerLazySingleton<UpdatePet>(
    () => UpdatePet(getIt<PetRepository>()),
  );
  getIt.registerLazySingleton<DeletePet>(
    () => DeletePet(getIt<PetRepository>()),
  );

  // ===== Task UseCases =====
  getIt.registerLazySingleton<WatchTasks>(
    () => WatchTasks(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<GetTask>(() => GetTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton<CreateTask>(
    () => CreateTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<UpdateTask>(
    () => UpdateTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<DeleteTask>(
    () => DeleteTask(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ToggleTaskDone>(
    () => ToggleTaskDone(getIt<TaskRepository>()),
  );

  // ===== Family UseCases =====
  getIt.registerLazySingleton<CreateFamily>(
    () => CreateFamily(getIt<FamilyRepository>(), getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<JoinFamily>(
    () => JoinFamily(getIt<FamilyRepository>()),
  );
  getIt.registerLazySingleton<CheckFamilyExists>(
    () => CheckFamilyExists(getIt<FamilyRepository>()),
  );
  getIt.registerLazySingleton<GetFamily>(
    () => GetFamily(getIt<FamilyRepository>()),
  );

  // ===== Notification UseCases =====
  getIt.registerLazySingleton<NotifyFamily>(
    () => NotifyFamily(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<GetFcmToken>(
    () => GetFcmToken(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<RequestNotificationPermission>(
    () => RequestNotificationPermission(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<SetupFcmToken>(
    () =>
        SetupFcmToken(getIt<NotificationRepository>(), getIt<AuthRepository>()),
  );

  // ===== Blocs =====
  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(notifyFamily: getIt<NotifyFamily>()),
  );
}
