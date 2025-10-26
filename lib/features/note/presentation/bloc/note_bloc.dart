import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/usecase/usecase.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';
import 'package:personal_note/features/note/domain/usecase/delete_note.dart';
import 'package:personal_note/features/note/domain/usecase/get_notes.dart';
import 'package:personal_note/features/note/domain/usecase/save_note.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final SaveNote _saveNote;
  final GetNotes _getNotes;
  final DeleteNote _deleteNote;
  NoteBloc({
    required SaveNote saveNote,
    required GetNotes getNotes,
    required DeleteNote deleteNote
}) :
        _saveNote = saveNote,
        _getNotes = getNotes,
        _deleteNote = deleteNote,
        super(NoteInitial()) {
    on<NoteEvent>((_, emit) => emit(NoteLoading()));
    on<NoteSaveEvent>(_onNoteSaveEvent);
    on<NoteGetEvent>(_onNoteGetEvent);
    on<NoteDeleteEvent>(_onNoteDeleteEvent);
  }

  Future<void> _onNoteSaveEvent(NoteSaveEvent event, Emitter<NoteState> emit) async{
    final res = await _saveNote(event.note);
    res.fold(
            (failure) async => emit(NoteError(message: failure.message)),
            (success) async => emit(NoteLoaded(notes: success))
    );
  }

  Future<void> _onNoteGetEvent(NoteGetEvent event, Emitter<NoteState> emit) async{
    final res = await _getNotes(NoParams());
    res.fold(
            (failure) async => emit(NoteError(message: failure.message)),
            (success) async => emit(NoteLoaded(notes: success))
    );
  }

  Future<void> _onNoteDeleteEvent (NoteDeleteEvent event, Emitter<NoteState> emit) async{
    final res = await _deleteNote(event.note);
    res.fold(
            (failure) async => emit(NoteError(message: failure.message)),
            (success) async => emit(NoteLoaded(notes: success))
    );
  }
}
