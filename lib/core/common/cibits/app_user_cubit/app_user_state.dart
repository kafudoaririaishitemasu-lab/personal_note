part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState{
  final User user;
  final String notesBoxName;
  final String pendingNotesBoxName;
  final String pendingDeleteNotesBoxName;

  AppUserLoggedIn({
    required this.user,
    required this.notesBoxName,
    required this.pendingNotesBoxName,
    required this.pendingDeleteNotesBoxName,
  });
}