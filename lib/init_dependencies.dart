import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:personal_note/features/auth/data/service_impl/auth_service_impl.dart';
import 'package:personal_note/features/auth/domain/service/auth_service.dart';
import 'package:personal_note/features/auth/domain/usecases/google_login.dart';
import 'package:personal_note/features/auth/domain/usecases/google_sign_out.dart';
import 'package:personal_note/features/note/data/data_source/note_cloud_data_source.dart';
import 'package:personal_note/features/note/data/service_impl/note_service_impl.dart';
import 'package:personal_note/features/note/domain/service/note_service.dart';
import 'package:personal_note/features/note/domain/usecase/delete_note.dart';
import 'package:personal_note/features/note/domain/usecase/get_notes.dart';
import 'package:personal_note/features/note/domain/usecase/save_note.dart';
import 'package:personal_note/features/note/presentation/bloc/note_bloc.dart';
import 'package:personal_note/firebase_options.dart';
import 'config/theme_controller.dart';
import 'core/common/cibits/app_user_cubit/app_user_cubit.dart';
import 'core/common/cibits/internet_cubit/network_cubit.dart';
import 'core/network/connection_checker.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/data_source/auth_data_source.dart';
import 'features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'features/note/domain/entities/note.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initializeFirebase();
  await _initializeGoogleSignIn();
  await _initHive();
  _fixScreenRotation();
  _initTheme();
  _initAuth();
  _initNote();

  /// Common Utilities
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerLazySingleton<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => AppRouter());
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);

  /// App use cubits
  serviceLocator.registerLazySingleton(() => NetworkCubit());
  serviceLocator.registerLazySingleton(() => AppUserCubit(serviceLocator()));
}

void _fixScreenRotation() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _initializeGoogleSignIn() async {
  GoogleSignIn googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize();
  serviceLocator.registerLazySingleton(() => googleSignIn);
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Note>('pendingNotes');
  await Hive.openBox<Note>('pendingDeleteNotes');
}

void _initTheme() async {
  await ThemeController.loadThemeFromStorage();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthDataSource>(
      () => AuthDataSourceImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory<AuthService>(
      () => AuthServiceImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory(() => GoogleLogin(serviceLocator()))
    ..registerFactory(() => GoogleSignOut(serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        googleLogin: serviceLocator(),
        googleSignOut: serviceLocator(),
      ),
    );
}

void _initNote() {
  serviceLocator
    ..registerFactory<NoteDataSource>(
      () => NoteDataSourceImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory<NoteService>(
      () => NoteServiceImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory(() => SaveNote(serviceLocator()))
    ..registerFactory(() => DeleteNote(serviceLocator()))
    ..registerFactory(() => GetNotes(serviceLocator()))
    ..registerLazySingleton(
      () => NoteBloc(
        saveNote: serviceLocator(),
        deleteNote: serviceLocator(),
        getNotes: serviceLocator(),
      ),
    );
}
