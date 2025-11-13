import 'package:hive/hive.dart';
import '../../features/note/domain/entities/note.dart';

class StorageManager {
  Box<Note>? _notesBox;
  Box<Note>? _pendingBox;
  Box<Note>? _pendingDeleteBox;

  String _notesBoxName(String uid) => 'notes_$uid';
  String _pendingBoxName(String uid) => 'pending_$uid';
  String _pendingDeleteBoxName(String uid) => 'pendingDelete_$uid';

  Future<void> openForUser(String uid) async {
    final nb = _notesBoxName(uid);
    final pb = _pendingBoxName(uid);
    final pdb = _pendingDeleteBoxName(uid);

    if (!Hive.isBoxOpen(nb)) {
      _notesBox = await Hive.openBox<Note>(nb);
    } else {
      _notesBox = Hive.box<Note>(nb);
    }

    if (!Hive.isBoxOpen(pb)) {
      _pendingBox = await Hive.openBox<Note>(pb);
    } else {
      _pendingBox = Hive.box<Note>(pb);
    }

    if (!Hive.isBoxOpen(pdb)) {
      _pendingDeleteBox = await Hive.openBox<Note>(pdb);
    } else {
      _pendingDeleteBox = Hive.box<Note>(pdb);
    }
  }

  Box<Note> get notesBox {
    if (_notesBox == null) throw Exception("NotesBox not opened");
    return _notesBox!;
  }

  Box<Note> get pendingBox {
    if (_pendingBox == null) throw Exception("PendingBox not opened");
    return _pendingBox!;
  }

  Box<Note> get pendingDeleteBox {
    if (_pendingDeleteBox == null) throw Exception("PendingBox not opened");
    return _pendingDeleteBox!;
  }

  Future<void> closeBoxes() async {
    await _notesBox?.close();
    await _pendingBox?.close();
    await _pendingDeleteBox?.close();
    _notesBox = null;
    _pendingBox = null;
    _pendingDeleteBox = null;
  }
}
