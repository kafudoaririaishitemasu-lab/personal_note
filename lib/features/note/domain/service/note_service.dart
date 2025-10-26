import 'package:fpdart/fpdart.dart';
import 'package:personal_note/core/error/failures.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';

abstract interface class NoteService{
  Future<Either<Failure, List<Note>>> getNotes();

  Future<Either<Failure, List<Note>>> saveNote({
    required Note note
});

  Future<Either<Failure, List<Note>>> deleteNote({
    required Note note
});
}