import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_note/config/app_pallete.dart';
import 'package:personal_note/core/router/app_router.dart';
import 'package:personal_note/core/utils/screen_size.dart';
import 'package:personal_note/features/note/domain/entities/note.dart';
import 'package:personal_note/features/note/presentation/bloc/note_bloc.dart';
import 'package:personal_note/init_dependencies.dart';

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
  Timer? _debounce;

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
    if(_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty && (widget.note.title.isNotEmpty || widget.note.content.isNotEmpty)){
      context.read<NoteBloc>().add(NoteDeleteEvent(note: widget.note));
      serviceLocator<AppRouter>().pop();
      return;
    }

    if(_titleController.text.isEmpty && _contentController.text.isEmpty) return;

    if(_titleController.text == widget.note.title && _contentController.text == widget.note.content && _isLocked == widget.note.isLocked) {
      return;
    }

    if (_debounce ?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<NoteBloc>().add(NoteSaveEvent(note: Note(
          id: widget.note.id,
          title: _titleController.text,
          content: _contentController.text,
          isLocked: _isLocked,
          isTrashed: widget.note.isTrashed,
          createdAt: widget.note.createdAt,
      )));
    });
  }

  void _moveNoteToTrash(){
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text,
      isLocked: _isLocked,
      isTrashed: !widget.note.isTrashed
    );
    context.read<NoteBloc>().add(NoteSaveEvent(note: updatedNote));
    serviceLocator<AppRouter>().pop();
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
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(_isLocked ? "Note 🔒" : "Note 🔓"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          Row(
            children: [
              Switch(
                value: _isLocked,
                onChanged: _toggleLock,
                inactiveTrackColor: whiteColor,
                activeThumbColor: Theme.of(context).brightness == Brightness.light
                    ? lightPrimary
                    : darkPrimary,
              ),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: _moveNoteToTrash,
                  icon: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).brightness == Brightness.light
                        ? grey800
                        : whiteColor,
                    size: screenWidth(context) * 0.07,
                  )
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth(context) * 0.025,
        ),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
