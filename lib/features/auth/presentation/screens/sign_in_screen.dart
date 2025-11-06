import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/config/app_pallete.dart';
import 'package:personal_note/core/common/cibits/internet_cubit/network_cubit.dart';
import 'package:personal_note/core/network/network_guard.dart';
import 'package:personal_note/core/router/app_router.dart';
import 'package:personal_note/core/utils/screen_size.dart';
import 'package:personal_note/core/utils/snackbar.dart';
import 'package:personal_note/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:personal_note/init_dependencies.dart';

import '../../../presentation/screens/splash_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Timer? _debounce;

  void _handleSignIn() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final connectionState = await context.read<NetworkCubit>().checkConnection();
      if (connectionState) {
        if(!mounted) return;
          context.read<AuthBloc>().add(AuthSignInEvent());
      } else {
        if (!mounted) return;
          UiSnack.showNetworkErrorSnackBar(context, isNetworkError: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NetworkGuard(
      callback: () {},
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth(context) * 0.03,
              vertical: screenHeight(context) * 0.015,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/logo.png",
                  width: screenWidth(context) * 0.3,
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: 'Welcome to P Note ✌️',
                    style: TextStyle(
                      fontSize: screenWidth(context) * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C4043),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text:
                        'Login to secure your data with end-to-end encryption.',
                    style: TextStyle(
                      fontSize: screenWidth(context) * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),

                // --- Google Sign-In Button ---
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (blcCtx, state) {
                    if (state is AuthSignedIn) {
                      UiSnack.showInfoSnackBar(
                        context,
                        message: "Welcome to your space 🫶",
                      );
                      serviceLocator<AppRouter>().pushAndRemoveUntil(SplashScreen(),);
                    } else if (state is AuthFailure) {
                      UiSnack.showInfoSnackBar(blcCtx, message: state.message, isError: true);
                    }
                  },
                  builder: (blcCtx, state) {
                    return ElevatedButton(
                      onPressed: state is AuthLoading ? () {} : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth(context) * 0.03,
                          vertical: screenHeight(context) * 0.015,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/glogo.png',
                              height: screenWidth(context) * 0.06,
                            ),
                            SizedBox(width: screenWidth(context) * 0.035),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C4043),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text:
                        'We have only Google SignIn method for your privacy and better experience 😊.',
                    style: TextStyle(
                      fontSize: screenWidth(context) * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),

                // TextButton(
                //   onPressed: () async {
                //     final res = await AuthService().signOut();
                //     if (res == "Success") {
                //       UiSnack.showInfoSnackBar(context, message: "Log out");
                //     } else {
                //       UiSnack.showInfoSnackBar(context, message: "Failed");
                //     }
                //   },
                //   child: Text("Log out"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
