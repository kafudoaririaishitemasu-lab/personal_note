import 'package:flutter/material.dart';
import 'package:personal_note/config/app_pallete.dart';
import 'package:personal_note/core/common/cibits/app_user_cubit/app_user_cubit.dart';
import 'package:personal_note/core/utils/snackbar.dart';
import 'package:personal_note/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:personal_note/features/presentation/screens/home_screen.dart';

import '../../../../core/network/network_guard.dart';
import '../../../../core/router/app_router.dart';
import '../../../../init_dependencies.dart';

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
      final user = serviceLocator<AppUserCubit>().auth.currentUser;
      if (user != null) {
        serviceLocator<AppRouter>().pushAndRemoveUntil(HomeScreen());
      } else {
        serviceLocator<AppRouter>().pushAndRemoveUntil(SignInScreen());
      }
    } catch (e) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png"),
              ],
            )
        )
    );
  }
}