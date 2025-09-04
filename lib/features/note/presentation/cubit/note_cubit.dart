import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_source/note_data_source.dart';
import '../../domain/entities/note.dart';
import 'package:flutter/material.dart';

part 'note_state.dart';

class NotesCubit extends Cubit<NoteState> {
  final NoteStorage storage;

  NotesCubit(this.storage) : super(NoteInitial());

  Future<void> loadNotes() async {
    emit(NoteLoading());
    final notes = await storage.loadNotes();
    emit(NoteLoaded(notes: notes));
  }

  Future<void> deleteNote(String id) async {
    if (state is NoteLoaded) {
      final currentState = state as NoteLoaded;
      final notes = List<Note>.from(currentState.notes);

      notes.removeWhere((n) => n.id == id);

      emit(NoteLoaded(notes: notes));
      await storage.saveNotes(notes);
    }
  }

  Future<void> saveNote(Note note) async {
    if (state is NoteLoaded) {
      final currentState = state as NoteLoaded;
      final notes = List<Note>.from(currentState.notes);

      final index = notes.indexWhere((n) => n.id == note.id);

      final trimmedTitle = note.title.trim();
      final trimmedContent = note.content.trim();

      if (trimmedTitle.isEmpty && trimmedContent.isEmpty) {
        await deleteNote(note.id);
        return;
      }

      if (index != -1) {
        notes[index] = note;
      } else {
        notes.insert(0, note);
      }

      emit(NoteLoaded(notes: notes));
      await storage.saveNotes(notes);
    }
  }

}
