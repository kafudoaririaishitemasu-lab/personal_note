part of 'note_bloc.dart';

@immutable
sealed class NoteEvent {}

final class NoteSaveEvent extends NoteEvent{
  final Note note;
  NoteSaveEvent({required this.note});
}

final class NoteGetEvent extends NoteEvent{}

final class NoteDeleteEvent extends NoteEvent{
  final Note note;
  NoteDeleteEvent({required this.note});
}
