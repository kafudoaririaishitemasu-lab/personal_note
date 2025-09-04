import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:personal_note/core/theme/app_pallete.dart';
import 'package:personal_note/features/note/presentation/screen/note_screen.dart';
import '../../domain/entities/note.dart';

class NoteTile extends StatefulWidget {
  final Note note;

  const NoteTile({super.key, required this.note});

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {

  Future<void> _authenticateAndNavigate() async {
    if(!widget.note.isLocked){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteScreen(note: widget.note)),
      );
    }else {
      final LocalAuthentication auth = LocalAuthentication();
      bool didAuthenticate = false;
      try {
        didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to open this note',
          options: const AuthenticationOptions(
            biometricOnly: false,
            // fingerprint first, fallback to device password
            stickyAuth: true,
          ),
        );
      } catch (e) {
        debugPrint("Auth error: $e");
      }

      if (didAuthenticate && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteScreen(note: widget.note)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _authenticateAndNavigate,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textP2),
        ),
        constraints: const BoxConstraints(
          maxHeight: 20.0 * 12,
        ),
        child: widget.note.isLocked
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                  Icons.lock, size: 32,
                  color: Colors.deepOrange,
                shadows: [
                  Shadow(
                    color: Colors.grey,
                    offset: Offset(0, 3),
                    blurRadius: 15
                  )
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: widget.note.title.isEmpty ? "Note is Locked" : widget.note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: widget.note.title.isEmpty ? "Add Title..." : widget.note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                widget.note.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                maxLines: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

