import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_note/core/error/exceptions.dart';
import 'package:personal_note/core/utils/storage_manager.dart';

import '../../../../core/utils/encryptor.dart';
import '../../domain/entities/note.dart';

abstract interface class NoteDataSource {
  Future<List<Note>> saveNoteLocal({required Note note});

  Future<List<Note>> saveNoteLocalAndCloud({required Note note});

  Future<List<Note>> getCloudNotes();

  List<Note> getLocalNotes();

  List<Note> deleteNoteLocal({required Note note});

  Future<List<Note>> deleteNoteLocalAndCloud({required Note note});
}

class NoteDataSourceImpl implements NoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final StorageManager storageManager;

  NoteDataSourceImpl(this.firestore, this.auth, this.storageManager);

  @override
  Future<List<Note>> saveNoteLocal({required Note note}) async {
    final notesBox = storageManager.notesBox;
    final pendingBox = storageManager.pendingBox;
    notesBox.put(note.id, note);
    final n = note.copyWith();
    pendingBox.put(n.id, n);
    print("LOCAL ________");
    return notesBox.values.toList().reversed.toList();
  }

  @override
  Future<List<Note>> saveNoteLocalAndCloud({required Note note}) async {
    final notesBox = storageManager.notesBox;
    final pendingBox = storageManager.pendingBox;
    notesBox.put(note.id, note);

    print("CLOUD ________");
    final user = auth.currentUser;
    if (user != null) {
      await firestore
          .collection('users')
          .doc(user.email)
          .collection('notes')
          .doc(note.id)
          .set({
            'title': note.title.isNotEmpty ? encrypt(note.title) : '',
            'content': note.content.isNotEmpty ? encrypt(note.content) : '',
            'isLocked': note.isLocked,
            'isTrashed': note.isTrashed,
            'createdAt': note.createdAt,
          });

      if (pendingBox.isNotEmpty) {
        await uploadPendingNotes();
      }
    }
    return notesBox.values.toList().reversed.toList();
  }

  @override
  List<Note> getLocalNotes() {
    final notesBox = storageManager.notesBox;
    return notesBox.values.toList().reversed.toList();
  }

  @override
  Future<List<Note>> getCloudNotes() async {
    final notesBox = storageManager.notesBox;
    final pendingBox = storageManager.pendingBox;
    final pendingDeleteBox = storageManager.pendingDeleteBox;


    final user = auth.currentUser;
    if (user == null) return [];

    if (pendingBox.isNotEmpty) {
      await uploadPendingNotes();
    }

    if (pendingDeleteBox.isNotEmpty) {
      await deletePendingNotes();
    }

    final snapshot = await firestore
        .collection('users')
        .doc(user.email)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      notesBox.clear(); // safe: no local-only if queues are empty
      return [];
    }

    final List<Note> cloud = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final String title = data['title'];
      final String content = data['content'];
      cloud.add(
        Note(
          id: doc.id,
          title: title.isNotEmpty ? decrypt(title) : title,
          content: content.isNotEmpty ? decrypt(content) : content,
          isLocked: (data['isLocked'] ?? false) as bool,
          isTrashed: (data['isTrashed'] ?? false) as bool,
          createdAt: data['createdAt'],
        ),
      );
    }

    await notesBox.clear();
    await notesBox.putAll({for (final n in cloud) n.id: n});

    return cloud;
  }

  @override
  List<Note> deleteNoteLocal({required Note note}) {
    final notesBox = storageManager.notesBox;
    final pendingDeleteBox = storageManager.pendingDeleteBox;

    notesBox.delete(note.id);
    pendingDeleteBox.put(note.id, note);
    return notesBox.values.toList().reversed.toList();
  }

  @override
  Future<List<Note>> deleteNoteLocalAndCloud({required Note note}) async {
    final notesBox = storageManager.notesBox;
    final pendingDeleteBox = storageManager.pendingDeleteBox;

    await notesBox.delete(note.id);
    await pendingDeleteBox.put(note.id, note);

    final user = auth.currentUser;
    if (user == null) {
      throw ServerException("Something went wrong");
    }

    try {
      if (pendingDeleteBox.isNotEmpty) {
        for (final pendingNote in pendingDeleteBox.values.toList()) {
          await firestore
              .collection('users')
              .doc(user.email)
              .collection('notes')
              .doc(pendingNote.id)
              .delete();
          pendingDeleteBox.delete(pendingNote.id);
        }
      }

      return notesBox.values.toList().reversed.toList();
    } catch (e) {
      print(e.toString());
      throw ServerException("Failed to Delete");
    }
  }

  Future<void> uploadPendingNotes() async {
    final pendingBox = storageManager.pendingBox;

    final user = auth.currentUser;
    if (user == null) return;

    try {
      for (final n in pendingBox.values.toList()) {
        await firestore
            .collection('users')
            .doc(user.email)
            .collection('notes')
            .doc(n.id)
            .set({
              'title': n.title.isNotEmpty ? encrypt(n.title) : '',
              'content': n.content.isNotEmpty ? encrypt(n.content) : '',
              'isLocked': n.isLocked,
              'isTrashed': n.isTrashed,
              'createdAt': n.createdAt,
            });
        pendingBox.delete(n.id);
      }
    } catch (e) {
      throw ServerException("Failed to upload note");
    }
  }

  Future<void> deletePendingNotes() async {
    final pendingDeleteBox = storageManager.pendingDeleteBox;
    final user = auth.currentUser;
    if (user == null) return;

    try {
      for (final n in pendingDeleteBox.values.toList()) {
        await firestore
            .collection('users')
            .doc(user.email)
            .collection('notes')
            .doc(n.id)
            .delete();
        pendingDeleteBox.delete(n.id);
      }
    } catch (e) {
      throw ServerException("Failed to Delete note");
    }
  }
}
