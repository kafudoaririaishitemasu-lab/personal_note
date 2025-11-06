import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/common/cibits/app_user_cubit/app_user_cubit.dart';
import 'package:personal_note/core/router/app_router.dart';
import 'package:personal_note/core/utils/screen_size.dart';
import 'package:personal_note/core/utils/snackbar.dart';
import 'package:personal_note/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:personal_note/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:personal_note/features/note/presentation/screen/trash_note_list_screen.dart';
import 'package:personal_note/init_dependencies.dart';

import '../../../config/app_pallete.dart';
import '../../../config/theme_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(ThemeController.isDarkMode);

  void _onToggle(bool value){
    isDarkMode.value = value;
    ThemeController.toggleTheme();
  }

  void _handleSignOut(BuildContext context){
    context.read<AuthBloc>().add(AuthSignOutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUserCubit>().auth.currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: lightPrimary),
            accountName: RichText(
                text: TextSpan(
                    text: user != null
                        ? user.displayName
                        : "User"
                )
            ),
            accountEmail: RichText(
                text: TextSpan(
                    text: user != null
                        ? user.email
                        : "user@gmail.com"
                )
            ),
            currentAccountPicture:CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                  user != null
                      ? user.displayName != null ? user.displayName!.substring(0,1) : "UR"
                      : "UR",
                style: TextStyle(
                    color: Colors.orange,
                  fontSize: screenWidth(context) * 0.05
                ),
              ),
            ),
          ),
          /// Sign out button
          BlocConsumer<AuthBloc, AuthState>(
            listener: (ctx, state) {
              if(state is AuthSignedOut){
                serviceLocator<AppRouter>().pushAndRemoveUntil(SignInScreen());
              }
              else if(state is AuthFailure){
                UiSnack.showInfoSnackBar(ctx, message: state.message);
              }
            },
            builder: (ctx, state){
              return ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Sign Out"),
                onTap: state is AuthLoading
                    ? (){}
                    : (){_handleSignOut(context);},
              );
            },
          ),

          /// This Tile for change theme
          ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, value, child) {
                return ListTile(
                  leading: value
                      ? const Icon(Icons.brightness_6)
                      : const Icon(Icons.brightness_low),
                  title: value
                      ? const Text("Dark Mode")
                      : const Text("Light Mode"),
                  trailing: Switch(
                    activeThumbColor: darkPrimary,
                    activeTrackColor: whiteColor,
                    inactiveTrackColor: whiteColor,
                    value: value,
                    onChanged: _onToggle,
                  ),
                );
              }
          ),

          GestureDetector(
            onLongPress: (){
              serviceLocator<AppRouter>().push(TrashNoteListScreen());
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              width: screenWidth(context),
              height: 50,
              child: Text(" "),
            ),
          )
        ],
      ),
    );
  }
}