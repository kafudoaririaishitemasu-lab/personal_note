import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/usecase/usecase.dart';
import 'package:personal_note/features/auth/domain/usecases/google_login.dart';
import 'package:personal_note/features/auth/domain/usecases/google_sign_out.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleLogin _googleLogin;
  final GoogleSignOut _googleSignOut;
  AuthBloc({
    required GoogleLogin googleLogin,
    required GoogleSignOut googleSignOut,
}) :
        _googleLogin = googleLogin,
        _googleSignOut = googleSignOut,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignInEvent>(_onAuthSignIn);
    on<AuthSignOutEvent>(_onAuthSignOut);
  }

  void _onAuthSignIn(AuthSignInEvent event, Emitter<AuthState> emit) async{
    final res = await _googleLogin(NoParams());
    await res.fold(
          (failure) async => emit(AuthFailure(message: failure.message)),
          (success) async => emit(AuthSignedIn())
    );
  }

  void _onAuthSignOut(AuthSignOutEvent event, Emitter<AuthState> emit) async{
    final res = await _googleSignOut(NoParams());
    await res.fold(
            (failure) async => emit(AuthFailure(message: failure.message)),
            (success) async => emit(AuthSignedOut())
    );
  }
}
