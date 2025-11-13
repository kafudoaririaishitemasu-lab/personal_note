import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState>{
  final FirebaseAuth auth;
  AppUserCubit(this.auth) : super(AppUserInitial());

  bool checkUserLogin() {
    if (auth.currentUser != null) {
      emit(AppUserLoggedIn(
          user: auth.currentUser!,
          notesBoxName: "notes${auth.currentUser!.uid}",
          pendingNotesBoxName: "pendingNotes${auth.currentUser!.uid}",
          pendingDeleteNotesBoxName: "pendingDeleteNotes${auth.currentUser!.uid}"
      ));
      return true;
    } else {
      emit(AppUserInitial());
      return false;
    }
  }
}
