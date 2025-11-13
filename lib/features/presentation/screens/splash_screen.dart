import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/config/app_pallete.dart';
import 'package:personal_note/core/common/cibits/app_user_cubit/app_user_cubit.dart';
import 'package:personal_note/core/utils/snackbar.dart';
import 'package:personal_note/core/utils/storage_manager.dart';
import 'package:personal_note/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:personal_note/features/presentation/screens/home_screen.dart';

import '../../../../core/network/network_guard.dart';
import '../../../../core/router/app_router.dart';
import '../../../../init_dependencies.dart';
import '../../../core/utils/screen_size.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      checkLoginStatus();
    });
  }

  void checkLoginStatus() async{
    if (_navigated) return;
    _navigated = true;
    try {
      final isLoggedIn = serviceLocator<AppUserCubit>().checkUserLogin();
       final ds = serviceLocator<StorageManager>();
      if (isLoggedIn) {
        final userId = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.uid;
        await ds.openForUser(userId);
        serviceLocator<AppRouter>().pushAndRemoveUntil(HomeScreen());
      }
      else {
        serviceLocator<AppRouter>().pushAndRemoveUntil(SignInScreen());
      }
    } catch (e) {
      if(!mounted) return;
      UiSnack.showInfoSnackBar(context, message: e.toString());
      serviceLocator<AppRouter>().pushAndRemoveUntil(SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return NetworkGuard(
        callback: (){
          checkLoginStatus();
        },
        child: Scaffold(
            backgroundColor: whiteColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/splashIMG.png",
                    width: screenWidth(context) * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )
        )
    );
  }
}