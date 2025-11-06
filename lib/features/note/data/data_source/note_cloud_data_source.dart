import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:personal_note/core/error/exceptions.dart';

import '../../../../core/utils/encryptor.dart';
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
    final newNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      isLocked: note.isLocked,
      isTrashed: note.isTrashed,
      createdAt: note.createdAt,
    );
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
          'title': encrypt(note.title),  /// encryptText(note.title)   TODO have to complete this feature
          'content': encrypt(note.content), ///encryptText(note.content),
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

      if(pendingBox.isNotEmpty) await uploadPendingNotes();
      if(pendingDeleteBox.isNotEmpty) await deletePendingNotes();

      final snapshot = await firestore
          .collection('users')
          .doc(user.email)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();
      if(snapshot.docs.isEmpty) return [];

      final List<Note> notes = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String title = (data['title'] ?? '') as String;
        final String content = (data['content'] ?? '') as String;

        String titleRaw;
        String contentRaw;

        try {
          // Assume encrypted; if not, this throws.
          titleRaw = decrypt(title);
          contentRaw = decrypt(content);
        } catch (_) {
          // Not encrypted -> use plaintext for UI, but encrypt & update in DB.
          titleRaw = title;
          contentRaw = content;

          String encTitle = "";
          String encContent = "";

          if(title.isNotEmpty) encTitle = encrypt(titleRaw);
          if(content.isNotEmpty) encContent = encrypt(contentRaw);

          await firestore.collection('users')
              .doc(user.email)
              .collection('notes')
              .doc(doc.id)
              .update({
            'title': encTitle,  /// encryptText(note.title)   TODO have to complete this feature
            'content': encContent, ///encryptText(note.content),
          });
        }

        notes.add(Note(
          id: doc.id,
          title: titleRaw,
          content: contentRaw,
          isLocked: (data['isLocked'] ?? false) as bool,
          isTrashed: (data['isTrashed'] ?? false) as bool,
          createdAt: data['createdAt'],
        ));
      }

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
            'title': encrypt(pendingNote.title),
            'content': encrypt(pendingNote.content),
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

}