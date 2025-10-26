part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignInEvent extends AuthEvent{}

final class AuthSignOutEvent extends AuthEvent{}
