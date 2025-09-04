part of 'note_cubit.dart';

@immutable
sealed class NoteState {}

final class NoteInitial extends NoteState{}

final class NoteLoading extends NoteState{}

final class NoteLoaded extends NoteState{
  final List<Note> notes;
  NoteLoaded({required this.notes});
}