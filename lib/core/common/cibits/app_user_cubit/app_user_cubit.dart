import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState>{
  final FirebaseAuth auth;
  AppUserCubit(this.auth) : super(AppUserLoggedIn(user: auth.currentUser));
}
