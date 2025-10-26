import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/common/cibits/app_user_cubit/app_user_cubit.dart';
import 'package:personal_note/features/note/presentation/bloc/note_bloc.dart';

import 'config/app_theme.dart';
import 'config/theme_controller.dart';
import 'core/common/cibits/internet_cubit/network_cubit.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'features/presentation/screens/splash_screen.dart';
import 'init_dependencies.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(
      providers: [
        /// CUBIT PROVIDERS
        BlocProvider(create: (_) => serviceLocator<NetworkCubit>()),
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),

        /// BLOC PROVIDERS
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<NoteBloc>()),

      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.themeModeNotifier,
        builder: (_, mode, __){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Personal Note',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            navigatorKey: serviceLocator<AppRouter>().navigationKey,
            home: SplashScreen(),
          );
        }
    );
  }
}

