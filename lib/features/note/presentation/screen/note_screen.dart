import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/core/theme/app_pallete.dart';
import '../../domain/entities/note.dart';
import '../cubit/note_cubit.dart';

class NoteScreen extends StatefulWidget {
  final Note note;

  const NoteScreen({super.key, required this.note});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _isLocked = widget.note.isLocked;

    _titleController.addListener(_autoSave);
    _contentController.addListener(_autoSave);
  }

  void _autoSave() {
    final updated = Note(
      id: widget.note.id,
      title: _titleController.text,
      content: _contentController.text,
      isLocked: _isLocked,
    );

    context.read<NotesCubit>().saveNote(updated);
  }

  void _toggleLock(bool value) {
    setState(() {
      _isLocked = value;
    });
    _autoSave();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLocked ? "🔒 Locked Note" : "Note"),
        backgroundColor: orange50,
        actions: [
          Row(
            children: [
              Switch(
                value: _isLocked,
                onChanged: _toggleLock,
                activeColor: textDark,
                inactiveTrackColor: white,

              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Note Title",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "Start typing...",
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
