import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/note.dart';

class NoteStorage {
  static const String _notesKey = "NOTES_LIST";

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];
    return notesJson.map((e) => Note.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_notesKey, notesJson);
  }
}
