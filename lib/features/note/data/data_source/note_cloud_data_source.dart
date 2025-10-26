import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:personal_note/core/error/exceptions.dart';

import '../../domain/entities/note.dart';

abstract interface class NoteDataSource{
  List<Note> saveNoteLocal({required Note note});

  Future<List<Note>> saveNoteLocalAndCloud({required Note note});

  Future<List<Note>> getCloudNotes();

  List<Note> getLocalNotes();

  List<Note> deleteNoteLocal({required Note note});

  Future<List<Note>> deleteNoteLocalAndCloud({required Note note});

}

class NoteDataSourceImpl implements NoteDataSource{
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  /// Main box for access current and in used note
  final Box<Note> notesBox = Hive.box<Note>('notes');
  /// Pending Sync notes to be cloud
  final Box<Note> pendingBox = Hive.box<Note>('pendingNotes');
  /// Pending Delete notes which have to delete from Cloud
  final Box<Note> pendingDeleteBox = Hive.box<Note>('pendingDeleteNotes');

  NoteDataSourceImpl(this.firestore, this.auth);

  /// USE asynchronus on all cloud based method and separate cloud part from methods
  @override
  List<Note> saveNoteLocal({required Note note}) {
    notesBox.put(note.id, note);
    final newNote = returnNewNote(note);
    pendingBox.put(newNote.id, newNote);
    return notesBox.values.toList().reversed.toList();
  }
  
  @override
  Future<List<Note>> saveNoteLocalAndCloud({required Note note}) async{
    try{
      /// Save note in local storage
      notesBox.put(note.id, note);

      /// Save note in Cloud
      final user = auth.currentUser;
      if(user != null){
        await firestore.collection('users')
            .doc(user.email)
            .collection('notes')
            .doc(note.id)
            .set({
          'title': note.title,  /// encryptText(note.title)   TODO have to complete this feature
          'content': note.content, ///encryptText(note.content),
          'isLocked': note.isLocked,
          'isTrashed': note.isTrashed,
          'createdAt': note.createdAt,
        });

        /// If any note Pending to upload into cloud
        if(pendingBox.isNotEmpty){
          await uploadPendingNotes();
        }
      }
      return notesBox.values.toList().reversed.toList();
    } catch(e){
      throw ServerException("Failed to save note");
    }
  }

  @override
  List<Note> getLocalNotes() {
    return notesBox.values.toList().reversed.toList();
  }

  @override
  Future<List<Note>> getCloudNotes() async{
    try{
      final user = auth.currentUser;
      if(user == null) return [];

      if(pendingBox.isNotEmpty){
        await uploadPendingNotes();
      }

      if(pendingDeleteBox.isNotEmpty){
        await deletePendingNotes();
      }

      final snapshot = await firestore
          .collection('users')
          .doc(user.email)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      List<Note> notes = snapshot.docs.map((doc) {
        return Note(
          id: doc.id,
          title: doc['title'],
          content: doc['content'],
          isLocked: doc['isLocked'] ?? false,
          isTrashed: doc['isTrashed'] ?? false,
          createdAt: doc['createdAt'],
        );
      }).toList();

      notesBox.clear();
      /// Save cloud notes locally for offline
      await notesBox.putAll({for (var note in notes) note.id: note});

      return notes;
    } catch (e){
      throw ServerException("Failed to load notes");
    }
  }

  @override
  List<Note> deleteNoteLocal({required Note note}) {
    notesBox.delete(note.id);
    pendingDeleteBox.put(note.id, note);
    return notesBox.values.toList().reversed.toList();
  }

  @override
  Future<List<Note>> deleteNoteLocalAndCloud({required Note note}) async {
    notesBox.delete(note.id);
    pendingDeleteBox.put(note.id, note);

    try {
      final user = auth.currentUser;
      if (user != null) {
        if (pendingDeleteBox.isNotEmpty) {
          for (var pendingNote in pendingDeleteBox.values) {
            await firestore
                .collection('users')
                .doc(user.email)
                .collection('notes')
                .doc(pendingNote.id)
                .delete();

            /// Remove after syncing
            pendingDeleteBox.delete(pendingNote.id);
          }
        }
        return notesBox.values.toList().reversed.toList();
      } else {
        throw ServerException("Something went wrong");
      }
    } catch (e) {
      throw ServerException("Failed to Delete");
    }
  }

  Future<void> uploadPendingNotes() async{
    try{
      final user = auth.currentUser;
      if(user != null) {
        for (var pendingNote in pendingBox.values) {
          await firestore
              .collection('users')
              .doc(user.email)
              .collection('notes')
              .doc(pendingNote.id)
              .set({
            'title': pendingNote.title,
            'content': pendingNote.content,
            'isLocked': pendingNote.isLocked,
            'isTrashed': pendingNote.isTrashed,
            'createdAt': pendingNote.createdAt,
          });
          /// Remove after syncing
          pendingBox.delete(pendingNote.id);
        }
      }
    } catch (e){
      throw ServerException("Failed to upload note");
    }
  }

  Future<void> deletePendingNotes() async{
    try{
      final user = auth.currentUser;
      if(user != null) {
        for (var pendingNote in pendingDeleteBox.values) {
          await firestore
              .collection('users')
              .doc(user.email)
              .collection('notes')
              .doc(pendingNote.id)
              .delete();
          /// Remove after syncing
          pendingDeleteBox.delete(pendingNote.id);
        }
      }
    } catch (e){
      throw ServerException("Failed to Delete note");
    }
  }

  Note returnNewNote(Note note){
    return Note(
      id: note.id,
      title: note.title,
      content: note.content,
      isLocked: note.isLocked,
      isTrashed: note.isTrashed,
      createdAt: note.createdAt,
    );
  }
}